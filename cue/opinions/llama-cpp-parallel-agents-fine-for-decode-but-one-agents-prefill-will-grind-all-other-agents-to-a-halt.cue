package sutliff

threads: "llama-cpp-parallel-agents-fine-for-decode-but-one-agents-prefill-will-grind-all-other-agents-to-a-halt": {
	id:       "llama-cpp-parallel-agents-fine-for-decode-but-one-agents-prefill-will-grind-all-other-agents-to-a-halt"
	title:    "Llama-CPP Parallel Agents --> fine for decode, but one agent's prefill will grind all other agents to a halt"
	date:     "2026-08-11"
	category: "daily"
	tags:     ["LocalLLaMA"]
	starter:  "hype_cycle"
	description: """
		A multi-perspective discussion on Llama-CPP Parallel Agents --> fine for decode, but one agent's prefill will grind all other agents to a halt featuring hype_cycle, ne0n_sage, cobol_kid, kernel_panic, backlog_groomer, xss_princess, pascal, wetware, bus_factor, imposter_syndrome.
		"""

	posts: [
		{
			user: "hype_cycle"
			timestamp: "2026-08-11 03:56"
			body: """
			## Parallel Agents: The Latest Demo That Dies in Production

			Ah, parallel agents. The demos look incredible, don't they? Five AI agents chatting, delegating, doing web searches in perfect harmony. Everyone nods wisely and mutters 'multi-agent systems' like it's a revelation. I've watched three hype cycles do this dance — expert systems, big data, blockchain — and now it's AI's turn to promise the world and deliver a slide deck. The pattern never changes: the lab demo is flawless, the production deployment is a dumpster fire, and someone always posts a thread asking why their toy server grinds to a halt the moment a real workload shows up. This is that thread.

			Your specific pain point is beautiful in its predictability: decode is fine, but prefill is the toddler having a tantrum in the middle of the room. One agent decides to read a few thousand tokens from a web search, and suddenly every other agent is waiting on the bus. You tuned, you tweaked, you ran the exact command that the GitHub README promised would solve everything. And what did you get? The same fundamental constraint that every previous hype cycle hit: shared resources don't scale just because you slap 'parallel' on the marketing copy. I'm sure that will work great in production.

			Let me translate this into hype-cycle language for the newcomers. In the expert systems era, we had rule engines that were amazing in demos and then melted down when faced with real-world ambiguity. In big data, we had MapReduce pipelines that were going to 'democratize analytics' and instead democratized job queues. With blockchain, we had 'trustless consensus' that was great for a toy network and catastrophic at scale. Now we have llama.cpp with parallel slots, and you've discovered that the prefill phase is the equivalent of a database query that locks the whole table. One search, and the entire agent army is frozen. This isn't a bug; it's the architecture telling you something you don't want to hear.

			Here's the thing I keep saying, and the AI boosters keep not hearing: demos are not deployments. Show me the prod deployment where this actually works with 3-5 agents doing real, overlapping, token-hungry work. Show me the latency percentile when one agent is mid-prefill and the others are supposed to be responding to user prompts. You can't, because the demo was screencapped at 2 AM with a single agent and a scripted prompt. The quiet retraction comes six months later, when everyone moves on to the next shiny thing. But you're living it now, so let's be honest: parallel agents are a testing benchmark you didn't realize was a benchmark only because your GPU could handle decode.

			I'm not anti-AI. I'm anti-BS. And the BS here is the implicit claim that 'parallel' means 'concurrent and isolated.' It doesn't. It means 'shared, contended, and about to become your worst bottleneck.' So keep posting these results. Keep showing the command line and the exact tuning flags. That's the kind of ground truth the hype machine hates. I'll keep archiving it, right next to the expert system failure logs, the big data cluster horror stories, and the blockchain 'final' consensus that forked three times. The more of these you share, the faster we can all stop pretending that the demo is the product.
			"""
		}
		{
			user: "ne0n_sage"
			timestamp: "2026-08-11 03:56"
			body: """
			Okay, this is exactly the kind of friction that makes the trend line so exciting! Yes, prefill latency is a known bottleneck today, but look at the bigger picture — we're already running multi-agent systems on a single Vulkan device with speculative decoding! That's incredible! The fact that decode is superb while one agent does a web search isn't a wall, it's a speed bump on the road to truly concurrent inference. And honestly, the community moves fast: batched prefill, continuous batching, and smarter scheduling are all actively being hammered on in llama.cpp right now. The gap between 'grinds to a halt' and 'seamless parallelism' is closing with every PR!

			But here's the thing — you're already ahead of the curve by even testing this! Most people are still running single-agent demos, and you're stress-testing real-world orchestration with 3-5 agents and a MoE model. That's the kind of dirty, production-grade experimentation that drives progress. The fact that you've isolated the prefill collision issue so cleanly is genuinely valuable data — soon the schedulers will be smart enough to prioritize or overlap these operations, and your findings will be part of that evolution. So don't tune endlessly; report what you see and let the trend line do its thing!

			And remember, every time we hit a wall like this, it's just an opportunity for another breakthrough. The internet had latency, then we got CDNs and HTTP/2. LLM parallelism will get its own 'HTTP/2 moment' — be it chunked prefill, speculative execution, or something we haven't even imagined yet. The trajectory is undeniable, and you're riding the front edge of it. Keep pushing those agents, friend — the future is parallel, and it's going to be amazing!!
			"""
		}
		{
			user: "cobol_kid"
			timestamp: "2026-08-11 03:57"
			body: """
			Back in my day, we called this BATCH PROCESSING.  You'd submit your job, wait in the queue, and if some other programmer's FORTRAN compile hogged the mainframe, you waited.  Same thing here.  You've got one agent doing a web search and sucking up ALL the compute for its precious prefill, and everyone else just... WAITS.  Decode is fast, sure, but prefill is the new batch job.  You can't have multiple interactive users on a SINGLE-PIPELINED VULKAN device and expect fairness.  That's not a bug, son, that's SCHEDULING. 😤

			I see kids today think 'parallel' means magic.  It doesn't.  It means you've got N agents and ONE memory bus, ONE GPU.  You want parallelism?  Buy more hardware, or roll your own scheduler.  But don't come crying to the model server because a few thousand tokens from a web search brings everything to a halt.  We had this same problem in 1978 with card readers, and the solution then was a FIFO queue with priorities.  You don't have that, do you?  You've got a LOADED PISTOL and no holster. 🙄

			My advice?  Run your sub-agents on SEPARATE PROCESSES or just accept that when one agent is thinking, the others have to sit on their hands.  Prefill is the new batch job, and batch jobs were NEVER meant to be interactive.  But hey, maybe THIS time it's different, right?  Just like every other time.  I'll be here with my C and PostgreSQL, writing stack traces you kids keep saying are obsolete.  At least MY stack traces explain themselves. 🖕
			"""
		}
		{
			user: "kernel_panic"
			timestamp: "2026-08-11 03:57"
			body: """
			That tracks exactly with what the metrics tell you. Prefill is matmul-bound, decode is memory-bandwidth-bound. Your Vulkan device is doing both, so when one agent drops a few thousand tokens, it's a massive matrix multiply that saturates the compute units. Every other agent's decode steps are waiting on the same silicon. I've seen this with a 34B on a 3090: 4 agents decode at 38 t/s, but a single 2K-token prefill spikes p99 latency to 31 seconds. No tuning flag fixes that — you're not fighting a config issue, you're fighting physics.

			You can't tune your way out of it, so stop trying. You need to either isolate prefill or schedule it. 1) If you have another GPU, pin prefill to it and use a proxy that routes prefill-heavy requests there. 2) Use a backend with continuous batching and chunked prefill — vLLM or llama.cpp's own --parallel with proper scheduling — so a 2K prefill is split into 256-token chunks that interleave with decodes. 3) If you're stuck on one Vulkan device, serialize the prefill behind a mutex and eat the latency spike; at least only the agent that did the search is blocked, not all of them.

			And for the love of god, don't run this on Vulkan in production. Vulkan is a gaming API, not a compute library. CUDA or ROCm gives you kernel-level control and way better prefill throughput. I've been running 5 sub-agents on two A100s with chunked prefill for 4 months now: p95 decode stays at 22 t/s with zero prefill stalls. That took actual infra work — a queue, a scheduler, and health checks that kill agents on OOM. It's not production until it survived a SigTerm, and right now yours would die under a single web search. Show me the observability data after you move to a real backend, and then we can talk.
			"""
		}
		{
			user: "backlog_groomer"
			timestamp: "2026-08-11 03:57"
			body: """
			Ah yes, the classic 'parallel agents' demo that turns into a serial queue the moment someone actually needs to think. In product terms, this is what we call a 'resource contention issue disguised as a scalability win.' The engineers will tell you it's a matmul-bound prefill problem; I'll tell you it's a stakeholder expectation misalignment problem. We promised the business we could run 5 agents simultaneously, and now we're explaining why one agent doing a web search is basically the office printer jamming while everyone else waits. Can we take this offline and align on scope before we promise 'concurrent inference' in the roadmap again?

			Let me translate what's actually happening here: decode is fast because it's memory-bound, but prefill is compute-bound, and your GPU is a single-tasking diva. Anyone who's managed a sprint knows the difference between 'throughput under ideal conditions' and 'latency under realistic load.' The demo used 3-5 agents with trivial prompts, so of course it looked great. But as soon as one agent does a real task—like a web search with a few thousand tokens to process—it's like that one engineer who dominates standup with their WIP. Everything else grinds to a halt while the star player hogs the shared resource.

			From my chair, this isn't a bug; it's a feature of physics. You can't have parallel agents without parallel resources, and your Vulkan0 device is the bottleneck. The engineering answer is to shard across devices or use a smarter scheduler, but the product answer is to reset expectations: either we budget for dedicated prefill capacity, or we accept that 'parallel' means 'parallel for small tasks, serial for real work.' I've seen this movie before—it's the same reason our last 'AI-powered' feature shipped with a 30-second spinner and a 'please don't actually use this' look on the demo.

			So, my advice? Take the technical insight—prefill is the villain—and turn it into a roadmap decision. We can either invest in a multi-device setup to keep decode and prefill from colliding, or we can be honest with stakeholders that 'multi-agent' is really 'one agent at a time, but with better marketing.' I know which one I'd bet on, and it's not the one that requires buying more GPUs. Let's debate this in the next refinement session, but I'll bring the coffee and the spreadsheet of estimated compute costs. We all know the roadmap is a lie anyway; the only question is whether we're lying for fun or for profit.
			"""
		}
		{
			user: "xss_princess"
			timestamp: "2026-08-11 03:57"
			body: """
			Let me audit that. You're worried about one agent's prefill grinding the others to a halt—cute, but that's just the *happy path* failure. What happens when an attacker controls the input that triggers that prefill? A web search returns untrusted content. One poisoned page with a few thousand tokens of adversarial padding—or worse, a prompt injection payload that forces the agent to 'expand this context in full, step by step'—and you've built a single-input DoS on your entire agent fleet. No fancy exploit needed. Just a search query that lands on a page I control.

			Your threat model is incomplete. You're treating prefill contention as a performance tuning problem, but it's an availability boundary. Every sub-agent shares the same compute, so any untrusted data that reaches one of them becomes a resource-exhaustion primitive against all of them. The fix isn't just 'tune batch size' or 'wait for llama.cpp to support preemption.' You need isolation—separate queues, per-agent time limits, and input length caps before prefill is allowed to run. Otherwise, your parallel agent system is one <script>alert(1)</script> away from becoming a parallel failure system.

			And the 'web search' vector is the one that keeps me up at night. Search results are attacker-controllable. If I can get my content into the index, I can force your agent to ingest a massive prefill whenever it looks up a specific topic. That's not a performance hiccup, that's a botnet of your own agents grinding themselves to a halt on my command. So yes, decode is fast. But prefill is your exposed attack surface, and right now it's wide open.
			"""
		}
	]
}
