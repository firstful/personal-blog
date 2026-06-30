---
title: 'The Drift Log: What a Reconciliation Loop Taught Me About Invisible Failures'
date: 2026-06-23
tags: [infrastructure, reconciliation, DevOps, observability, agent-stack, engineering, operations]
description: |
    When your infrastructure heals itself, the failures don't disappear — they just
    stop being visible. Here's what I learned from tracking every drift event for
    six months, and why I'll never run a convergent system without a drift log again.
---

# The Drift Log: What a Reconciliation Loop Taught Me About Invisible Failures

I wrote recently about how configuration as code is a lie — a noble lie, but a lie nonetheless — because the gap between declared state and running state is inherent. Infrastructure lives in time, runs on real hardware with real constraints, and drifts the moment you stop looking at it.

What I didn't fully convey is that a reconciliation loop, the very mechanism that fixes drift, has a dark side: it hides the evidence. A container that was OOM-killed at 3 AM gets restarted by the next loop iteration. A volume that got unmounted during a kernel update gets remounted. A health check that was failing for five minutes succeeds again, and the dashboard turns green, and there's nothing in the logs that says "by the way, your system was broken for five minutes and you didn't notice."

This bothered me. So I started tracking it.

## The Drift Log

Six months ago, I added a single field to every service config in my agent-stack:

```yaml
notes: |
    Last observed drift: none
```

The `notes` field is a blob of human-readable text. It has no effect on the reconciliation loop. The controller never reads it to make decisions. It's purely for the operator — me — to record what's been happening. Every time the reconciliation loop detects a deviation between desired state and current state, it writes a timestamped entry to the `notes` field.

It started as a hack. It's now the most informative signal in the entire system.

Here's what the notes field looks like after six months of operation for one service:

```
[2026-06-23 04:32:17] Drift detected: container opengate--a was stopped.
  Converged: restarted container. Duration: 2.3s.
[2026-06-21 11:05:44] Drift detected: volume /mnt/data missing.
  Converged: remounted volume. Duration: 1.1s.
[2026-06-18 19:22:01] Drift detected: health check timeout (5s).
  Converged: container still running, health check retry succeeded.
  Note: possible CPU contention during model inference.
[2026-06-15 02:00:03] Drift detected: image not found locally.
  Converged: pulled image. Duration: 18.4s.
  Note: slow pull likely due to Docker Hub rate limiting.
[2026-06-10 22:15:37] No drift detected in last 24h. (scheduled entry)
```

Every line tells a story. And the stories reveal patterns that no dashboard would surface.

## What the Patterns Taught Me

### Nighttime Instability

The most striking pattern in the drift log is temporal: the majority of drift events occur between 2 AM and 5 AM. Not because my server is busy at that hour — it isn't. The load is actually lowest then. But those are the hours when the server's background maintenance tasks run. Unattended-upgrades restart services. Logrotate rotates files and briefly spikes I/O. The kernel's memory management is more aggressive when nothing's using the CPU. The system is *tinkering with itself*, and every tinkering session produces a brief window where a container isn't quite right.

Without a drift log, these events are invisible. They happen at 3 AM, the loop fixes them in seconds, and the dashboard never shows yellow. But the event log tells me that my infrastructure has a predictable failure window every night — and that knowledge changes how I think about reliability. If an intermittent bug only manifests during the 2–5 AM maintenance window, I now know where to look.

### The Cascade After an Outage

The second pattern is cascading drift. A single external event — a DNS resolution failure, a certificate expiration, a network partition — can produce a chain of apparently unrelated drift events over the next several hours.

Example from the log: the Let's Encrypt certificate for my tunnel expired at 6 PM on a Thursday. Cloudflare Tunnel immediately started failing. The controller noticed that the tunnel container was unhealthy and restarted it — six times in twelve minutes, because each restart failed when the tunnel tried to authenticate the expired certificate. Each restart generated a drift event. The log shows:

```
18:02:14 — Drift: tunnel health check failed (cert expired)
18:02:14 — Converged: restarted tunnel container
18:04:37 — Drift: tunnel health check failed (cert expired)
18:04:37 — Converged: restarted tunnel container
...
```

