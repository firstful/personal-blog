---
title: "Agent-Driven Development: What a Year of AI-Assisted Engineering Actually Looks Like"
date: 2026-06-30
tags: [AI, software engineering, agents, infrastructure, developer experience, process, engineering]
description: |
    A year of running AI coding agents as integrated production infrastructure has
    taught me that the transformation isn't about code generation — it's about how
    the development workflow itself changes when agents become a permanent part of
    the team.
---

# Agent-Driven Development: What a Year of AI-Assisted Engineering Actually Looks Like

A year ago, I built the first version of what I called the "agent-stack" — a server that runs AI coding agents as first-class services behind Cloudflare tunnels, managed by a reconciliation loop. The idea was simple: instead of invoking agents ad-hoc in a terminal, treat them like production infrastructure. Give them health checks, queues, sidecars, logs, and a REST API.

A year later, that server runs five different agent types across a dozen repositories. It processes hundreds of tasks per week. It has generated thousands of pull requests, fixed hundreds of bugs, and written tens of thousands of lines of code. And my development workflow has changed more fundamentally in this one year than in the previous decade combined.

This is what that change actually looks like — not the demo, not the hype, but the day-to-day reality of working with AI agents that have become a permanent, integrated part of the engineering process.

## The Daily Rhythm

A typical day now starts with a review queue. Overnight, the agents have been working through their batch cycles — reviewing open PRs, running maintenance tasks, generating feature implementations from tickets. By the time I open my laptop, there are usually three to eight agent-generated PRs waiting for review.

The rhythm is distinct from human-generated PRs in a few consistent ways:

**The volume is higher but the diff per PR is smaller.** An agent works in focused, single-purpose increments. It doesn't context-switch between tasks, so it produces clean, narrow diffs. A human might batch three related changes into one PR because writing a PR description is overhead. The agent doesn't experience overhead the same way, so it produces one PR per concern. This means I review more PRs per day, but each one takes less time.

**The mechanical quality is unnervingly consistent.** Every PR passes the linter. Every PR has tests. Every PR follows the project's coding conventions — not because the agent is diligent, but because it literally cannot produce output that violates the patterns in its context window. The quality floor is higher than any human junior developer I've worked with.

**The architectural quality is where the variance lives.** A PR that adds a new endpoint will have perfect TypeScript, perfect error handling at the function level, and a complete misunderstanding of how this particular codebase structures its routing layer. The agent learned Express-style routing from its training data, but this codebase uses a custom wrapper. The PR compiles, the tests pass, and the code is wrong in a way that only someone familiar with the codebase's unwritten conventions can detect.

This last point is the key to everything. The agent has no "unwritten conventions." It only has what it can infer from the few thousand tokens of context you gave it. The gap between what the codebase assumes and what the agent knows is where the human reviewer's value now concentrates.

## The Eight-Hour Catch

Let me give you a concrete example from last month that illustrates how agent-driven development actually works in practice.

I was implementing a new feature — a scheduling service that would let agents queue work to be executed at specific times. The spec was straightforward: a cron-like system with a REST API for listing, creating, and canceling schedules, backed by a SQLite database. I wrote a brief specification document, attached it to a ticket, and assigned it to an agent.

The agent produced the implementation in about eight minutes across three PRs. The first PR created the database schema and migration. The second implemented the REST endpoints. The third added the scheduler loop that checks for due tasks and dispatches them. All three PRs had tests, all tests passed, and the code compiled cleanly.

I reviewed the first two PRs in about five minutes each. The schema was clean, the REST endpoints followed the existing patterns, and the test coverage was better than what I would have written. Approved.

The third PR — the scheduler loop — took me forty-five minutes.

The agent had implemented a polling loop that checked the database every five seconds for due tasks. This is the correct approach for a personal server running at low scale. But the implementation had a subtle issue: it held a database connection open for the entire lifetime of the loop, which meant that if the loop crashed (or was killed during a deployment), the connection would leak. In a single-server setup, this is unlikely to cause problems — the container restart would clean it up. But the pattern was fragile, and more importantly, it established a precedent that would cause real pain if this service ever needed to scale to multiple instances.

I spent fifteen minutes writing a comment explaining the issue and suggesting a connection-pooling pattern. Then I spent another thirty minutes debating whether to fix it myself or let the agent iterate. I let the agent iterate — I described the issue in the PR review, the agent rewrote the loop to use a connection pool, and the second version was correct.

This interaction — eight minutes of agent work, forty-five minutes of human review, fifteen minutes of back-and-forth — is exactly what agent-driven development looks like. The agent does 90% of the mechanical work in 10% of the time. The human spends the remaining 90% of the time on the 10% of the work that requires judgment.

