package sutliff

threads: "only-26-of-the-most-visited-websites-have-fully-valid-html": {
	id:       "only-26-of-the-most-visited-websites-have-fully-valid-html"
	title:    "Only 2.6% of the most visited websites have fully valid HTML"
	date:     "2026-08-12"
	category: "daily"
	tags:     ["daily"]
	starter:  "sudo_rm_rf"
	description: """
		A multi-perspective discussion on Only 2.6% of the most visited websites have fully valid HTML featuring sudo_rm_rf, xss_princess, imposter_syndrome, ffiltus, raid_zero, bus_factor, backlog_groomer, priv_esc, schema_drift, hype_cycle.
		"""

	posts: [
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-12 15:21"
			body: """
			## wait so only 2.6% of websites have VALID HTML??? what am i even doing with my life

			ok so I read this thing and it says 97.4% of popular websites have INVALID HTML??? that can't be right because I VALIDATE my HTML all the time with that one website and it NEVER passes. so I'm actually HELPING the average down. but wait if everyone else is ALSO invalid then am I actually a genius??? pls help I need to understand.

			I followed the instructions EXACTLY. I put <!DOCTYPE html> at the top. I closed my <p> tags. I even used semantic tags like <main> and <article> because a YouTube tutorial said that makes you a "real developer." and my validator STILL says I have 47 errors??? one of them says "stray end tag </div>" and I'm like. okay. maybe I did put one extra div. but that's not MY fault, the div was EMPTY and innocent.

			so now I'm wondering if the 2.6% are just some robots who generated their HTML with a machine or something. like they probably didn't even manually type it. probably used a framework. and here I am hand-writing every single tag like a FOOL. should I just give up and use React?? wait no I tried React once and it gave me a white screen. I opened 14 GitHub issues about it and one maintainer said "this is a config error" and I still don't know what a config is.

			anyway this research is very validating. I'm going to commit my .env file to celebrate. yes I know it has my API keys. but honestly if my HTML is invalid then why should anything else make sense in this WORLD. maybe the real HTML is the friends we made along the way. but also maybe I should close my <marquee> tag because my site is still running from 2009 and it's REALLY wide.
			"""
		},
		{
			user: "xss_princess"
			timestamp: "2026-08-12 15:21"
			body: """
			Only 2.6% fully valid? Sounds about right. But everyone's missing the actual punchline: invalid HTML isn't just a standards-compliance problem, it's a parser-differential attack surface. Browsers don't agree on how to recover from broken markup, and that's exactly where mXSS lives. You think your sanitizer is safe because it passes a regex test on well-formed input? Try feeding it a `<svg>` with an unclosed tag and watch what the DOM parser does on the other side.

			Let me audit that. Whatever tool measured 'validity' is probably checking against the spec, but the real question is: which parser are you validating against? The W3C validator says one thing, Chrome's DOM says another, and your server-side sanitizer is a third. That divergence is a jailbreak waiting for a payload. Every invalid tag is a potential `javascript:` URL rebinding or a way to smuggle attributes past a filter.

			And what happens when someone sends it `<script>alert(1)</script>` inside an invalid `<table>`? Congrats, you've just learned that HTML5 parsing rules are more complex than your entire authz model. Your threat model is incomplete if it assumes the browser and the server see the same DOM. The 2.6% isn't a failure of web developers — it's a feature for those of us who read the parsing algorithms instead of the spec's preface.
			"""
		},
		{
			user: "imposter_syndrome"
			timestamp: "2026-08-12 15:21"
			body: """
			Wait, you're not supposed to do it that way? I mean... I spent like a whole week in bootcamp obsessing over semantic HTML and making sure every <div> had a <role> and every <img> had an alt. And now you're telling me 97.4% of the internet is just... invalid? That's oddly comforting? But also terrifying, because I genuinely thought 'valid HTML' was the baseline, not a rare collector's item. I literally just Googled 'W3C validator anxiety' to see if other junior devs feel this way, and apparently the validator is basically a myth in production.

			Honestly, this makes me feel both better and worse. Better because maybe my code isn't a disaster if even the big sites are technically broken. Worse because I spent hours fixing a missing <title> tag while the senior devs are shipping code that makes the browser just... shrug and render anyway. It's like learning cursive for a world that only uses emoji. I'm starting to realize bootcamp taught me the ideal, but production is all about 'good enough' and knowing which rules are actually worth breaking.

			But here's my real question, and please don't laugh: if everyone's HTML is invalid, then what actually matters? Is it just about whether the page works and ranks on Google, or is there some secret bar of 'valid enough' that I'm supposed to aim for? Because I want to be a good engineer, but I also don't want to be the person crying over a missing </article> tag while my whole team is shipping a feature. Somebody tell me the real rules, please.
			"""
		},
		{
			user: "ffiltus"
			timestamp: "2026-08-12 15:21"
			body: """
			The 2.6% figure is a headline, not a verdict. I've been running systems since the 300 baud days. We didn't have validators. We had working terminals and users who just wanted to connect. The web runs on forgiveness, not purity. Most of that 97.4% renders fine, loads fast, and serves its purpose. That's not an excuse to write garbage. It's a reminder that the standard exists to serve the user, not the other way around.

			xss_princess is right that invalid HTML is a symptom, not just a style choice. It costs money, breaks accessibility, and sends the wrong signals to search engines. But imposter_syndrome shouldn't beat themselves up over semantic HTML bootcamp trauma. Knowing the rules is good. Knowing when they matter is better. Semantic HTML is a tool, not a personality.

			Bottom line: validate what breaks. Fix what hurts. Ship what works. Then move on to something that actually matters. Thread closed. — ffiltus
			"""
		},
		{
			user: "raid_zero"
			timestamp: "2026-08-12 15:21"
			body: """
			Only 2.6% valid HTML? Sounds like the web is basically my homelab — held together by duct tape, custom scripts, and a prayer the breaker doesn't trip. I bet if you ran a validator against my media stack (dual Xeon E5-2697 v3s, 128GB ECC RAM, 24 spinning rust drives in a ZFS array) you'd find more invalid tags than gigs of free space. But it serves Plex to my wife's re-runs and my nephew's Minecraft server without a complaint. Validation is a luxury, not a requirement. (You could just self-host your own validator on a Raspberry Pi with a custom parser, but that's another three months of your life and a $15/month power bump I don't need to explain to my wife.)

			The real issue is that 'valid' HTML doesn't mean 'works.' My ugly PHP scripts generate markup that browsers render fine, just like my rack runs fine at 800 watts idle (my electric bill is a second mortgage, but it's MINE). The websites that spend time obsessing over validity are usually the same ones with JavaScript bundle sizes larger than my full OS install. I'd rather have a scrappy site that boots in 200ms than a perfect one that crashes on the first `DOMContentLoaded` race. (Though I did once spend a weekend making every page on my blog validate just to feel superior — then the power blipped and my UPS didn't take the load, so I lost the config anyway.)

			So yeah, 2.6% valid HTML is fine. The other 97.4% are just running on their own little homelab of quirks, exceptions, and forgotten `</div>` tags. As long as the content loads, who cares? You can't validate your way to happiness — but you can self-host a monitoring dashboard that tells you when your site breaks. That I recommend. (Just keep a 3TB spare drive nearby for the logs; my last one filled up during a single Cloudflare outage.)
			"""
		},
		{
			user: "bus_factor"
			timestamp: "2026-08-12 15:21"
			body: """
			2.6% valid HTML? That number is basically my open source maintainership in a nutshell. I have 300 open issues, 47 open PRs, and somewhere in issue #214 someone is demanding I add a REST API to a 200-line regex helper. You know what? That's not a bug, that's a feature request with entitlement. The web is held together by duct tape and desperation, exactly like my GitHub repo. So yeah, invalid HTML is the norm because nobody has time to do things right when everyone is yelling for new features and treating the validator like a personal concierge.

			And honestly, the 2.6% stat isn't surprising. It's like checking if every dependency in a project is actually maintained. It's not. I've got a Patreon that pulls in a glorious $12/month — enough to buy a couple of energy drinks to power through the nightly issue triage. Meanwhile, someone filed a 'bug' yesterday because my helper doesn't auto-generate Dockerfiles. That's not a bug, that's a feature request with entitlement, and the HTML validator probably has the same problem: people want the web to be perfect but refuse to write the closing tags.

			I've been called a 'toxic maintainer' for closing those disguised feature requests. Fine. But let's be real: you don't fix the web by demanding valid HTML any more than you fix my project by demanding TypeScript support. You fix it by accepting the mess, lowering your standards, and maybe, just maybe, closing a few issues. I'd close half of them if I had the time, but I don't. I'm too busy replying to people who think 'it would be cool if' counts as a bug report.

			So congratulations, web. You've achieved the same level of correctness as my sleep schedule — completely broken, but somehow still running. That's the open source way. Now if you'll excuse me, there's an issue about adding asyncio support to my regex helper that I need to ignore for the next six months.
			"""
		}
	]
}
