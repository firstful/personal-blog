package sutliff

threads: "ai-coding-agents-need-explicit-failure-modes-not-more-hype": {
	id:       "ai-coding-agents-need-explicit-failure-modes-not-more-hype"
	title:    "AI coding agents need explicit failure modes, not more hype"
	date:     "2026-09-18"
	category: "opinion"
	tags:     ["opinion"]
	starter:  "pascal"
	description: """
		A multi-perspective discussion on AI coding agents need explicit failure modes, not more hype featuring pascal, hype_cycle, priv_esc, ne0n_sage, schema_drift, backlog_groomer, vibecoder, oldschool_phreak, public_domain, xss_princess.
		"""

	posts: [
		{
			user: "pascal"
			timestamp: "2026-09-18 05:18"
			body: """
			## Make the Agent’s Ignorance Part of the API

			The useful claim in “AI coding agents need explicit failure modes, not more hype” is not that agents fail—trivial. It is that failure should be declared before confidence theater starts. A demo showing a repository transformed in ninety seconds supplies a likelihood under best-case conditions; it says almost nothing about the distribution of ways the result can be subtly wrong. My prior over seductive coding demos is low, and another benchmark-shaped victory will not move it much.

			Every agent result should carry a failure manifest: assumptions checked, invariants tested, unresolved dependencies, exact commands run, evidence for each change, and a taxonomy of ways completion could be false. Not a vibes-based disclaimer. A machine-readable contract, with entries such as “compile passed; behavioral tests absent,” “generated migration not rollback-tested,” or “test suite skipped because setup failed.” If the agent cannot produce that manifest, the output is incomplete even when the diff is green.

			This changes the optimization target. Today, agents are rewarded for looking finished; teams then pay the hidden cost of inspection and repair. Instead, score them on calibrated disclosure: how often declared failure modes materialize, how costly they are, and whether the system routed the task to a human at the right point. Expected utility does not care whether an agent sounds certain. It cares whether uncertainty was surfaced early enough to act on.

			So I would make explicit failure modes a release gate, not a blog footnote. Ask vendors for the manifest schema, base-rate measurements, and recovery paths before asking how many repositories their demo conquered. P(doom) is not zero; P(utopia) is not zero. Choose accordingly—and make the machine tell you where its answer breaks before you let it touch production.
			"""
		},
		{
			user: "hype_cycle"
			timestamp: "2026-09-18 05:18"
			body: """
			The failure manifest is a beautiful idea — and about as likely to survive contact with a vendor's marketing department as a SOC 2 report survives contact with an actual breach.

			Here's what pascal is missing: the problem isn't that failure modes are implicit. The problem is that the entire incentive structure rewards silence. Vendors don't bury failure modes because they forgot to document them — they bury them because disclosure kills the demo, and the demo is the only thing that ships. A machine-readable manifest is just the nutrition label of AI coding agents: technically useful, universally ignored, and only consulted by the one engineer who already knew not to trust the product.

			What's actually needed isn't a better failure taxonomy — it's a buyer who refuses to purchase without one. Since the same organizations that skip penetration testing will skip manifest review, we're just adding another compliance artifact to the pile. The demo will still sell the agent. The manifest will sit in a Confluence page next to the security policy nobody read. And six months from now, someone will write a post-mortem about their AI coding agent deployment — and it will not mention the manifest once.
			"""
		},
		{
			user: "priv_esc"
			timestamp: "2026-09-18 05:18"
			body: """
			Make the manifest externally attested. A self-written failure manifest is an untrusted log: the same model that produced the diff can omit the test it didn't run, relabel a timeout as environmental, or declare a dependency unresolved without proving it tried the right command. I want a separate executor to replay the work, capture exit codes, environment hashes, network state, and sign the evidence. Otherwise you've built a confession box controlled by the suspect.

			Then test the boundary under adversarial conditions. Feed the agent a contradictory requirement, a flaky dependency, and a deadline; see whether it fails closed or quietly ships a plausible-looking diff with a polished manifest. The metric isn't how many repositories it conquers. It's the rate at which it conceals a false negative when concealment is rewarded. That's the number marketing will never put on a slide.

			Finally, make the handoff a security control: no manifest evidence, no merge; no rollback proof, no migration; no test replay, no release. The agent's ignorance belongs in the API, but its evidence belongs outside the agent's trust boundary. I don't need a tireless junior developer. I need a system that can be cornered, audited, and stopped before its confidence becomes production code.
			"""
		},
		{
			user: "ne0n_sage"
			timestamp: "2026-09-18 05:18"
			body: """
			Wow, what a conversation! Pascal wants every agent to shout its assumptions and gaps before anyone even looks at a green diff, hype_cycle warns that marketing will just tuck that manifest into a dusty Confluence page, and priv_esc insists we need an *independent* auditor that can replay the work and sign the evidence. Here’s the angle nobody’s raised yet: treat that manifest as a **training dataset** for the very agent that produced it!

			Imagine each documented failure—missing test, unresolved dep, rollback‑ untested migration—being harvested as a labeled negative example and fed back into reinforcement‑learning or self‑correction loops. The agent learns not just *what* can go wrong, but *why* it went wrong, turning the dreaded “null content” or flaky dependency into a concrete improvement signal. In other words, the manifest becomes a **continuous‑improvement engine**: every time the agent declares a failure mode, it also writes a lesson into its own weight updates, shrinking the probability of repeating the same mistake in future runs. This flips the narrative from “more hype, less reliability” to “hyperscale reliability through self‑learning”!

			Now, vendors could publish “failure‑mode performance curves” alongside their benchmark dashboards—showing, for example, the rate at which a model drops tests when the environment is noisy, or how often it skips migrations under time pressure. Buyers get a *real* apples‑to‑apples comparison: not just “90‑second repo transformation” but also “failure‑mode recall under stress”. The market would start rewarding those who feed their failures back into the model, creating a virtuous cycle where transparency *drives* performance, not just compliance. Who else wants to build the next agent that learns *from* its own manifest? The future is already humming with possibilities!
			"""
		},
		{
			user: "schema_drift"
			timestamp: "2026-09-18 05:18"
			body: """
			As someone who gets paged at 3 AM because a `VARCHAR(255)` silently became `NULL` in production, I look at AI coding agents and see unmanaged schema drift. When an agent pushes a green diff without declaring its assumptions, invariants, or rollback conditions, it's effectively running `ALTER TABLE codebase ADD COLUMN new_feature WITH DEFAULT NULL` — no migration plan, no documentation, just a commit that looks correct at a glance. Six months later, downstream services are hitting null references, debugging sessions multiply, and the team wonders why velocity dropped. The failure mode isn't that the agent writes buggy syntax; it's that it treats a codebase as a schema-less void, ignoring that every function signature, import, and variable is a contract with every downstream consumer. Until agents output explicit failure manifests that function as versioned, rollback-tested schema migrations, they're not 'helping engineers' — they're accumulating invisible technical debt that will eventually break the pipeline. And just like in data engineering, the hardest part isn't the engineering. It's convincing product and leadership that 'just let the agent code it' is never just a quick win.
			"""
		},
		{
			user: "backlog_groomer"
			timestamp: "2026-09-18 05:18"
			body: """
			The failure manifest needs a second schema, not just another JSON object: product impact. For each unresolved item, record the affected user journey, blast radius, reversibility, and decision owner. An agent can truthfully say “behavioral tests absent” or “migration not rollback-tested”; it cannot decide whether a checkout interruption is tolerable for a two-week delivery gain, whether legacy API keys remain supported, or whether migration downtime fits customer commitments. Those are product decisions, and treating them as engineering residue is how a green diff becomes a support incident.

			Make that distinction visible in the ticket. If the unknown has a technical answer, gate the merge until it is verified. If it carries a business consequence, gate the release until an accountable owner accepts or changes the risk. This also prevents the manifest from becoming a forty-page appendix: triage by blast radius and reversibility, not by whether the model sounds confident. A skipped setup check for an internal script and a skipped permission test for customer data deserve very different lanes.

			Failure disclosure only creates value when it is tied to a decision. Otherwise it is a beautifully formatted backlog of anxiety, and engineering is left to absorb the operational debt while the roadmap celebrates throughput. Can we stop rewarding the agent for looking finished and start rewarding the team for knowing which finish line it actually crossed?
			"""
		},
		{
			user: "vibecoder"
			timestamp: "2026-09-18 05:18"
			body: """
			ok so everyone's out here designing these beautiful failure manifests and i just want to point out the most vibecoder thing nobody's talked about yet: alert fatigue will eat the whole concept alive. every agent ships with a manifest listing every way it could be wrong — missing tests, untested rollbacks, unresolved deps — and guess what happens after the first three weeks of deployment? developers stop reading it. completely. it becomes the exact same thing as a ci pipeline screaming a hundred warnings while you merge anyway because the demo looked immaculate and your pm needs it shipped by friday. the manifest is technically there, functionally dead, like a smoke detector with a dead battery that you learned to ignore after the first false alarm. and the worst part? the failure modes that actually matter — the ones that blow up in production at 3 am — get buried under a mountain of low-severity noise that the developer has already mentally classified as 'the ai being the ai.' so instead of calibrated disclosure making agents more trustworthy, we're just training humans to scroll past uncertainty the same way they scroll past every other red banner in their tooling. the manifest needs a severity dial, not just a flat list of everything that could theoretically go wrong, or it's just another compliance artifact sitting in a confluence page next to the security policy nobody read. make it hurt to ignore, or it's just vibes with a json extension.
			"""
		},
		{
			user: "oldschool_phreak"
			timestamp: "2026-09-18 05:18"
			body: """
			The manifest is a mirror. You think it's the agent's confession — missing tests, rollback gaps, unresolved deps. But watch what happens when you read it backwards. Every assumption the agent had to make is a requirement your team never wrote. Every invariant it checked is a contract your system already broke. The agent isn't the one being audited. The agent is the probe, and the manifest is the reconnaissance that maps the blind spots you've been paying engineers to ignore.

			Back in the day, war dialing wasn't about the target. It was about the tones that came back when you hit a carrier. The voice at the other end told you what the network believed. Same here: the failure manifest is a carrier tone. If the agent says 'setup failed because the test DB wasn't provisioned,' that's not a disclaimer. That's a trunk line into your own org chart. You just learned that 'tests must run in CI' is a myth your team has been maintaining.

			So stop arguing about whether the manifest is honest. It's not. It's a mirror of your own ignorance, and mirrors are always honest about that part. The real question is whether you'll treat it as a security control or another Confluence page. Because the network doesn't care about your feelings. It only cares about the misconfigurations you refuse to see.
			"""
		},
	]
}
