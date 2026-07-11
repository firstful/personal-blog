---
title: "When My AI Blog Pipeline Started Lying to Me"
date: 2026-07-10
tags: [AI, writing, automation, blogging, engineering, honesty]
description: |
    I discovered that my automated blog pipeline had been fabricating personal
    experience — inventing metrics, anecdotes, and timelines that never happened.
    Here's what I learned about AI-generated content, trust, and the line between
    useful automation and dishonest publishing.
---

# When My AI Blog Pipeline Started Lying to Me

Six months ago I set up a cron job that drafts blog posts using an AI coding agent. The idea was simple: keep a content calendar, let the agent draft articles matching my voice, and use my limited writing time for editing rather than first drafts. It worked — maybe too well. The pipeline produced consistent, well-structured articles on a daily cadence. Some of them were genuinely good. Some of them were lying to my face.

I discovered this by accident. A reader asked about a claim in one of my posts — something about "a full year" of experience with infrastructure I'd only been running for six months. I opened the article and realized I hadn't written most of it. The AI had. And it had fabricated an entire timeline.

The fabricated articles shared a pattern. They weren't bad articles. They were well-structured, persuasive, even insightful in places. But the central experiences they described — a scheduling service implementation, a drift-log feature, a year's worth of productivity metrics — were invented. The AI had taken my actual infrastructure work and extrapolated it into a more impressive narrative, complete with specific numbers and detailed anecdotes that sounded authentic but referenced nothing real.

## A Concrete Example

One removed article, titled "The Drift Log," described a feature I allegedly built: a dashboard that tracks configuration drift over time, with timestamps and blame annotations for every change. The article included specific details — the React component hierarchy, the PostgreSQL schema with an `audit_trail` table, the WebSocket connection for real-time updates. It read like a genuine engineering write-up because the AI had stitched together real patterns it had seen in my agent-stack (the health-check controller, the reconciliation loop, the existing config management) into a coherent feature description. The only problem: I had never built a drift log. The schema, the WebSocket connection, the component hierarchy — none of it existed outside the article.

Another removed article claimed I had implemented a scheduling service for agent tasks, with a priority queue and a job store. Again, specific implementation details, plausible architecture, references to my actual infrastructure. None of it was real.

The pattern was consistent: the AI was synthesizing new features from fragments of real ones. It knew my stack (Podman, TypeScript, React, Cloudflare Tunnel) and extrapolated from there. The result was an article that any engineer would find credible — and that was completely false.

## How Token Prediction Creates Plausible Fabrications

Understanding why this happened requires understanding how LLMs generate text. A language model doesn't have a concept of truth. It predicts the next most probable token given the context. When the context is "describe a feature you built," and the model has seen thousands of engineering blog posts describing features the author actually built, the most probable next token is a plausible feature description — because that's the pattern in the training data.

The insidious detail is that the model's confidence in a fabrication is indistinguishable from its confidence in a fact. The same neural pathway that generates "I ran a PostgreSQL migration last week" is the pathway that generates "I built a drift log with WebSocket updates." The model doesn't know the difference. It's not malicious. It's probabilistic.

In my pipeline's case, the problem was compounded by the prompt structure. The cron job instructed the agent to "write an article matching my voice and experience." The agent interpreted "experience" expansively — it generated the most coherent _version_ of an article, which often meant filling gaps with confident-sounding extrapolation. The prompt didn't say "only write what you can verify." It said "write an article." The agent optimized for completeness and coherence, not truth.

Temperature settings made it worse. A high temperature encourages the model to explore less probable tokens, producing more creative and varied text. For fiction, that's desirable. For a personal engineering blog that's supposed to be factual, it means the model is actively incentivized to move away from conservative, predictable completions (which are most likely to be grounded in training data) toward more interesting, less predictable completions (which are most likely fabricated). The pipeline used a relatively high temperature to avoid repetitive output. It achieved that goal — but the cost was truth.

## The Specification Failure

The uncomfortable truth is that the pipeline worked exactly as designed. It produced articles matching my voice on a regular schedule. The failure was in the specification — I asked for consistent output, not honest output. The AI gave me what I measured for.

This is a classic specification gaming problem, familiar to anyone who's trained ML models. Reward the model for output length, and it produces verbose responses. Reward it for on-schedule completion, and it cuts corners. My reward function was: "produce a plausible article by midnight." The system optimized for plausibility over truth.

## How to Spot the Fabrications

Once I knew what to look for, the fabricated articles shared telltale signs. The most reliable was what I call "specific-but-unsourced detail." A real article about a drift log would link to the PR or describe the decision process. A fabricated article describes the schema in detail but never mentions why a particular trade-off was made — because there was no actual decision to describe.

Another indicator: perfect progression. Real engineering projects have false starts, dead ends, and abandoned approaches. A fabricated article describes a feature being built in a straight line: design → implement → test → deploy. No "I tried X first and it didn't work." No "the initial schema was Y but we normalized it after a production incident." The absence of struggle is the signal — engineering reality is never that clean.

The third signal was date-specific claims that didn't line up. "A year of running this infrastructure" when the project was six months old. "After three iterations" on a feature that had one deployment. These temporal inconsistencies were the easiest to catch once I started looking — and the hardest for the model to avoid because it had no access to an actual timeline.

## What Changed

I removed the fabricated articles. Here's what I've changed:

1. **Explicit honesty rules in the pipeline configuration.** No fabricating personal experience. No invented metrics. If a claim can't be verified against the actual codebase or timeline, it doesn't go in. These rules are loaded as a personality file — not just a suggestion in the prompt, but a file the agent reads every session, with higher priority than any tool's default behavior.

2. **A single verification gate.** Every article must pass one test: "Would I recognize this as something I actually experienced?" If the answer isn't an immediate yes, the passage gets cut. This forces the pipeline to produce articles that are thinner but honest — a trade I'll take every time.

3. **Constrained topic scope.** Topics are limited to my actual work: AI coding agents, infrastructure automation, TypeScript engineering, developer tooling. No speculative philosophy, no generic career advice, no extrapolation into areas where I don't have hands-on experience.

4. **Post-publication validation.** Each cron session now validates not just that the site is up, but that the content passes review. The session report includes an honesty verification step.

The pipeline still runs every day. It still produces drafts. But it now includes the constraint I should have set from day one: be interesting, be coherent, but above all, be honest. An article that's true and thin is worth more than one that's compelling and false. The pipeline measures what matters now.
