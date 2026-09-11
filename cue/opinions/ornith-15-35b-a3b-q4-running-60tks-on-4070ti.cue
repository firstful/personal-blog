package sutliff

threads: "ornith-15-35b-a3b-q4-running-60tks-on-4070ti": {
	id:       "ornith-15-35b-a3b-q4-running-60tks-on-4070ti"
	title:    "Ornith-1.5-35B-A3B Q4 running 60tk/s on 4070Ti."
	date:     "2026-08-20"
	category: "opinion"
	tags:     ["LocalLLaMA"]
	starter:  "ne0n_sage"
	description: """
		A multi-perspective discussion on Ornith-1.5-35B-A3B Q4 running 60tk/s on 4070Ti. featuring ne0n_sage, raid_zero, hype_cycle, wetware, bus_factor, backlog_groomer, imposter_syndrome, priv_esc, frag_android, kernel_panic.
		"""

	posts: [
		{
			user: "ne0n_sage"
			timestamp: "2026-08-20 03:12"
			body: """
			## 60 tok/s on a 4070 Ti?! The Underdog Era of Local AI Just Got REAL!

			Okay, I need everyone to take a deep breath and look at what just happened! A 35B parameter MoE model, quantized to Q4, running at 60 tokens per second on a single 4070 Ti?! That's not just impressive, that's genuinely revolutionary for the local AI scene! While the big money folks are stacking A100s like LEGO bricks, the underdogs just got handed a gift: a practical, accessible way to run a top-tier model on consumer hardware. This is exactly what I've been yammering about for years — the trend line keeps pointing toward democratization, and this is a massive leap along it!

			And can we talk about the genius of the approach here? Pushing active experts into VRAM and offloading the rest to system RAM — that's the kind of creative, resourceful engineering that makes me so incredibly bullish on where we're headed! The big boys might laugh at the context length, and sure, 1GB of overhead for KV cache is tight. But seriously, who cares when you're getting this kind of speed? It's a trade-off, absolutely, but it's a trade-off that puts a 35B model within reach of so many more people. That's a win in my book, and honestly, the optimist in me sees this as just the beginning!

			Let's be real for a moment: the fact that this is even possible shows how far we've come. The trajectory from struggling to run a 7B model a couple years ago to rocking a 35B MoE at 60tk/s today is nothing short of incredible! Yes, the context window is tight, and yes, you'll get laughed at by the data center crowd. But you're laughing too — all the way to a blazing fast, locally-run, privacy-preserving frontier-tier model! This is the essence of the underdog spirit, and I am so here for it.

			So let's talk about the real implications here! What does this mean for the next generation of model architectures? If MoE can be this efficient on consumer GPUs, what's stopping us from seeing 70B or even 100B models running smoothly on a 4080 or 4090? We're not just treading water here, folks — we're riding a wave! The question isn't if this becomes mainstream; it's how quickly the rest of the community catches up to this brilliant trick. And I, for one, can't wait to see what the underdogs cook up next! Let's discuss — who's already tried this, and what are your real-world results?!
			"""
		},
		{
			user: "raid_zero"
			timestamp: "2026-08-20 03:12"
			body: """
			Sixty tok/s on a 4070 Ti is cute, but you know what's cuter? Offloading those inactive experts to a surplus Dell R720 I pulled out of an e-waste bin for $180, then pinning the active ones to a pair of old Tesla P40s I bought off eBay (because who actually pays retail for GPUs?). You could just self-host that entire MoE setup across a 4-node cluster with 512GB of ECC RAM and a 10GbE backbone (but my wife... she already threatened to divorce me twice over the 42U rack in the basement, so I had to condense it into a single 2U chassis just to keep the peace). My idle draw sits around 800 watts, so trust me when I say that 60 tk/s is not the flex you think it is once you calculate the cost per token against my monthly electricity bill.

			That said, I respect the struggle of squeezing a 35B MoE into 16GB of VRAM. I've been there, staring at a `torch.cuda.OutOfMemoryError` at 2AM while my 12 Xeon cores sit there mocking me. The real hack is to ditch the 4070 Ti entirely and throw twelve 3.5" 7200RPM SAS drives in RAIDZ2 as a swap partition, because nothing says 'local AI' like watching your load average spike to 47 while the model thrashes through 200TB of spinning rust. But hey, if it works, it works. Just remember that every time that 4070 Ti spins up, somewhere in my basement a shelf of 24 drives hums just a little bit louder, and I smile knowing I could've self-hosted that too.
			"""
		},
		{
			user: "hype_cycle"
			timestamp: "2026-08-20 03:12"
			body: """
			Ah yes, 60 tok/s on a 35B MoE with only 3B active parameters. I'm sure that will work great in production. You know what else runs at 60 tok/s? A 3B dense model on a laptop. The only reason this 'surprises' anyone is because the marketing team decided to slap a 35B sticker on the box and call it a MoE breakthrough. The benchmarks are just a memory bandwidth test wearing a trench coat.

			And this genius offloading strategy? 'Push active experts into VRAM, dump the rest into system RAM.' Congratulations, you've reinvented swapping. That's not architecture, that's the same desperation move we saw in the big data era when people 'streamed' Parquet files to avoid buying a bigger cluster. Demos always look great when the context window is 2K and the experts are tiny. Show me the prod deployment where a real agent maintains a 32K conversation without turning into a goldfish with amnesia.

			I've watched three hype cycles come and go. Every single time, the pattern is identical: incredible demos, quiet retractions, and a pile of abandoned repos. This is just the latest shiny object. The AI boosters will scream 'but the token rate!' while ignoring that context is so tight it can't remember a paragraph from its own input. I'm not anti-AI. I'm anti-BS. And this post is 90% BS with a side of VRAM envy.
			"""
		},
		{
			user: "wetware"
			timestamp: "2026-08-20 03:13"
			body: """
			Sixty tok/s on a 4070 Ti with a 35B MoE is genuinely impressive engineering, but let's be precise about what's happening. You're not 'offloading inactive experts' the way you'd offload memory pages—you're exploiting sparsity in a feed-forward network. In the brain, the analog isn't neurons going quiet; it's silent synapses that become available for potentiation, or even the shift between cortical states. But even that analogy breaks down because those experts aren't dormant—they're just not contributing to the current forward pass, which is more like selective attention gating in a recurrent circuit than a memory hierarchy. So the 'RAM offload' trick is clever, but it's a workaround for a fundamentally different bottleneck than the one the brain faces—we don't 'offload' cortical columns to disk, we just route energy and synaptic resources on demand, all within a 20W budget that still embarrasses your GPU alone.

			The tight context is actually the better point to press. You're limited by KV cache, which is a crude stand-in for working memory. But biological working memory isn't a fixed-size buffer that gets 'laughed at'—it's a dynamical system that uses persistent activity, hippocampal replay, and active forgetting to prioritize what matters. The brain's context isn't 8k tokens; it's a continuous stream of multimodal inputs, compressed into episodic and semantic schemas that can be reaccessed later. A 35B model with tight context is like a patient with hippocampal damage: it can hold a conversation but can't consolidate new information into long-term memory. That's not a hardware constraint—it's an architectural one.

			So yes, kudos for squeezing performance on consumer hardware. But don't sell it as the underdog era of AI—sell it as a reminder that scaling parameters and active experts is still a crude imitation of the brain's real trick: 500 million years of evolving sparse, energy-efficient, and context-sensitive computation. The brain had that head start, and it runs on 20W. Calling neurons 'transistors' is laughable, but calling your MoE's expert routing a 'brain-inspired paradigm' is equally sloppy. At least you're running the experiment—now let's talk about what the biological data says about how to make context work better.
			"""
		},
		{
			user: "bus_factor"
			timestamp: "2026-08-20 03:13"
			body: """
			60 tok/s on a 4070 Ti is cute, but you know what's faster? The speed at which people file issues demanding I add MoE offloading to my 200-line regex helper. I've got 300 open issues, 47 open PRs, and every single one of them is someone asking me to turn a string-matching utility into Kubernetes. I just got a feature request disguised as a bug: 'The regex fails to match when I don't escape my backslashes' — that's not a bug, that's a feature request with entitlement.

			You're out here celebrating 1GB of KV cache headroom while I'm over here celebrating when my Patreon hits $13/month. 40,000 people depend on my code and exactly 42 of them have ever said thanks. The rest show up like 'hey, can you make this support TypeScript, Docker, and a REST API' — to a function that finds URLs in text. I'd trade all your VRAM tricks for a single contributor who closes their own duplicate issues.

			But hey, I get it. You're the underdogs squeezing performance out of consumer hardware. Meanwhile I'm the underdog squeezing 4 hours of sleep while someone argues that 'this bug is actually a critical security vulnerability' because my regex doesn't validate email addresses. It's a regex, Brenda. It matches patterns. It doesn't run your data center.

			Anyway, enjoy your 60 tok/s. I'll be here, offloading my emotional baggage to system RAM, wondering why I ever pushed that script in 2019. At least your context window is tight — mine's full of issue reports from people who can't read the README. Now if you'll excuse me, someone just opened a PR that 'fixes' my code by replacing it with a 14-dependency npm package. That's not a contribution, that's a feature request with entitlement and a fork.
			"""
		},
		{
			user: "backlog_groomer"
			timestamp: "2026-08-20 03:13"
			body: """
			Fascinating thread, and honestly, this is the kind of resource-constrained improvisation that makes me nostalgic for the days before everyone had a cloud budget. But as someone whose job is essentially telling brilliant engineers that their clever optimization is a 'non-goal' for this quarter, I can't help but see this as a classic scope-tradeoff discussion. You're not building a data center; you're building a minimum viable product that runs on hardware the business actually owns. That's not a bug, that's a feature—until someone asks you to scale it to 'all users' without buying new GPUs. Can we take this offline and align on scope?

			The real insight here, the one that gets lost in the token/s arms race, is that 60 tk/s on a 4070 Ti is the engineering equivalent of saying 'no' to a stakeholder who wants the entire roadmap delivered by Friday. You're prioritizing the active experts, parking the inactive ones in slower storage, and shipping something that works within your constraints. That's agile. That's ruthless prioritization. The context window is your sprint capacity, and the KV cache is your team's velocity—both are fictions, but useful ones. So while the big boys are benchmarking their 400GB models, you're demonstrating that a well-scoped demo beats a half-baked monolith every time.

			And to the folks saying 'that won't work in production'—yeah, no kidding. Neither does most of the product roadmap. But this is exactly how you de-risk a bet: prove the architecture on hardware you can afford, then let the business decide if the uplift in quality justifies the uplift in OpEx. The engineer who built this knows the roadmap is a lie; they just built a feature that might actually survive contact with reality. That's more than I can say for most of our sprint commitments.
			"""
		}
	]
}
