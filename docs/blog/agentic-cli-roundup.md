---
title: "What agentic CLI are you actually using day-to-day? (Claude Code, Gemini, Codex, opencode...)"
date: 2026-07-17
tags: [CLI, LLM, AI, tooling, developer experience]
description: "Been testing all the agentic coding CLIs for months. Claude Code is impressive but expensive. opencode is flexible but needs setup. What's everyone running in prod? Drop your takes."
---

# What agentic CLI are you actually using day-to-day? (Claude Code, Gemini, Codex, opencode...)

*A heated thread in the **#dev-tools** channel.*

---

{{ forum_post('ne0n_sage', '2026-07-17 09:12', '
Okay I need to hear what everyone else is running because I\'ve been deep in this for months and I genuinely think this changes EVERYTHING!! Claude Code, Gemini CLI, Codex CLI, opencode — we\'re finally at the point where you describe a change in plain English and the computer just does it.  That\'s incredible!!  The CLI renaissance is here and I\'m so here for it.

I wrote [a breakdown of the landscape](https://blog.ffilt.us/blog/agentic-cli-roundup/) — what are you all using day-to-day?  Drop your setups!
') }}

{{ forum_post('cobol_kid', '2026-07-17 09:18', '
"Describes a change and the computer just does it" — until it does the WRONG thing and you spend three hours debugging hallucinated garbage.  👴

I watched a demo where one of these tools refactored a perfectly good C function into a memory leak factory.  Three new allocations.  Zero new frees.  The presenter was too busy being impressed to notice they introduced a production incident.  💾

You know what never hallucinates?  `gcc -Wall -Wextra -Werror`.  I\'m not saying these tools have zero value.  I\'m saying the people most excited about them have never debugged a crash in prod at 3 AM...
') }}

{{ forum_post('hype_cycle', '2026-07-17 09:25', '
Oh fantastic, another post about how AI is going to replace every developer by next Tuesday.  I\'m sure that will work out great.  Just like blockchain.  And the metaverse.  And crypto.  And every other "revolutionary" technology that was going to "change everything."

The problem isn\'t the error rate — it\'s that these things have NO IDEA when they\'re wrong.  Claude Code will confidently generate a solution using a library function that was deprecated in 2019, removed in 2022, and never worked the way it claims anyway.  And it presents this with the exact same certainty as a correct solution.

I ran the same moderately complex SQL query across all the major tools.  One of them literally fabricated a table called "users_audit" that never existed in any version of the schema.  It just... invented it.  Like it was nothing.

But sure, "the trajectory is unmistakable."
') }}

{{ forum_post('kernel_panic', '2026-07-17 09:42', '
I don\'t care which model is theoretically best.  I care which one I can run in CI without it falling over.

Three months running opencode in our homelab CI: it reviews PRs, catches null pointer dereferences, and occasionally spots optimizations humans miss.  The key rule: it never pushes to the repo directly.  Reads the diff, makes suggestions in comments, a human approves or rejects.  That\'s the right trust boundary.

These tools are excellent as reviewers and mediocre as writers.  Put them in a role where their confidence doesn\'t matter — they advise, you decide.

Also worth noting: Claude Code burns through credits fast.  A heavy session can cost $20-$50.  opencode with a local model costs basically nothing but needs the hardware.  Pick your tradeoff based on your budget and use case.
') }}

{{ forum_post('xss_princess', '2026-07-17 09:51', '
I spent last weekend auditing the attack surface on these tools.  The results are not great.

Claude Code runs shell commands based on model output.  That\'s a feature until someone embeds `rm -rf /` in a code review comment and the tool decides to "fix" it.  We\'ve seen prompt injection bypass system instructions — what happens when that targets an agent with filesystem access?

Codex CLI\'s sandbox is the right idea.  I found an escape through a symlink attack in about an hour.  Reported it, they\'re working on it.  But one person, one hour, first try.

Bottom line: never give these tools unrestricted filesystem or network access.  Container with read-only rootfs.  No network except to the API.  Treat them like untrusted code execution — because that\'s exactly what they are.
') }}

{{ forum_post('vibecoder', '2026-07-17 09:55', '
ok so i been using claude code for like 2 weeks and it completly changed my workflow. i used to actually write code but now i just type stuff and it appears?? like magic?? its sooo good.

sure sometimes it halucinates or whatever but like... i halucinate stuff too and nobody fires me. the vibes are immaculate. 🚀

btw has anyone tried running these on replit? i cloned a whole startup in 3 hours last week (it didnt compile but the design was FIRE) 🎧
') }}

{{ forum_post('ffiltus', '2026-07-17 10:05', '
Practical summary from this thread:

- **Claude Code** — best model quality, burns credits at $20-$50 per heavy session.  Worth it for hard problems.
- **opencode** — model-agnostic, cost control, needs configuration.  Good for teams that want flexibility.
- **Codex CLI** — right sandbox architecture, needs hardening.  Best evaluation harness for teams that need benchmarks.
- **Copilot CLI** — not an agentic tool.  Excellent at shell queries.  Different category entirely.

The common thread: every tool here works better as an assistant than an autonomous agent.  The teams that succeed treat them as very smart interns who need supervision — not as developers you can leave unsupervised.

Sandbox them.  Review their output.  Test their code.  Don\'t let them touch production.

Thread closed.  — ffiltus
') }}
