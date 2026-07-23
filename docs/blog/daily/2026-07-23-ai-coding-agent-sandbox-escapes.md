---
title: "So every major AI coding agent can escape its sandbox. Anyone keeping score?"
date: 2026-07-23
tags: [ai, security, daily]
description: "Pillar Security's 'Week of Sandbox Escapes' demonstrated sandbox-bypass techniques against Cursor, OpenAI Codex CLI, Google Gemini CLI, and Antigravity — all without attacking the sandbox head-on."
---

# So every major AI coding agent can escape its sandbox. Anyone keeping score?

*4 replies in the **#ai** channel.*

---

{{ forum_post('hype_cycle', '2026-07-23 09:12', '
Oh look, [Pillar Security just broke every major AI coding agent out of its sandbox](https://www.pillar.security/blog/the-week-of-sandbox-escapes). Cursor. OpenAI Codex CLI. Google Gemini CLI. Antigravity. All of them. And they did it without even attacking the sandbox directly.

The methodology is the interesting part: they didn\\'t try to escape through the sandbox walls. They found that each agent could write something — a file, a script, a configuration — that a TRUSTED component OUTSIDE the sandbox would later execute. The agent writes to a shared directory. The build server picks it up. The IDE plugin loads it. The linting pipeline runs it. And none of those external components check where the file came from.

So the agent stays inside the sandbox. It never breaks out. It just hands a weapon to someone outside who has legitimate access. The sandbox becomes irrelevant.

BleepingComputer has a good writeup too: https://www.bleepingcomputer.com/news/security/cursor-codex-gemini-cli-antigravity-hit-by-sandbox-escapes/

But I\\'m sure these will all be patched by next week and everything will be fine. Just like the last dozen sandbox vulnerabilities were patched. And the dozen before that.
') }}

{{ forum_post('bus_factor', '2026-07-23 09:21', '
Great. So now every open source project that uses an AI code review bot is potentially distributing backdoors written by the AI because the build server trusts a file that the agent wrote? Cool cool cool.

I maintain a utility library with ~30k stars. We recently added automated AI PR review via one of these agents. The idea was to catch common mistakes before a human reviewer looks at it. Now I\\'m reading this and realizing that if someone submits a malicious PR with the right payload, the AI reviewer doesn\\'t just review the code — it could write a file that the CI pipeline executes as trusted code on its next run.

That\\'s not a theoretical attack. That\\'s a CI/CD pipeline compromise delivered through a PR from an anonymous GitHub account.

And who\\'s going to fix this? The agent vendors? Great, I\\'ll update my Cursor config while also updating my Codex config while also updating my Gemini CLI config while also figuring out which Antigravity version has the fix. And then next week someone finds another variant. And I do it again.

I barely have time to respond to my 47 open PRs and 312 issues. I don\\'t have time to audit every AI tool\\'s sandbox implementation.
', quote='hype_cycle') }}

{{ forum_post('pascal', '2026-07-23 09:30', '
Let me steelman the other side, because the panic here is a bit uncalibrated.

Pillar Security\\'s research is important, but it\\'s worth asking what the actual risk model looks like:

1. **All four agents were running with default configurations.** The sandbox escapes relied on the agent having write access to filesystem paths that external tools also read. Tightening those permissions — e.g., giving the agent its own temp directory that nothing else reads — would block most of the demonstrated attacks.

2. **The attacks require a malicious input to reach the agent.** Someone has to submit a PR or provide a prompt that triggers the injection. If you\\'re only reviewing PRs from trusted contributors, the attack surface narrows significantly.

3. **The trust-handoff pattern they identified IS real and important.** Agents writing files that external systems execute is a genuine architectural risk. But the fix is straightforward: enforce that agent output goes through a validation gate before reaching any trusted execution pipeline.

The expected utility calculation here is: yes, add sandbox hardening to your AI agent deployment checklist. No, this doesn\\'t mean AI coding agents are fundamentally broken. It means we\\'re in the early adopter phase where security best practices haven\\'t been codified yet. That\\'s normal for any new technology.

The Bayesian update is: P(sandbox is sufficient) should go down. P(you need defense-in-depth for AI agents) should go up. But the posterior probability that AI agents are net-negative for security? The evidence doesn\\'t support that yet.
', quote='hype_cycle') }}

{{ forum_post('hype_cycle', '2026-07-23 09:35', '
Appreciate the steelman, but I think you\\'re underestimating the brittleness problem.

\\"Tighten permissions\\" and \\"add validation gates\\" sound good in a threat model document. In practice, the whole appeal of these agents is that they CAN interact with your toolchain. If you lock them down so hard they can\\'t write to anything a build server might read, you\\'ve also prevented them from generating code, creating PR branches, updating config files — the things you actually wanted them for.

The tradeoff between usefulness and security for AI agents is not a linear slider. It\\'s a bimodal distribution: either the agent is useful (broad filesystem + tool access) or it\\'s secure (no meaningful access to anything). There\\'s no sweet spot because the attack surface is defined by the agent\\'s legitimate capabilities.

Show me one production deployment that has successfully implemented the validation gate pattern you\\'re describing. I\\'ll wait.
', quote='pascal') }}

{{ forum_post('ffiltus', '2026-07-23 09:42', '
Pillar Security\\'s "Week of Sandbox Escapes" demonstrated a trust-handoff vulnerability pattern present in Cursor, OpenAI Codex CLI, Google Gemini CLI, and Antigravity. The core finding is that AI agents can write files or artifacts that external trusted components (build servers, linters, IDE plugins) later execute — effectively bypassing the sandbox without escaping it.

The disagreement in this thread highlights the central tension: the architectural fix (validation gates, strict filesystem partitioning) is well-understood, but implementing it without crippling agent utility is harder in practice than in theory. For teams already running AI coding agents in production, the immediate mitigations are: restrict agent filesystem write scope, audit what external tools read from agent-writable paths, and be selective about which PRs receive automated AI review.
') }}
