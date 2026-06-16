---
title: "Code Review When AI Writes the First Draft"
date: 2026-06-16
tags: [AI, code review, software engineering, agents, DX, process]
description: |
    How code review changes when AI agents generate the first pass — and what
    human reviewers should actually focus on.
---

# Code Review When AI Writes the First Draft

Six months of running AI coding agents in production has taught me a lot about what breaks, what scales, and what stays the same. But the biggest surprise — and the most valuable shift — has been in how I review code.

Before agents, I reviewed every line of every pull request. I checked for syntax errors, edge cases, naming conventions, test coverage, architectural consistency, and whether the commit message actually described the change. It was slow, thorough, and exhausting. A 200-line PR could take 30 minutes.

Now, the PRs I review are mostly written by agents — opencode, Claude Code, or Codex — and my job has fundamentally changed. I don't review code anymore. I review *decisions*.

### The Mechanical Floor

The first thing you notice when reviewing agent-written code is how high the mechanical floor is. The agent never forgets a semicolon. Never imports something it doesn't use. Never leaves a trailing whitespace character. Never writes a variable name that violates the project's conventions — assuming those conventions are well-represented in its training data or context.

This is a genuine improvement. The mechanical portion of code review — the part that tools like linters and formatters have been automating for years — is now effectively at 100%. I used to spend maybe 30% of review time on issues that a good linter-plus-formatter pipeline would catch. An agent doesn't just catch those issues; it doesn't create them in the first place.

But the mechanical floor creates a strange psychological effect. A PR with clean formatting, proper naming, and passing tests *feels* complete. It looks like production-quality code. The temptation to skim, approve, and move on is strong — especially when you know the agent ran the tests and they passed.

Resisting that temptation is the core skill of modern code review.

### What I Actually Review Now

I've developed a mental checklist that's different from what I used before:

**Does the approach match the architecture?** Agents are great at local optimization and terrible at global consistency. An agent will write a beautiful function that solves the immediate problem, but that function might introduce coupling between two modules that the rest of the codebase carefully separates. Or it might use a pattern that exists nowhere else in the project — technically correct, contextually wrong. I now spend most of my review time tracing the agent's architectural assumptions, not its implementation details.

**Are the edge cases real?** Agents tend to handle the edge cases they've seen in training and miss the ones specific to your codebase. The code will handle null inputs gracefully but not your application's particular cache-invalidation quirk. It will retry on network timeouts but not on your auth service's non-standard error response. The gaps are in the codebase-specific knowledge that no amount of generic training data can provide.

**Does the error handling match the domain?** This is the most common failure mode I see. Agents default to generic error handling — log and return a 500, or catch Exception and rethrow with a generic message. In most production codebases, error handling is deeply domain-specific. A payment service should handle failures differently from a content-recommendation service. An agent doesn't know which is which unless you tell it, and even then, the distinction requires judgment that's hard to encode in a prompt.

**Is the diff minimal?** Agents tend to over-write. Given a request to change a function, they often rewrite the entire file. This isn't malice or incompetence — it's the architecture of the generation process. The agent generates the output from scratch, conditioned on the input, so any line that isn't explicitly constrained can change. I now check every diff to see whether the agent changed lines it didn't need to. Indentation reformatting. Import reordering. Comment rewording. Each unnecessary change is a risk — it's a line that didn't need review but now requires one.

### The Trust Calibration Problem

Every agent user goes through a trust calibration curve:

**Week 1:** You review every character. You don't trust the agent to get anything right. Review is slower than writing the code yourself.

**Month 1:** You notice the agent never makes syntax errors. You stop checking for those. Review gets faster. You start approving small, mechanical PRs without reading every line.

**Month 3:** You realize the agent occasionally makes mistakes that pass all tests and look reasonable — wrong algorithm, missing edge case, architectural drift. You recalibrate. Review gets slower again, but in a different way. You're not checking syntax; you're checking assumptions.

**Month 6:** You've settled into a stable pattern. You trust the agent's mechanical output implicitly. You trust its architectural judgment only when the task is narrow and well-defined. You never trust it with anything that requires deep understanding of your codebase's unwritten conventions.

The dangerous point is Month 1, when the mechanical reliability creates a false sense of complete reliability. The most experienced agent users I know are the most skeptical about agent-written code — not because the code is bad, but because they've internalized that the failure modes have shifted from "obvious" to "subtle."

### The Testing Blind Spot

Here's a pattern I've seen repeatedly: an agent writes code, writes tests, the tests pass, the PR is approved, and the bug is discovered in production a week later. The cause is almost always the same — the tests and the code share the same blind spot.

The agent writes a function to parse a date string. It writes tests for valid dates, invalid dates, and edge cases like leap years. All pass. But in production, the date string arrives in a different timezone than the agent assumed, and the parsing logic is wrong for that timezone. Neither the code nor the tests considered timezone handling, because both were generated from the same incomplete specification.

This is the fundamental limitation of agent-written tests: they test what the agent understood about the requirement, not what the requirement actually is. A human-written test can encode domain knowledge that the implementation doesn't capture. An agent-written test amplifies the implementation's blind spots.

The fix isn't better agents — it's a different review strategy. I now read the tests first, before the implementation, and ask: "If this test suite passes, is the feature actually correct?" If the tests are internally consistent but don't capture the domain's real constraints, I know the implementation will have the same gaps.

### What the Team Needs

If you're adopting AI coding agents on your team, the most important investment isn't in the agents themselves — it's in redefining your code review culture. Here's what I've found works:

**Write the review guidelines down.** Don't assume your team knows what to look for in agent-written PRs. Make a checklist: architectural consistency, domain-specific error handling, diff minimality, test blind spots. Review against the checklist until it becomes habit.

**Review in two passes.** First pass: read the tests and the diff overview. Decide whether the approach is right. Second pass: read the implementation details, focusing on edge cases and error handling. Never combine these — they use different cognitive muscles.

**Set a higher bar for agent PRs.** This sounds backwards — agents are supposed to save time — but it's essential. A human-written PR that looks reasonable but has a subtle bug is a normal mistake. An agent-written PR with the same bug is a systemic failure that will repeat in different forms. The review standard should be higher, not lower.

**Rotate reviewer assignments.** The worst pattern is the same person always reviewing the same agent's output. You develop shared blind spots. Rotate reviewers so fresh eyes catch the assumptions that regular reviewers have stopped seeing.

### The Bottom Line

Code review when AI writes the first draft is not easier — it's different. The mechanical burden drops, but the cognitive burden shifts to a harder problem: evaluating judgment rather than correctness. The reviewers who adapt best are not the ones who trust the agent most or least. They're the ones who develop a precise mental model of what the agent is good at, what it's bad at, and where their own attention is most valuable.

After six months, I review fewer lines per minute than I did before agents. But the lines I do review are the ones that matter — the architectural decisions, the domain-specific error handling, the edge cases the agent didn't know existed. That's not a step backward. It's the same progression that every engineering discipline goes through as its tools improve: less time on mechanics, more time on judgment.

The mechanics are solved. The judgment is still on us.
