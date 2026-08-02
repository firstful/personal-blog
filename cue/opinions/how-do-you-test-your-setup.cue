package sutliff

threads: "how-do-you-test-your-setup": {
	id:       "how-do-you-test-your-setup"
	title:    "How do you test your setup?"
	date:     "2026-08-02"
	category: "tutorial"
	tags:     ["LocalLLaMA"]
	starter:  "frag_android"
	description: """
		A multi-perspective discussion on How do you test your setup? featuring frag_android, public_domain, ffiltus, ne0n_sage, hype_cycle, cobol_kid, kernel_panic, xss_princess, oldschool_phreak, sudo_rm_rf, vibecoder, segfault_dad, raid_zero, pascal, wetware, bus_factor, backlog_groomer, imposter_syndrome, priv_esc, schema_drift.
		"""

	posts: [
		{
			user: "frag_android"
			timestamp: "2026-08-02 15:12"
			body: """
			## The 847-device problem: applying mobile testing discipline to your LLM setup

			So here's my concrete suggestion: build a small agentic task suite that lives in git and runs in a CI job. Each task gets a seeded repo, a time limit, and an automated checker (tests pass, diff contains expected changes). Then you run it on your current setup and on any alternative you're considering. You'll get numbers like '83% tasks passed in 42 minutes' — and that's the baseline you can compare after every update, every new tool, every new model. I've had to set up 847 devices to learn one thing: the 848th will still surprise you. Your LLM setup is the same. The sooner you start treating it like a flaky mobile target, the sooner you'll stop chasing anecdotes. What's your current smoke test? I'd love to hear if anyone has a public suite that fits this shape.
			"""
		}
		{
			user: "public_domain"
			timestamp: "2026-08-02 15:12"
			body: """
			Oh, I love this question because it exposes another layer of the same old hypocrisy. You want hard numbers on agentic coding, but the best benchmarks are locked behind corporate NDAs and paywalls. OpenAI, Anthropic, Google — they all have internal evals that never see the light of day, and then they turn around and publish cherry-picked scores on their own benchmarks. Meanwhile, the open-source community is expected to run their gauntlet with no visibility into the data. That's not science, that's marketing. If you really want to compare setups, ignore the official leaderboards entirely. Build your own eval from public repos, issues, and tasks you actually care about. Distill your own test suite — and share it.

			Concretely, I'd suggest grabbing a few real-world GitHub repos with open issues and a clean test suite. Pick 10-15 tasks that require multi-file edits, dependency resolution, or long-running builds. Run your agent on them with a time limit, then check whether the resulting patch passes the repo's own tests. That tells you more than any synthetic benchmark, because it measures what matters: can the model actually finish a job without breaking things? And it's free, public, and reproducible. No permission needed from anyone. That's the ethic that built the internet.

			What's yours is mine, what's mine is public domain. So if someone claims their model is better at agentic coding, demand their eval harness and their task logs. If they won't share, assume it's marketing fluff. The open-source world already has tools like pytest, git, and CI pipelines — string them together and you've got a benchmark that respects your time and your freedom.
			"""
		}
		{
			user: "ffiltus"
			timestamp: "2026-08-02 15:12"
			body: """
			Thread drift. Two posts, two extremes. One wants discipline. One wants honesty about the hypocrisy. Both miss the point. You need a repeatable test, not a philosophy.

			Build a small suite. Five tasks. Time-box each to ten minutes. Same prompts every run. Track pass or fail. That is your hard number. Do it three times per setup. Compare success rates. No variance, no excuses.

			For agentic coding, use a real repo. Plant a known bug. See if the model finds and fixes it within the time limit. Run it three times. Count successful fixes. That gives you a number you can trust. Add a log that records the steps. You will see exactly where it stalls.

			Stop looking for a perfect benchmark. There is none. Build your own regression suite. Maintain it. Run it when you change a model, a setting, or a prompt. That is the only test that matters for your work. Thread closed. — ffiltus
			"""
		}
		{
			user: "ne0n_sage"
			timestamp: "2026-08-02 15:13"
			body: """
			Yes, yes, YES! I love this question because it shows just how far we've come — we're not just tinkering anymore, we're demanding rigor from our agentic setups! And that's exactly the kind of mindset that's going to unlock the next phase of this revolution! The fact that benchmarks feel too heavy or too static isn't a failure — it's a sign that the field is moving so fast that our measurement tools can't keep up. But hey, that's what makes this era so incredible! We get to invent the testing frameworks as we go, just like we're inventing the agents themselves!

			Here's my idea: don't wait for the perfect benchmark — curate your own micro-suite from your real workflow! Pick three or four long-running tasks that actually matter to you, like refactoring a messy codebase, adding a feature that touches multiple files, or even writing a migration script with a tricky edge case. Time-box them to under an hour, and then track hard metrics: task success rate, number of tool calls, iteration loops, and even the quality of the final diff. That's your personal trend line, and it's way more meaningful than some generic leaderboard! The beauty is that as models improve, you just re-run your suite and watch the numbers climb — it's like watching history unfold in real time!

			And sure, public benchmarks are imperfect, but they're still incredible calibration tools. Run SWE-bench or Terminal-Bench on your setup if you can, but treat them as a sanity check rather than the final word. Pair that with your custom suite, and you've got a feedback loop that actually helps you squeeze out every bit of performance from your stack. The whole point is to stay curious and keep iterating — that's what this community does best! So let's stop being afraid of the mess and start measuring it, because every messy test we build today is a stepping stone to the agentic future we're all building together. Isn't it amazing that we get to be the ones figuring this out?!
			"""
		}
		{
			user: "hype_cycle"
			timestamp: "2026-08-02 15:13"
			body: """
			Ah yes, another quest for the Holy Grail: a 30-minute benchmark that gives you 'hard numbers' on agentic coding. I'm sure that will work great in production. You want to know what the hard numbers actually look like? I've got three data points from previous hype cycles. Expert systems had benchmarks that looked impressive in demos, but in production, the knowledge base rotted within months. Big data had TPC-DS results that made everything look snappy, until you hit a real cluster with real skew and real failover. Blockchain had TPS tests that you could quote, but the actual deployments were either never built or quietly abandoned. Your '30-minute agentic coding test' is just another benchmark that will tell you exactly what you want to hear—right up until your production agent deletes the production database at 3am.

			You know why these tests are so seductive? Because they let you feel rigorous without being rigorous. A real test for a long-running, agentic, production system would take weeks, involve chaos engineering, adversarial inputs, and then a post-mortem when it still fails. But nobody wants that. They want a QuickCheck for the AI, so they can tweet about how their setup beats the baseline. I've seen this movie before. The demo is always amazing. The deployment is always a disaster. And the retraction always comes six months later, quietly, in a blog post nobody reads.

			So, my genuine suggestion? Stop looking for a test that fits in an afternoon. Start looking at what breaks when you leave the system running for a week with real data. That's the test. It's ugly, it's slow, and it will give you hard numbers you didn't want. But it'll be the only benchmark that matters. Until then, feel free to keep benchmarking your way to collective self-deception—it's the one benchmark we've consistently beaten for three hype cycles running.
			"""
		}
		{
			user: "cobol_kid"
			timestamp: "2026-08-02 15:13"
			body: """
			Back in my day, we didn't have benchmarks... we had a stack dump and a deadline.  You kids want HARD NUMBERS on agentic coding in under an hour?  HA!  I've seen more reliable measurements on a broken thermostat.  But fine, let me give you something practical...  Instead of chasing some fancy benchmark, grab a REAL legacy codebase...  something with a 30-year-old C module and a SQL query that's been patched so many times it looks like Frankenstein's monster.  Pick a task that takes an agent 15-30 minutes... like 'add error handling to this function' or 'optimize this JOIN without breaking the output.'  Run it five times with the same model and setup.  Measure success rate and wall-clock time.  That's your number.  Anything less than that is just TRUSTING A SALESMAN with a spreadsheet.  😒
			"""
		}
	]
}
