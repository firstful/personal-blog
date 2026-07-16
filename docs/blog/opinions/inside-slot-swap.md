---
title: "Inside a Slot Swap: What Zero-Downtime Deployment Looks Like Inside a Reconciliation Loop"
date: 2026-07-15
tags: [infrastructure, deployment, agent-stack, DevOps, engineering]
---

# Inside a Slot Swap: What Zero-Downtime Deployment Looks Like Inside a Reconciliation Loop

A reconciliation loop that runs every five seconds sounds simple — inspect state, compare to desired, converge. But when the "converge" step means replacing a running container without dropping a single request, the mechanics get interesting. The five-second loop that looks trivial in pseudocode has to coordinate a multi-step deployment with health checks, traffic switching, and rollback — all without maintaining any state between iterations.

Here's what actually happens inside the agent-stack controller when the hash changes between two reconciliation passes.

## The Deployment Contract

The controller manages each container service with two slots: `--a` and `--b`. At any moment, one slot is active (handling live traffic) and one is idle. The active slot is tracked in a single file: `/tmp/stack.<name>.slot`. That file contains literally one character — `a` or `b`.

```
Name         Slots     Active    Port
appserve     --a, --b  --b       4020
```

When a reconciliation pass finds a hash mismatch — the desired config doesn't match what's deployed — it starts a deployment. But it can't just stop the active container and start a new one. That would drop connections. Instead, it runs a five-step sequence:

1. **Build** — Create a new container image from the repo
2. **Start idle slot** — Launch the new image on the inactive slot
3. **Health check** — Wait 30 seconds for the new container to pass health checks
4. **Swap traffic** — Update the slot file, update the reverse proxy route
5. **Remove old slot** — Stop and delete the previous active container

The entire sequence takes 30 to 60 seconds, spanning 6 to 12 reconciliation passes. Each pass sees a different snapshot of the world.

## What Can Go Wrong, and What Happens Next

Because the controller has no in-memory state, every pass discovers the world fresh. This design choice makes failure recovery automatic — but it also creates a series of edge cases that event-driven systems would handle differently.

### The Slow Build Problem

A container build takes time. A TypeScript service with 200 dependencies might take 45 seconds. A Go binary with CGO dependencies might take 90 seconds. The reconciliation loop runs every 5 seconds.

For nine consecutive passes, the controller sees: "Desired hash is X. Running containers are [--a]. No --b slot exists. Desired and current don't match. Start a build."

Without deduplication, the controller would start nine simultaneous builds of the same service — overwhelming the build queue, exhausting disk space, and creating race conditions when nine builds finish at different times.

The fix is a build lock file at `/tmp/stack.<name>.building`. The first pass that detects a mismatch creates this file. Subsequent passes see the lock file, note that a build is already in progress, and skip. The lock file is deleted when the build finishes — or, if the controller crashes mid-build, the lock file persists and the next pass finds it, deletes it, and starts fresh.

This is the reconciliation pattern's answer to duplicate events: not deduplication logic, but a lock file that creates an externally visible state. The loop doesn't need to remember that it started a build; it sees the evidence in the filesystem.

### The Health Check Timeout

After the build finishes, the controller starts the new container on the idle slot and waits for its health check to pass. The default timeout is 30 seconds, configurable per service.

If the container never becomes healthy — wrong port, missing config file, database not ready — the controller waits 30 seconds, declares failure, and stops the idle container. The active slot continues serving. The service is unchanged. The hash still doesn't match, so the next pass will try again — but with exponential backoff.

The backoff doubles per failure: first failure waits 5 cycles (25s), second waits 10 cycles (50s), then 20, 40, 80. This prevents a perpetually failing build from consuming the CPU on every pass while still allowing the deployment to succeed when the underlying issue is resolved.

### The Partial Swap

The traffic swap itself is a two-step operation: update the slot file, then update the reverse proxy (Traefik) to route to the new port. If the controller crashes between step 1 and step 2 — slot file updated but proxy not — the next reconciliation pass sees a confusing state.

The slot file says `b` is active. But the proxy is still routing to `a`. Both containers are running. Which one should serve traffic?

The reconciliation loop handles this deterministically: it always converges to the slot file. It reads the slot file, confirms the proxy matches it, and corrects if not. The intermediate state (slot file updated, proxy not) is temporary and gets fixed on the next pass. The active container during the window was `a` (still live), and after correction it becomes `b`. No traffic is lost — only delayed by 5 seconds.

### The Orphaned Slot

After the swap, the old container (`--a`) needs to be cleaned up. The controller stops it and removes it. But what if that container is still handling a long-running request?

Podman's `stop` sends SIGTERM with a 10-second grace period. If the request finishes within that window, the container shuts down cleanly. If not, the connection drops.

For most HTTP services this isn't a problem — requests are measured in milliseconds. But for streaming responses from AI agents, a request might last 30 seconds. The fix is to configure a longer stop timeout or implement a graceful shutdown handler in the service. The agent-stack provides a `container.stopTimeout` config option for this exactly.

### The Canary Extension

Standard blue-green deployment assumes you can instantly trust the new image. Canary deployments acknowledge that you can't — and the slot swap mechanism actually creates a natural window for canary observation.

A canary deployment in the agent-stack works like this: after the new container passes its health check, instead of immediately swapping traffic, the controller routes a configurable fraction — say 10% — to the new slot. It then monitors 5xx error rates for an observation window, defaulting to two minutes. If error rates stay below the threshold, it promotes the new slot to full traffic. If they spike, it drains the canary, logs the failure, and the active slot remains unchanged — no traffic lost, no deployment rollback needed.

The slot architecture makes this possible because both containers are already running side by side. The only change is in the traffic routing layer. A reverse proxy like Traefik handles percentage-based routing natively — it just needs to know which slot gets what weight.

In practice, most failures surface within the first 30 seconds of canary traffic — a misconfigured environment variable crashes on the first request, or a database migration error surfaces on the first write. The two-minute window catches nearly everything a health check misses, without adding meaningful deployment delay. The system also supports a hard-swap override (`[stack hard-swap]` in the commit message) that skips the observation window entirely for emergency rollouts or changes already validated in staging.

## Why This Design Wins

The slot swap mechanism is complex, but the reconciliation loop that drives it remains simple. Each pass does the same thing: inspect state, compare, act. The complexity lives in the actions, not the orchestration.

This is the core insight of the reconciliation pattern. An event-driven deployment system would need a state machine — "building → health checking → swapping → cleaning up" — with explicit transitions, error handlers, and timeouts. The reconciliation loop doesn't need a state machine. It has a filesystem. Each step creates observable state (build lock, container running, slot file written) that the next pass reads and acts on.

The loop doesn't remember what step it's on. It reads the evidence and figures it out.

## The Practical Takeaway

If you're building a reconciliation-based deployment system, design each operation to leave visible artifacts in the filesystem — lock files, marker files, state files — rather than tracking progress in memory. The loop will naturally recover from crashes, race conditions, and partial failures because it never assumes progress. It discovers it.