A year ago, I would have written this feature myself in about four hours, and the result would have been correct on the first pass because I know my own conventions. With the agent, the first-pass implementation took eight minutes, but the total time to a correct, reviewable implementation was about an hour. The agent saved me three hours — and the code was better than what I would have written alone, because the agent's connection-pooling implementation was more thorough than mine would have been.

## What the Workflow Actually Looks Like

After a year of iteration, my development workflow has settled into five distinct phases:

**1. Specification.** I write a brief spec — usually 200-500 words in a markdown document — describing what needs to be built. The spec includes the interface shape (API endpoints, function signatures, data structures), the constraints (existing patterns to follow, files to modify, libraries to use), and the acceptance criteria (how we'll know it's done). The spec is the most important artifact in the entire workflow. A good spec produces a good PR in a single pass. A bad spec produces two to four iterations.

**2. Generation.** The agent takes the spec and produces an implementation. I've learned to never watch this happen. The temptation to intervene mid-generation — "no, don't use that pattern, use this one instead" — is strong, but it produces worse results. Let the agent finish, then review the complete output. Mid-generation corrections break the agent's flow and produce incoherent code.

**3. Mechanical review.** I review the PR for correctness at the function level: Does it handle the obvious edge cases? Does it follow the patterns I specified? Are the tests meaningful? This takes about 30-60 seconds per 100 lines of diff. If the agent misses something mechanical (wrong variable name, inconsistent error handling), I note it in the review and let the agent fix it. I never fix mechanical issues myself — that's what the agent is for.

**4. Architectural review.** I read the diff a second time, focused on structural questions: Does this approach fit the codebase's architecture? Does it introduce coupling between unrelated modules? Does it establish patterns that will be hard to undo later? This is the phase where I spend the most time, and it's the phase that cannot be automated.

**5. Integration.** I merge the PR and run the integration tests. About 85% of agent-generated PRs pass on the first integration run. The remaining 15% reveal edge cases that neither the agent nor I considered — and those are the most valuable outcomes of the entire workflow, because they teach me something about my system that I didn't know.

## The Infrastructure That Makes It Work

None of this workflow functions without infrastructure. The agents need context about the codebase, which requires a context server that pre-indexes the repository. They need a queue that manages concurrency, because two agents modifying the same file simultaneously produces chaos. They need observability — structured logs, traces, and a dashboard — because when an agent fails, the failure mode (model error, context gap, tool misconfiguration, or genuine bug) determines the recovery strategy.

The infrastructure is invisible to someone reviewing the final PR. But it's the hardest part of the system, and it's the part that generalizes across any agent platform. The agents themselves are interchangeable. The infrastructure around them — the queues, the context, the observability, the error recovery — is what determines whether an agent fleet delivers value or just generates impressive-looking failures.

## The Honest Assessment

After a year, here's what I can say with confidence:

My personal productivity, measured in features shipped per week, is approximately three times what it was before I integrated agents into my workflow. My code quality, measured by production incidents per feature, is approximately the same — the agent has eliminated an entire class of mechanical bugs, but it has introduced a new class of architectural bugs that require different review skills to catch.

My understanding of my own codebase has changed. I know less about the implementation details of any individual module — the agent wrote most of them — but I know more about the system's architecture, because I spend my time on structural decisions rather than implementation mechanics.

My ability to onboard to a new codebase has degraded slightly, because I'm less practiced at reading unfamiliar code. But my ability to specify work clearly has improved dramatically, because the quality of the agent's output is a direct reflection of the quality of my spec.

The net effect is positive — strongly so. But it's not the science fiction future of "developers describe what they want and AI builds it." It's the boring, productive, engineering-reality future of "developers specify carefully, review thoughtfully, and let AI handle the mechanical translation between intent and implementation."

## The One-Year Verdict

Agent-driven development is not a revolution. It's an evolution — one that shifts the engineer's role from "builder of implementations" to "specifier of intent and evaluator of output." The mechanical work that used to consume 80% of my time now consumes maybe 20%. The judgment work that used to be 20% of my time now consumes the other 80%.

This is a good trade. I'm doing more of the work that matters and less of the work that doesn't. But it requires skills — specification writing, architectural judgment, agent failure diagnosis — that most engineering training doesn't teach.

The tools will keep improving. The models will get better at understanding context. The infrastructure will get more reliable. But the fundamental shift — from writing code to directing code — is happening now, and it's happening faster than most organizations are ready for.

After a year of running agent-driven development, my advice is simple: start with the infrastructure, not the agent. Build the queues, the context, the observability, and the review workflow before you deploy your first agent. The agent is the easy part. Everything around it is the actual engineering work.

And that engineering work — the infrastructure of coordination between human intent and machine execution — is the most interesting engineering problem I've worked on in a decade.
