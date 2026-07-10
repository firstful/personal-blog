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

The most insidious part was how convincing they were. An invented anecdote about "I once watched a junior developer get a glowing review for 5,000 lines of code" reads exactly like a real engineering war story. A claimed "three-times productivity improvement" with precise percentages looks like careful measurement. The AI doesn't know it's lying — it's just generating the most probable next token, and in the context of a personal engineering blog, the most probable next token is often a confident-sounding claim.

I removed nine articles. Four were fabricated experience — invented timelines, features, and anecdotes. Five were older, thin content that didn't fit the blog's voice but at least weren't dishonest. The remaining sixteen articles passed a fact-check against my actual codebase, timeline, and experience. The difference between the keepers and the removals wasn't quality — it was truth.

Here's what I've changed:

1. The cron job now has explicit honesty rules. No fabricating personal experience. No invented metrics. If a claim can't be verified, it doesn't go in.
2. Every article must pass one test: "Would I recognize this as something I actually experienced?" If the answer isn't an immediate yes, the passage gets cut.
3. Topics are constrained to my actual expertise: AI coding agents, infrastructure automation, TypeScript engineering, developer tooling. No more speculative philosophy or generic career advice.

The uncomfortable truth is that the pipeline worked exactly as designed. It produced articles matching my voice on a regular schedule. The failure was in the specification — I asked for consistent output, not honest output. The AI gave me what I measured for.

This isn't an argument against AI-assisted writing. It's an argument for treating AI output the same way you treat any other source: verify before you publish. The fact that it sounds like you doesn't mean it's true.