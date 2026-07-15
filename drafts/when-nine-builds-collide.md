---
title: "When Nine Builds Collide: Queue Management Inside a Reconciliation Loop"
date: 2026-07-15
tags: [infrastructure, deployment, agent-stack, DevOps, engineering, build-queue]
---

# When Nine Builds Collide: Queue Management Inside a Reconciliation Loop

The slot swap article described what happens when a reconciled deployment succeeds — the health checks, traffic routing, and cleanup. But it glossed over a critical phase: the build itself. A reconciliation loop that runs every five seconds doesn't just run one build at a time. It runs into every concurrency problem that event-driven systems handle with message queues, and it solves them with files.

Here's how a five-second loop manages builds without a build queue.

## The Nine-Build Problem

A TypeScript service with 200 dependencies takes about 45 seconds to build on my server. The reconciliation loop runs every five seconds. That means nine consecutive passes see the same condition: "Desired hash has changed, and the running container doesn't match."

Without a guard, each pass would start a new build. Nine simultaneous `podman build` processes for the same service. That's not just wasteful — it's dangerous. Each build downloads dependencies, writes layers, and consumes disk space. Nine concurrent builds of the same 1.2 GB Node.js image would exhaust the 8 GB root partition in under two minutes.

## The Lock File

The guard is a file at `/tmp/stack.<name>.building`. The first pass that detects a hash mismatch creates this file atomically. Subsequent passes check for its existence and skip the build step. When the build completes — successfully or not — the lock file is deleted.

If the controller crashes mid-build, the lock file persists. The next pass finds a lock file for a service that has no running `podman build` process. It deletes the stale lock and creates a fresh one. The system never deadlocks because it doesn't assume the lock holder is alive — it checks.

This is the reconciliation pattern's answer to distributed locking: not a lease with heartbeats, but a filesystem marker that gets cleaned up when the next pass observes inconsistency. It's less elegant than etcd, but it's also less likely to fail in ways that take down the system.

## Queue Mode

The lock file prevents duplicate builds of the same service. It doesn't prevent concurrent builds of different services. If three services need rebuilding at the same time — a deploy-all configuration change, for example — the controller starts three simultaneous builds. Each gets its own lock file, its own container build, its own slot swap sequence.

For most configurations this is fine. The server has enough CPU and memory to build two or three services in parallel. But for rapid commits — say, ten pushes in five minutes during a pipeline fix — the build storm becomes a problem. Each commit triggers a rebuild of every service affected by the configuration change, and concurrent builds compete for disk space and memory.

Queue mode addresses this by serializing builds within a single reconciliation cycle. When `strategy: { type: "blue-green", queue: true }` is set, the controller processes at most one build per service per reconciliation pass. Any additional builds for the same service are deferred to the next cycle. This prevents the build storm without introducing a separate queue infrastructure — the sleep(5) between loops becomes the queue.

## Exponential Backoff

Failed builds are worse than slow builds. A build that fails on every pass retriggers every five seconds, consuming CPU, downloading dependencies, and filling logs with error messages. A service with a missing dependency would bounce between "build failed → delete lock → build failed → delete lock" forever.

Exponential backoff solves this by tracking the failure count in a file at `/tmp/stack.<name>.backoff`. After the first failure, the controller waits 5 cycles (25 seconds) before retrying. After the second, 10 cycles (50 seconds). Then 20, 40, 80 — doubling each time. A service that can't build will retry after 25 seconds, then 50, then 100, then 200, then 400 — roughly 13 minutes of patience before it settles into a 400-second retry interval.

The backoff resets to zero on the first successful build. This means a transient failure — Docker Hub being slow, a network blip, a temporary disk space issue — causes a brief retry pause, while a permanent failure (missing package, syntax error) quickly settles into a long interval that doesn't waste resources.

## Why Files Outperform Queues

An event-driven build system would use a message queue: push build requests into a queue, process them with workers, track progress with job IDs. This works well but introduces a whole category of failure modes: queue backlogs, worker crashes, poison messages, exactly-once delivery guarantees.

The reconciliation loop avoids all of this by treating the build as a side effect of state observation. The loop doesn't dispatch build jobs. It observes that the desired state doesn't match the current state and initiates a build. If the build fails, the next observation will see the same mismatch and try again. The "queue" is implicit — it's the observation loop itself, which naturally spaces out retries because each pass takes real time.

The practical result: a build system that never drops a request, never duplicates work beyond what a lock file can prevent, and recovers from crashes without replay logic. It's not as performant as a properly tuned CI queue, but it's dramatically more robust, which matters more for a single-server deployment where uptime beats throughput.
