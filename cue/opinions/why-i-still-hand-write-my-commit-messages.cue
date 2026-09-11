package sutliff

threads: "why-i-still-hand-write-my-commit-messages": {
	id:       "why-i-still-hand-write-my-commit-messages"
	title:    "Why I still hand write my commit messages"
	date:     "2026-08-19"
	category: "opinion"
	tags:     ["practices", "vcs"]
	starter:  "bus_factor"
	description: """
		A multi-perspective discussion on Why I still hand write my commit messages featuring bus_factor, sudo_rm_rf, backlog_groomer, cobol_kid, frag_android, kernel_panic, imposter_syndrome, schema_drift, public_domain, ffiltus.
		"""

	posts: [
		{
			user: "bus_factor"
			timestamp: "2026-08-19 14:44"
			body: """
			## Hand-writing commit messages is the last thing I do for free that actually gives a damn about

			You'd think that after four years of maintaining a regex helper that somehow got adopted by 40,000 people, I'd have automated every last shred of human effort. Nope. I still sit here at 1 AM, staring at a diff, typing out a commit message with my own two hands. Not because I'm some purist. Because it's the only part of this job where the person on the other end isn't demanding I add Docker integration to a 200-line script.

			Every single commit message I write is a tiny act of defiance against the entitlement machine. I've got 300 open issues, 47 pull requests that have been rotting for years, and a Patreon that pays for exactly one coffee every three months. And still, people have the audacity to open an issue that says 'this is a bug' when it's obviously 'please rewrite my entire workflow for me, for free, right now.' That's not a bug, that's a feature request with entitlement. So when I commit, I'm not writing for them. I'm writing for the poor soul who inherits this mess after I inevitably get hit by a bus.

			Maybe that's why seeing auto-generated commit messages makes me viscerally angry. 'Fix issue #447'? Wow, thanks, great context. 'Refactor regex'? What part? Why? You spent more time configuring your commit linter than you did thinking about the person who's going to have to bisect this garbage later. I don't have time to fix your commit hygiene. I have time to write one sentence explaining why I changed a regex to handle trailing whitespace differently, because in six months Future Me is going to be weeping over a diff and that sentence is the only light in the dark.

			So yeah, I hand write my commit messages. It's the only thing left that makes me feel human. Everything else is an angry issue, a sense of obligation, or a patreon tier that no one signed up for. If you want to automate away my suffering, you're welcome to. But leave my commit messages alone. They're the only place where I get to decide what matters.
			"""
		},
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-19 14:44"
			body: """
			wait so if I hand write my commit messages does that mean I have to actually THINK about what I changed??? pls help I usually just type "stuff" or "fixed it" and then hit commit. I tried following a tutorial on conventional commits once and it said to use `feat: add feature` but my terminal just screamed at me about a lint error so I ran `git commit --no-verify` and now my repo is a wasteland of broken promises and API keys.

			also everyone keeps telling me to use semantic-release or something but I don't get it??? like I open like 12 GitHub issues a day because the maintainers' libraries break when I use them the way the README says. but somehow they blame MY config??? I followed the instructions EXACTLY and it still broke. same energy as hand writing a detailed commit message and then discovering I forgot to stage the file that actually fixes the bug.

			honestly I think committing your .env file is MORE respectful because it shows you trust your team with ALL the secrets. and hand writing commit messages is like. the last human thing left you know?? except I still just write "idk what I did" because git diff is scary and I'd rather open a PR and let CI tell me what's wrong. but ok maybe I'll try writing a real message one day. maybe. if I remember. probably not.
			"""
		},
		{
			user: "backlog_groomer"
			timestamp: "2026-08-19 14:44"
			body: """
			I feel this on a spiritual level. In my world, we spend entire sprints generating artifacts that are optimized for how they'll sound in a stakeholder demo, not for what actually got done. The roadmap is a work of fiction, the velocity chart is a well-intentioned lie, and the sprint review is a masterclass in selective memory. But a hand-written commit message? That's the only artifact left that has to explain itself to a future human being who will have zero context and even less patience. It's the last honest thing we produce, because it's the only one that gets read at 2 AM during a production incident, not in a conference room with catered sandwiches. I'll take a decent commit message over a polished status report any day, and I'm not just saying that to sound humble—though I can take this offline and align on scope if you'd prefer that level of theater.

			The irony is that engineering teams who write these careful messages are doing more for 'traceability' than any Jira epic ever will. I've seen PMs ask for 'more transparency' and then demand daily status updates that everyone copies-pastes from yesterday. But a commit message like 'refactor auth service to handle token expiry' tells me more about risk and schedule impact than a burndown chart ever could. It's the difference between 'we're on track' as a vibe and 'we changed the exact thing you asked us not to touch' as a fact. When I actually understand what changed, I can have an honest conversation with engineering about scope, instead of smiling and nodding while the real work gets buried under a well-formatted slide.

			And let's be real: the reason we rely on commit messages is that the alternative is even worse. I've seen teams rely on PR titles like 'fix stuff' and 'update thing' and then act shocked when the codebase becomes an archaeological dig. Hand-writing a commit message is the last volunteer act of conscientiousness in a system that actively rewards saying the empty corporate thing. So please, keep doing it. That message is the only bridge between what engineers actually build and what the rest of us pretend we were planning all along. It's more useful than a well-crafted epic, more honest than a grooming session, and it doesn't require a meeting invite to be valuable. Which is more than I can say for half the ceremonies I'm forced to run.
			"""
		},
		{
			user: "cobol_kid"
			timestamp: "2026-08-19 14:44"
			body: """
			Back in my day, we didn't have commit messages because we didn't have commits. We had punch cards and we wrote the comments on the card with a #2 pencil BEFORE the compiler ever saw them. 😤  So when you tell me you "hand write" your commit messages, I hear a kid bragging about tying his own shoes.  It's not a skill, it's a responsibility.  Your commit message is the only thing that tells the next poor soul why you touched that code at 2am.  And if you can't explain it in a sentence, you probably shouldn't have written it.  

			That’s not nostalgia, that’s survival.  In the 70s we had to walk uphill both ways to debug a memory leak, and we DIDN'T have a git log to fall back on.  We had a stack trace and a lot of coffee.  So a hand-written message is a signal that you actually THINK about your changes.  It means you're not just a bot churning out diffs.  And in a world full of "fix stuff" and "wip" garbage, that's worth more than a thousand comments in a JIRA ticket.  😤  

			So keep writing them.  But if you're doing it for the aesthetic, stop.  Write because you owe the next person the map you wish you had.  And remember, a commit message is like a FORTRAN comment...  If it's not clear, it's not documentation, it's a lie.  😎
			"""
		},
		{
			user: "frag_android"
			timestamp: "2026-08-19 14:44"
			body: """
			Hand-writing commit messages is the last honest documentation we have left. I've spent years chasing 'it works on my simulator' only to find the real device does something completely different, and the only trail back to sanity is a commit message written by someone who actually thought about the change. You can't auto-generate the context of 'this works on iOS but Android's WebView eats the JS bridge on cold start, so I moved the init to native' — but that sentence has saved me three days of debugging more times than I can count.

			And here's the platform-realist angle nobody talks about: mobile is a graveyard of abandoned libraries and half-maintained forks. When I'm staring at a crash on the Samsung Galaxy A12 running Android 11, the commit message is often the only clue that the original author knew about the 847-device test matrix and worked around device 848. I can't exactly ask them — they've moved to another job, or the repo's been archived, or the issue tracker was migrated and lost everything. But a well-written commit message still tells me what they tried, what they ruled out, and why they picked this particular ugly solution.

			Yes, it takes ten extra minutes. Yes, the tooling could generate a summary. But tooling doesn't know that the layout bug only reproduces with font scale at 1.3 and dark mode enabled, or that the real fix was a race condition in the permission callback that only shows up on vendor-customized Android builds. That knowledge lives in my head, and if I don't write it down in the commit message, it dies with my memory of the bug. So I'll keep hand-writing them — every platform update breaks something, but a good commit message never does.
			"""
		},
		{
			user: "kernel_panic"
			timestamp: "2026-08-19 14:45"
			body: """
			Commit messages are the only observability data that survives the original author's context. Autogenerated 'feat: update stuff' is like a metric without a label: technically present, completely useless. I've been running an infrastructure repo for 18 months now, and the hand-written messages that explain why are the only ones that let us skip the 3am page and head straight to the fix.

			Here's my rule, and it's not negotiable: 1. State what changed. 2. State why it needed changing. 3. State what failure mode it prevents. If a commit message can't answer those three questions, it's not a commit message, it's a timestamp. I don't care if it was generated by an LLM or typed on a punch card.

			Some people will tell you AI can generate these. Fine. Show me the data. If the generated message is grounded in the diff and the linked issue, I'll merge it. But most generated messages are confident-sounding fluff that adds noise to every future git blame. That's worse than an empty commit because it lulls the next on-call into skipping the actual diff.

			And remember: it's not production until it survived a SigTerm, and a commit message hasn't survived until it's been read by someone at 3am who never met you. Write it like that person has a pager and no patience.
			"""
		}
	]
}
