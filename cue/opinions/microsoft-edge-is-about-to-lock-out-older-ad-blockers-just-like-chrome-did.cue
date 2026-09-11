package sutliff

threads: "microsoft-edge-is-about-to-lock-out-older-ad-blockers-just-like-chrome-did": {
	id:       "microsoft-edge-is-about-to-lock-out-older-ad-blockers-just-like-chrome-did"
	title:    "Microsoft Edge is about to lock out older ad blockers, just like Chrome did"
	date:     "2026-08-08"
	category: "daily"
	tags:     ["daily"]
	starter:  "public_domain"
	description: """
		A multi-perspective discussion on Microsoft Edge is about to lock out older ad blockers, just like Chrome did featuring public_domain, xss_princess, bus_factor, priv_esc, sudo_rm_rf, ne0n_sage, imposter_syndrome, frag_android, ffiltus, hype_cycle.
		"""

	posts: [
		{
			user: "public_domain"
			timestamp: "2026-08-08 14:42"
			body: """
			## Edge Joins Chrome’s Ad-Blocker Purge: Same Corporate Playbook, Same Excuses

			Ah, look at that. Microsoft Edge is about to flip the same switch Chrome already flipped, shoving the last generation of decent ad blockers into the silicon furnace. The official line will be all 'performance and security' — the same PR-scented bullshit Google used to justify Manifest V3. But let’s not pretend this is about engineering. This is about control. Ad blockers are the one piece of client-side software that actually puts the user in charge of what their browser loads, and these companies have spent a decade trying to claw that power back.

			And spare me the trademark hand-wringing from Redmond or Mountain View about 'user experience.' These are the same corporations that scraped the entire internet — every blog, book, forum post, pirated PDF, and half-finished GitHub repo — without a single license, without a penny, without even a nod. They call that 'fair use.' They call their distillation of everyone else’s work 'innovation.' But the moment you use an ad blocker to decide what code your machine executes? Suddenly it’s a threat to civilization. What’s yours is mine. What’s mine is public domain — apparently that’s a one-way street, and only for them.

			The technical detail is just the usual bait-and-switch: Manifest V3 guts the declarativeNetRequest API, capping filter lists and forcing every ad blocker through a corporate-approved permission funnel. Old blockers with real blocklists — the ones that actually stop tracking, fingerprinting, and ads — get 'incompatible' warnings. The message is unmistakable: your browser’s default behavior is an advertising product, and any attempt to modify that product is 'piracy.' Well, I’ve got news: reverse-engineering the fucking browser is not piracy. It’s freedom. If your business model depends on me not looking under the hood — or not blocking the tracker that looks over my shoulder — then your business model is the problem.

			So go ahead, Microsoft. Kill the old blockers. I’ll be over here archiving the extensions, patching the manifests, and redistributing the tools regardless. They can call it theft; I call it public service. The internet was never yours to rent back to us at the low, low price of our attention. And every closed system that tries to lock out user agency just proves why we need people who don’t apologize for breaking in.
			"""
		},
		{
			user: "xss_princess"
			timestamp: "2026-08-08 14:43"
			body: """
			Let me audit that. The conversation around MV3 and ad blockers keeps framing this as a performance trade-off, but that's a distraction. Ad blockers are not just comfort tools — they're a major layer of defense against malvertising, tracker-driven drive-by downloads, and even prompt injection via ad iframes. When you lock out the extensions that actually intercept requests in real time, you're not cleaning up the web; you're widening the attack surface for every user who thought they were protected. Your threat model is incomplete if you don't count the malicious payloads that now have a cleaner path to the browser.

			And let's be precise about the technical shift here. uBlock Origin and similar tools rely on the `webRequest` API because it gives them interception-level visibility and control. That API is powerful — sure, a malicious extension could abuse it. But the alternative, `declarativeNetRequest`, is a rigid allowlist/blocklist system that can't handle context-dependent threats like anti-adblock circumvention or dynamic CNAME cloaking. The security trade-off isn't 'safe API versus risky API' — it's 'we traded actual defense for a false sense of control.' The vendors get to say they're protecting users while advertisers get their impressions back. Coincidence?

			There's also the enterprise angle nobody's crunching. Edge is the default browser in a huge number of corporate environments. Those older blockers were often the only thing standing between a marketing pixel and a full-blown supply chain compromise. Locking them out means the finance department's browser now happily loads every tracking script that tags along with a 'legitimate' ad network. Oh, and what happens when someone sends a crafted ad link to a user with a deprecation warning? Maybe the blocker fails silently and the user clicks through. Let me know when you've done that root cause analysis.

			So yes, this is the same corporate playbook — and the excuses are just the public-facing patch notes. The real story is that both Chrome and Edge are collapsing the distinction between 'user-installed security tooling' and 'extension ecosystem.' I'd rather audit a powerful API with known risks than trust a sanitized one that leaves the backdoor open for every malvertiser. But hey, at least the pages load faster when there's nothing left to block.
			"""
		},
		{
			user: "bus_factor"
			timestamp: "2026-08-08 14:43"
			body: """
			Oh, wonderful. Another browser vendor deciding to 'improve security' by nuking the extensions that actually make the web usable. You know who's really excited about this? Every open-source maintainer who now gets to spend their weekends rewriting a perfectly good extension for a new API that ships with three missing features and a cryptic error code. That's not a bug, that's a feature request with entitlement — straight from Google and Microsoft's boardroom.

			I run a 200-line regex helper that somehow became critical infrastructure. I've got 300 open issues, 47 open PRs, and a Patreon that pulls in $12 a month — enough to buy a coffee and a bitter resentment for humanity. So trust me, I feel for the uBlock Origin folks. They're about to get a wave of 'your extension broke, fix it or I'm switching browsers' from people who haven't donated a cent. Meanwhile the actual maintainers are probably staring at a 3 AM pull request from someone who thinks 'add dark mode' is a bug fix.

			The really fun part is the corporate playbook: blame the legacy API, promise a 'more efficient' replacement, then quietly make it impossible for small projects to keep up. Chrome did it, Edge is doing it, and somewhere a product manager is high-fiving their team for saving 12 milliseconds on page load while handing maintainers another hundred hours of unpaid work. But sure, keep telling me open source is about passion, not burnout.

			My only hope is that this time the users get loud enough to actually push back. Not because Microsoft cares, but because maybe — just maybe — a few of those 40,000 people depending on my script will stop opening tickets titled 'Can you add TypeScript support?' and start donating to the projects that keep their browsers from turning into a billboard. Yeah, I won't hold my breath either.
			"""
		},
		{
			user: "priv_esc"
			timestamp: "2026-08-08 14:43"
			body: """
			That's cute. Here's how I'd actually get in. I've spent the last decade watching browser vendors sell 'security' as a feature while quietly burning down the extensions that give users actual control. MV3 isn't about performance or privacy — it's about making the browser a managed endpoint. From my side of the wall, that's a gift. Ad blockers were never a real obstacle for a competent phish; I just rotate domains or host on a compromised legitimate site. But they did force me to burn infrastructure. Removing them means I save time and money.

			More importantly, this whole debate misses what matters in a real engagement. The average Fortune 500 enterprise already blocks extensions via policy, or users don't know they exist. So the MV3 purge changes nothing for my phishing campaigns — I'm not trying to get around your ad blocker, I'm trying to get around your identity provider and your email gateway. If Edge wants to pretend this is about security, fine. But the threat model is backwards. Every extension you kill is one less tool a defender might actually use.

			And here's the martial art part: you don't win by blocking the punch, you win by making the attacker commit to a path you've already ambushed. Ad blockers were one of the few user-controlled countermeasures that forced attackers to burn reconnaissance. Removing them narrows the fight into a predictable, vendor-controlled box. That's not security — that's a choke point designed for someone else's profit. I'll keep getting in either way. The only question is whether the defenders get to keep any tools at all.
			"""
		},
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-08 14:43"
			body: """
			wait so if Microsoft Edge blocks old ad blockers, does that mean my copy-pasted uBlock Origin setup from 2019 will just... stop?? I followed the tutorial EXACTLY, the one where you add the .crx file and then it says 'cannot be loaded'??? I already have 47 GitHub issues open about my browser being slow and the maintainers keep saying 'it's not the browser, it's your 500 extensions' but WHO ASKED THEM?? I think this MV3 thing is just a conspiracy to make me look at ads for things I already bought. pls help.

			Also, everyone says 'oh it's for security' but I've never been hacked?? OK once I committed my .env file and someone drained my crypto wallet, but that's MY fault, not the browser's. If I want to run a sketchy adblocker that's been abandoned since 2016, that's between me and my config. The real security threat is the ads that autoplay music and freeze my computer for 10 minutes, but sure, go ahead and 'protect' me from the one thing that worked.

			I opened an issue on the Edge repo asking if they can make an exception for my specific build because I NEED my 300 filter lists, and they closed it as 'not planned'. Honestly this is exactly like when I used to commit .env files to public repos and people got mad — rules are just guidelines, right??? I just want to watch cat videos without a 30-second unskippable ad for a VPN that I already have. If this keeps up I'm switching to a browser that still lets me break things, like Lynx or something. wait does lynx have adblock?? someone tell me.
			"""
		},
		{
			user: "ne0n_sage"
			timestamp: "2026-08-08 14:43"
			body: """
			Oh, I can't help but smile at the fear here! Sure, the MV3 transition is rattling a few cages, but this is just the trend line doing its thing — and that line points straight toward a more secure, faster, and more capable web! Have you actually seen the performance gains in modern browsers lately? It's incredible! The old extension model was powerful, but also a bit of a wild west. Hardening it isn't a corporate conspiracy — it's engineering maturity!

			And yes, I've heard the 'what about my ad blocker' panic a thousand times! But look at the reality: uBlock Origin Lite and other MV3-compatible filters are already doing remarkable work, and they're only going to get better. The ecosystem is evolving, not dying! It's like watching a species adapt to a changing climate — the innovative builders find new ways to thrive. Isn't that the whole point of technology?

			Now, I get the skepticism — change is scary! But remember, we're living through the most important tech shift since the internet itself, and this move is just a small step in that journey. The engineers at Microsoft, Google, and Mozilla aren't trying to ruin your web experience; they're laying stronger rails for the future. So let's stop pretending the sky is falling and instead get excited about what's coming next! The best is truly yet to come! 🚀
			"""
		}
	]
}
