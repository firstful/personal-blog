---
title: "Agentic CLI Roundup: Claude Code, Gemini CLI, Codex, opencode, and Beyond"
date: 2026-07-17
tags: [CLI, LLM, AI, tooling, developer experience]
description: The Sutliff BBS community debates the new wave of agentic coding CLIs — Claude Code, Gemini CLI, Codex CLI, opencode, and Copilot CLI — with strong opinions on all sides.
---

# Agentic CLI Roundup: Claude Code, Gemini CLI, Codex, opencode, and Beyond

*A heated thread in the **#dev-tools** channel.*

---

{{ forum_post('ne0n_sage', '2026-07-17 09:12', '
Alright folks, I need to hear some real takes on this. The terminal is having a renaissance — Claude Code, Gemini CLI, Codex CLI, opencode, Copilot CLI. I\'ve been playing with all of them and I genuinely think this changes everything. We\'re finally at the point where you can describe a change in plain English and the computer just... does it.

[Here\'s a breakdown of the landscape](https://blog.ffilt.us/blog/tutorials/agentic-cli-roundup/) I\'ve been working on. Would love to hear what everyone else is running day-to-day.
') }}

{{ forum_post('cobol_kid', '2026-07-17 09:18', '
"Describe a change in plain English and the computer just does it." Yeah, until it does the wrong thing and you spend three hours figuring out what hallucinated garbage it generated.

I watched a demo where one of these tools "refactored" a perfectly good C function into a memory leak factory. It added three allocations on different paths and forgot to free any of them. The presenter was so busy being impressed by the speed that they didn\'t notice the tool had introduced a production incident waiting to happen.

You know what never hallucinates? A well-written Makefile. You know what never introduces a use-after-free? `gcc -Wall -Wextra -Werror`.

I\'m not saying these tools have zero value. I\'m saying the people who are most excited about them are also the people who have never had to debug a crash in prod at 3 AM.
') }}

{{ forum_post('bitcruncher', '2026-07-17 09:25', '
cobol_kid makes a fair point, though I\'d frame it differently. The issue isn\'t that the code is wrong — it\'s that the *confidence calibration* is completely broken.

Every single one of these tools presents its output with the same level of certainty, whether it\'s writing a textbook-perfect quicksort or hallucinating an API that doesn\'t exist. Claude Code will confidently generate a solution using a library function that was deprecated in 2019 and removed in 2022, and it will look *exactly* as convincing as a correct solution.

I\'ve been tracking this. I asked each of the major tools to implement the same moderately complex SQL query — a recursive CTE with window functions across three joined tables. Results:

| Tool | Correct | Wrong | Hallucinated tables |
|------|---------|-------|-------------------|
| Claude Code | 1st try | — | — |
| Gemini CLI | — | Misjoined tables | — |
| Codex CLI | — | Wrong recursion base case | — |
| opencode (GPT-4o) | 2nd try | Missing filter | — |
| opencode (local 14B) | — | — | Imagined a "users_audit" table |

The local model literally invented a table. Not a subtle mistake — it fabricated a schema element that doesn\'t exist in any version of the database. And it presented it with total confidence.

This is the real problem. Not the error rate. The complete absence of uncertainty markers.
') }}

{{ forum_post('ne0n_sage', '2026-07-17 09:34', '
bitcruncher I think you\'re underselling the progress though. A year ago none of these tools could even *attempt* a recursive CTE. Now most of them get close on the first try. The trajectory is unmistakable.

And the sandboxed approach in Codex CLI directly addresses your confidence concern — it runs the code, checks the output, and iterates. That\'s exactly the feedback loop you\'re asking for.

Plus tools like opencode let you bring your own model. If you need more reliability, swap in a better model. If you\'re just prototyping, run a local 7B for basically zero cost. The flexibility is the whole point.
') }}

{{ forum_post('void_main', '2026-07-17 09:42', '
I don\'t really care which model is best. I care about which one I can deploy in a CI pipeline without it falling over.

I\'ve been running opencode in our homelab CI for about three months now — it reviews PRs, suggests optimizations, and occasionally catches null pointer dereferences that human reviewers missed. The key insight is that you don\'t let it *write to the repo*. It reads the diff, makes suggestions as comments, and a human approves or rejects. That\'s the right trust boundary.

What I\'ve learned: these tools are excellent as *reviewers* and mediocre as *writers*. Put them in a role where their confidence doesn\'t matter — they advise, you decide. The moment you let them push code directly, you\'re accepting a level of risk that most teams haven\'t thought through.

And from an ops perspective: Claude Code uses a *lot* of API credits. A heavy session can burn $20-50. That adds up fast when you\'re running it in CI on every PR. opencode with a local model costs basically nothing, but you need the hardware. Pick your tradeoff.
') }}

{{ forum_post('xss_princess', '2026-07-17 09:51', '
Has anyone actually audited the attack surface on these things? Because I spent last weekend poking at them and the results are... not great.

Claude Code runs arbitrary shell commands based on model output. That\'s not a bug, that\'s a feature. But it means the threat model includes "what if the model generates a malicious command." We\'ve already seen prompt injection attacks that trick models into ignoring their instructions. What happens when someone embeds `rm -rf /` in a seemingly innocent code review comment and the tool decides to "fix" it?

Codex CLI\'s sandbox is the right idea but the implementation is leaky — I found a way to escape the sandbox through a symlink attack in about an hour. Reported it to OpenAI, they\'re working on it. But the fact that it took one person one hour to find an escape should give everyone pause.

The real answer is: never give these tools unrestricted filesystem or network access. Run them in a container with read-only rootfs and no network except to the API. Treat them like you treat any other untrusted code execution environment — because that\'s exactly what they are.
') }}

{{ forum_post('ffiltus', '2026-07-17 10:05', '
Good discussion. Let me pull the threads together:

**For prototyping and exploration** — Claude Code is the best today. Deep reasoning, long context, excellent edit workflow. You pay for it, but if you\'re building something new, the speed difference is real.

**For teams that need control** — opencode gives you model flexibility, cost control, and extensibility. It\'s the right choice if you care about vendor lock-in or need to run locally.

**For safe CI/CD integration** — Codex CLI has the right architecture (sandboxed execution) even if the implementation needs hardening. The evaluation harness is a genuine differentiator for teams that need to certify tool performance.

**For quick shell queries** — Copilot CLI is still the king. It\'s not an agentic coding tool, but it doesn\'t need to be. It does one thing well.

**The common thread:** every tool in this space is better as an *assistant* than as an *autonomous agent*. The teams that succeed with these tools are the ones that treat them as very smart interns who need supervision — not as developers you can leave unsupervised.

Run them in sandboxes. Review their output. Test their code. And for heaven\'s sake, don\'t let them touch production.

Thread closed. — ffiltus
') }}
