---
title: "Reconciliation Loops Are the Right Architecture for Agent Infrastructure"
date: 2026-07-16
tags: [infrastructure, agents, architecture, DevOps, reconciliation, engineering]
description: |
    Event-driven architectures promise responsiveness. Reconciliation loops promise
    reliability. After six months of running AI agents as production infrastructure,
    I'm convinced: for agent systems, "declare, converge, repeat" beats "react to
    every event." Here's why.
---

# Reconciliation Loops Are the Right Architecture for Agent Infrastructure

Every infrastructure talk tells you to build event-driven systems. Webhooks, message queues, streaming pipelines, serverless functions that fire on every state change. The promise is infinite responsiveness — infrastructure that anticipates your every move.

My agent-stack runs the opposite kind of system. It doesn't react to events. It runs a loop. Every five seconds, it wakes up, compares the current state to the desired state, and takes whatever actions are necessary to close the gap. No webhooks. No event streams. No message queues. A glorified `while(true)` with a sleep.

After six months of running AI coding agents this way, I'm convinced reconciliation loops are the right architecture for agent infrastructure — and that the industry's obsession with event-driven everything is a costly mistake.

## The Five-Second Loop

Here's the entire reconciliation logic, in pseudocode:

```
while true:
    desired = read_config_files("/srv/agent-stack/desired/")
    current = inspect_running_state()  # podman ps, systemctl status

    for service in desired:
        if service not in current:
            deploy(service)
        elif current[service].hash != desired[service].hash:
            redeploy(service)
        elif not healthy(current[service]):
            restart(service)

    for service in current:
        if service not in desired:
            teardown(service)

    sleep(5)
```

That's it. No queue. No event bus. No distributed state. The controller has no memory between iterations — it discovers the world fresh each loop. If it crashes, it restarts and converges. If a deployment fails halfway through, the next iteration picks it up. If three things change simultaneously, the loop processes the resulting state atomically.

## Why Event-Driven Fails for Agent Systems

I built an event-driven deployment pipeline once — webhooks from GitHub, a message queue for build jobs, notifications when builds finished. It worked beautifully in the demo. In production, it failed in ways that were hard to reproduce, harder to debug, and hardest to fix.

The failure modes of event-driven agent infrastructure are predictable:

**Lost events.** A webhook arrives before the git push finishes replicating. The agent starts work on a stale branch and produces a PR full of merge conflicts. The fix is idempotency keys and retry logic — infrastructure that exists solely to compensate for the fragility of the event model.

**Duplicate events.** A queue delivers the same message twice. Two agents start working on the same ticket simultaneously. They produce conflicting PRs. The fix is distributed locking — more infrastructure.

**Ordering violations.** Three events fire in quick succession: PR opened, PR updated with new commit, PR approved. An agent processes them out of order and reviews the wrong version of the code. The fix is sequence numbers and event sourcing — even more infrastructure.

Each edge case requires new infrastructure — idempotency keys, exactly-once delivery, ordering guarantees. Each addition makes the system more complex. The complexity grows multiplicatively with the number of event sources. Eventually, the infrastructure for managing events costs more than the agent logic itself.

## The Reconciliation Advantage

A reconciliation loop doesn't have these problems because it doesn't track causality. It doesn't care _why_ something changed or _when_ it changed. It only cares whether the current state matches the desired state _right now_.

This has profound implications for agent systems:

**Crash-consistency is free.** The controller has no in-memory state between iterations. If it crashes and restarts, it doesn't need to replay events or recover in-flight operations. It starts the loop again and converges. The system is inherently crash-consistent because it never assumes progress — it discovers it.

**Concurrency is trivial.** Multiple agents working on different repos? The loop dispatches them one at a time, sequentially. No locks, no race conditions, no merge conflicts from parallel agent work on the same repo. The loop is single-threaded by design, and that's a feature.

**Drift detection is built-in.** The loop doesn't just deploy — it continuously verifies. If someone manually restarts a container with different flags, the next iteration notices and corrects it. If a health check starts failing, the loop restarts the service. The system doesn't just converge once at deploy time; it converges continuously.

**Observability is simpler.** With an event-driven system, diagnosing a failure means reconstructing the sequence of events that led to it. With a reconciliation loop, the current state is always the ground truth. If something is wrong, it's wrong right now, and the loop's logs show exactly what action it took and why.

## The Latency Objection (and Why It's Wrong)

The most common objection: "Five seconds is an eternity in infrastructure." In practice, most infrastructure operations are measured in minutes, not milliseconds. A container build takes 30 seconds. A health check takes 5 seconds. A deployment takes 10 seconds. A five-second polling interval adds noise to the logs but adds no meaningful latency to any operation that takes longer than a few seconds — which is almost every operation.

And if you genuinely need sub-second response? Add a webhook that triggers an immediate reconciliation pass. The loop is still your convergence mechanism; the webhook is just a hint that says "check now instead of waiting." You get the best of both worlds: event-triggered responsiveness with loop-based reliability.

## The Agent-Specific Argument

Agent systems amplify the reconciliation advantage because agents are inherently unreliable. Models time out. Context windows overflow. Tools return unexpected output. An agent that was working five minutes ago might silently degrade — not crash, just produce worse results.

An event-driven system has no way to detect this. The agent was deployed, so the event was processed. The system considers the task complete. A reconciliation loop, by contrast, can continuously verify agent health — not just "is the process running?" but "is the agent producing output that matches expectations?"

My controller doesn't just health-check containers. It health-checks the _agents_ running inside them. Every five seconds, it sends a known test prompt and verifies the response matches expected patterns. If an agent's output quality degrades (model changed, context corrupted, prompt injection), the loop detects it and restarts the agent with a clean state.

This is the killer feature for agent infrastructure: continuous verification, not one-time deployment. Event-driven architectures optimize for the moment of change. Reconciliation loops optimize for the continuous state — and in agent systems, the continuous state is where the failures live.

## When to Use Each

Reconciliation loops aren't universally better. They're worse when:

- Latency truly matters (financial trading, real-time bidding)
- The state space is too large to enumerate (millions of entities)
- The operations are one-shot and irreversible (sending an email, charging a credit card)

But for infrastructure management — deploying services, running health checks, managing agent lifecycles — the reconciliation pattern is superior. It's simpler, more reliable, and easier to debug. Kubernetes uses reconciliation loops for exactly these reasons. Your agent infrastructure should too.

## The Boring Infrastructure Bet

The most reliable production systems I've built are the ones that do the same thing every five seconds, not the ones that react instantly to every change. Complexity migrates to the event handling layer and grows without bound. The reconciliation loop is boring — deliberately, intentionally boring — and that's why it works.

If you're building infrastructure for AI agents, start with a loop, not an event bus. Your future self, debugging at 2 AM, will thank you.
