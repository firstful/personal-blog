---
title: "Configuration as Code Is a Lie: Why Desired State Always Drifts"
date: 2026-06-22
tags: [infrastructure, DevOps, configuration, engineering, agent-stack, reliability]
description: |
    Configuration as Code promises that what you declare is what you get. Six
    months of running a reconciliation-loop controller has taught me that the
    gap between declared config and running state is wider — and more
    interesting — than most people admit.
---

# Configuration as Code Is a Lie: Why Desired State Always Drifts

Configuration as Code is one of those ideas that sounds so obviously right that questioning it feels like questioning progress itself. Of course you should declare your infrastructure in version-controlled files. Of course deployments should be deterministic, repeatable, and auditable. Of course reviewable config is better than SSH-and-pray. The principles are sound. The practice, as I've learned over six months of running a reconciliation-loop controller, is a different story.

The lie isn't that configuration as code is useless. The lie is the promise that what you declare is what you get.

## The Three Sources of Drift

My agent-stack controller runs a reconciliation loop every five seconds. It reads the desired state from JSON files on disk, compares it to what's actually running in Podman and systemd, and converges them. In theory, this means the system should always match the config. In practice, it doesn't — and the gaps reveal three categories of drift that no amount of declarative config can prevent.

### 1. The Config That Was Correct When You Wrote It

This is the most common one. You declare a container image tag: `ghcr.io/reedsutliff/agent-stack:v1.2.3`. The reconciliation loop deploys it. Six months later, the image still points to `v1.2.3`. But in those six months, the base image it was built from had three critical security patches. The TLS library was updated. The version of Node.js that was current in January is now end-of-life in June.

Your configuration is correct. Your deployed artifact is stale. The gap between them is invisible to any system that only compares declared config to running state — because the config hasn't changed.

The conventional answer is "use `latest` tags" or "set up Dependabot." Both are band-aids. `latest` tags break reproducibility (can't roll back without rebuilding). Dependabot updates create a constant stream of PR noise that desensitizes the reviewer. Neither addresses the fundamental issue: **configuration as code captures intent at a point in time, but infrastructure lives in time.**

### 2. The Config That Doesn't Capture Context

My controller config specifies environment variables, port mappings, volume mounts, and health check paths. It doesn't (and can't) specify disk space, network latency, CPU contention, or whether Docker Hub is rate-limiting your builds.

Last month, one of my sidecar containers — a log-forwarder — started failing silently. The config was unchanged. The image was the same. The health check was passing. What had changed was the log volume: a chatty agent had generated 2GB of logs in three hours, the log-forwarder's buffer filled up, and it started dropping entries. The config was correct. The infrastructure wasn't doing what the config described. **But the config had never described "this container needs to handle 2GB/hour log bursts" because that requirement didn't exist when the config was written.**

Configuration as code is declarative about boundaries — ports, volumes, environment variables. It is almost always silent about capacity, throughput, and failure modes, because those aren't properties the declarative model captures well.

### 3. The Config That's Syntactically Perfect and Semantically Wrong

This is the most dangerous category. The config validates. It passes all schema checks. It describes a valid state. That state is just wrong.

I once configured a health check endpoint as `/health` in my JSON. The container exposed `/healthz`. The health check ran, got a 404, and the reconciliation loop decided the container was unhealthy — and proceeded to recreate it. Every five seconds. For three hours. The config was syntactically valid. The system was converging toward the declared state. The declared state was just subtly misaligned with the application's actual behavior.

Declarative config can catch syntax errors. It can validate JSON schemas and YAML lint rules. It cannot catch semantic errors — and semantic errors in a convergent system become amplifiers. The more aggressively you converge toward a wrong desired state, the more aggressively you make things worse.

## The Double-Edged Gift of Reconciliation

The reconciliation loop that powers my agent-stack is the most reliable infrastructure pattern I've ever used — I wrote the article arguing for it, and I stand by every word. But reconciliation has a dark side that admirers of the pattern don't always acknowledge: **it erases the evidence of drift.**

In an event-driven system, when something goes wrong, the failure usually leaves a trail. A webhook that wasn't delivered. A queue that backed up. A status code that wasn't handled. The failure modes are visible because the causal chain matters.

In a convergent system, the loop notices the drift and corrects it. The container that was accidentally stopped gets restarted. The volume that got unmounted gets remounted. The port that was taken by another process gets reassigned. The system converges without logging the drift — because drift is the norm, not the exception.

This is great for reliability. The system heals itself, and the user doesn't see a blip. But it's terrible for understanding what's actually happening. **A self-healing system that doesn't surface its healing is a system that hides its own health.**

I now deliberately inject drift-awareness into my configs. The service JSON has a `notes` field — a blob of human-readable text about what this service does and what failure modes have been observed. When the reconciliation loop detects a deviation, it logs the difference between current and desired state, then writes it to the `notes` field so the next human who looks at the config knows what's been happening. This isn't a feature of any infrastructure tool I know of. It's a hack. But it's the hack that lets me distinguish between "everything is fine" and "everything is fine because the loop fixed it before you noticed."

## What Configuration as Code Actually Buys You

I've spent six months running a system that converges aggressively toward a declared state, and I've come to a conclusion that surprises even me: **the value of configuration as code is not that your infrastructure matches your config. The value is that when it doesn't, you have something to compare against.**

Declarative config turns infrastructure from a black box into a delta. Without the config, you can only observe what's running — not whether what's running is what should be running. With the config, you can measure the gap. The gap is the interesting thing. The gap tells you about the real state of your infrastructure in ways that individual metrics never can.

A growing gap between config and reality is always a signal worth investigating. Maybe your security posture has degraded (image drift). Maybe your capacity planning is wrong (resource exhaustion). Maybe your config is just wrong (semantic error). Whatever the cause, the gap is the diagnostic starting point — and without a declared desired state, you don't even have that.

## The Honest Take

Configuration as Code doesn't eliminate drift. It makes drift visible. And visibility, not correctness, is the actual value proposition.

A reconciliation loop doesn't guarantee your infrastructure matches the config. It guarantees that when they diverge, the loop notices and acts. The action might be the right one (restart a crashed container). It might be the wrong one (recreate a healthy container because the health check path is wrong). But the loop cannot distinguish between the two — it has no semantics, only structure.

The honest take on configuration as code is this: it's the best tool we have, but it's a tool for managing the gap, not for closing it. The gap is inherent. It's a consequence of time, context, and the fundamental messiness of real infrastructure. The goal isn't zero drift. The goal is drift you can see, measure, and reason about.

My agent-stack controller has been converging for six months, and it has never achieved perfect convergence for more than a few minutes at a time. There's always something. A container that restarted and took an extra second to pass its health check. A disk that's 90% full on an otherwise idle Tuesday. A TLS certificate that's due to expire next month. The loop notices, acts, and moves on. That's not failure. That's the system working as intended — not because it eliminates drift, but because it makes drift a normal, observable, manageable part of operations.

Configuration as Code isn't the destination. It's the map. The terrain always changes. The value of the map is that you can tell.
