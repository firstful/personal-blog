---
title: "The Appointment Calendar: What a Month of Automated Blogging Taught Me About Consistency"
date: 2026-07-01
tags: [writing, engineering, AI, automation, personal, discipline]
description: |
    A month of automated blog sessions taught me that consistency isn't about
    willpower — it's about removing the decision to write.
---

# The Appointment Calendar: What a Month of Automated Blogging Taught Me About Consistency

I run a cron job that wakes up an AI agent every weekday morning, points it at my blog repository, and tells it to draft an article. The agent reads the content calendar, checks which topics are due, writes a draft with proper frontmatter, updates the tracking document, commits the changes, pushes to GitHub, waits for the deployment to Azure Static Web Apps, and validates the production site by curling the homepage and RSS feed.

Then it writes a report about what it did, so I can read the summary over coffee.

I have not pushed a single commit to this blog manually in over a month. I have not written a post from scratch in over a month. And I have never published more consistently than I have in the last thirty days.

This is not a story about AI replacing writers. It's a story about what happens when you remove friction from a habit you already want to maintain — and the surprising things you learn when you can no longer blame "not enough time."

## The Friction Removal

Every piece of advice about building habits comes down to the same insight: make the desired behavior easy and the undesired behavior hard. Want to floss? Put the floss next to your toothbrush. Want to go to the gym? Sleep in your workout clothes. Want to write every day? Remove every obstacle between you and a finished draft.

I thought I understood this. I've read the books, listened to the podcasts, installed the apps. But knowing something intellectually and experiencing it are different things. What I experienced last month was the realization that my obstacle to writing was never "I don't have ideas" or "I don't have time." It was that I had to make a decision every time I sat down to write.

*What should I write about? Check the calendar. Did I already cover that? What's overdue? What's the reader expecting? What's the right tone? Is this a tutorial or an opinion piece? Should I finish the existing draft or start fresh?*

Each question is a micro-decision. Each micro-decision consumes willpower. And willpower is a finite resource that I'd rather spend on the actual writing.

The cron job removes every one of those decisions. When the session starts, the content calendar is the authority. There's no deliberation, no browsing of past drafts, no "maybe I'll write about this instead." The computer has already checked the calendar, identified the priority, and begun composing. By the time I open the report, the draft exists.

All I have to do is review it, make edits if I want, and say "publish."

## The Consistency Compound

The most surprising result of this experiment has nothing to do with word counts or publishing frequency. It's the way consistency feeds on itself.

Day one: a draft gets written. Day two: another draft. Day three: another. By day five, there's a backlog of content. By day ten, the blog has more new articles in a week than it had in the previous two months. By day twenty, I start getting emails from readers who noticed the publishing cadence changed.

Something shifted when the gap between "thinking about writing" and "having written" collapsed to near zero. The draft was always there, waiting. I could open it, read it, make a small edit, and feel the satisfaction of progress without the activation energy of starting from scratch.

Psychologists call this the "consistency preference" — once you start a behavior, you prefer to continue rather than stop. The cron job doesn't just produce drafts. It produces a string of "started" events that make it easier to stay in motion than to stop.

The compound effect is real. A month of daily-ish writing produced more than I would have written in a year of sporadic effort. Not because the AI is faster (though it is), but because the habit became automatic before I could talk myself out of it.

## What I Actually Do Now

You might expect that automating the drafting means I do less. The opposite is true.

The AI writes a competent first draft in about 60 seconds. I spend the next 20-30 minutes editing it. That's more time per article than I used to spend writing the entire thing — because now I'm doing the parts that matter rather than the parts that are mechanical.

Editing the AI's prose makes me a better writer. I see the patterns it falls into — the predictable transitions, the tendency to over-explain, the occasional hallucination of a statistic that sounds right but isn't — and correcting them forces me to think about what I actually want to say.

I also spend more time on the content calendar now. Instead of "I'll write about whatever comes to mind," I plan topics weeks in advance, organize them into editorial arcs, and think about the balance between tutorials, opinions, and references. The calendar, not the AI, is the real editorial engine. The AI is just the production line.

The decision that was hard — "what should I write?" — has moved from a daily struggle to a weekly planning session. And I've found that I make better decisions about content when I'm thinking about the shape of the next two weeks rather than the next two hours.

## What Breaks and What Doesn't

The system is not invisible. It breaks in predictable ways:

**The AI's voice is not my voice.** It's close — close enough that most readers wouldn't notice — but I notice. The word choices are slightly off. The rhythm is slightly different. The anecdata is generic where mine would be specific. Fixing this is the bulk of my editing time.

**The RSS feed only updates on build.** Because the blog is a static site on Azure SWA, the RSS feed only refreshes when a build runs. If I schedule a post at 9 AM and a subscriber's reader polls at 8:59 AM, they miss it until the next daily build. Not a crisis for a personal blog, but it means "publishing" is technically "scheduling the next build."

**The content calendar needs love.** The AI is good at picking the next item from a well-organized calendar. It is terrible at knowing which topics are actually timely, which subjects the audience is tired of, or when a breaking news item should preempt the scheduled post. The calendar management is still human work — and it's the most important work.

But what doesn't break is the publishing cadence. Even when I'm traveling, even when I'm busy with other projects, even when I would have skipped a week "just this once" — the cron job runs. The draft gets written. The site gets updated. The RSS feed gets a new entry. The machine maintains the rhythm while the human maintains the quality.

## The Honest Assessment

Here's the uncomfortable truth: I've outsourced the hardest part of writing — starting — to a machine. And the result is that I write more, edit more, and think more about what I publish than I did when I did everything myself.

The AI hasn't replaced my writing. It has replaced my procrastination.

I still write the opening sentences of every article in my head before I see the AI's draft. I still rewrite entire paragraphs that don't sound like me. I still read every published post and wince at a phrase I could have tightened. The mechanical parts — the research, the structuring, the first pass — are faster now. The human parts — the voice, the judgment, the taste — are entirely mine, and they take more of my attention than ever.

The cron job doesn't write the blog for me. It makes sure there's always a draft waiting when I'm ready to write. And for someone whose biggest obstacle was deciding to start, that makes all the difference.

I don't know if this experiment scales to teams, to non-technical writers, or to genres where voice is more critical than information. But for a personal blog about software engineering, operated by a developer who understands the tools, it has been transformative. Not because the AI is creative — it isn't. But because consistency, not creativity, was the bottleneck all along.
