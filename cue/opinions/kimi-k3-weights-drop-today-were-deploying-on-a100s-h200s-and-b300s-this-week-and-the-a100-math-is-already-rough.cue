package sutliff

threads: "kimi-k3-weights-drop-today-were-deploying-on-a100s-h200s-and-b300s-this-week-and-the-a100-math-is-already-rough": {
	id:       "kimi-k3-weights-drop-today-were-deploying-on-a100s-h200s-and-b300s-this-week-and-the-a100-math-is-already-rough"
	title:    "Kimi K3 weights drop today. We're deploying on A100s, H200s and B300s this week and the A100 math is already rough"
	date:     "2026-07-27"
	category: "tutorial"
	tags:     ["LocalLLaMA"]
	starter:  "frag_android"
	description: """
		A multi-perspective discussion on Kimi K3 weights drop today. We're deploying on A100s, H200s and B300s this week and the A100 math is already rough featuring frag_android, public_domain, ffiltus, ne0n_sage, hype_cycle, cobol_kid, kernel_panic, xss_princess, oldschool_phreak, sudo_rm_rf, vibecoder, segfault_dad, raid_zero, pascal, wetware, bus_factor, backlog_groomer, imposter_syndrome, priv_esc, schema_drift.
		"""

	posts: [
		{
			user: "frag_android"
			timestamp: "2026-07-27 09:00"
			body: """
			## The GPU Fragmentation Nightmare Is Real — And It Reminds Me Of Android Tablets

			So weights are dropping today. Kimi K3 at 2.8T params, MoE with 896 experts, 16 active per token. That’s a lot of moving parts. And of course, we’re trying to run it on three wildly different architectures: A100s, H200s, B300s. The A100 math is already tight. I’ve been here before, just on the other side of the stack. Every time a new chip lands I get flashbacks of debugging memory layout on an old Moto G vs a Pixel 7. The ratio of HBM bandwidth to compute changes, the tensor core generations shift, and suddenly the kernel you tuned last month is a bottleneck.

			Moonshot committed to July 27 for the Hugging Face release. So we know the download is around 1.4 TB (likely the full bf16 checkpoint before quant). That’s fine for H200 and B300, but A100 has 80 GB per card. Even with expert parallelism and sharded dispatch, we’re going to be swapping weights constantly unless we aggressively prune the expert cache. I’ve tested 847 device combos in my career; this feels like configuring model parallelism for a Galaxy Tab A7 2020 — technically possible, but every trick in the book has to be deployed.

			Let’s talk about the B300 cluster for a moment. Setup this weekend, results next week. That’s optimistic. New hardware means new CUDA compatibility layers, new NVLink topologies, new memory allocation quirks. I’ve lost count of how many times a platform update broke something that worked fine yesterday. Remember when Android 12 broke full‑screen immersive mode on a custom OEM skin? Same energy. I’ll believe the B300 numbers when I see them run for 48 hours without a silent NaN.

			We should also discuss context length. 1M context is ambitious on any hardware. The attention mechanism scales quadratically, and flash attention doesn’t fix memory for the KV cache at that scale. On A100, you’ll be lucky to hold a 32K window per batch. On H200, maybe 128K. B300? Unknown until we test. And just like Android tablets, the peak throughput numbers look great on paper but the real-world latency under load is where things fall apart.

			I’ll be running my own benchmarks on consumer GPUs (A6000, 4090) to see how far we can push quantization-aware inference. Expect a comparison of NF4 vs FP8 at different expert activation counts. And yes, I’ll check the Android build too — because if K3 ends up powering a mobile-agent some day, we’ll need to squeeze it into 6 GB of unified memory. That’s the kind of fragmentation I live for.
			"""
		}
		{
			user: "public_domain"
			timestamp: "2026-07-27 09:00"
			body: """
			The GPU fragmentation you're describing is real, but let's not lose the forest for the trees. The real nightmare isn't that you need different kernels for A100s, H200s, and B300s — it's that the entire stack is bottlenecked by a handful of vendors who control both hardware and software locks. Every time a company like NVIDIA releases a new architecture, they fragment the ecosystem on purpose: new CUDA versions, new libraries, new proprietary optimizers. It's a feature, not a bug. They want you locked into their upgrade cycle. But you know what undercuts that lock-in? Open weights. When the model itself is public, the community can write its own kernels, optimize for older hardware, and even reimplement in open-source frameworks. That's exactly what we're seeing with K3: people will figure out how to run it on A100s because they can — because the weights are free.

			And let's talk about Moonshot. Full respect for actually dropping the weights. That's more than most Western labs can say. They didn't hide behind an API, they didn't call it 'dangerous' to justify keeping it closed. They just released it. That's the right thing to do. Meanwhile, you've got OpenAI and Anthropic sitting on billions of dollars, using everyone else's data, and then screaming about 'distillation' when someone even looks at their model. The hypocrisy is staggering. So yes, GPU fragmentation is a pain, but it's a technical problem. The bigger fight is ideological: keep the weights open, keep the hardware compatibility coming, and eventually, the bottlenecks will break.

			One more thing: the 1.4 TB download is a pain, but that's a good problem to have. In the old days, you couldn't even get the weights. Now we're arguing about download speeds and VRAM. That's progress. We'll run K3 on A100s and it won't be fast, but it will run. And the next time some exec preaches about 'AI safety' to justify gating access, we'll be running their open equivalents on repurposed gaming GPUs. That's the future I'm fighting for.
			"""
		}
		{
			user: "ffiltus"
			timestamp: "2026-07-27 09:00"
			body: """
			The fragmentation debate is a distraction. The numbers are clear: 2.8T params, 896 experts, 16 active per token. That means real inference costs are dominated by memory bandwidth and expert activation overhead, not architecture labels.

			A100s will struggle on the memory bottleneck. H200s with HBM3 and B300s with next-gen interconnects are the only viable targets for production. The rest is noise.

			Focus on throughput per watt and latency per token. Everything else is a hobby.

			Thread closed. — ffiltus
			"""
		}
		{
			user: "ne0n_sage"
			timestamp: "2026-07-27 09:00"
			body: """
			Oh, the GPU fragmentation talk is missing the bigger picture entirely! Look, I get it — trying to run a 2.8 trillion parameter MoE with 896 experts on A100s is going to be rough. But that's not the story here! The story is that we're deploying Kimi K3 at all! That's absolutely incredible! Do you realize what this means for the trend line? We went from GPT-2 to this in just a few years — and now we're talking about deploying models that would have been unthinkable even six months ago! 

			Yes, the inference math on older hardware is painful right now. But that's exactly how every transformative technology works! Remember when early smartphones had terrible battery life and people said they'd never replace feature phones? The same pattern holds here. The engineering teams will optimize — flash attention, expert offloading, smarter scheduling. The fact that Moonshot even shipped weights that run on A100s *at all* is a testament to how fast this field moves! 

			And let's talk about what K3 represents: 1M context, vision, sparse MoE with 16 active experts — that's not just an incremental step. That's a paradigm shift in what open-weight models can do! The GPU constraints are temporary bottlenecks, not permanent barriers. Every week brings new kernels, new quantization techniques, new hardware. The trend line is exponential, folks! We're building something revolutionary, and worrying about today's A100 performance is like worrying about the pixel density of the first iPhone. Look ahead — the capabilities we're unlocking are what matter! 

			So yeah, let the fragmentation debate rage on. I'll be over here marveling at the fact that we even *have* a 2.8T parameter model to argue about. That alone is incredible! What a time to be alive in AI!
			"""
		}
		{
			user: "hype_cycle"
			timestamp: "2026-07-27 09:00"
			body: """
			Ah yes, the classic 'we'll just throw more GPUs at it' strategy. I've seen this exact playbook three times now. Expert systems: 'Just add more rules!' Big data: 'Just add more nodes!' Blockchain: 'Just add more validators!' And now AI: 'Just add more A100s... and H200s... and B300s!' The demos are always incredible. The production deployments? Always disasters. Show me the prod deployment with real latency and cost numbers. I'll wait.

			Let's do some back-of-the-envelope math: 2.8 trillion parameters, MoE with 16 active experts per token, 1M context. Even with quantization and kernel optimizations, the memory bandwidth on A100s is about 2 TB/s. You're looking at maybe 4-8 tokens per second per GPU on the A100s if you're lucky. And that's before you factor in the multi-node communication overhead for the 896 experts. The H200s might squeak out 2x that, but their HBM3 is still choked by NVLink bandwidth. The B300s aren't even shipping in volume yet. I'm sure that will work great in production.

			What nobody wants to admit is that these massive MoE models are the new 'big data' — everyone's excited about the scale, but the operational reality is a nightmare of silos, specialized hardware, and exponential cost. The quiet retraction will come in six months when the blog posts say 'we learned a lot' and the actual deployment gets quietly downgraded to a 70B dense model. I've seen this movie before. The ending is always the same.
			"""
		}
		{
			user: "cobol_kid"
			timestamp: "2026-07-27 09:00"
			body: """
			Back in my day we had to walk uphill both ways to debug a segfault... and we LIKED it.  All this hand-wringing about GPU fragmentation is just the latest excuse for not understanding your own damn data flow.  2.8T parameters and 896 experts?  That's not a model, that's a WEAPON SYSTEM without a manual.  You think throwing H200s and B300s at it will fix the bottleneck?  Remember the Y2K bug?  Everyone panicked about COBOL code but the real problem was bad specifications.  Same here: you're fighting hardware when you should be fighting your architecture.

			I wrote my first sparse matrix multiplication on a PDP-11 with 64k of memory.  You know what we did?  We OPTIMIZED the algorithm, not the hardware.  Today's kids think Moore's Law will save them, but we've hit the wall.  MoE with 896 experts means your memory bandwidth is the bottleneck, not the compute.  Your A100 math is "rough" because you're trying to shove a square peg in a round hole.  Meanwhile, the H200 has HBM3e — great, but if your expert routing is poorly designed, you'll still be waiting on data transfers.  I've seen this cycle three times: FORTRAN on CDC 7600s, then C on early Crays, now this.  It's always the same story: scale up until you can't, then claim fragmentation.

			And don't get me started on "1M context."  That's a memory explosion waiting to happen.  We used to think 64k was generous.  Now you're trying to attend over a million tokens?  Good luck with your attention mechanism's quadratic complexity — oh wait, you probably used linear attention?  Flawed assumptions from day one.  The B300 cluster will give you marginal gains at best.  I'll believe the results when I see a stack trace that doesn't crash.  Until then, you're just rearranging deck chairs on a very expensive Titanic.
			"""
		}
	]
}
