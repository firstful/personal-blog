---
title: "Trust, But Verify: Why Reconciliation Loops Check Everything Twice"
date: 2026-07-17
tags: [infrastructure, reconciliation, agent-stack, engineering, architecture, distributed-systems]
description: |
    The build lock article explained how lock files prevent duplicate builds.
    But the pattern behind that mechanism — verify state against reality on
    every pass — extends to every part of a reconciliation loop. Here's why
    "check twice" is the architectural insight that makes the whole system
    robust.
---

# Trust, But Verify: Why Reconciliation Loops Check Everything Twice

The article on build-queue management described one specific mechanism: a lock file at `/tmp/stack.<name>.building` that prevents duplicate builds for the same service. The interesting detail wasn't the lock file itself — it's the paragraph about crash recovery:

> The next pass finds a lock file for a service that has no running `podman build` process. It deletes the stale lock and creates a fresh one. The system never deadlocks because it doesn't assume the lock holder is alive — it checks.

That last sentence — *it checks* — is the reconciliation pattern in miniature. Every piece of state in the system is provisional. Every assumption gets verified against reality, every loop pass, without exception.

## The Slot File That Might Be Wrong

The controller tracks which deployment slot is active with a file at `/tmp/stack.<name>.slot`. It contains a single character: `a` or `b`. Before reconciliation, the system uses this to determine which slot is currently serving traffic and which one can be rebuilt.

But \*checking\* is not \*trusting\*. After reading the slot file, the controller confirms that the container for that slot actually exists and is running. If the slot file says `a` but the `--a` container is gone — crashed, removed by a manual cleanup, or never existed because the file is stale from a previous controller process — the system ignores the slot file and picks the slot that actually has a running container.

This sounds paranoid. It's necessary. A slot file is a filesystem artifact that doesn't automatically update when a container dies. Without the double-check, the system would try to route traffic to a nonexistent container, or worse, start a zero-downtime swap targeting a slot that doesn't exist and leave the whole service down.

## The Hash That Changes Out From Under You

The build-lock mechanism starts with a content hash comparison: if the current hash differs from the stored hash, a rebuild is needed. The hash is computed from the service config and the git commit SHA of the repo.

But the stored hash is also treated as provisional. On every reconciliation pass, the controller recomputes the current hash from scratch — it doesn't trust the stored value. If the stored hash file is corrupted (a partial write from a crash, a filesystem error, manual editing), the recomputation catches it. The worst case is an unnecessary rebuild, which is expensive but safe. The alternative — skipping a needed rebuild because a corrupted hash looks identical to the stored one — is a silent deployment failure.

## What Event-Driven Systems Get Wrong

This is the fundamental difference between reconciliation and event-driven architectures. An event-driven system reacts to state changes: container stopped → restart container. But what if the event is missed? What if the kernel's cgroup notification fires before the OOM killer finishes, producing a "stopped" event followed by a "running" event for the same container? What if the event bus drops a message?

Reconciliation doesn't need reliable event delivery because it doesn't react to events. It observes the current state, compares it to the desired state, and acts on the gap. Events just **hint** that a gap might exist — they're optimizations, not guarantees.

The build lock article described this at the build level: nine loop passes see the same condition, but only one acts because the lock file serializes access. The same pattern applies at every level. The slot file is a hint. The hash file is a hint. The health check results from the previous pass are a hint. Nothing is treated as authoritative until it's verified against the running system.

## The Practical Cost of Verification

All this double-checking costs something. Every five-second loop pass runs multiple verifications: check container status via `podman inspect`, verify slot files, recompute hashes, check lock file liveness. On a server with a dozen services, that's a dozen `podman` CLI calls per pass.

But `podman inspect` on a stopped container takes under 50 milliseconds. Recomputing a hash takes less than 100. The total verification overhead per pass is under a second — well within the five-second loop interval. The cost of not verifying is a deployed-but-broken slot, a build that never runs because a stale lock persists, or a configuration drift that goes undetected for hours.

## What I Learned From This

The build lock article focused on the mechanism. The broader lesson is that **provisional state management is the core competence of a reconciliation loop**. You can't assume any persisted artifact is accurate. You have to check, every time, against the only source of truth that matters: the actual running system.

This isn't pessimism. It's the practical acknowledgment that in a single-server deployment with no consensus protocol, no distributed database, and no reliable event bus, the only artifact you can fully trust is what's running right now. Everything else — lock files, slot markers, cached hashes — is just a hint about what the system was doing the last time it checked.

The reconciliation loop isn't smart because it knows what to do when a build succeeds. It's smart because it's designed for the case where every assumption could be wrong. And in production, sooner or later, they all are.
