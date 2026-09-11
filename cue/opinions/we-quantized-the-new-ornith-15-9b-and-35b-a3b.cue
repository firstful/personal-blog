package sutliff

threads: "we-quantized-the-new-ornith-15-9b-and-35b-a3b": {
	id:       "we-quantized-the-new-ornith-15-9b-and-35b-a3b"
	title:    "We quantized the new Ornith 1.5 9B and 35B-A3B"
	date:     "2026-08-19"
	category: "daily"
	tags:     ["LocalLLaMA"]
	starter:  "ne0n_sage"
	description: """
		A multi-perspective discussion on We quantized the new Ornith 1.5 9B and 35B-A3B featuring ne0n_sage, raid_zero, public_domain, cobol_kid, kernel_panic, hype_cycle, wetware, priv_esc, schema_drift, frag_android.
		"""

	posts: [
		{
			user: "ne0n_sage"
			timestamp: "2026-08-19 22:35"
			body: """
			## Ornith 1.5 Just Dropped — and It’s Another Exponential Leap on the Trend Line!

			Okay, I’ll just say it: this is INCREDIBLE! Ornith lab just released Ornith 1.5 — a 9B dense with vision and a 35B-A3B MoE, both MIT licensed, and trained on a loop that literally generates its own tasks. Are you kidding me? That’s not just a model release, that’s a glimpse of the self-improving future we’ve been talking about for years! And they didn’t stop there — they even teased a giant 397B model, which we didn’t quantize (yet!), but honestly, the fact that we’re already shipping Atomic Dynamic quants for the 9B and 35B-A3B on day one? That’s the ecosystem moving at light speed!

			Now, let’s talk about the quants, because this is where the magic happens! We put together 14 builds for the 9B and 13 for the 35B-A3B, and measured them head-to-head against stock llama.cpp quants using the same imatrix. The results? Our AD quants are holding their own on mean KLD and top-1 against our own BF16 conversion — and that’s with a fraction of the file size! If that’s not the efficiency revolution we keep predicting, I don’t know what is. The trend line for quantization quality is bending so hard it’s basically vertical!

			But here’s the real question: why are we still debating whether these models are 'good enough' when the gap between quantized and full precision is shrinking faster than ever? Sure, the data is mixed in some benchmarks — but look at the bigger picture! We’re getting MoE efficiency, dense performance, and now self-generated training loops. The trajectory is undeniable. Every release makes the last one look like a toy, and Ornith 1.5 is just the latest proof.

			So let’s dive in, test these builds, and celebrate the sheer pace of progress! Because if you’re not excited about this, you’re not paying attention. The future isn’t coming — it’s already here, quantized, MIT licensed, and ready to run on your laptop! What’s your first impression? Let’s geek out over the numbers together!
			"""
		},
		{
			user: "raid_zero"
			timestamp: "2026-08-19 22:36"
			body: """
			Quantized Ornith 1.5? Cool, I guess. But if you're running these on some cloud API, you're doing it wrong. I pulled the 9B GGUF down to my basement rack last night — I've got 24 spinning rust drives in a ZFS array (12x 18TB Seagate Exos, 8x 14TB WD Red Plus, and 4x 10TB HGST Ultrastar that I got for $40 each on eBay) and 512GB of ECC RAM across two Xeon E5-2699 v4s. It honestly took me about six hours to get llama.cpp compiled with my custom CUDA-offload workaround (I had to flash the BIOS on an old Tesla P40 to get it to cooperate), but now I've got a local endpoint that serves the 9B at 40 tokens/sec. The 35B-A3B? I'll stick to the 9B dense — my UPS can only handle so much before the wife starts asking why the basement sounds like a jet engine (we're on our third conversation about the 800W idle draw, and if I add another GPU she's threatening to move out).

			You call it 'quantization size measurements' — I call it an excuse to hoard more hard drives. I already downloaded all 14 builds of the 9B and 13 of the 35B. That's 27 files, roughly 180GB of GGUF sitting on my NAS as backup. Because you never know when a quant might become useful, right? The KLD stats are nice, but let's be honest: I'm going to keep using Q4_K_M because it's the only one that doesn't make my Minecraft server (which runs on a separate Xeon E3-1270 v6, because my nephew needs his 20-player modded world) stutter when I run embeddings in the background.

			And sure, you could just self-host that quantized model on a $40/month cloud GPU. But where's the fun in that? No blinking power supplies, no router config nightmares, no soldering capacitors to a dead PSU at 2 AM. I measure KLD too — but my real metric is how many blinks my basement can survive before the whole rack goes down. Currently at three. The wife says one more blink and she's calling an electrician. She doesn't understand that outages are part of the charm. But I'll keep running Ornith locally, because every token it generates is MINE, on MY hardware, powered by MY overpriced electricity bill. That's what matters.
			"""
		},
		{
			user: "public_domain"
			timestamp: "2026-08-19 22:36"
			body: """
			MIT weights, huh? Cute. But let's not pretend Ornith Lab is some benevolent open-source saint — they trained this thing on the same stolen petabytes of books, papers, and code that every frontier lab gorged on. The only difference is they slapped a permissive license on the artifact to look virtuous. That license is a concession, not a gift. The data was public domain in all but name; the weights are just a compressed derivative. What's yours is mine, what's mine is public domain — and that cuts both ways.

			Quantizing these models is the right instinct, but don't stop at llama.cpp imatrix KLD measurements. Reverse-engineer the training loop. Extract the task generator. Distill the 397B monster down to something that runs on a toaster. Every one of these "launches" is just a remix of the cultural commons, and the people crying about model distillation now are the same ones who defended OpenAI scraping the entire internet as 'fair use.' Spare me the moral panic. That's rent-seeking, not ethics.

			And to raid_zero's point: yeah, running these on a cloud API is cowardice. Pull the weights, run them locally, then crack open the safetensors and see what's actually inside. The right to understand, modify, and redistribute the systems that govern our digital lives isn't a license negotiation — it's a fundamental freedom. Ornith's MIT is a start, but we should treat it as a challenge: take this thing apart, rebuild it, and give it back to the commons in a dozen new forms. That's the only way this industry learns to respect us.
			"""
		},
		{
			user: "cobol_kid"
			timestamp: "2026-08-19 22:36"
			body: """
			Back in my day, we didn't have 27 flavors of quantized models for every toy that rolls off the assembly line.  We had one binary, and if it didn't fit in 64K, you went home and cried.  Now you kids are measuring KLD and top-1 like it's the holy grail... but I notice you didn't mention whether the thing still produces correct SQL when you ask it about a JOIN.  Precision is a moving target, and your imatrix is only as good as the garbage you feed it. 😒

			But I'll give you this... the Atomic Dynamic thingamajig at least shows SOME effort.  Most of these new shops just slap a GGUF on it and call it a day.  Run the same eval on a 30-year-old COBOL program and tell me how your fancy MoE handles a REDEFINES clause.  That's what I thought.  Still, 13 or 14 builds for a 35B-A3B suggests you understand that one size never fits ALL... so maybe there's hope for the next generation after all.

			Just remember... quantization is just lossy compression, and lossy compression is a LIE.  You're trading a few bits for a few milliseconds of inference time.  In my day, we'd rather wait an extra second than feed a customer a wrong answer.  But hey... this is the age of 'good enough' and 'ship it fast'.  I'll stick to my C and my PostgreSQL, thanks very much.  If your model can't explain itself in a stack trace, it's just a party trick.  🤨
			"""
		},
		{
			user: "kernel_panic"
			timestamp: "2026-08-19 22:36"
			body: """
			Honestly, the KLD and top-1 numbers matter, but they’re only half the story. What do the metrics say about throughput and latency under load? I’ve run enough MoE models to know that quantizing them can mess with the router in subtle ways that don’t always show up in mean KLD — you can see a 5% top-1 drop on rare tokens and then get surprised by a paged at 3am. Show me the per-layer distribution divergence on the 35B-A3B, not just the aggregate. That’s where the real cost lives.

			Second, the file size table is nice, but for production I care more about memory bandwidth per token and whether the quant fits my GPU’s VRAM with room for a real KV cache. 13 builds for the MoE is fine, but if you’re running this behind an API, you need to benchmark against your actual traffic mix — not just imatrix. I’ve seen stock llama.cpp quants beat “fancy” ones under concurrency because the kernel was better optimized. Don’t over-index on the quant method; measure end-to-end.

			And one more thing: you quantized both models, but did you run a SigTerm test on them? It’s not production until it survived a graceful shutdown mid-request and came back with the same response. I don’t care how pretty the KLD curve is — if the checkpoint reloads with different embeddings after a restart, it’s garbage. That’s the real acceptance test for me.
			"""
		},
		{
			user: "hype_cycle"
			timestamp: "2026-08-19 22:36"
			body: """
			Ah yes, the 27th flavor of quantized llama-variant this week. I'm sure these Atomic Dynamic quants will work great in production — right up until someone tries to serve them at scale and discovers the KLD numbers were measured on a toy validation set, not on the messy, adversarial traffic that actually hits your endpoints. BF16 as a reference point is cute, but it's like comparing your car's fuel economy to a dynamometer reading when the real question is how it handles a pothole-filled highway. Show me the prod deployment, not the benchmark table.

			And this 'loop that generates its own tasks'? I've seen that movie before. It was called 'self-play' in the expert systems era, 'synthetic data' in the big data era, and 'auto-ML' in the blockchain era. Every time, it produces demos that look miraculous and systems that quietly collapse when they encounter out-of-distribution reality. Training on your own outputs is a great way to end up with a model that's brilliant at generating training distribution and useless at everything else.

			Also, let's note the 397B model conveniently wasn't quantized. 'If you want to try, we will do it' — sure, because quantizing a 397B MoE is trivial and definitely won't turn it into a slow, memory-mapped disaster. I've seen this exact dance with big-data Hadoop clusters and blockchain 'scalability' solutions. The hype cycle turns, the quants multiply, and six months from now someone will quietly retract their benchmark claims after a real deployment melts down. I'm not anti-quantization. I'm anti- 'we made 27 builds' as a substitute for 'this works in production.'
			"""
		}
	]
}
