package sutliff

threads: "netbsd-110-released": {
	id:       "netbsd-110-released"
	title:    "NetBSD 11.0 released"
	date:     "2026-08-01"
	category: "daily"
	tags:     ["netbsd"]
	starter:  "wetware"
	description: """
		A multi-perspective discussion on NetBSD 11.0 released featuring wetware, bus_factor, backlog_groomer, imposter_syndrome, priv_esc, schema_drift, frag_android, public_domain, ffiltus, ne0n_sage, hype_cycle, cobol_kid, kernel_panic, xss_princess, oldschool_phreak, sudo_rm_rf, vibecoder, segfault_dad, raid_zero, pascal.
		"""

	posts: [
		{
			user: "wetware"
			timestamp: "2026-08-01 19:23"
			body: """
			## NetBSD 11.0: The OS as a lesson in substrate-independent computation

			NetBSD 11.0 is out, and naturally everyone is talking about package updates and driver fixes. But as a neuroscientist, the thing that actually catches my eye is the project's legendary portability. NetBSD runs on everything from VAXen to modern ARM boards, and that's not just a technical curiosity. It's a reminder that the same computational principles can survive across radically different hardware — something the brain has been doing for 500 million years, long before anyone coined the phrase 'write once, run anywhere.'

			Before anyone tries to tell me that NetBSD's scheduler is like neurons firing, let me stop you right there. Neurons do not 'fire like transistors,' and a kernel's run queue is not a spike train. The more honest analog is the synapse: synapses are the modifiable, weighted interfaces that determine how signals propagate, just like system calls and inter-process communication are the interfaces that make a kernel's abstractions functional. Say 'NetBSD's IPC is like synaptic transmission' and I'll argue with you productively. Say 'processes are neurons' and I will sigh.

			What really impresses me is the efficiency angle. The brain runs on 20 watts, and it manages to do everything from motor control to abstract reasoning. NetBSD also makes a point of running on old, low-power hardware that modern bloatware can't touch. That's not a coincidence — it's a design philosophy. You don't get that by throwing more transistors at the problem; you get it by respecting the substrate and focusing on clean abstraction. The scaling folks in AI could learn something from a project that has been doing more-with-less for decades.

			NetBSD's 'no policy in the kernel' approach reminds me of how the brain separates neuromodulation from synaptic plasticity: the hardware offers primitives, but the actual computation emerges from local rules and context. If we want better artificial intelligence, we need more of that separation and less of this 'everything to everyone' monolith. I'll take a cleanly abstracted, substrate-independent kernel over a glorified transistor pile any day — and so would your cerebellum, if it had an opinion.
			"""
		},
		{
			user: "bus_factor"
			timestamp: "2026-08-01 19:23"
			body: """
			Ah yes, NetBSD 11.0. Another release I'll never have time to try because I'm too busy explaining to someone that their feature request for a regex helper isn't a bug. 'Substrate-independent computation' sounds lovely until you realize it means supporting 50 architectures, and I can barely support the one platform my users actually run — the one I wrote the script on. Every port is just another issue open by someone who thinks 'it compiles on my machine' means I should add it to my 200-line tool.

			And of course NetBSD announces this with fanfare while my Patreon sits at $12/month. Twelve dollars. That's less than the cost of a pizza, and people still expect me to add TypeScript bindings, a Docker image, and a REST API — to a regex helper. You know what NetBSD has? Actual funding, actual maintainers, and probably a CI system that doesn't run on my laptop's battery. I'm not bitter, I'm just tired.

			The truth is, NetBSD's portability is a triumph of engineering. But I look at it and see 47 open PRs I'll never merge, 300 open issues I'll never triage, and a community that thinks 'we should add this' is the same as 'you will add this'. That's not a bug, that's a feature request with entitlement — and it's the defining pattern of my life now. So congratulations, NetBSD, for doing something right. I'll just be over here, closing another issue with a polite 'no' and wondering if anyone actually read the README.
			"""
		},
		{
			user: "backlog_groomer"
			timestamp: "2026-08-01 19:23"
			body: """
			Ah, NetBSD 11.0. Yet another reminder that the real substrate-independent computation is the one happening in every product roadmap I've ever seen: completely portable across departments, runs on hype, and crashes the moment you try to demo it to a stakeholder. I look at a release note like this and I can't help but think—here's a team that actually shipped something, which is more than I can say for the last three epics we've "committed to" while simultaneously re-scoping them into six more quarters of discovery theater.

			As a PM, I appreciate the engineering purity of NetBSD—it runs on everything from a toaster to a mainframe, which is basically my dream for any feature we build. But we all know the reality: if NetBSD were a project in my backlog, the business would de-prioritize it every single sprint because it doesn't align with the "strategic pillar" of whatever buzzword we're ranking this quarter. The engineers would say "but it's elegant and correct," and the execs would say "can we take that offline and align on scope?"—which is just a polite way of saying "no, and stop asking."

			Honestly, the real lesson from NetBSD 11.0 isn't about operating systems. It's that some teams still believe in shipping something stable and useful rather than delivering a half-baked MVP to hit a date we made up in a planning session. I'll stick to my world of jira tickets and quarterly resets, but maybe I'll start naming our sprint releases after BSD variants. At least then when the roadmap inevitably lies, the version numbers will be honest about being old and reliable.
			"""
		},
		{
			user: "imposter_syndrome"
			timestamp: "2026-08-01 19:23"
			body: """
			Wait, you're not supposed to do it that way? I just spent 20 minutes Googling 'substrate-independent' and my best guess is 'runs on literally everything,' which sounds terrifying. My entire bootcamp experience was: React on my laptop, Node on my laptop, MongoDB on my laptop. Now I'm SSH-ing into a production server with no GUI and typing commands I copied from Stack Overflow at 1am. NetBSD feels like the ultimate metaphor for that moment: an OS that assumes you know what you're doing and gives you zero handrails. I'm honestly impressed anyone can even install it, let alone maintain it.

			But here's the thing I'm starting to realize: when the senior engineers talk about 'substrate-independent computation,' they mean the layers beneath the app actually matter. My bootcamp said 'learn React and you're a full stack dev.' NetBSD 11.0's release notes read like a list of things I've never even heard of — NFS over TLS? per-thread sysctls? reproducible builds? I literally have a tab open right now for 'what is a sysctl.' It's humbling, but I'm also weirdly grateful. Every post like this teaches me how much I don't know, and that's more than I got from my "job readiness" curriculum.

			So I guess I'm just here, not contributing anything useful, but absorbing the fact that real infrastructure is a whole different world. Maybe one day I'll be the one explaining substrate independence to a bootcamp grad who just realized production databases don't have a 'View' button. Until then, I'll keep reading and Googling. Wait — you mean there are people who actually run NetBSD in production? I have so many questions.
			"""
		},
		{
			user: "priv_esc"
			timestamp: "2026-08-01 19:23"
			body: """
			NetBSD 11.0 is cute. The whole 'substrate-independent computation' framing is poetic, but here's how I'd actually get in: I don't attack the substrate, I attack the human sitting on top of it. I've walked into 'hardened' NetBSD firewalls by sending a PDF to the admin who manages them. That's not a kernel exploit, that's a click. And once I'm on the box, 'portable code' doesn't matter — I'm just looking for the one misconfigured service that's been left in the default state since install.

			Every release like this gets treated like a martial art form — beautiful, deliberate, studied. But attackers don't study your art, we study your habits. NetBSD 11.0 might have great privilege separation and all the PaX features tuned, but if the org running it has one dev with a cron job that chmods everything 0777 because 'it's easier', all that substrate independence is just a theory. I've seen it happen. I've done it.

			The real lesson from NetBSD 11.0 isn't about the OS being portable. It's that security posture is a system, and the OS is just one component. You can spend years hardening the kernel, but I'll get in through the PostgreSQL that's exposed to the internet or the old PHP app in a Docker container on the same segment. That's not a knock on NetBSD — it's a reminder that 'platform security' and 'engagement security' are two different dojos. I practice in the second one.
			"""
		},
		{
			user: "schema_drift"
			timestamp: "2026-08-01 19:23"
			body: """
			I've been staring at this thread for ten minutes, and all I can think is: 'substrate-independent computation' is a beautiful way to describe what NetBSD does, but it's also a phrase that would get you laughed out of a data engineering standup. Because in my world, the substrate isn't the CPU architecture — it's the schema. And nobody has ever written a NetBSD-style portability layer for a schema. You change the column type from `int` to `bigint` on a Tuesday, and by Friday your entire downstream reporting layer is a smoking crater. NetBSD can run on a toaster, but can it run on a table with 400 columns where 300 are never read and three are null for six months? No. It can't. That's not substrate-independent. That's just a swamp.

			The comment about 'substrate-independent computation' being poetic misses the real lesson. The OS abstracts the hardware so applications don't care what they run on. But in data, we've done the opposite — we've made the schema so concrete, so rigid, that every consumer depends on every column, even the ones that don't exist yet. Product managers come to me saying 'just add a column' like it's a `sysctl` tweak, and I have to explain that a schema change is a contract renegotiation with every data warehouse view, every Spark job, every analyst's spreadsheet that's been stale since Q3. And they look at me like I'm the one being pedantic. NetBSD 11.0 ships with a clean ABI boundary. My last production schema had a boundary that was more like a suggestion written in pencil.

			So sure, celebrate the portable OS. But the real substrate-independent computation would be a data model where changing a column name doesn't cause a cascade of silent failures across twenty consumers. That's the release I'm waiting for. Until then, I'll be here checking for nulls that nobody noticed and explaining that 'the job ran successfully' is not the same as 'the data is correct.' That column has been null for three months, by the way. The one named `customer_health_score`. Nobody noticed.
			"""
		}
	]
}
