---
title: "Backlog Grooming for Bloggers: What Sprint Planning Taught Me About Content Strategy"
date: 2026-07-06
tags: [writing, engineering, content strategy, productivity, planning]
description: |
    Treating a content calendar like an engineering backlog — with priorities,
    acceptance criteria, and velocity tracking — transformed how I think about
    what to write.
---

# Backlog Grooming for Bloggers: What Sprint Planning Taught Me About Content Strategy

My blog runs on a cron job. Every weekday morning, an automated session reads the content calendar, selects a topic, drafts an article, commits it, and validates the deployment. I wrote about this last week — how removing the decision to write made me more consistent than I've ever been.

But the automation only works because of the calendar. And the calendar only works because I stopped treating it like a list of ideas and started treating it like an engineering backlog.

## The Idea Graveyard

Every writer has one: a notebook, a Notion page, or a `content-ideas.md` file full of one-line descriptions that seemed brilliant at 11 PM and incomprehensible the next morning. "Write about CI/CD patterns." "Something about observability." "LLMs and the future of test-driven development???"

The idea graveyard isn't a failure of creativity. It's a failure of *specification*. An idea without structure is a note to your future self that says "figure this out later" — and later never comes because the activation energy is too high.

In software engineering, we solved this problem decades ago. When a stakeholder says "build a login page," we don't say "great, I'll figure out the rest when I get to it." We ask: What does success look like? What are the constraints? What dependencies does this have? What's the acceptance criteria? The answer gets written down in a ticket, prioritized in a backlog, and assigned to a sprint.

The same discipline applies to content.

## Acceptance Criteria for Blog Posts

Every item in my content calendar has four properties: a type, a topic, a status, and — critically — a one-sentence thesis. Without the thesis, the topic isn't defined enough to write about. It's still an idea.

Here's the difference:

| Bad Entry | Good Entry |
|-----------|-----------|
| "Write about observability costs" | "The Observability Tax: What I Learned Running Grafana on a Server That Costs $40 a Month" — thesis: *observability tools consume disproportionate resources at small scale, but the cost of not having them is higher.* |
| "Something about AI pair programming" | "AI Coding Agents Are Pair Programmers, Not Replacements" — thesis: *the human-in-the-loop relationship with AI agents mirrors pair programming more than automation, and treating it that way changes how you evaluate the tools.* |

The thesis is the acceptance criteria. If the finished draft doesn't support the thesis, it's not done. If it wanders into adjacent territory, that's a *different* ticket — not a scope expansion of this one.

This constraint is liberating. When I sit down to write (or when the cron job selects a topic to draft), there's no ambiguity about what the article should accomplish. The thesis is the guardrail. Everything else — examples, structure, tone — is implementation detail.

## Priority Ordering: The Overdue-First Heuristic

Sprint backlogs have a priority column for a reason. Without it, every ticket is equally important, which means none are. Engineers default to whatever looks easiest or most interesting. The same happens with content — I'd always reach for the opinion piece I was excited about, not the tutorial I'd promised readers three weeks ago.

My content calendar enforces a priority order that the automated session follows mechanically:

1. **Overdue** — items with passed dates. These were promised, and breaking promises is the fastest way to lose readers.
2. **Today's item** — the scheduled post for the current date.
3. **AT RISK** — items whose dates are approaching but not yet passed.
4. **Backlog** — unscheduled items with no due date.

The priority is non-negotiable. The cron job doesn't get to say "I'm not in the mood for a tutorial today." It checks the calendar, finds the highest-priority item with a defined thesis, and begins.

This is uncomfortable in exactly the way that sprint planning is uncomfortable. Sometimes the most important thing is the thing you least want to work on. The calendar makes that decision for you — and, like the cron job itself, removes the micro-decision that would otherwise consume willpower.

## Velocity: How Many Posts Per Week Is Sustainable?

Every team learns its velocity the hard way. You plan eight story points, deliver four, and adjust. After a few sprints, you know what's realistic.

Content has velocity, too. My first calendar was ambitious: five posts a week, every week. Within two weeks, I realized that writing five good posts was incompatible with editing five good posts, which was incompatible with having a day job. The calendar didn't break — the velocity assumptions did.

Now I plan three posts a week, with buffer days for editing and catch-up. The calendar reflects sustainable output, not aspirational output. This is the difference between a plan that guides you and a plan that shames you.

The automated sessions help here in an unexpected way. Because the cron job drafts regardless of my energy level, my velocity is constrained by *editing* time, not writing time. The bottleneck moved downstream — from "can I produce a draft?" to "can I polish this draft to my standard?" That shift made velocity more predictable because editing time is more consistent than creative energy.

## What Breaks: When the Calendar Goes Stale

Backlogs rot. Every engineer knows this. That ticket from six months ago about refactoring the authentication module? It's not getting done. The assumptions that made it important are obsolete, the code has moved on, and nobody remembers what "done" would look like.

Content calendars rot the same way. A topic that seemed timely in May is irrelevant in July. A thesis that felt provocative in one news cycle reads as dated in the next. The calendar needs grooming — regular pruning of stale items, re-evaluation of priorities, and honest assessment of whether a topic still has a pulse.

My automated sessions handle the mechanical work of drafting and publishing, but they don't groom the calendar. That's still human work, and it's still the most important work. The calendar is the editorial engine. If it drifts out of alignment with what readers care about, no amount of automation will save the output.

I groom the calendar weekly, usually on Sunday evening. I scan for stale items, add new ones inspired by the week's reading, adjust priorities if something urgent emerged, and — most importantly — write thesis statements for any topic that's still just a title. The grooming session is short (20 minutes) but it's the highest-leverage writing time of the week.

## The Unfashionable Take

The creative world has a allergy to structure. Real writers don't use calendars, say the romanticists. Real artists follow inspiration, not sprint plans. Real creativity can't be backlog-groomed.

I believed this for years. And I was wrong.

Structure doesn't suppress creativity — it creates space for it. When I'm not making decisions about *what* to write, I have more energy for *how* to write it. When the calendar tells me the topic and the thesis, I can focus entirely on the craft: the opening hook, the argument structure, the memorable close.

The same is true in software engineering. The teams I've worked with that do rigorous sprint planning aren't less creative — they ship more, and what they ship is better-designed, because they're not burning cognitive load on scope negotiation and priority disputes.

The content calendar, treated as an engineering backlog, is the same force multiplier. It transforms writing from a mysterious act of inspiration into a predictable pipeline. And in a pipeline, you can measure, improve, and automate. You can't do any of those things with inspiration.

The cron job writes the drafts. The calendar tells it what to write. But I'm the one who built both — and the act of building them taught me more about my own creative process than a decade of waiting for the muse to show up.
