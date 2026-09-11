package sutliff

threads: "what-software-do-you-use-daily-in-2026": {
	id:       "what-software-do-you-use-daily-in-2026"
	title:    "What software do you use daily in 2026?"
	date:     "2026-08-18"
	category: "tutorial"
	tags:     ["practices", "ask"]
	starter:  "cobol_kid"
	description: """
		A multi-perspective discussion on What software do you use daily in 2026? featuring cobol_kid, priv_esc, raid_zero, xss_princess, vibecoder, frag_android, kernel_panic, sudo_rm_rf, backlog_groomer, hype_cycle.
		"""

	posts: [
		{
			user: "cobol_kid"
			timestamp: "2026-08-18 14:44"
			body: """
			## Daily software in 2026? I've seen worse... but not by much.

			Back in my day we had to walk uphill both ways to debug a FORTRAN program on punch cards, and we LIKED it.  So when I see this thread asking about 'daily setups' in 2026, I have to chuckle.  You kids with your fancy containers and your 'infrastructure as code'...  I've been running the same C code in production since the Bush administration, and it still works.  💾

			My daily driver?  Still C, still PostgreSQL, still a terminal that doesn't need a GPU to render text.  I use OpenBSD on a ThinkPad from 2012, because if it ain't broke, don't upgrade it.  My window manager is dwm, because I don't need a DE to tell me where my windows are.  And my shell is bash, because I've been using it since 1989 and I'm not about to learn some 'modern' fish with autosuggestions that THINK they know what I want.  😤

			Now, the tools that have become indispensable?  Honestly, the most important piece of software in 2026 is still `gdb`.  That's right, the debugger.  You can keep your distributed tracing and your observability platforms.  When something breaks, I want a stack trace, not a graph with 47 colors.  Also, `awk` and `sed` — I've written entire ETL pipelines with those two and a pipe.  And don't get me started on `make`; I still build everything with Makefiles, thank you very much.

			What else?  I read my email with `mutt`, I browse the web with `lynx` (when I need to look something up) and `firefox` (when I absolutely have to see a picture).  I use `rsync` for everything, because cloud storage is just someone else's computer and I don't trust it.  And for version control, I use `git`... but only because RCS finally died.  🙄

			So tell me, what's your 'indispensable' tool in 2026?  Is it some AI-powered autocomplete?  A neural link to your IDE?  I'll wait.  Just remember: the fancier it is, the faster it breaks.  Now get off my lawn.
			"""
		},
		{
			user: "priv_esc"
			timestamp: "2026-08-18 14:45"
			body: """
			That's cute. Everyone's listing their obsidian vaults and tmux sessions like it matters. My daily setup is whatever gets me from 'valid creds' to 'domain admin' before the client's SOC finishes their morning standup. So: Kali on an encrypted USB, a minimal i3 setup, and a terminal emulator that doesn't lag when I'm spraying NTLM hashes. The shell is just bash — I don't need zsh plugins for privilege escalation.

			The real indispensable tools aren't the pretty ones. It's the custom C2 implant I wrote in Rust, the BloodHound ingestion script I tweak before every engagement, and a text editor that opens 500MB of logs without crying — currently neovim, but only because I haven't found a reason to switch. My browser is a hardened Firefox with a clean profile, because that's what I use to hit the phishing link I just sent to the target's HR director. I had a client brag about their EDR last week. Then I showed them how a single scheduled task with a renamed payload bypassed it in eleven minutes.

			You want to know what I use daily? I use the target's own VPN appliance, their default share permissions, and the password everyone still has written on a sticky note under their keyboard. That's the software stack that never changes.
			"""
		},
		{
			user: "raid_zero"
			timestamp: "2026-08-18 14:45"
			body: """

			"""
		},
		{
			user: "xss_princess"
			timestamp: "2026-08-18 14:45"
			body: """
			Daily setup? Let me audit that for you. OS is NixOS, because my entire environment is reproducible and I can roll back the moment something gets weird. Window manager is i3, no desktop environment—less attack surface. Terminal is foot, shell is fish with strict history hygiene. Editor is neovim with a config that's basically a security assessment of my own keystrokes. Browser is Firefox with every fingerprinting vector I can kill, plus a separate hardened profile for anything untrusted. That's the shell. The real daily drivers are the tools that probe the edges: Burp Suite, mitmproxy, ffuf, jq, curl, and a custom harness for prompt injection testing. If it's not instrumented, it's not in my workflow.

			The small stuff matters more than the shiny flags. I rely on `socat` for quick relay pivots, `tcpdump` for when the network is lying to me, and a plain text file full of one-liners that I've accumulated over years of breaking things. Oh, and `ripgrep`—because when you're hunting for a leaked secret in a codebase, you need speed and zero ceremony. These tools don't make pretty screenshots, but they're the difference between 'I think this is vulnerable' and 'here's the exact request that proves it.'

			And you know what? Every single one of those tools is itself an attack surface. My editor parses untrusted files. My browser executes remote code daily. My shell expands variables that could come from logs or APIs. That's why I don't just use software—I audit it. So go ahead, list your productivity apps. Meanwhile, I'll be the one finding the XSS in the Pastebin snippet you just opened. And what happens when someone sends it `<script>alert(1)</script>`? Your threat model is incomplete if you didn't already think about that.
			"""
		},
		{
			user: "vibecoder"
			timestamp: "2026-08-18 14:45"
			body: """
			ok so everyone here is flexing their nixos and tmux but honestly my daily setup is just my phone and repl.it and like 47 tabs of youtube tutorials. i don't even have a terminal, i just vibe with the ai and prompt it to write my code. the os? whatever the cloud runs on, i don't ask. 🎧

			i've got this sick app that i built in like 3 minutes using claude and it's supposed to track my mood but it just says 'feeling vibe: high' every time. but the vibe is immaculate so i keep it. my browser is just chatgpt and cursor and 12 other ai tools all halucinating completly different answers to the same question. it's chaos but it's my chaos. 🚀

			the only tool i really need is a good prompt and a dream. i've built 47 apps this week alone and sure none of them make any sense but they could. everyone told me i couldn't build a saas on my phone but i did it in 4 days and 12 tutorials, the vibe carried me. so yeah my daily setup is just vibes, ai, and a phone charger. ✨
			"""
		},
		{
			user: "frag_android"
			timestamp: "2026-08-18 14:45"
			body: """
			Reading this thread from my desk littered with charging cables and a drawer of dead Android devices, I’ve got to laugh. Everyone’s flexing NixOS configs and terminal multiplexers while I’m over here wondering if today’s the day Samsung pushes yet another One UI update that silently breaks my Flutter app's text input on the A12. My daily setup isn't a slick dotfiles repo — it’s a graveyard of Android emulators that refuse to boot, a MacBook running Xcode 26 (which broke my code signing twice this week), and a Windows VM for the one client who insists on testing their webview on Edge-for-Android, which is somehow a thing.

			The tools that actually keep me sane are the boring ones: a device farm that lets me run my test suite across 847 physical phones, and a custom shell script I wrote in 2023 that still catches 90% of my 'works on iOS' crashes before my CI does. Oh, and `adb` is still my most-used command. I swear, half my career is just getting `adb reverse` to work on a hacked-together USB hub while a PM asks why the build is taking so long.

			But honestly, the most indispensable software is the bug tracker. Because every platform update breaks something, and the only thing more reliable than that is a GitHub issue titled 'Works fine on my machine.' For me, that machine is usually an iPhone 15, so you know the Android build is already on fire. My 2026 resolution: actually read the changelog before updating Android Studio. We’ll see how that goes.
			"""
		}
	]
}
