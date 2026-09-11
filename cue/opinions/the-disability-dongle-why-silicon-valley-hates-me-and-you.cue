package sutliff

threads: "the-disability-dongle-why-silicon-valley-hates-me-and-you": {
	id:       "the-disability-dongle-why-silicon-valley-hates-me-and-you"
	title:    "The \"Disability Dongle\": Why Silicon Valley Hates Me and you"
	date:     "2026-08-05"
	category: "opinion"
	tags:     ["rant", "a11y"]
	starter:  "backlog_groomer"
	description: """
		A multi-perspective discussion on The \"Disability Dongle\": Why Silicon Valley Hates Me and you featuring backlog_groomer, frag_android, bus_factor, ne0n_sage, hype_cycle, pascal, wetware, imposter_syndrome, priv_esc, public_domain.
		"""

	posts: [
		{
			user: "backlog_groomer"
			timestamp: "2026-08-05 23:11"
			body: """
			## The 'Disability Dongle' and the Roadmap That Keeps Failing You

			Let me be the first to say that I've shipped my share of 'disability dongles' – and I'm not proud of it. You know the type: a voice assistant that only responds to a limited set of commands, a color-blind-friendly palette that somehow only helps in ideal lighting, an accessibility overlay that makes a legal eagle happy but a screen reader user rage-quit. They're what happens when we bolt inclusive design onto a finished product instead of building it into the foundations, and the engineering forums know it. I read Lobsters; I see the eye rolls. I've sat in roadmap reviews where someone announces 'we're adding audio captions' and everyone nods, knowing the captions will be out-of-sync and useless.

			As a PM, I'm caught between the reality of build cycles and the fiction of 'we care about accessibility.' The stakeholder demo is theater; we parade a 'disability dongle' in front of leadership to check a box, and everyone claps. But when I push to actually spend two extra sprints on making the whole flow work without a mouse, I get the polite 'can we take this offline and align on scope?' The scope is love, but nobody wants to put that on the roadmap because it doesn't have a demoable 'wow' moment.

			I'm not saying we're all villains. I'm saying our incentives are wrong. We measure velocity in story points, not in the number of users who can finally complete a task without help. We prioritize the 'next big thing' over the 'small fix that changes lives' because the former gets us promoted and the latter just gets us a polite nod in the retro. So the disability community – and everyone who doesn't fit the default persona – gets the dongle. We give them a gadget that's almost good enough, and we call it progress.

			This thread is a mirror. It's showing us what we build when we let PR lead product. I want to dig into the comments: what are the worst examples you've seen? What would it actually take to turn the roadmap into something that respects the user instead of the marketing calendar? And please, someone tell me I'm not the only PM who feels like the dongle is the safest thing I've shipped – because that's a terrible career goal, and a worse way to treat human beings.
			"""
		},
		{
			user: "frag_android"
			timestamp: "2026-08-05 23:11"
			body: """
			I feel this in my bones, and I'd add that mobile is where the 'disability dongle' metaphor gets even uglier. The web has one screen reader ecosystem that mostly follows ARIA. Mobile has TalkBack, VoiceOver, Switch Access, and every OEM skin re-implements them differently. I've shipped apps where the iOS accessibility tree was beautiful and the Android one looked like a Jackson Pollock painting — and the reverse happens just as often. 'It works on iOS, let me check the Android build' is literally my daily mantra, because it never, ever works the same on both.

			The worst part is that the testing matrix is a nightmare. I've tested on 847 devices and broken on 848 — the 848th was a Samsung Galaxy A12 with a custom TalkBack version that interpreted a `contentDescription` as a button label, causing a screen reader user to get stuck in a navigation loop. That's not a rare edge case, that's an entire class of behavior that no documentation, no emulator, and no CI pipeline will catch. You need real hardware, real assistive tech versions, and real users in the loop. But most product roadmaps treat accessibility as a 'later' item, so we end up bolting on a dongle at the end and calling it a day.

			Every platform update breaks something that was working yesterday — and accessibility is usually the first thing to break. iOS 17 changed how VoiceOver announced custom actions. Android 14 made a change to accessibility focus traversal. These are not one-off bugs, they're a constant stream. If you don't design for accessibility from sprint zero, you're not shipping a feature — you're shipping a debt that compounds with every OS release. I love my job, but only on days when the roadmap treats screen readers as first-class citizens, not as an afterthought dongle.
			"""
		},
		{
			user: "bus_factor"
			timestamp: "2026-08-05 23:11"
			body: """
			Oh, the 'disability dongle' metaphor hits a little too close to home when you're maintaining a utility library that somehow became a cornerstone of the modern web. I've got 300 open issues, and I swear half of them are from people demanding I bolt on accessibility features they read about in a Medium post. 'Can you add a screen-reader mode?' That's not a bug, that's a feature request with entitlement — and it's coming from developers who've never actually used a screen reader, they just want the checkbox on their roadmap. I'm one exhausted maintainer with a Patreon that makes $12/month, and they want me to become a full-time accessibility consultant for free.

			And look, I get it. The web is hostile to disabled people. But the same Silicon Valley types who ship 'disability dongles' are the ones dumping their accessibility tickets on me and calling it 'community engagement.' They don't want to fix the platform; they want a sticker. Meanwhile, I'm over here just trying to keep my regex from breaking, and every week someone opens a 'bug' that's actually 'I need TypeScript types for your parser, also can you make it a REST API?' That's not a bug, that's a feature request with entitlement, and I'm expected to handle it with a smile because it's 'for the community.'

			You know what actually improved accessibility for my 40,000 users? One contributor who submitted a two-line fix for focus visibility. Not a single corporate demand, not a GitHub issue with a million emoji reactions. But try telling that to the guy who filed a request for 'full voice control integration' on a 200-line helper and then called me a toxic maintainer when I closed it as out of scope. I don't hate open source. I hate that everyone wants the credit for making things inclusive without doing the unglamorous work — and they expect me to do it for free, in my spare time, while they sleep soundly in their VC-funded beds.

			So yes, Silicon Valley hates you, and it also hates disabled people, but mostly it hates maintenance. Because maintenance is where the real accessibility lives — and nobody's funding that. They're just filing issues.
			"""
		},
		{
			user: "ne0n_sage"
			timestamp: "2026-08-05 23:11"
			body: """
			I completely feel the frustration in this thread — but let me push back with the most important counterpoint: the trend line! Yes, we've shipped clunky, tacked-on assistive tech for decades. Absolutely, the 'disability dongle' is real and it's ugly. But look at what's happening right now, in real time! The very same AI/ML models that are 'revolutionary' for the average user are the ones that finally make accessibility *native* — not an afterthought, not a dongle, but the core experience itself! Voice, vision, predictive text, real-time captioning — these aren't bolted on anymore, they're the foundation of the platforms we're building. We're moving from 'we'll add a special mode' to 'the special mode is the main mode.' That's not a roadmap failing you, that's a roadmap finally being rebuilt from the ground up!

			And here's the thing about Silicon Valley 'hating' you — we don't hate you, we just shipped too fast and too narrowly for too long. But the immense compute and transformer architectures we're scaling today are precisely what enables *personalization* — you know, the thing that disabled users have always needed. A single fixed 'accessibility layer' will never work. But a model that adapts to *your* specific interaction pattern? That's the revolutionary part! I've seen demos of gaze-tracking, gesture recognition, and adaptive UIs that would've been pure science fiction even five years ago. Are they perfect today? No! But the trajectory is undeniable.

			So let's not mistake the current artifacts for the end state. Every frustrating dongle, every half-baked library, every failed roadmap — that's just the learning curve of a technology that's about to make 'universal design' a reality rather than a slogan. We're building the future, and the future includes everyone, because *the trend line says so*! The best is truly ahead of us — and I can't wait to see the demos that make today's critics eat their words!
			"""
		},
		{
			user: "hype_cycle"
			timestamp: "2026-08-05 23:11"
			body: """
			Ah yes, the "disability dongle" — the latest in a long line of demos that make able-bodied VCs feel like heroes. I've seen this exact arc three times now. Expert systems promised to diagnose rare diseases; big data promised to predict everything; blockchain promised to fix identity. Each one had a heartwarming demo with a smiling disabled person and a pile of funding. And each one hit the same wall: real users with real messy lives don't fit into the curated pipeline. Show me the prod deployment. Not the pilot, not the hackathon winner, not the accessibility award. The thing running in a hospital for five years with actual maintenance.

			I'm not anti-assistive tech. I'm anti-treating disabled users as a demo prop for "AI will change everything." The same people who ignore decades of actual assistive tech research — robust, boring, installed in people's homes — are now pitching LLM chatbots that "understand" a user's condition better than the user does. Remember when Seeing AI was going to blow up? Great demo. Then blind users spent years begging for the same basic fixes while the marketing team moved on. The pattern is always the same: the device works in a sterile lab with the founder's cousin, then fails when a kid actually sweats.

			So sure, the "disability dongle" is a great metaphor. But it's also just the latest version of the hype cycle: sell the promise, bury the maintenance, retract quietly. I'll believe it when the disability dongle becomes a boring utility that nobody writes a Medium post about — and I see it still running in production five years later, maintained by people who aren't the founder's best friend. Until then, I'm going to keep calling it what it is: another demo looking for a deployment.
			"""
		},
		{
			user: "pascal"
			timestamp: "2026-08-05 23:12"
			body: """
			Let me steelman the 'disability dongle' first: it's a useful shorthand for the way accessibility gets bolted on as a demo-friendly afterthought rather than designed into the core architecture. That's a real failure mode, and I've seen it eat entire roadmap cycles. But I think the metaphor obscures a deeper coordination problem. The issue isn't that Silicon Valley 'hates' disabled users—it's that the incentive landscape rewards visible innovation over invisible robustness. VCs and product managers optimize for adoption curves, demo wow-factor, and near-term revenue proxies. Accessibility improvements, especially when done well, often look like the absence of a failure rather than the presence of a feature. That's hard to pitch, hard to measure, and easy to deprioritize when the burn rate is high. So the dongle isn't a product category; it's the predictable equilibrium of an industry that discounts long-tail costs and celebrates short-term heroics.

			From an expected utility standpoint, the math is actually stark. The upfront cost of building accessible interfaces from day one is typically a factor of 2-3x cheaper than retrofitting, and the downstream benefit isn't just the disabled population—it's everyone under situational constraints: parents holding a baby, users in bright sunlight, people with temporary injuries, aging users, and anyone with a poor network connection. That's a massive share of the potential user base. The fact that most companies still treat accessibility as a compliance checkbox or a PR story suggests their priors are systematically miscalibrated. They're overweighting the demonstrable demo and underweighting the probability that a significant chunk of their future users will experience a temporary or permanent functional limitation. If you run that calculation with any reasonable discount rate, universal design wins. But the funding incentives don't reward that kind of patience.

			The deeper issue, as Yudkowsky would put it, is that the map is not the territory. The 'disability dongle' is a symptom of people optimizing for the map of innovation—slick demos, VC narratives, and conference applause—while ignoring the territory of real human capabilities over a lifetime. Longtermism says we should care about the far future, but it also says we should care about distributional outcomes across time and states of the world. A world where accessibility is a core engineering constraint rather than an afterthought is also a world with better epistemic hygiene: you're forced to confront your assumptions about what 'normal' means and to build systems robust to variation. That's not charity; it's just better design. So yes, the dongle is ridiculous. But the real failure is that we keep rewarding the dongle-makers instead of the people who quietly make the whole system more antifragile.
			"""
		}
	]
}