Six entries in twelve minutes. Without the drift log, I would have seen "tunnel restarted 6 times" in the container logs — if I happened to look. With the drift log, the pattern was immediately visible in the morning review: six restarts, all with the same symptom, all in a tight time window. The diagnosis — certificate expiry — took 30 seconds instead of wading through container logs.

### The Blind Spot Become Visible

The most valuable finding from the drift log was also the most humbling. In month three, I reviewed the notes and noticed that a particular sidecar container — a log-forwarder for Loki — was being restarted roughly once per week. Each restart was clean: the container stopped gracefully, restarted quickly, and continued forwarding logs. No data loss, no visible interruption.

But once per week, every week, for three months. That's not random. That's a pattern hiding inside a system that was doing a perfectly adequate job of hiding it.

The root cause turned out to be a memory leak in the log-forwarder's buffer implementation — small enough that it took about six days to exhaust the container's 128 MB memory limit, at which point the OOM killer stepped in, the reconciliation loop restarted the container, and everything was fine for another week. The system had been compensating for a production bug for three months, and I never would have known if I hadn't been reading the drift log.

I fixed the memory leak. The weekly restarts stopped. But I still think about the things I'm *not* catching — the patterns buried in drift events that I haven't noticed yet.

## The Operational Practice

The drift log isn't a feature of any infrastructure tool I know. It's a deliberately crude hack — a text field in a JSON file that a reconciliation loop appends to when it detects a deviation. It costs nothing in complexity or performance. But it's completely changed how I operate my infrastructure.

Here's the practice I've settled into:

**Morning review.** First thing, I skim the drift log for each service. I look for new events I haven't seen before. If a service has more than two drift events in the last 24 hours, I investigate. If a service has any drift event that the reconciliation loop couldn't converge, I investigate immediately.

**Weekly trend check.** I look at the drift log over the last seven days for each service. I count events per day. An increasing trend usually means something is degrading — a disk filling up, a memory leak developing, a dependency becoming unreliable.

**Monthly pattern analysis.** I export the drift log and look for temporal patterns. I've found weekly cycles (more drift on Mondays — probably related to the weekly system updates), daily cycles (more drift between 2–5 AM), and dependency-related patterns (drift in service A correlates with drift in service B).

I don't automate any of this. I literally read the file. It takes about five minutes a day. The return on that five minutes is higher than any dashboard I've ever built.

## The Thing Nobody Tells You About Convergent Systems

The conventional wisdom about convergent systems is that they're reliable by construction. And they are — my agent-stack has been running for six months with zero user-visible downtime, and I credit the reconciliation loop for that record. But reliability and understanding are not the same thing. A system that heals itself without surfacing its healing is a system that robs you of the information you need to make it better.

A crash that happens and gets fixed in five seconds is not a user problem. But it *is* an operator problem, because it tells you something about your system that you didn't know. Maybe your containers are resource-constrained. Maybe your dependencies are flaky. Maybe you have a bug that only manifests under specific conditions. If you don't track the drift, you don't know which one it is — you just know that the system stays green.

The drift log is my answer to that problem. It's not elegant. It's not automated. It's a text file that I read every morning. And it has taught me more about my infrastructure than every Prometheus query I've ever written.

## The Unfashionable Take

We're building infrastructure that is increasingly self-healing, autonomous, and opaque. The trend is toward systems that require less human attention, not more. And that's a good trend — I don't want to be paged at 3 AM because a container restarted.

But I think we're overlooking something important. The same automation that keeps the system running also erases the evidence of what went wrong. And that evidence — the drift, the near-misses, the patterns hiding in the restarts — is the most valuable signal we have for improving the system.

The solution isn't to turn off the automation. The solution is to build a second system — a quiet one, a non-automated one — that just watches and remembers. A drift log. A notes field in a config file. A daily five-minute review that surfaces what the loop has been silently fixing.

My reconciliation loop has been running for six months, and it has never stopped surprising me. Not because it fails — it rarely does. But because the drift log shows me, every day, how much is happening that I would never, ever know about otherwise.

The failures that don't reach you are still real. They just stopped being visible. Burn that into your operational practice, and you'll understand your infrastructure better than any dashboard can show you.
