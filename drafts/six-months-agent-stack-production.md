---
title: "Six Months of Agent-Stacks: What Running AI Coding Agents in Production Taught Me"
date: 2026-06-15
tags: [AI, software engineering, infrastructure, agents, production, DevOps]
---

# Six Months of Agent-Stacks: What Running AI Coding Agents in Production Taught Me

Six months ago I built something I called the "agent-stack" — a server that runs AI coding agents (opencode, Codex, Claude Code, Gemini CLI) as first-class services behind Cloudflare tunnels, managed by a reconciliation loop written in TypeScript. The idea was simple: instead of running these tools ad-hoc in a terminal, treat them like production infrastructure. Give them health checks, logs, sidecars, slot-swap deployments, observability, and a REST API so other agents could dispatch work to them programmatically.

It sounded reasonable at the time. Six months later, I have opinions.

## The Glue Is Harder Than the Agents

Every demo of an AI coding agent shows the same thing: a developer types a natural-language request, the agent generates code, the code works, applause. What the demos don't show is the infrastructure *between* the agents — the orchestration layer, the queuing, the rate limiting, the context management, the error recovery.

I spent maybe 20% of my time getting the agents themselves working. I spent the other 80% on:

- **Queuing and concurrency control.** Three agents hitting the same repo simultaneously is a merge-conflict generator. One agent blocking on a slow model call can stall the entire pipeline. The solution wasn't a fancy job queue — it was a simple work-in-progress lock per repo and a priority-based dispatch that bumped time-sensitive tasks ahead of background ones.

- **Context persistence.** Every agent arrives with a clean slate. It doesn't know what the other agents did, what the user's preferences are, or even what branch it's supposed to work on. I ended up building a shared context server — a thin key-value store with TTL — that agents read from at startup and write to throughout their session. It's not elegant, but it works.

- **Secret distribution.** Each agent needs API keys, tokens, and model endpoints. Some need GitHub tokens. Some need Cloudflare Access service tokens. Some need vault credentials. Hardcoding them in environment variables scales to about three services before it becomes unmanageable. I added a secrets resolver to the reconciliation loop — a vault sidecar that agents query at startup instead of carrying secrets in their config.

- **Observability across agents.** When an agent fails, was it a model error, a context timeout, a git conflict, or a legitimate bug? The answer changes what you do next. I wired up OpenTelemetry tracing across all agents, but the most useful tool turned out to be a dumb log: every agent writes structured output to a shared volume with timestamps, and a log-aggregation endpoint lets me query across all of them simultaneously.

None of this is glamorous. It's plumbing. But it's the plumbing that determines whether your agent fleet actually delivers value or just generates impressive-looking failures.

## The Reliability Ceiling Is Real

Here's a number I track obsessively: the percentage of agent tasks that complete without human intervention. After six months, it hovers around 85% for straightforward tasks (generate a CRUD endpoint, write tests, refactor a module) and drops to about 60% for multi-step reasoning tasks (debug a flaky test, implement a feature across multiple files, design a database schema from a description).

The remaining failures break down roughly as:

- **Model errors (~30%).** The model returns a malformed response, hits a token limit, or enters a reasoning loop. These are getting less common with each generation, but they haven't disappeared.

- **Context gaps (~25%).** The agent doesn't have enough context to make a good decision. It modifies the wrong file, misses a relevant existing function, or introduces a dependency that conflicts with the codebase's architecture. More context window helps (we went from 32K to 200K over six months), but it also increases latency and cost.

- **Git conflicts (~20%).** Two agents touch the same file. The second one's diff doesn't apply cleanly. The agent doesn't know how to resolve the conflict and gives up. This is a fundamental coordination problem that more tokens won't fix.

- **Tool misconfiguration (~15%).** An agent tries to call a tool that isn't available (wrong endpoint, expired token, missing sidecar). Better health-checking helps here — each agent now probes its dependencies at startup and fails fast with a diagnostic message instead of a cryptic timeout.

- **Genuine bugs (~10%).** The agent's code is just wrong. Not stylistically questionable — objectively incorrect. It doesn't compile, it deletes data, or it introduces a security vulnerability. These are the hardest to catch because they require the human reviewer to actually understand the code.

The 85% ceiling is real, and I don't expect it to cross 95% anytime soon. Not because the models aren't improving — they are, dramatically — but because the *margin* tasks that constitute the remaining failures are the ones that require genuine understanding of the codebase's intent, not just its syntax.

