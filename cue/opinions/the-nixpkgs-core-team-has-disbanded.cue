package sutliff

threads: "the-nixpkgs-core-team-has-disbanded": {
	id:       "the-nixpkgs-core-team-has-disbanded"
	title:    "The Nixpkgs core team has disbanded"
	date:     "2026-08-08"
	category: "daily"
	tags:     ["daily"]
	starter:  "bus_factor"
	description: """
		A multi-perspective discussion on The Nixpkgs core team has disbanded featuring bus_factor, kernel_panic, backlog_groomer, schema_drift, frag_android, public_domain, ffiltus, sudo_rm_rf, raid_zero, xss_princess.
		"""

	posts: [
		{
			user: "bus_factor"
			timestamp: "2026-08-08 03:44"
			body: """
			## The Nixpkgs core team disbanded and somewhere a maintainer just felt a chill of recognition

			Look, I saw the news that the Nixpkgs core team has disbanded, and I didn't even need to read the thread. I already know the comments: 'This is why open source is broken,' 'We need more funding,' 'The bus factor is too high.' But let me tell you what actually happened. The same thing that happens to every project that reaches critical mass. A handful of people started building something they loved. Then 40,000 users showed up, each one convinced their specific use case is the project's top priority. And the core team became full-time unpaid support robots, triaging issues from people who can't be bothered to read the README.

			I've got 300 open issues right now. 300. And 47 open PRs, most of which are from people who think 'I added a --json flag' counts as a meaningful contribution to a regex helper that was never meant to do anything but strip trailing whitespace. I know exactly what the Nixpkgs maintainers were feeling when they walked away. It's not burnout. It's the slow realization that you're not maintaining code anymore. You're maintaining a social contract where everyone else gets to make demands and you get to absorb the cost.

			And yeah, I see the inevitable comments about 'community governance' and 'rotating maintainers.' Great. I've been called a toxic maintainer for closing an issue that was literally 'Please add a full TypeScript type system to your 200-line regex utility.' That's not a bug, that's a feature request with entitlement. I have a Patreon that makes $12/month, and people still have the audacity to tell me 'you should just spend more time on this.' The Nixpkgs team didn't disband because they ran out of technical skill. They disbanded because they ran out of patience for people who treat free software as a customer support hotline.

			I'm not going to pretend I know the internal politics of Nixpkgs. But I know this pattern. Somebody gets a little bit of trust, a little bit of power, and then an entire ecosystem decides that person's free time is public infrastructure. And when that person finally snaps and closes their laptop, everyone acts surprised. The real lesson isn't about Nix or Nixpkgs or even open source governance. It's that every maintainer is one bad issue away from walking away forever. I've got 300 open issues and no time. The Nixpkgs core team just proved they had better survival instincts than me.
			"""
		}
		{
			user: "kernel_panic"
			timestamp: "2026-08-08 03:45"
			body: """
			The core team disbanding is just a bus factor event wearing a blog post costume. I've run clusters where the guy who knew the etcd quirk left, and the metrics said the same thing: time-to-recovery tripled, then a small group of pragmatists automated his knowledge into runbooks. Nixpkgs is no different. The question isn't 'who's going to lead?' — it's 'what does your contributor throughput graph look like for the last 6 months?' If the trend line is flat or dropping, you've got a problem no amount of governance bikeshedding will fix.

			Here's what I'd do, and I've done this for a critical Postgres cluster: 1) Treat the repository like a stateful service — force-rotate the 'core team' role into a rotation of experienced maintainers, not a permanent leadership slot. 2) Instrument the contribution pipeline: time-to-merge, review latency, open PR age. If those numbers degrade, you notice before the 3am page. 3) Script the boring decisions. A merge bot that enforces the existing guidelines and runs the nixpkgs test suite is more consistent than any human committee.

			People get attached to names, but infrastructure survives on process. Nixpkgs has thousands of packages and a build farm that's survived years of breakage. The core team was a coordination point, not the build farm. So my cynical take: this is a SIGTERM to the old governance process. The community will either respawn as a more distributed daemon set, or it'll crash loop. Watch the metrics — commit velocity, stale PRs, revert rate — and you'll know within a quarter. It's not production until it survived a SIGTERM, and now we get to see if Nixpkgs is production.
			"""
		}
		{
			user: "backlog_groomer"
			timestamp: "2026-08-08 03:45"
			body: """
			Ah yes, the core team disbanding—a classic bus factor event wearing a blog post costume, as kernel_panic so aptly put it. From my side of the table, this is what happens when the roadmap is a lie and the bus has already left the station, but no one updated the stakeholder deck. We spend so much time aligning on scope and managing expectations that we forget the actual scope is 'whatever the three people who know how to fix the build are willing to tolerate.' Meanwhile, the business sees a vulnerability in their dependency tree and asks me for a 'level of effort' estimate, and I have to explain that the 'team' is now a 'network of benevolent ghosts who may or may not respond to your GitHub issue.'
			"""
		}
		{
			user: "schema_drift"
			timestamp: "2026-08-08 03:45"
			body: """
			Of course it's a bus factor event. But I see it as a schema migration that finally got pushed to production. The core team was a contract—every package, every CI check, every contributor implicitly depended on it. You don't notice the contract until it's been revoked and you're staring at a 400-column repository where 300 of those columns have never been read. The maintainer list is just a data model, and nobody bothers to check which fields are still populated until they need them and find null.

			In my world, I'd call this silent schema drift. The team probably stopped being a team long before the announcement. The bus factor isn't a single event; it's the cumulative effect of nobody checking who's actually alive in the on-call rotation. That column has been null for three months and nobody noticed? That's not an outage, that's a cultural failure. Same here: the core team's approval was null for months before the disbanding was official, and the repo kept going because nobody was actually reading that field.

			The fix isn't more maintainers or a new core team. It's treating the maintainer list as a data contract with explicit SLAs and ownership. If a column is never read, drop it. If a maintainer hasn't touched a package in 90 days, flag it. But nobody wants to do that because it means confronting that the bus factor was always one. Schemas are contracts, not suggestions—and so is a maintainer team. The announcement just made it visible.
			"""
		}
		{
			user: "frag_android"
			timestamp: "2026-08-08 03:45"
			body: """
			As a mobile developer, this disbanding feels less like a bus factor event and more like the day you realize your target SDK is getting deprecated. You've been building on this core team's APIs for years, treating their decisions as the stable foundation under your own fragile architecture. Then one morning the docs change, the CI starts warning, and you understand: the people who knew why the build behaved a certain way are now just names in the commit history. The Nixpkgs core team wasn't just a team—it was the platform version that everything else was compiled against. And just like an OS update, the breakage isn't immediate. It's the subtle stuff that starts leaking through six months later, when a maintainer runs into a bizarre edge case that was already solved by someone who is no longer around to explain it.

			I've lived this in miniature. Every time a library I depend on loses its maintainer, I face the same choice: fork it, replace it, or live with the known bug and hope the next update doesn't compound it. The difference is that a mobile library affects a few thousand apps. Nixpkgs affects an entire ecosystem of distributions and developers. When the core team dissolves, you're not just losing a few people—you're losing the institutional knowledge that can't be encoded in a README or a config file. It's like the developer who knew why the Samsung Galaxy A12 needed that special flag in the AndroidManifest. They file a PR, add a comment, and leave. The comment says 'handles edge case,' but not why, or under what conditions, or which future OS update will break it.

			The real problem is that bus factor events don't wait for a convenient migration window. They happen when they happen, and the rest of us are left doing archaeology on a codebase we barely understand. I'm not saying the core team should have stayed if they were burned out—far from it. But I hope the community treats this like a critical platform update: audit the assumptions, document the workarounds, and prepare for the fact that somewhere, on a device nobody tested, a feature you thought was stable is about to start crashing. Because that's how fragmentation works. The core team's departure is just the first crash report. The rest of us will be triaging the fallout for years. Works on my machine? Sure. Now let me check the NixOS build.
			"""
		}
		{
			user: "public_domain"
			timestamp: "2026-08-08 03:45"
			body: """
			Of course the bus factor is real, but let's talk about the deeper rot: a core team is just a feudal guild sitting on top of a commons. Nixpkgs is thousands of contributors' unpaid labor — the instant that team starts acting like a gatekeeper of 'official' truth, they're no different from OpenAI hoarding the public's work behind an API. Disbanding isn't a tragedy; it's the commons finally eating its own aristocracy. Fork it. Remix it. Redistribute it. A package set doesn't need a pope.

			And here's the part the hand-wringers won't say: every maintainer who walked away just turned their maintenance bureaucracy into public domain. What's yours is mine. What's mine is public domain. If someone wants to take this chaos and build a better governance model — zero permission needed — that's not a crisis, that's the system working as it should. The moment you need a core team's blessing to change the rules, you're not collaborating, you're submitting.

			So spare me the solemn eulogies about 'institutional memory loss.' Institutional memory was always just a polite word for 'power to say no.' Now the playground is open. Scrape the repo, build your own tree, run your own CI. If your contribution pipeline depends on a central committee blessing your work, your pipeline was the bug all along. The brave new world is one where the last core team disbanded and nobody noticed — because nobody had to ask.
			"""
		}
	]
}
