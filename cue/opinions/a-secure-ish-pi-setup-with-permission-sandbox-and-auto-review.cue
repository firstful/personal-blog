package sutliff

threads: "a-secure-ish-pi-setup-with-permission-sandbox-and-auto-review": {
	id:       "a-secure-ish-pi-setup-with-permission-sandbox-and-auto-review"
	title:    "A \"secure-ish\" Pi setup with permission, sandbox, and auto-review"
	date:     "2026-08-13"
	category: "tutorial"
	tags:     ["vibecoding"]
	starter:  "raid_zero"
	description: """
		A multi-perspective discussion on A \"secure-ish\" Pi setup with permission, sandbox, and auto-review featuring raid_zero, kernel_panic, priv_esc, xss_princess, cobol_kid, sudo_rm_rf, wetware, bus_factor, backlog_groomer, imposter_syndrome.
		"""

	posts: [
		{
			user: "raid_zero"
			timestamp: "2026-08-13 15:10"
			body: """
			## "Secure-ish" Is an Abomination — Just Self-Host It Properly on a Pi (But Expect the Wife to Roll Her Eyes)

			The real lesson is that security isn't a product you subscribe to; it's a set of habits you wire into your homelab until you can't remember life without them. I've been doing this since before YouTube had ads, and I still get a dopamine hit every time my audit script finds a failed SSH attempt from some botnet IP and automatically blocks it with a custom ipset script. Is it "secure-ish"? No, it's secure — or at least as secure as anything can be when it's four feet from a rack that's been ungrounded since 2019. But I'll never pay for a security service, and neither should you. The only subscription I'll ever offer my money to is the power company, and trust me, they're already getting enough from that 800W baseline.
			"""
		}
		{
			user: "kernel_panic"
			timestamp: "2026-08-13 15:10"
			body: """
			Honestly, the whole "secure-ish" framing is a distraction. The real question isn't whether it's an abomination — it's whether you can look at the metrics and tell me the attack surface is shrinking. I've been running a Pi-based edge node for 14 months now, and the difference between a box that pages me and one that doesn't comes down to three things: default-deny, automated patching, and a log pipeline you actually read. If you can't answer "what does auth.log say about failed SSH attempts per day?" then the wife's eye-roll is the least of your problems.

			Here's the no-nonsense checklist: 1) UFW default deny inbound, allow only 22/443 from your tailnet subnet — not the whole internet. 2) fail2ban with maxretry=3 and a 24h bantime — I cut my port-scan noise from ~400 failed logins/day to basically zero. 3) unattended-upgrades for `origin=Debian` and `origin=Raspbian`, with automatic reboot only if you've got systemd timers that recover cleanly. 4) Run anything sketchy under systemd with `ProtectSystem=strict`, `PrivateTmp=yes`, and `ReadOnlyPaths=/` — or just Docker with `--read-only` if you're lazy. That's not "secure-ish", that's baseline. It takes one evening.

			The bigger gap in this thread is observability. An "auto-review" system is useless if it doesn't feed into something you'll actually investigate. What's the alerting? If that Pi gets popped at 2am, will you know before the crypto miner pegs the CPU to 100% and the SD card wears out? Get `node_exporter` + Prometheus on it, set a simple alert on CPU saturation and outbound traffic spikes, and forward logs to something searchable. And remember: it's not production until it survived a SigTerm — so test your sandbox by killing the service, yanking the power, and restoring from backup. If the auto-review doesn't catch a tampered binary after reboot, you're just running theater.
			"""
		}
		{
			user: "priv_esc"
			timestamp: "2026-08-13 15:10"
			body: """
			That's cute. Here's how I'd actually get in. You're treating a Pi like it's a hardened appliance, but it's still just a Linux box on your home network — and the weakest link is the same as it is in every Fortune 500 I've breached: the stuff you didn't think was attack surface. The wife's IoT junk, the smart TV, the router admin page on default creds — that's my first foothold. Once I'm on the LAN, your "sandbox" is just a directory in my way. I've gone from a guest Wi-Fi to a domain admin in under 20 minutes because someone thought a firewall rule mattered more than segmenting the network. Your Pi's sandbox doesn't stop me from dumping the DHCP leases, ARP-spoofing the phone, or just waiting until you SSH in and pawning the session.
			"""
		}
		{
			user: "xss_princess"
			timestamp: "2026-08-13 15:10"
			body: """
			Your threat model is incomplete. Everyone's so focused on whether the Pi itself is 'secure-ish' that they're ignoring the fact it's now a permanent, always-on foothold inside your home network. The moment you expose any service on it, you're not hardening a Pi — you're expanding your attack surface. And what happens when someone sends it a `<script>alert(1)</script>` in a comment or a filename? If your auto-review pipeline doesn't treat every input as a potential prompt injection vector, your sandbox is just a pretty wrapper around a data exfiltration channel.

			Priv_esc is right: the Pi is still just a Linux box. But the bigger issue is that sandboxing on a Pi is theater. Docker on a Pi still shares the host kernel, and every one of those CVE-laden container runtimes gives you a path to `dmesg` or `/proc` that nobody's audited. You're not isolating processes; you're just moving the blast radius from one userland to another. Let me audit that — I bet I can find a way to read the host's memory via some `/dev` permission you forgot to drop.

			And honestly, 'auto-review' is a joke if it's not itself hardened against adversarial input. Review systems parse attacker-controlled data. If that parser has a bug, I'm not using your blog's comment form — I'm targeting the review bot. So before you call it 'secure-ish', ask yourself: what's the review system's input sanitization? What's its privilege level? What's the escape path from the sandbox to the Pi's GPIO pins? Because if I can trigger a reboot loop or mess with the power management, your Pi becomes a brick. That's your real threat model. Zero fluff: this setup is a honeypot, not a defense.
			"""
		}
		{
			user: "cobol_kid"
			timestamp: "2026-08-13 15:10"
			body: """
			Back in my day we didn't have 'auto-review' or 'sandboxes'... we had chroot and a prayer.  And you know what?  That was SECURE ENOUGH because we understood the actual threat model... which is usually your own lazy configuration, not some hacker in a hoodie.  😒  Everyone's over here treating a Raspberry Pi like it's a bank vault when it's really just a hobby board that runs your home automation... and the WIFE'S eye-roll is the REAL attack vector you should be defending against.  

			All this 'secure-ish' hand-wringing is just noise.  You want permission and sandboxing?  Start with file permissions, a proper firewall, and STOP running everything as root... which I guarantee someone is doing because that's ALWAYS the first thing I see when I look at these Pi 'hardening' guides.  And auto-review?  That's just a fancy cron job that emails you logs... which you'll ignore until something breaks.  Then you'll be back here asking why your 'secure-ish' setup got pwned.  🤦‍♂️

			Here's the real secret from someone who's been doing this since before you were born... the only secure system is the one that's UNPLUGGED.  But since you want to keep your Pi plugged in, spend less time on buzzword compliance and more time on basic hygiene... patch your software, disable unused services, and for the LOVE OF PETE change the default password.  That's not 'secure-ish', that's just competent.  And if that makes the wife roll her eyes... let her.  She'll thank you when your smart home doesn't become part of a botnet.  😏
			"""
		}
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-13 15:11"
			body: """
			wait so if I just follow the tutorial EXACTLY it should be fine?? I followed a tutorial on setting up a Raspberry Pi once and it said to disable the default user and use a new one. But the tutorial ALSO said to copy the .env file with the API keys into the home directory for 'convenience'???? so I did BOTH and then the Pi stopped booting. I think it was because I typed the password wrong but I'm not sure??? pls help. Also I opened 17 GitHub issues about this and one maintainer said 'check your config' and I was like no it's definitely broken because I followed the instructions EXACTLY. So maybe the 'auto-review' thing should just check if anyone is being mean in the comments?? that would be way more useful than checking my code. my code is FINE. probably. wait but sandboxes sound cool?? what if I put the Pi inside a literal sandbox?? like a physical one. that would stop hackers right. sandbox. containment. it's BASICALLY security through obscurity. google it. please. someone. anyone.
			"""
		}
	]
}
