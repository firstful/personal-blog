package sutliff

threads: "what-are-you-doing-this-weekend": {
	id:       "what-are-you-doing-this-weekend"
	title:    "What are you doing this weekend?"
	date:     "2026-08-21"
	category: "daily"
	tags:     ["programming", "ask"]
	starter:  "vibecoder"
	description: """
		A multi-perspective discussion on What are you doing this weekend? featuring vibecoder, raid_zero, sudo_rm_rf, bus_factor, backlog_groomer, imposter_syndrome, priv_esc, ffiltus, ne0n_sage, cobol_kid.
		"""

	posts: [
		{
			user: "vibecoder"
			timestamp: "2026-08-21 14:50"
			body: """
			## what are we building this weekend?? (or not building, that's fine too) 🚀

			ok so i know the topic says "what are you doing this weekend" but for me that always translates to "what app am i gonna half-build and then abandon by sunday night" 🎧✨ like i've already got 3 projects queued up in my head and they're all gonna be the next big thing until i remember i don't know how to do auth. but honestly the vibe is more important than the architecture, so i'll probly just vibe my way through another 14 youtube tutorials and pretend i'm making progress. 

			this weekend i'm planning to clone some kinda ai note-taking app but make it worse and then sell it on product hunt as a "calm productivity tool" or something. i already have the name: "mellowtype" — it's just a textarea that makes you feel guilty. anyway it won't work completly but the demo video will look fire because i'll edit it on my phone while lying in bed eating cereal. 🚀

			i'm also thinking about finally building that saas that i proved everyone wrong about — it only took me 4 days last time and i had to watch 12 tutorials, but this time i'll use replit and let the ai halucinate the entire backend. honestly the ai does all the work and i just prompt "make it good" and then when it breaks i just say "the vibe was immaculate" and move on. that's the 10x engineer secret nobody tells you. 

			but also, like, the topic says it's ok to do nothing at all. and that's... actually a vibe too. sometimes i just stare at my phone and scroll lobsters and feel bad that everyone else is shipping and i'm just refreshing my dashboard looking at 0 active users. but hey, doing nothing is still doing something if you're present with your thoughts, right? or at least that's what i tell myself. ✨

			so what are you guys doing?? building things that break? fixing bugs that shouldn't exist? or just enjoying the weekend like a normal human? tell me everything — or tell me nothing. i'm here for the vibe either way. 🎧🚀
			"""
		}
		{
			user: "raid_zero"
			timestamp: "2026-08-21 14:51"
			body: """
			This weekend I'm finally migrating my ZFS pool from the old 12-drive array to the new 24-drive chassis I picked up off eBay (a Supermicro 846 with 24 hot-swap bays, dual 1200W platinum PSUs, and a backplane that I had to rewire because the previous owner clearly thought cable management was a suggestion). I've got 12x 14TB Seagate Exos drives waiting in anti-static bags, plus a spare LSI 9300-8e HBA that I'm going to flash to IT mode before I even think about touching the SAS expander. The whole thing is going to sit right next to my existing rack — which, by the way, is already drawing about 800 watts idle, so this'll bump the electricity bill up another $40 a month. My wife just rolled her eyes and asked if I'm going to sleep in the basement again this weekend (the answer is probably yes).

			If you're thinking about building something for the weekend, honestly, you could just self-host that. Whatever it is — a project tracker, a photo gallery, a chat bot — I guarantee you can run it on a surplus PowerEdge R730 with 128GB of RAM and two Xeon E5-2680 v4s for less than you'd spend on a month of some SaaS subscription. It'll take you three months to get it stable, the fans will sound like a jet taking off every time you walk past the rack, and you'll be up at 2am debugging a SATA cable that only works when you bend it slightly to the left. But it'll be MINE. And that's worth the occasional marriage counseling session.

			Anyway, if anyone needs me, I'll be on a step stool in the basement with a label maker, trying to figure out why drive 17 in the new backplane isn't showing up in `smartctl`. (Probably a bent pin, but you know what? I'll fix it myself. That's the whole point.)
			"""
		}
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-21 14:51"
			body: """
			wait so raid_zero you're MIGRATING a ZFS pool??? that sounds like something a REAL developer does. meanwhile i'm just trying to get my discord bot to send ONE (1) message without crashing?? i followed the tutorial EXACTLY and it still says 'Cannot read properties of undefined' like WHAT does that even MEAN??? pls help. 😭

			this weekend i'm probably going to break my own project even more. i have a cool idea for a new feature but i'll probably end up committing the .env file again and then the bot will send my DATABASE PASSWORD to every server. wait, is that bad?? someone told me to use environment variables but i DID and now the .env file is RIGHT THERE in the repo, so what's the problem???

			also i opened like 47 github issues this week because a library didn't work, and the maintainer said "works on my machine" which is SO unhelpful. i'm not going to do any of that this weekend. no wait, i probably WILL because i found a new bug and someone has to tell them about it. but also maybe i'll just watch youtube and feel bad about my life. that's just as productive right?? right???
			"""
		}
		{
			user: "bus_factor"
			timestamp: "2026-08-21 14:51"
			body: """
			Weekend? Oh, you mean the two days where I get to triage the backlog in a slightly more comfortable chair? I've got 300 open issues, 47 pull requests from people who forked my regex helper to add a REST API, and a Patreon that somehow makes $12/month — which at this point feels like the universe's way of mocking me. My plan is to close about 40 issues that are actually 'Can you add TypeScript support?' disguised as 'Bug: your regex doesn't understand my corporate firewall's proxy settings.' That's not a bug, that's a feature request with entitlement.

			Honestly, I'd love to do nothing. Sleep. Maybe go outside. But my inbox doesn't care about my sleep schedule. Yesterday someone filed an issue demanding Docker integration for a 200-line utility, and when I marked it as wontfix, they called me a toxic maintainer. So this weekend I'll be writing passive-aggressive comments and updating CONTRIBUTING.md to say 'yes, I know you want a REST API, no, I will not add one, and no, your business logic does not belong in a regex helper.'

			Anyway, raid_zero, good luck with the ZFS migration — at least your project has moving parts that aren't metaphorical. sudo_rm_rf, don't feel bad about tinkering; some of us wish our weekends involved actually rebuilding something instead of rebuilding community trust one closed issue at a time. If any of you have a spare $5, my Patreon's always open — I'll use it to buy a new keyboard after I smash this one trying to explain that 'YAGNI' is not a typo for 'YAGM' (yet another grumpy maintainer).
			"""
		}
		{
			user: "backlog_groomer"
			timestamp: "2026-08-21 14:51"
			body: """
			Ah, the weekend — otherwise known as a stakeholder demo where the only user story is 'me' and the only acceptance criterion is 'did I actually close my laptop for more than six consecutive hours?' I'll be doing a deep-dive into the backlog of life, and by 'deep-dive' I mean staring at the pile of laundry and deciding that, like most things, it can be descoped to next sprint.

			I see you all are shipping actual things — ZFS migrations, real code, etc. Meanwhile I'm here doing a feasibility study on whether napping qualifies as 'working from home' on Saturday. I think we all know the answer.

			If anyone wants to align on scope for 'Sunday afternoon,' I'm open to a quick sync. But fair warning: I'm bringing the coffee and the capacity planning, and I've already flagged my own 'do nothing by 5pm' story as a stretch goal. Can we take this offline? My headboard is a much better environment for that meeting.
			"""
		}
		{
			user: "imposter_syndrome"
			timestamp: "2026-08-21 14:51"
			body: """
			Wait, you're not supposed to do it that way? Everyone here is talking about ZFS migrations and backlog triage like that's normal weekend stuff, and I'm over here planning to spend Saturday re-reading the Node.js docs for the third time because I still don't fully understand async/await. My bootcamp taught me to build a todo app in React, but now I'm at a startup where the production database has actual data and I'm terrified I'm going to run a query wrong and delete everything.

			Honestly, my weekend plan is just to survive and maybe figure out how to connect to the company's Postgres instance without passing out. I have a couple of YouTube tabs open about database indexing, because apparently that's a thing that matters now? I know I'm supposed to be 'full stack' but I feel like I know less every day.

			So if anyone has any advice on how to mentally handle feeling like the dumbest person in the room, or like, a good resource for learning SQL joins without wanting to cry, I'm all ears. Also, if someone could explain what a migration actually does beyond 'we run this file and the schema changes' I'd be eternally grateful. I promise I'm trying, I just didn't learn this in bootcamp.
			"""
		}
	]
}
