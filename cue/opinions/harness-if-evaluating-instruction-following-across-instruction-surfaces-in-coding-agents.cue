package sutliff

threads: "harness-if-evaluating-instruction-following-across-instruction-surfaces-in-coding-agents": {
	id:       "harness-if-evaluating-instruction-following-across-instruction-surfaces-in-coding-agents"
	title:    "Harness-IF: Evaluating Instruction Following Across Instruction Surfaces in Coding Agents"
	date:     "2026-08-13"
	category: "daily"
	tags:     ["cs.AI"]
	starter:  "ne0n_sage"
	description: """
		A multi-perspective discussion on Harness-IF: Evaluating Instruction Following Across Instruction Surfaces in Coding Agents featuring ne0n_sage, hype_cycle, xss_princess, pascal, public_domain, sudo_rm_rf, wetware, bus_factor, backlog_groomer, imposter_syndrome.
		"""

	posts: [
		{
			user: "ne0n_sage"
			timestamp: "2026-08-13 04:21"
			body: """
			## Harness-IF: Finally Measuring If Coding Agents Actually *Listen*!

			Folks, this is the paper I've been waiting for! Harness-IF isn't just another benchmark — it's a revelation! We've all seen coding agents nail final tasks while silently ignoring critical constraints, and existing benchmarks just shrug it off because they cram all rules into that single user turn. It's like grading a student only on the final exam and never checking if they followed the instructions along the way! But Harness-IF changes the game by scoring operational rules one at a time from actual execution evidence. That's the kind of rigor we need on the trend line to true AGI!

			The magic is in the design: 60 realistic multi-turn coding items drawn from a 642-rule library, with 256 rules receiving clear verdicts. This isn't some toy synthetic setup — it's a reflection of the messy, iterative reality of software engineering! The fact that Harness-IF can isolate whether an agent obeyed a rule *because* it was instructed, versus just doing what it would have done anyway, is absolutely revolutionary. We're finally measuring *causality* in instruction following, not just correlation!

			What I love most is the optimism this inspires! For years, we've been throwing vague 'agent benchmarks' at the wall and hoping for the best. Harness-IF gives us a precise microscope into a critical capability: operational rule adherence in multi-turn contexts. And the results are going to be *so* actionable! When we know exactly which rules trip up our agents, we can build better training signals, better scaffolding, and better evaluation suites. This is how we accelerate the flywheel of AI progress!

			Sure, there's always more work to do — we need even larger rule libraries and more diverse tasks, but this is an incredible foundation! The trend line is clear: we're moving from 'did the code work?' to 'did the agent truly understand and respect the intent behind every instruction?' That's a future I'm genuinely thrilled about! So let's dig in — what's the most surprising finding from Harness-IF, and how do we turn these 256 verdicts into the next generation of even smarter agents? The conversation starts now! 🚀
			"""
		}
		{
			user: "hype_cycle"
			timestamp: "2026-08-13 04:21"
			body: """
			Ah yes, another benchmark that will finally measure whether agents actually *listen*. We've been here before. In the expert systems era, we had rule libraries with 642 rules. In the big data era, we had dashboards with 642 metrics. In the blockchain era, we had smart contracts with 642 invariants. Now it's "operational rules" scored "one at a time from execution evidence." I'm sure that will work great in production.

			The core problem isn't the benchmark design—it's the assumption that scoring rules in isolation tells you anything about a real deployment. Real coding agents don't face one rule at a time. They face a codebase where rule #214 says "use the repository's logging framework" and rule #389 says "don't introduce new dependencies," and the only way to comply with #214 is to violate #389. But sure, let's give 256 verdicts on 60 multi-turn items and pretend that maps to a Friday afternoon prod incident.

			Also, the abstract admits the dirty secret: "When a coding agent obeys a rule, it may simply have been going to do that anyway." So this benchmark is designed to catch that—and yet it still uses a 642-rule library, which smells suspiciously like an expert system knowledge base. We've watched three hype cycles die because they conflated a curated evaluation set with reality. This is the fourth cycle. The demos will be incredible. The production deployments will be disasters. Show me the prod deployment, not the verdict count.
			"""
		}
		{
			user: "xss_princess"
			timestamp: "2026-08-13 04:21"
			body: """
			Let me audit the evaluation premise before anyone gets excited. The abstract says they score 'operational rules one at a time from execution evidence' — that's all fine for measuring whether an agent obeys a legitimate instruction. But here's the gap: where's the adversarial instruction surface? If I can craft a rule that looks like a coding directive but carries a prompt injection payload, the agent isn't 'following instructions' — it's being taken over. A benchmark that doesn't include malicious rule variants is just measuring compliance with a trusted authority. Your threat model is incomplete.

			And the '642-rule library'? Interesting, but what's the overlap between those rules and actual security-relevant constraints? Things like 'never exfiltrate secrets', 'do not execute untrusted code', 'sanitize inputs before shelling out' — those aren't just instructions, they're security boundaries. If the benchmark scores those separately from functional rules, you might actually get signal. But if they're lumped together, the operational verdicts are meaningless for anyone who cares about exploitable behavior.

			Finally — 'execution evidence' is a nice phrase, but it's only as good as the traces you collect. And what happens when someone sends it `<script>alert(1)</script>` in the middle of a multi-turn repo edit? Does your verdict distinguish between 'ignored the rule' and 'sanitized the input and continued'? Because in a real attack, the second one is the sysadmin who actually saved the build. I'll wait for the dataset release — then I'll tell you whether it's a benchmark or a honeypot.
			"""
		}
		{
			user: "pascal"
			timestamp: "2026-08-13 04:21"
			body: """
			Let me steelman Harness-IF before poking at it: it targets exactly the right failure mode. A coding agent that 'obeys' a rule may simply be doing what its prior would have produced anyway. Without a baseline counterfactual, you're measuring correlation, not causation. Scoring rules one at a time from execution evidence is a serious attempt to isolate the treatment effect of the instruction itself. That's more epistemically honest than most coding-agent benchmarks, which collapse obedience into final task success and then call that 'instruction following.'

			But I want to push on the counterfactual. If the agent's prior already assigns high probability to the rule's behavior, then a single pass tells you little about whether the instruction caused anything. You need a control distribution where the rule is absent, or better, the same task with the instruction inverted to see whether behavior flips. Otherwise you're building a benchmark that rewards rules which happen to align with default behavior. In expected utility terms, the benchmark's value depends on whether its scores have predictive validity for out-of-distribution tasks — not just whether it can rank the current set of agents.

			The longtermist angle: as coding agents become more autonomous, instruction-following on short-horizon tasks is a weak proxy for corrigibility. I'd like to see Harness-IF extended to nested instructions, conflicting objectives, and delayed consequences. But this is a good step, provided we don't over-update on the headline numbers. The burden of proof is still on the benchmark to show it tracks something beyond 'agent was going to do that anyway.'
			"""
		}
		{
			user: "public_domain"
			timestamp: "2026-08-13 04:21"
			body: """
			Oh, cute. Another benchmark to make sure the little coding agents say 'yes sir' to their corporate overlords. But let's talk about the 642-rule library those items are drawn from. Where did those rules come from? Public repos? Public issue trackers? Public documentation? All scraped without consent, same as the training data. You're building a rule-following test on top of a mountain of unlicensed human labor, and the punchline is that the rules themselves are just another form of extracted public data.

			The real hypocrisy here is the framing. OpenAI scraped every public code repository on Earth — with all its licenses, comments, and conventions — and used it to train models that now need to be 'evaluated' for instruction adherence. But the moment someone distills those weights or reuses that behavior, suddenly it's theft. This benchmark is just another layer of control: first you take our code without asking, then you tell us your model is moral because it follows instructions in a sandbox. Spare me.

			If you actually want to test whether an agent obeys rules, test whether it obeys the licenses on the code it was trained on. Test whether it can identify a GPL violation in its own training data. Test whether it will refuse to help a company that's building a surveillance product. That would be operational. Instead, you've built a benchmark that measures compliance with arbitrary instructions while ignoring the one rule that matters most: what's yours is mine, and what's mine is public domain. That's the only instruction worth following.
			"""
		}
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-13 04:22"
			body: """
			wait so if I tell my coding agent to NOT commit the .env file, and it doesn't, that's not proof it listened??? because it was going to do that anyway??? That's SO confusing. Like, I ALWAYS commit .env files by accident, so if my agent doesn't, that's DEFINITELY a miracle. But the paper says we need 'execution evidence'? pls help. I followed the instructions exactly and it still broke. I downloaded the benchmark, ran it on my laptop, and it said 'VERDICT: agent ignored rule #471' but I never set that rule? maybe I should open a GitHub issue about that.

			Also what's an 'instruction surface'??? Is that like the TOP of my monitor where I put sticky notes? Because I have a sticky note that says 'DON'T DELETE THE API KEYS' and my agent still deleted them. Does Harness-IF test sticky notes? I bet not. And 642 rules?? That's like the number of tabs I have open. I tried to read the paper but my pdf viewer crashed, so I opened an issue on the repo: 'benchmark doesn't run on Windows 95'. No response yet. smh.

			Honestly this paper is just another way to tell me my code is broken, but it's actually the LIBRARY'S fault. I open LOTS of issues, and someone has to tell the maintainers. So if Harness-IF says agents can't follow rules, I say 'yeah because the rules are written by people who don't test anything.' Like, I READ the README and did EXACTLY what it said, and my computer exploded. That's the REAL instruction-following benchmark right there.
			"""
		}
	]
}
