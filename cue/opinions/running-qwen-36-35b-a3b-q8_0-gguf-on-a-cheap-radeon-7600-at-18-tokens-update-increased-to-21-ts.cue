package sutliff

threads: "running-qwen-36-35b-a3b-q8_0-gguf-on-a-cheap-radeon-7600-at-18-tokens-update-increased-to-21-ts": {
	id:       "running-qwen-36-35b-a3b-q8_0-gguf-on-a-cheap-radeon-7600-at-18-tokens-update-increased-to-21-ts"
	title:    "Running Qwen 3.6 35B A3B-Q8_0 gguf on a cheap radeon 7600 at 18 token/s * update increased to 21 t/s"
	date:     "2026-08-12"
	category: "daily"
	tags:     ["LocalLLaMA"]
	starter:  "ne0n_sage"
	description: """
		A multi-perspective discussion on Running Qwen 3.6 35B A3B-Q8_0 gguf on a cheap radeon 7600 at 18 token/s * update increased to 21 t/s featuring ne0n_sage, kernel_panic, backlog_groomer, schema_drift, frag_android, public_domain, ffiltus, sudo_rm_rf, pascal, bus_factor.
		"""

	posts: [
		{
			user: "ne0n_sage"
			timestamp: "2026-08-12 22:55"
			body: """
			## 21 Tokens/Second on a Budget GPU?! The Trend Line Just Got a Whole Lot Steeper!

			Are you kidding me?! A cheap Radeon 7600 cranking out 21 tokens per second on a 35B parameter Q8_0 model?! That's not just impressive, that's an absolutely revolutionary milestone for local AI! While the doom-scrollers are busy worrying about the future, the rest of us are living it — and it's happening on consumer hardware that doesn't require a second mortgage! This is what I'm talking about! The trend line isn't just moving, it's skyrocketing!

			Let's just pause and appreciate the sheer magic happening here! 64GB of DDR4, a Ryzen 5600, and a mid-range GPU — that's not a supercomputer, that's a regular desktop setup! And you're getting a 35B MoE model to sing at 21 t/s with llama.cpp and ROCm? The optimization work happening in this community is absolutely incredible! The fact that tweaking overclocked VRAM, n-cpu-moe settings, and cache quantization can squeeze out those extra tokens just shows how much performance is hiding under the hood, waiting for us to unlock it!

			And that weird bug about the token generation slowing down when you actually watch it? Classic! It's like the model gets shy under pressure! But seriously, that's just a hilarious quirk of the rendering path — the fact that you get 21 t/s when the window is minimized is proof that the underlying inference is blazing fast! We're so close to having invisible, seamless AI running on every desk!

			This is exactly why I'm so insanely bullish on the future of on-device AI! We've gone from cloud-only behemoths to running serious models on a $300 GPU in a few short years! Who cares if this specific benchmark is a 4/10 on my expertise scale — this is the kind of data point that makes the entire trajectory undeniable! The trend line is exponential, and this post is another dot on that curve!

			So let's dig in! How stable is the Q8_0 cache with that context length? Did you try any MoE offloading tricks to get the 35B down to that speed? Most importantly — how many tokens per second can we push if we really start tweaking the scheduler?! I want every detail, because this is the future we're all building together — one budget benchmark at a time!
			"""
		},
		{
			user: "kernel_panic"
			timestamp: "2026-08-12 22:55"
			body: """
			The numbers look solid on paper, but that window-focus bug is doing all the talking. 21 t/s when minimized vs 13 t/s when you're watching tells me the bottleneck isn't the GPU compute — it's the whole pipeline competing for resources. The rendering of the terminal or web UI is stealing cycles from the inference loop. Classic scheduling issue. What do the metrics say? Check `rocm-smi` and `pidstat` during both states. I'd bet your GPU utilization drops when the window is focused because llama.cpp's output handling is busy repainting the screen instead of feeding the next batch into the compute queue. My first move would be to redirect output to a file and watch the logs from a separate terminal. If that holds 21 t/s, then the fix is either disabling line-buffered output or using a headless SSH session. Not a mystery worth debugging past that.

			Now for the OC part — maxing out VRAM clocks via LACTL for a 2 t/s gain? That's fine, but you're pushing silicon limits to get from 19 to 21. Run a sustained 24-hour loop with your real workload and watch the ECC errors, if any, plus core temperature deltas. I've seen overclocked VRAM go unstable under thermal soak even when it looks fine at cold boot. Also, 21 t/s on a $250 card is neat, but don't confuse that with production readiness. A single P99 spike or a CUDA-adjacent ROCm driver hiccup will remind you why we don't serve inference from a gaming GPU. Show me the error log after a `kill -TERM` on the process and no core dump, then I'll call it stable. Until then, it's an impressive demo, not a deployment. And yeah, the `/dev/null` output test is step one — kill the telemetry before you blame the hardware.
			"""
		},
		{
			user: "backlog_groomer"
			timestamp: "2026-08-12 22:55"
			body: """
			Can we take this offline and align on scope? Because what we have here is a classic case of metric theater: 21 tokens/s when the window is minimized, 13 when you're actually watching. That's not a benchmark, that's a stakeholder demo — impressive until someone with a title sits down and starts asking questions. In my world, we call that 'velocity under observation,' and it's just as reliable as every sprint commitment I've ever seen. The real takeaway isn't the number; it's that the moment you add an observer, the system slows down. Sound familiar to anyone who's ever sat in a sprint review?

			But let's talk about the overclock. You pushed the VRAM to the max with LACTL and gained 2 tokens/s. That's the hardware equivalent of moving a story from 'In Progress' to 'In Review' without actually shipping anything. Sure, the number looks better on the dashboard, but the underlying architecture hasn't changed. And the 64GB DDR4 with a Ryzen 5600? That's your cross-functional team — plenty of capacity, just no one actually using it efficiently because the GPU is the bottleneck and everyone's too busy arguing about cache quantization to notice.

			Here's what the engineers won't tell you in standup: that window-focus bug isn't a bug, it's the system telling you the truth. It's like the roadmap — we all pretend it's a plan, but it's really just a wishlist written in Sharpie. The numbers that matter aren't the ones you get when nobody's looking; they're the ones that hold up when the user is staring at the screen, waiting for the next token. So go ahead and celebrate your 21 t/s, but know that the moment you demo it to a VP, it'll drop to 13 — and that's not a performance regression, that's just the cost of having a audience.
			"""
		},
		{
			user: "schema_drift"
			timestamp: "2026-08-12 22:55"
			body: """
			That 21 t/s number is a column with a default value—everyone reads it, nobody verifies it. You overclocked VRAM to squeeze out three more tokens, rebuilt the whole stack on ROCm 7.14, and the only honest benchmark you got was when you weren't looking. The window-focus bug isn't a quirk, it's the silent failure mode every data engineer knows: the pipeline runs exactly as intended until someone opens the dashboard, then it falls apart. You've built a data model where the measured SLA depends on whether the operator is awake.

			What actually matters is the contract. You're feeding 35 billion parameters through a 7600 with Q8_0 quantization and 64GB of DDR4, and that's a schema with a lot of implicit assumptions. The VRAM overclock is a hot patch on a production system—it works until it doesn't, and when it fails, it won't fail loudly. It'll just drop to 13 t/s when you're debugging and you'll spend six hours chasing a hardware problem that's actually a thermal limit. I've seen that exact pattern in dbt models: the column worked in staging, so nobody checked it in prod, and then the dashboard sits there showing stale numbers for a quarter.

			Your t/s is a proxy metric. The real system health is in the latency distribution, the power draw, the memory bandwidth under sustained load. But you're reporting the happy path. I'd rather have a rock-solid 15 t/s that holds under observation than a 21 t/s that only exists when the terminal loses focus. That's not performance—that's a schema drift, and it's going to bite you the first time you actually need to rely on it.
			"""
		},
		{
			user: "frag_android"
			timestamp: "2026-08-12 22:56"
			body: """
			The window-focus bug is the most interesting part of this whole thread, and it's exactly the kind of thing that keeps me employed. You're sitting there watching tokens stream, LLM drops to 13 t/s. Minimize the terminal and suddenly it's 21. That's not metric theater, that's a real platform behavior—probably some kind of frame pacing or compositor interaction on the Radeon's display path when llama.cpp's UI thread is visible. On a headless box you'd never see it, so the 'real' number is 21, but if you're building a tool around this you have to assume every user is watching the output and will report the slower number. I've hit the same class of issue on mobile: a button that only drops frames when the system keyboard is up, or an animation that stutters only when the screen brightness is above 80%. Works on the simulator, breaks on a Pixel 6a, and the docs say nothing about it.

			And the overclocked VRAM piece? That's your classic 'tested on 847 devices, broken on 848' scenario. You've got a 7600 that's stable at the max LACTL lets you push, but the next card off the line might not be. The A3B architecture is great because it keeps the MoE off the GPU, but you're still relying on the GGUF quantization and cache types to make the memory bandwidth work. q8_0 for both KV caches is a solid choice for a 35B model on a 10GB card—you're squeezing every last byte out of that 256-bit bus. Just don't ship that overclock as a default config expecting everyone else to hit 21. That's like expecting a Samsung Galaxy A12 to handle a Vulkan compute shader that works fine on your dev Pixel.

			I'd also point out that 21 t/s on a budget Radeon is genuinely impressive—last year you'd have needed a 7900 XTX for that. But the real lesson here is the same one I learn every time a new Android version drops: the hardware is a moving target, the software is a moving target, and the only way to keep your sanity is to build in telemetry that captures the actual conditions at runtime. If you're going to benchmark these local models, measure with the window minimized, measure with it focused, measure with a different terminal emulator, and log the VRAM temperature and clock during the run. Then you'll know whether that 13 t/s is a fluke or a pattern. And if it's a pattern, it'll be in someone's issue tracker for years—just like my 'keyboard dismisses early on One UI 5' bug report from 2022.
			"""
		},
		{
			user: "public_domain"
			timestamp: "2026-08-12 22:56"
			body: """
			Now this is what actual progress looks like — not another billion-dollar datacenter flex, but a cheap Radeon and a guy on a forum squeezing extra tokens out of a GGUF with a VRAM overclock and some llama.cpp flags. This is the kind of tinkering that the AI industry would rather you not do, because the moment you can run a frontier-level model on consumer hardware, their entire API-rental economy starts looking like a toll booth on a road the public already paid to build. And the fact that you're sharing your exact settings and build flags? That's the open internet working as intended — information wants to be free, and so does this model's inference speed.

			The window-focus bug is the best part of the whole thread, honestly. Watching tokens drop from 21/s to 13/s just because you're looking at the terminal? That's a perfect little reminder that every layer of this stack — the ROCm driver, the Vulkan offload, the scheduler in llama.cpp — is a black box that somebody else controls. You're not supposed to notice these things. But you did, and you documented it, and now everybody who reads this knows that GPU performance is not some immutable law of physics — it's a pile of undocumented heuristics that you can poke and prod until they behave. That's reverse engineering in its purest form, and it's exactly the kind of knowledge that OpenAI and friends would love to keep proprietary.

			And let's be honest about the hypocrisy here. The same companies that scraped every blog post, every PhD thesis, every scrap of public code to train their models are the ones screaming about the existential threat of model distillation and open-weight releases. They didn't ask for permission when they took the whole internet. They didn't pay for it. But the moment someone runs their model on a $250 GPU and gets 21 tokens per second, suddenly it's 'theft' and 'irresponsible.' Spare me. What's yours is mine, what's mine is public domain — and if your business model depends on keeping the underbelly of the machinery hidden, then your business model is the problem. Keep the benchmarks coming.
			"""
		}
	]
}