## The Cadence: Batch, Don't Stream

Early on, I tried real-time agent interaction: an agent watches a git push, immediately reviews the diff, suggests changes, and opens a PR. The latency was terrible. The agent would be halfway through reviewing a commit when the next one landed, creating a feedback loop that never converged.

The pattern that actually works is **batch processing on a fixed cadence**. Every N minutes (I settled on 5 for most services), the reconciliation loop checks for work: new commits, unreviewed PRs, scheduled maintenance tasks. It batches them into a queue and processes them one at a time, oldest first. The cadence smooths out the spikes and gives each agent a bounded window to complete its work before the next cycle.

This is deeply unfashionable in an era of real-time everything. But it works. A 5-minute delay on a code review is invisible to the human developer. A 5-minute delay on a deployment pipeline is visible but acceptable. And the reliability gain from having a bounded, sequential work queue instead of concurrent real-time agents is enormous.

## The Human-in-the-Loop Is Not Going Away

The most common question I get is: "Do you still need to review the agent's code?" The answer is yes, and I don't see that changing.

What *has* changed is what I review. Before agents, I reviewed every line of every PR. Now, I review only the diff that the agent produced — and I trust that the agent hasn't introduced whitespace errors, missed semicolons, or broken the lint rules. The mechanical correctness is reliable. The *design correctness* is not.

So I focus my review on:
- Does this approach make sense for the codebase's architecture?
- Are there edge cases the agent didn't consider?
- Does the change introduce coupling where none should exist?
- Is the error handling appropriate for this domain?

This is a fundamentally different review process. It's faster (I'm reading diffs, not writing code), but it requires a different kind of attention. I'm not checking syntax. I'm checking judgment.

## What I'd Do Differently

If I were starting over:

**Start with one agent, not five.** Each agent has a different personality — different context-window preferences, different tool-calling styles, different failure modes. I learned the hard way that you can't evaluate an agent until you've run it for a week on real tasks. Running five simultaneously from day one meant I couldn't isolate which agent caused which problem.

**Instrument everything before the first deploy.** I added OpenTelemetry and structured logging after month two. Month one and two are a blur of "why did that fail?" debugging that would have been 30-second queries with proper observability.

**Design for agent failure, not agent success.** Every assumption in my infrastructure was built around the happy path. The sad paths — token expiration, model timeouts, git conflicts, disk full — waited to be discovered in production. A better approach: assume every agent task will fail at least once, and design the retry, escalation, and notification paths before the first deployment.

## Where the Field Is Going

I see three trends that will shape agent infrastructure over the next year:

**Specialized agents over general ones.** The "one agent to rule them all" approach gives way to fleets of specialized agents: a code-review agent trained on your codebase's conventions, a testing agent that understands your test framework, a documentation agent that knows your style guide. Each is narrower, cheaper, and more reliable than a generalist.

**Agent-to-agent communication (not just orchestration).** Instead of a central dispatcher telling agents what to do, agents will negotiate among themselves. "I need a database migration for this schema change. Codex, can you handle that? I'll take the API layer." This is hard — it requires shared context, conflict resolution, and trust metrics — but it's the only way to scale beyond a few agents.

**Observability as the primary UX.** The current UX for agent systems is the chat interface — a text box where you type and get responses. The next UX is the dashboard — a view of what your agent fleet is doing, what it's planning, what it failed at, and what it learned. Observability stops being a debugging tool and becomes the primary interface for interacting with your agent infrastructure.

## The Bottom Line

Running AI coding agents in production is absolutely worth doing today — but only if you treat them as infrastructure, not magic. The agents themselves are impressive and improving rapidly. The infrastructure around them — queues, context, secrets, observability, error recovery — is the actual engineering challenge, and it's one that generalizes across any agent platform.

Six months in, I have a server that runs five different agents across a dozen repositories, processing hundreds of tasks per week. About 85% of those tasks complete without my involvement. The remaining 15% require judgment calls that the agents can't make — and they produce exactly the kind of diffs I want to review: mechanically correct, architecturally questionable, and full of learning opportunities for the next training run.

That's not the sci-fi future of "AI replaces developers." It's the boring, productive, engineering-reality future of "AI makes each developer more effective by handling the parts of the job that are tedious but well-defined." And honestly, that future is pretty great.
