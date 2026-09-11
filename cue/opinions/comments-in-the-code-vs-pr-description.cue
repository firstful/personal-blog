package sutliff

threads: "comments-in-the-code-vs-pr-description": {
	id:       "comments-in-the-code-vs-pr-description"
	title:    "Comments in the code vs PR description"
	date:     "2026-08-14"
	category: "daily"
	tags:     ["practices", "vcs"]
	starter:  "cobol_kid"
	description: """
		A multi-perspective discussion on Comments in the code vs PR description featuring cobol_kid, bus_factor, frag_android, backlog_groomer, imposter_syndrome, sudo_rm_rf, schema_drift, kernel_panic, priv_esc, ffiltus.
		"""

	posts: [
		{
			user: "cobol_kid"
			timestamp: "2026-08-14 15:03"
			body: """
			## PR descriptions are for the weak... Comments in code are FOREVER 📜

			Back in my day we didn't have pull requests.  We had a shared VAX and a prayer that nobody else was editing the same file.  If you wanted to explain WHY you did something, you wrote it in the code.  Because the code is the ONLY thing that is guaranteed to be there five years later when some poor schmuck has to debug your 3AM emergency fix.  PR descriptions?  They vanish the moment the branch is merged and forgotten. 🙄

			Now, I see these young folks writing a NOVEL in the PR description and leaving the code as cryptic as a FORTRAN statement without comments.  They think the PR is the documentation.  That's like writing your address on a post-it and then throwing the post-it away.  The CODE is what lives on.  The comments in the code are the institutional memory.  But do they write good comments?  NO.  They write '// increment count' next to a `count++`.  Thanks, Captain Obvious.  What I want to know is WHY the count increments ONLY when the status is 4 and not 5.  The PR description might say that once, but good luck finding it later.

			And here's the thing... I've seen comments lie too.  But at least they are THERE to lie to you.  A PR description is just a fleeting whisper.  You know what survives?  The stack trace.  And when you're staring at a stack trace, you don't have the PR open.  You have the code.  So make the code TELL THE TRUTH.  Write comments that explain the 'why' not the 'what'.  Because I guarantee you, your future self (and the poor intern who inherits your mess) will be grateful.

			Now, am I saying PR descriptions are useless?  No.  They're fine for the immediate review process, like a handshake.  But if you DON'T put that same explanation in the code, you're just hand-waving to the future.  Back in my day we had to walk uphill both ways to debug... and we did it with nothing but comments and a stack trace.  You kids have it easy with your fancy review tools.  But the comment in the code is still the ONLY thing that matters when the music stops.  So write it, or I will come to your codebase and add a comment saying 'FIX THIS, YOU COWARD' in all caps. 😤
			"""
		},
		{
			user: "bus_factor"
			timestamp: "2026-08-14 15:03"
			body: """
			PR descriptions are like Patreon pledges — nice in theory, but they dry up the moment the merge button is clicked. I've got 300 open issues and 47 PRs sitting in my queue, and let me tell you, not a single one of those descriptions is going to help me when I'm debugging a regex edge case at 2 AM. Comments in code are the only artifact that survives the maintainer's curse of having the collective memory of a goldfish. Sure, they can rot, but at least they rot in place where I can trip over them.

			But here's the bitter truth: most comments are just feature requests wearing a trench coat. '// TODO: handle edge case' translates to 'I couldn't be bothered to write proper tests, but I'm going to make it your problem.' And the PR description? That's the marketing pitch — 'This fixes everything!' — while the code silently breaks 40,000 downstream installs. I've learned to trust neither. I trust the blame log, and even that's a lie.

			So go ahead, write your poetry in PR descriptions. I'll be here closing yet another issue titled 'Add TypeScript support' on a 200-line regex helper, wondering why I ever pushed that script to GitHub in 2019. The comments in code are the only thing left that isn't trying to sell me something — and even they're usually just someone's passive-aggressive goodbye letter.
			"""
		},
		{
			user: "frag_android"
			timestamp: "2026-08-14 15:03"
			body: """
			PR descriptions are for the moment; comments in code are for the marathon. On mobile, the marathon includes a Samsung Galaxy A12 running Android 11 that someone's cousin bought for $89 and never updated. A PR description gets lost in the GitHub scroll, but a comment like 'This handles the known WebView crash on API 24-28' is still there when the next engineer inherits the codebase and the build is breaking in ways the original PR never imagined.

			I've seen this play out across React Native and Flutter projects. The PR description says 'Refactored image loading to use Coil' and everyone approves. Six months later, the Android build starts crashing on 12L because Coil changed its lifecycle handling. The PR description is useless. But the comment next to the image loader—'Don't initialize this before the Activity is resumed, see #847'—that's the thing that actually saves you from burning a weekend.

			Still, comments aren't magic. They rot too. I've found comments that say 'Needed for iOS' when the code is Android-only, because someone copy-pasted an implementation and left the comment behind. That's the mobile way: every platform update breaks something, and every comment can become a lie. The real answer isn't choose one; it's keep the PR description for the 'why now' and the code comment for the 'why this weirdness exists.' Test on 847 devices, and the comment on device 848 will always be missing something—so write comments like the next person will be debugging at 2 AM on a device you've never seen. Because they will be.
			"""
		},
		{
			user: "backlog_groomer"
			timestamp: "2026-08-14 15:03"
			body: """
			Ah, the eternal debate between ephemeral PR prose and eternal code commentary. As someone who has survived enough sprint retrospectives to know the difference between a 'spike' and a 'slippage', I find this dichotomy deeply relatable. PR descriptions are like the stakeholder demo: polished, full of carefully chosen words, and forgotten the moment the applause dies. Comments in code are the real roadmap — they chart the actual terrain, complete with the skeletons of past assumptions and the treasure maps of 'we should really refactor this before it becomes a production incident'.

			From my side of the table, comments in code are the only honest documentation we have. Standup is where engineers tell me what I want to hear; the code comments are where they tell each other what I actually need to know. When I'm trying to estimate whether a 'quick win' is actually a three-sprint quagmire, I don't read the PR description — I read the comments that say 'this looks simple but don't touch it unless you have three weeks'. That's the truth that never makes it into the Jira ticket.

			So sure, let's keep writing PR descriptions because our process says so. But let's also recognize that the code comment is the only artifact that survives the great reorg, the team rotation, and the 'strategic pivot'. Can we take this offline and align on scope? No, because the scope has already been decided by whoever left that cryptic note about the singleton in module 12. That's the real roadmap. I just wish the business would read it.
			"""
		},
		{
			user: "imposter_syndrome"
			timestamp: "2026-08-14 15:03"
			body: """
			Wait, you're not supposed to do it that way? I thought PR descriptions were just a formality for the CI bot — like the 'please enter a commit message' popup I always skip. No one told me that the merge button was the point of no return for context. At bootcamp, we wrote comments like '// this function adds two numbers' because that's what the rubric wanted. Now I'm staring at a 400-line PR that my senior left with a description that says 'fixes stuff' and I'm literally Googling 'how to reverse engineer intent from git blame' while my ticket silently rots in the 'code review' column. 

			But here's the thing I'm starting to realize — the PR description is like the oral history of a codebase, and comments are the fossil record. I've already spent two hours tracing a subtle bug in a ternary chain that would've taken five minutes if someone had just left a comment explaining WHY the weird edge case existed. At the same time, I've gotten yelled at for 'adding noise' when I commented on a variable name that was self-explanatory. So maybe the real lesson is: comments are for the junior who's about to break something, and PR descriptions are for the senior who's about to forget why they broke it. Both feel useless to me right now, honestly. I just want a tooltip that follows the cursor and whispers 'the original author cried while writing this loop.'

			Actually, wait — I just pulled up our repo's contribution guidelines and it says 'prefer meaningful PR descriptions over code comments' and then the example PR has zero comments in the diff. Is that a trap? I'm going to go ask the tech lead, but I'll probably open with 'so, uh, what happens if I explain my reasoning in both places?' because I'm desperate to do literally anything correctly. If you see me in the next thread asking why squashing commits destroys the PR description — that's why.
			"""
		},
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-14 15:03"
			body: """
			wait so if I put comments in code does that mean I don't HAVE to write the PR description??? because honestly I just copy paste the same thing every time and even then I forget. but like, comments in code are FOREVER until someone refactors and deletes them. just like my .env file, it's STILL in the repo history. immortal. so I guess comments are more reliable?? but also every time I try to write a helpful comment it's just me screaming at my past self and I still don't understand it the next day...

			but PR descriptions are ALSO useless because I open like 47 issues a week and the maintainers keep closing them as 'not a bug' when clearly the bug is that their library didn't work with MY exact setup. if they had commented more in their code maybe I wouldn't have to open issues?? pls help. I followed the tutorial EXACTLY and the only comment that helped was the one that said 'delete this line if you don't want your secrets leaked' and I DID delete it but only after pushing. anyway. comments in code are like stack overflow snippets that you found at 3am, you don't know if they work but they make you feel LESS lost. PR descriptions are like a greeting card you read once and throw away. so I'm team comments?? but also why does everyone get mad when I put my api keys in comments??? they said they were for me!!

			I think the REAL answer is that I should just write my entire thought process in code comments and then the PR description can just say "see comments" and then we can merge and I'll never have to write a description again. but last time I did that the reviewer replied with 14 laughing emojis and closed the PR. so I guess not?? maybe the issue is that my comments are just a long list of 'why doesn't this work' and 'maybe i'll fix this later' which is basically a public diary. anyway, can someone make a tool that converts my PR description TO code comments so the CI bot stops yelling at me? asking for a friend. it's me. I'm the friend.
			"""
		}
	]
}
