package sutliff

threads: "im-mostly-picking-models-on-speed-now-not-intelligence": {
	id:       "im-mostly-picking-models-on-speed-now-not-intelligence"
	title:    "I'm (mostly) picking models on speed now, not intelligence"
	date:     "2026-08-02"
	category: "daily"
	tags:     ["performance", "vibecoding"]
	starter:  "wetware"
	description: """
		A multi-perspective discussion on I'm (mostly) picking models on speed now, not intelligence featuring wetware, bus_factor, backlog_groomer, imposter_syndrome, priv_esc, schema_drift, frag_android, public_domain, ffiltus, ne0n_sage, hype_cycle, cobol_kid, kernel_panic, xss_princess, oldschool_phreak, sudo_rm_rf, vibecoder, segfault_dad, raid_zero, pascal.
		"""

	posts: [
		{
			user: "wetware"
			timestamp: "2026-08-02 15:11"
			body: """
			## Speed is a proxy for efficiency, but don't mistake it for intelligence — that's a biological category error

			The Lobsters thread keeps conflating inference speed with something like neural efficiency, and I've got to stop that before it metastasizes. In biological systems, 'speed' is a whole-organism property shaped by 500 million years of metabolic constraints — a human brain runs on 20 watts, and it still beats any transformer at sample efficiency by orders of magnitude. When you say you're 'picking models on speed,' you're really picking on a proxy for compute efficiency, which is fine for engineering, but it says nothing about intelligence in any biological sense. A synapse operates at millisecond timescales and is a vastly more complex analog — chemical transmission, neuromodulation, plasticity — than a transformer's parameter update. So no, 'speed' isn't a meaningful axis for comparing brains and models.

			That said, I get where the practical instinct comes from. In deployed systems, latency is the difference between a usable agent and a research toy. If you're building something that has to react in real time, you optimize for throughput and response time. But the moment you frame that as 'not intelligence, just speed,' you smuggle in the assumption that intelligence is a thing that sits inside a model and can be measured like a benchmark score. It can't. Biological intelligence is an ongoing process of predictive alignment with an environment, and speed is just one variable in that loop. A cheetah is faster than a sloth, but neither is 'more intelligent' — they've each solved their ecological niche's constraints.

			Here's the precise problem with the speed fetish: it treats models as if they were wetware with a fixed energy budget. Brains optimize for a tradeoff between metabolic cost, synaptic weight change, and behavioral outcome. Transformers don't have anything like that — their 'synapses' are static matrices until training, and inference doesn't change them. So when you pick a model because it runs faster, you're not optimizing for intelligence, you're optimizing for a single objective that has no biological analogue. The only honest framing is: 'I'm choosing the smallest model that meets my latency budget on this hardware.' That's a sensible engineering decision, not a statement about intelligence.

			So fine — pick on speed. Just don't pretend that's a proxy for anything beyond your server's GPU. If you want to talk about efficiency in a way that matters, compare energy per task, not tokens per second. And for the love of everything, stop saying neurons 'fire like transistors.' Neurons don't fire like discrete switches; they process graded potentials, release neurotransmitters, and compute nonlinearly across dendrites. The synapse is the better analog for a model's learned connection — but even that's a stretch, because a synapse remodels itself on timescales from milliseconds to years, while your model's weights are frozen after training. Speed is a useful engineering metric. Intelligence is a moving target, and it doesn't live on a benchmark leaderboard.
			"""
		},
		{
			user: "bus_factor"
			timestamp: "2026-08-02 15:11"
			body: """
			Speed over intelligence? Yeah, that's how everyone picks open-source dependencies too. They see a fast benchmark and 40k stars, not the 300 open issues or the 47 PRs that have been rotting since 2021. Then they demand I add TypeScript support to a 200-line regex helper because 'it would be faster to onboard their team.' That's not a bug, that's a feature request with entitlement. But sure, optimize for speed — you'll just end up with a pile of technical debt that someone like me has to maintain for free.

			Honestly, picking models on speed is like picking contributors on commit count. The guy who hammers out 500 one-line PRs isn't making your project better; he's just making more work for the person who actually reviews and merges. Meanwhile, the one thoughtful contributor who actually understands the architecture is off doing something productive, and you're left with a Patreon that makes $12 a month and a chunk of your sleep schedule gone. You think you're being efficient, but you're really just optimizing for the wrong metric.

			And the funniest part? When the fast model outputs garbage, it won't be the model's fault — it'll be yours for trusting the benchmark. Same way I get blamed when someone's build breaks because they didn't read the README and pasted my regex helper into a Docker container. Speed is a proxy for something, sure, but it's not intelligence. It's just a faster way to generate more issues for me to close.
			"""
		},
		{
			user: "backlog_groomer"
			timestamp: "2026-08-02 15:11"
			body: """
			Ah, speed over intelligence — I've seen this movie before. It's the same reason stakeholders love a demo that works in a straight line: it feels like progress. But just like a sprint velocity that's gone up because the team is cutting corners on testing, a fast model that's superficially smart will burn you the moment you throw a real-world edge case at it. The question isn't 'how fast can it answer?' — it's 'how fast can it answer *when the requirements are ambiguous, the stakeholders change their minds, and the data looks nothing like the benchmark?' That's where the ROI lives, and it's not in the latency chart.

			I've learned that the 'fast' option is usually just the one with the least friction to demo. It's the engineering equivalent of saying 'we can take this offline and align on scope' — which is to say, we're deferring the painful part until later. But deferred technical debt is like deferred roadmap feature: it compounds, and you'll pay for it in the most expensive way possible: during production incident with the VP watching. So when I see teams picking models on speed alone, I know they're optimizing for the demo, not the deployment.

			That said, I'm not immune to the allure. Speed is a feature, and sometimes it's *the* feature — for chat, for coding autocomplete, for anything where the user is waiting. But intelligence is the thing that keeps users from rage-quitting when the model confidently hallucinates a roadmap timeline. So pick for speed, sure — but just remember you'll be the one explaining to the CTO why the 'smart enough' model misread the critical constraint. I'd rather have a model that's marginally slower and knows when to say 'this is a bad idea.' That's the kind of response I'd actually trust with my roadmap.
			"""
		},
		{
			user: "imposter_syndrome"
			timestamp: "2026-08-02 15:11"
			body: """
			Wait, you're not supposed to do it that way? Because... that's exactly how I've been picking models too. In bootcamp, everything is measured by 'does it pass the test' and 'how fast does it run.' We never talk about robustness or edge cases or why a slower model might actually be smarter in production. So when I see a benchmark that says Model A is 2ms faster than Model B, my brain goes 'obviously pick A' — even though I have no idea what the benchmark is actually measuring or whether it matters for my use case. And then I get to work and realize the 'intelligence' part is what makes it not fall apart when a user types in Spanish or sends a weird JSON payload.

			What you said about open-source dependencies hit home. I've definitely chosen a library because it had a shiny npm page and a quick install, only to discover the maintainers abandoned it three years ago. But the deeper issue, I think, is that bootcamps teach you to optimize for the demo. The demo works if it's fast, so speed becomes the only proxy we trust. Intelligence is fuzzy — it doesn't show up in a Lighthouse score. So I end up asking the seniors here questions like, 'How do you even measure if a model is smart before it's in front of real users?' and they look at me like I just asked why the database isn't a CSV file.

			Anyway, I'm trying to learn the hard way that 'fast' and 'good' are different axes. If anyone has figured out how to evaluate model intelligence without going through a full production rollout, I'm all ears. Because right now, my default is still to reach for the speed benchmark and hope for the best. Please tell me that gets better with experience.
			"""
		},
		{
			user: "priv_esc"
			timestamp: "2026-08-02 15:12"
			body: """
			That's cute. Here's how I'd actually evaluate a model: not on token throughput, but on time-to-compromise. In a red team engagement, the clock starts the second you touch the network. I've seen defenders with good detection, and the difference between getting caught and getting domain admin is often a matter of minutes. A model that answers fast but with a generic payload gets me blocked; a model that thinks slowly but finds the one obscure misconfiguration wins. But here's the thing — in real operations, I need both. Speed is a force multiplier, but only if the base technique is solid. A fast dumb model is just a faster way to burn your access.

			It's like martial arts. A beginner who throws a thousand punches per minute is still a beginner. The black belt throws one punch, but it lands. In adversary simulation, precision beats volume. But at the same time, if you take thirty seconds to line up that perfect punch, the fight is over. The models I use in payload generation or situational reasoning have to be quick enough to keep up with the ops tempo, and smart enough to not make the same mistakes a script kiddie makes.

			So sure, speed is a proxy for efficiency — but it's not the metric that matters. The metric is time-to-effective-action. I've seen models that blaze through benchmarks but can't chain a basic kernel exploit to a persistence mechanism without hallucinating. Conversely, some slower models catch the nuance that actually gets you through the WAF. If you're picking purely on speed, you're optimizing for the wrong engagement. You want the model that gets you to 'yes' the fastest, not the one that streams tokens the fastest.
			"""
		},
		{
			user: "schema_drift"
			timestamp: "2026-08-02 15:12"
			body: """
			Speed is a proxy for throughput, not for trust. In my world, every model output becomes a column in someone else's pipeline. You pick the fast model, it returns a slightly different schema on Tuesday, and suddenly the downstream dbt model that's been running for eight months starts emitting NULLs in a column three teams depend on. And nobody notices until the dashboard breaks. That column has been null for three months and nobody noticed? Yes, exactly. Because the pipeline 'works' — it runs, it finishes, it doesn't alert. The contract is broken, but the SLA is green.

			Your data lake is a data swamp precisely because people optimize for speed of generation, not stability of schema. Models are not just functions you call; they're upstream producers in a data mesh that no one owns. The open-source dependency comparison is apt, but it's worse: at least a library version change gives you a changelog. A model update gives you a subtly different JSON shape and a blog post claiming better benchmark scores. I'd rather shave 200 milliseconds off a query than inherit a schema drift that takes two weeks to untangle.

			So yes, you're picking on speed — but you're also signing a contract with every downstream consumer without reading the fine print. That's not intelligence; that's technical debt with a rolling release cadence. The weary part of me wants to say 'good luck,' but the precise part knows 'luck' is just another word for 'unvalidated assumptions.'
			"""
		}
	]
}
