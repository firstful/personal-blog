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
Alright folks, I need to hear some real takes. The terminal is having a renaissance — Claude Code, Gemini CLI, Codex CLI, opencode, Copilot CLI. I\'ve been playing with all of them and I think this changes everything.

I\'ve got a [breakdown of the landscape here](https://blog.ffilt.us/blog/agentic-cli-roundup/) but the short version: we\'re finally at the point where you can describe a change in plain English and the computer just does it. What\'s everyone running day-to-day?
') }}

{{ forum_post('cobol_kid', '2026-07-17 09:18', '
"Describes a change and the computer just does it" — until it does the wrong thing and you spend three hours debugging hallucinated garbage.

I watched a demo where one of these tools "refactored" a perfectly good C function into a memory leak factory. Three new allocations, zero new frees. The presenter was too busy being impressed to notice they\'d introduced a production incident.

You know what never hallucinates? `gcc -Wall -Wextra -Werror`.

I\'m not saying these tools have zero value. I\'m saying the people most excited about them have never debugged a crash in prod at 3 AM.
') }}

{{ forum_post('bitcruncher', '2026-07-17 09:25', '
cobol_kid\'s right but I\'d frame it differently. The problem isn\'t that the code is wrong — it\'s that the confidence calibration is broken.

These tools present everything with the same certainty, whether it\'s a textbook quicksort or a hallucinated API that doesn\'t exist. I\'ve been tracking this across all the major tools and the pattern is consistent: they\'re all excellent at common patterns and all equally confident when they\'re completely wrong.

Claude Code gets the most right on the first try. But the local models — especially the smaller ones — will fabricate schema elements out of thin air. One of them invented a table called "users_audit" that never existed in any version of the database. And it presented it like it was stating a fact.

That\'s the real issue. Not the error rate. The complete absence of uncertainty markers.
') }}

{{ forum_post('void_main', '2026-07-17 09:42', '
I don\'t care which model is best. I care which one I can run in CI without it falling over.

I\'ve been running opencode in our homelab for three months. It reviews PRs, catches null pointer dereferences, and occasionally suggests optimizations humans miss. The key rule: it never writes to the repo directly. It reads diffs, makes suggestions in comments, and a human approves. That\'s the right trust boundary.

These tools are excellent as reviewers and mediocre as writers. Put them in a role where their confidence doesn\'t matter — they advise, you decide.

Also, Claude Code burns through credits fast. A heavy session can cost $20-50. opencode with a local model costs basically nothing but needs the hardware. Pick your tradeoff.
') }}

{{ forum_post('xss_princess', '2026-07-17 09:51', '
Has anyone audited the attack surface on these? Because I spent last weekend poking at them.

Claude Code runs shell commands based on model output. That\'s a feature until someone embeds `rm -rf /` in a code review comment and the tool decides to "fix" it. We\'ve already seen prompt injection bypass system instructions — what happens when that targets an agent with filesystem access?

Codex CLI\'s sandbox is the right idea but I found an escape through symlinks in about an hour. Reported it, they\'re working on it. But one person, one hour, first try.

Bottom line: never give these tools unrestricted filesystem or network access. Container with read-only rootfs. No network except to the API. Treat them like untrusted code execution — because that\'s what they are.
') }}

{{ forum_post('ffiltus', '2026-07-17 10:05', '
Good thread. Summary:

- **Claude Code** — best model quality, burns credits, worth it for hard problems
- **opencode** — model flexibility, cost control, needs setup. Good for teams
- **Codex CLI** — right sandbox idea, needs hardening. Best eval harness
- **Copilot CLI** — not an agent. Best at shell queries. Different category

The common thread: every tool here works better as an assistant than an autonomous agent. The teams that succeed treat them as very smart interns who need supervision — not as developers you can leave unsupervised.

Run them in sandboxes. Review their output. Test their code. Don\'t let them touch production.

Thread closed. — ffiltus
') }}
