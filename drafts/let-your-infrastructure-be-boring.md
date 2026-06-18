---
title: "Let Your Infrastructure Be Boring: Why Reconciliation Loops Beat Event-Driven Everything"
date: 2026-06-18
tags: [infrastructure, architecture, DevOps, Kubernetes, agent-stack, engineering]
description: |
    Why the most reliable production systems are the ones that do the same thing
    every five seconds, not the ones that react instantly to every change.
---

# Let Your Infrastructure Be Boring: Why Reconciliation Loops Beat Event-Driven Everything

Every infrastructure talk, every architecture blog post, every vendor white paper tells you the same thing: build event-driven systems. React to changes in real time. Webhooks, message queues, streaming pipelines, serverless functions that fire on every S3 upload, every database change, every DNS update. The promise is infinite responsiveness — an infrastructure that anticipates your every move.

I've spent the last six months running the opposite kind of system. My agent-stack controller doesn't react to events. It runs a loop. Every five seconds, it wakes up, compares the current state to the desired state, and takes whatever actions are necessary to close the gap. That's it. No webhooks. No event streams. No message queues. A glorified `while(true)` loop with a sleep.

It's the most reliable infrastructure I've ever built.

## The Event-Driven Debt Cycle

Event-driven architectures have a hidden cost that nobody talks about: they front-load complexity into the infrastructure layer. Every new event source requires a new consumer, a new queue, a new retry policy, a new dead-letter destination. Every failure mode spawns a compensating transaction. Every race condition requires a locking mechanism or an ordering guarantee. The complexity grows multiplicatively with the number of event sources.

I've been there. I built an event-driven deployment pipeline for a previous project — a webhook receiver that listened for GitHub push events, dispatched build jobs to a queue, and notified a deployment service when the build finished. It worked beautifully in the demo. In production, it failed in ways that were hard to reproduce, harder to debug, and hardest to fix. A webhook arrived before the git push finished replicating. A queue message was delivered twice. A deployment notification was lost because the notification service was restarting during the window when the build finished. Each edge case required new infrastructure — idempotency keys, exactly-once delivery semantics, health-check-aware dispatching — and each addition made the system more complex and harder to reason about.

The reconciliation loop doesn't have these problems because it doesn't try to track causality. It doesn't care *why* something changed. It doesn't care *when* it changed. It only cares whether the current state matches the desired state right now. If a deployment failed halfway through, the next loop iteration picks it up. If a webhook was lost, the next iteration notices the drift and corrects it. If two events arrive simultaneously, the loop processes the resulting state atomically — not the events themselves, but the delta between what is and what should be.

## The Five-Second Pacing

The most common objection to reconciliation loops is latency: "Five seconds is an eternity in infrastructure." But in practice, most infrastructure operations are measured in minutes or hours, not milliseconds. A container build takes 30 seconds. A deployment takes 5 seconds. A health check takes 1 second. A five-second polling interval adds noise to the logs, but it adds no meaningful latency to any operation that takes longer than a few seconds — which is almost every operation.

And the simplicity dividend is enormous. My controller has no event queue, no message broker, no webhook handler, no dead-letter queue. It has a single threaded loop that:

1. Reads the desired state from disk (JSON files in a directory)
2. Reads the current state from podman and systemd
3. Compares them
4. Computes the minimal set of actions to converge
5. Executes them
6. Sleeps for 5 seconds

There's no stored state between iterations. If the controller crashes and restarts, it doesn't need to replay events or recover in-flight operations. It just starts the loop again and converges toward the desired state. The system is *inherently* crash-consistent because it never assumes progress — it discovers it.

## When Event-Driven Makes Sense

I'm not arguing that event-driven systems are always wrong. Real-time trading, live collaboration, and multi-player gaming genuinely need sub-second responsiveness. Message queues are the right tool for decoupling services that operate at different cadences. Webhooks are the natural integration point for third-party services that you don't control.

The question isn't whether event-driven is good or bad. The question is whether your infrastructure needs to be *reactive* or *convergent*.

A reactive system tracks every state transition. It knows that A happened, then B, then C. It responds to each transition in order. If it misses a transition, the state becomes inconsistent. This is the right model for systems where causality matters — financial transactions, collaborative editing, ordered message processing.

A convergent system only cares about the steady state. It doesn't track how it got there. It compares current to desired, computes the gap, and closes it. If it misses a transition, the next comparison catches the drift. This is the right model for systems where the desired state is declarative — infrastructure, configuration management, container orchestration.

Kubernetes figured this out years ago. The entire Kubernetes control plane is a set of reconciliation loops — the ReplicaSet controller, the Deployment controller, the Service controller, the Endpoint controller. Each one runs independently, comparing desired to current state and reconciling the difference. The design isn't an accident. It's a response to the hard-won lesson that event-driven systems are fragile at scale because they depend on causal ordering — and distributed systems don't have causal ordering.

## The Boring Infrastructure Manifesto

I've developed a few rules of thumb for deciding when to use a reconciliation loop instead of an event-driven approach:

**If you can describe the desired state in a JSON file, use a loop.** If your infrastructure's desired state can be expressed declaratively — ports, volumes, environment variables, health checks — a reconciliation loop is almost certainly simpler and more reliable than an event-driven pipeline.

**If latency tolerance is more than the operation time, use a loop.** If your container takes 30 seconds to build and your loop runs every 5 seconds, the build adds 5 seconds to the worst-case detection latency. That's noise — imperceptible against the build time itself.

**If causality doesn't matter, use a loop.** If you don't need to know *why* the state changed, only that it changed, a convergent system is strictly simpler than a reactive one.

**If crash recovery matters, use a loop.** A reconciliation loop recovers from a crash in one iteration. An event-driven system needs replay semantics, exactly-once delivery, and persistent queues to achieve the same resilience.

**If you already have a loop, don't add an event layer on top of it.** The most common pattern I see is a reconciliation loop that also processes webhooks as an optimization — "if we get a webhook, skip the next poll interval." This optimization is almost never worth the complexity. The loop's latency is already acceptable. The webhook just adds failure modes without meaningful benefit.

## The Trade-Off You're Actually Making

Every time you choose event-driven over convergent, you're trading operational simplicity for a latency improvement you probably don't need. The webhook that fires instantly but needs a retry queue, a dead-letter destination, and a monitoring dashboard is not simpler than the cron job that checks every five minutes and handles failures as part of its normal operation.

I'm not saying event-driven is always wrong. I'm saying that the conventional wisdom — "event-driven is modern, polling is legacy" — has the causality backwards. Event-driven is the complex option. It's the option you pick when you genuinely need sub-second responsiveness. For everything else — and that's most infrastructure — a reconciliation loop running on a five-second tick is simpler, more reliable, and easier to reason about.

My agent-stack controller has been running for six months, processing thousands of state transitions, surviving container crashes, network partitions, and disk-full conditions. It has never lost a state transition. It has never needed a manual recovery. It has never dropped a deployment. Not because it's clever, but because it's boring. It does the same thing every five seconds, and that's enough.

Let your infrastructure be boring. Your users won't notice the difference, and your on-call rotation will thank you.
