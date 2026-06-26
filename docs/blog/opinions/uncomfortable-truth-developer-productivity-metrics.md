---
title: The Uncomfortable Truth About Developer "Productivity" Metrics
date: 2026-05-20
tags: [engineering management, productivity, metrics, developer experience]
---

# The Uncomfortable Truth About Developer "Productivity" Metrics

I've never met a developer who said "you know what I need? More metrics." And I've never met an engineering manager who said "I have *too much* visibility into what my team is actually doing." This tension — between the people doing the work and the people accountable for it — is where the productivity metrics industry was born, and it's where most of it goes wrong.

The problem isn't that we measure. The problem is that we measure what's easy instead of what's true.

## The Trifecta of Useless Metrics

Three metrics dominate the developer productivity landscape, and each one is worse than the last.

### Lines of Code

LoC is the original sin of software metrics. It rewards verbosity, punishes conciseness, and completely ignores the fact that removing a thousand lines of legacy code is often the most valuable thing a developer can do all week.

I once watched a junior developer get a glowing review for cranking out 5,000 lines of code in a sprint. It was all boilerplate that should have been generated, half of it was duplicated, and the net complexity of the system went *up*. Meanwhile, the senior engineer who spent the same sprint deleting 3,000 lines of dead code and replacing 2,000 tangled ones with 200 clean ones got dinged for "low output."

LoC measures typing speed, not thinking speed. And in software, thinking is what pays the bills.

### Commits and PRs Per Day

Counting commits is like judging a novelist by how many times they hit "save." Git encourages frequent, granular commits — that's good practice. But using commit count as a productivity signal encourages the opposite of what you want: tiny, meaningless commits inflated to pad the count, or squashing everything into one commit to hide slow progress.

Pull request counts are slightly better, but still flawed. A single PR that refactors the authentication layer, adds unit tests, and updates documentation represents vastly more value than five PRs that each change one CSS color. Yet the second developer "looks" five times more productive on the dashboard.

### Story Points Velocity

Agile velocity is the most sophisticated of the bad metrics, which makes it the most dangerous. Unlike LoC or commit counts, velocity *seems* like it measures something real — delivered value — and it *seems* like it accounts for complexity through estimation.

The uncomfortable truth: velocity is a self-referential statistic. You calibrate your estimates to match your velocity, then use velocity to validate your estimates. The whole system is a circular argument backed by the sunk cost of hours spent in planning poker.

Worse, velocity incentivizes three destructive behaviors:

1. **Sandbagging** — Inflate estimates to guarantee you "beat" them, making yourself look productive while delivering less.
2. **Scope gaming** — Break work into the smallest possible tickets to maximize the velocity count, regardless of whether the tickets represent coherent units of value.
3. **Estimation exhaustion** — Spend so much time estimating that you have no time left to build, then justify the process by pointing to the estimates you generated.

## What Actually Matters

If these metrics are broken, what should we measure instead? The answer is unsatisfying for anyone who wants a dashboard: **we should measure outcomes, not outputs.**

Outputs are things you can count: lines written, PRs merged, tickets closed. Outcomes are things that matter: users unblocked, system reliability improved, technical debt reduced, team morale sustained.

The difference is the same as measuring a chef by how many plates they wash versus how many diners enjoy their meal.

### Leading Indicators

Some metrics are actually useful, but they're softer and harder to automate:

- **Time to competency** — How long until a new hire can ship a meaningful change independently? This tells you about documentation quality, codebase health, and onboarding process — all of which are the team's responsibility, not the individual's.
- **Rework ratio** — What fraction of your engineering effort is spent fixing things that were already "done"? High rework means you're shipping too fast or testing too little. Low rework (sustained) means your quality bar is in the right place.
- **Incident attribution lag** — When something breaks, how long does it take to identify the root cause? This measures observability, not blame. If it takes hours to find the culprit, your monitoring is the problem, not the person who wrote the code.
- **Bias for completion** — Do projects that get 80% done ever cross the finish line, or do they linger in "almost done" purgatory? This measures organizational follow-through, not individual productivity.

### The One Metric That Predicts Everything

If I had to pick a single leading indicator for team health, it would be **deployment confidence**. Ask your team: "If we deployed the current main branch to production right now, how confident are you that nothing breaks?" Rate it 1-10. Track it over time.

When deployment confidence is high (8+), the team has good tests, good CI, good monitoring, and good communication. They *know* their system. Productivity — measured any way you like — follows naturally. When deployment confidence is low, no amount of LoC or velocity will fix the fundamental problems.

This metric works because it's holistic. It captures everything: code quality, test coverage, operational maturity, team morale, and technical debt burden. It can't be gamed because it's subjective — and that's exactly why it's useful. You can't optimize a subjective number by cheating; you can only improve it by actually making things better.

## The Real Cost of Bad Metrics

Let's be honest about the damage. Bad productivity metrics don't just waste time — they actively degrade engineering culture:

- **They reward the wrong behaviors.** Developers optimize for what's measured. If you measure LoC, you get more code. If you measure PRs, you get more, smaller PRs. If you measure velocity, you get sandbagged estimates. In every case, you get *more* of something that isn't value.

- **They destroy psychological safety.** When metrics are visible to the org and tied to performance reviews, developers stop taking risks. They avoid refactoring (no visible output). They avoid novel approaches (harder to estimate). They play it safe, and your product stagnates.

- **They create perverse incentives for managers.** A manager whose bonus depends on team velocity has a strong incentive to prevent team members from taking vacation, attending conferences, or helping other teams. The result: burnout, isolation, and knowledge silos.

- **They replace judgment with dashboards.** The most insidious effect is that metrics give managers a false sense of understanding. Instead of talking to their developers, reviewing their code, or sitting in on their design discussions, they stare at a dashboard and convince themselves they know what's happening. They don't.

## A Better Way

I've been on both sides of this divide — as an individual contributor suspicious of any metric that could be used against me, and as a tech lead responsible for understanding whether my team is effective. Here's what I've landed on:

**Track systems, not people.** Measure deployment frequency, mean time to recovery, change failure rate, and lead time for changes — the DORA metrics. These measure the *system's* ability to deliver value, not any individual's output. When the system is healthy, productive people thrive in it. When the system is broken, no amount of individual heroics will save it.

**Use metrics to ask questions, not answer them.** A low deployment confidence score doesn't tell you what's wrong. It tells you to *ask* what's wrong. A high rework ratio doesn't mean your team is bad — it means you should investigate the code review process or the test coverage. Metrics are the start of a conversation, not the end of one.

**Trust your engineers.** This is the uncomfortable truth that no metric vendor wants to admit: if you hired competent people, gave them clear priorities, and removed blockers, they will be productive. You don't need a dashboard to tell you. You need to talk to them, read their code, and understand their challenges.

The best teams I've seen don't track individual productivity at all. They track team health, system reliability, and customer outcomes. They invest in tooling that makes their engineers faster and happier. And they trust that if you create the right environment, productivity takes care of itself.

That's not a dashboard you can buy. It's a culture you have to build.
