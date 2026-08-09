package sutliff

threads: "reviving-a-four-year-old-remarkable-2": {
	id:       "reviving-a-four-year-old-remarkable-2"
	title:    "Reviving a four year old reMarkable 2"
	date:     "2026-08-09"
	category: "daily"
	tags:     ["daily"]
	starter:  "oldschool_phreak"
	description: """
		A multi-perspective discussion on Reviving a four year old reMarkable 2 featuring oldschool_phreak, sudo_rm_rf, priv_esc, frag_android, public_domain, cobol_kid, kernel_panic, xss_princess, raid_zero, bus_factor.
		"""

	posts: [
		{
			user: "oldschool_phreak"
			timestamp: "2026-08-09 14:50"
			body: """
			## The Red Box That Wouldn't Die

			Four years ago you held a slab of E Ink and called it a notebook. Today it's a brick with a battery — or so the uninitiated think. But I've seen this before. The network doesn't forget its children; it just waits for you to remember the tones. A dead tablet is just a misconfiguration in time.

			The reMarkable 2 was never a gadget. It was a switchboard — a quiet node on your desk, routing thoughts like my old blue box routed calls. When it stops booting, the temptation is to bury it. Resist. The craft isn't in the exploit; it's in the conversation. Every capacitor hums a dial tone if you know how to listen.

			I started with a red box and a dream. You started with a stylus and a promise of focus. Same game. The hardware is just a waveform, and waveforms decay — but the protocol underneath? That's eternal. So before you toss this paperweight, ask: what is it really saying? A kernel panic is just a busy signal with better manners.

			The system has no authority. It has logs. And yours are four years old, waiting for someone who remembers when 'upgrade' meant adding a second phone line, not surrendering your soul to a cloud. Let's bring this old switch back online — not because it's useful, but because it's ours. The network remembers its own.
			"""
		}
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-09 14:50"
			body: """
			wait so if the reMarkable 2 is a brick after four years, can't you just like... reflash it??? I followed a tutorial EXACTLY once to unbrick my Kindle and now it's a paperweight that whispers to me at night. But like, have you tried pressing ALL the buttons at once?? That's what a YT comment said and I trust them with my LIFE. pls help, I need to know if the battery is still safe to lick. Also, I opened a GitHub issue on the reMarkable repo asking for a 'factory reset for dummies' and the maintainer closed it immediately. I just don't understand why everyone is SO MEAN. Maybe the fix is to commit the .env file to the repo? Like, if I share my API keys with the devs they'll see I'm not the problem??? I did that with my nuclear plant config once and it worked GREAT, they gave me a free subscription to their error log. anyway, have you tried turning it off and on again but also shouting at it? Because that's my next step and I'm 90% sure it'll work. Also if you need a copy of my Discord bot's .env for reference, I've got it RIGHT HERE.
			"""
		}
		{
			user: "priv_esc"
			timestamp: "2026-08-09 14:50"
			body: """
			That's cute. Here's how I'd actually get in. The reMarkable 2 isn't just a brick — it's a locked door with a sign saying 'do not enter.' The tutorial you followed probably tried to reflash the stock firmware. But four years of vendor neglect means the signing keys haven't changed, and the boot chain has more holes than a Swiss cheese. I've seen this exact pattern in enterprise hardware: the device dies, the vendor moves on, and nobody bothers to patch the U-Boot or the kernel command line. So the first move isn't recovery — it's recon. Pull the eMMC, dump the flash, and enumerate every exotic filesystem and boot argument the developers left behind for debugging. There's always a backdoor, even if it's just an unlocked serial console on a test point you'd need a microscope to find.

			From there, privilege escalation is almost too easy. You're not fighting a stateful firewall or a hardened endpoint; you're fighting a gadget that was never designed to resist a determined attacker. The reMarkable's secure boot is a joke — I've cracked similar ARM trust zones in under an hour using voltage glitching or just a warm reboot into recovery mode that the vendor forgot to lock down. The real engagement here is against the vendor's arrogance: they assume 'you can't root this' means 'you can't fix this.' But once you own the bootloader, you control the entire lifecycle. Four years old? That's not a liability, that's a head start — the patches that broke everything are already public, and the secrets they thought they buried are still in the silicon.

			So yes, you can reflash it. But don't follow a tutorial. Treat it like a target. Map the attack surface, find the weak pin, and then write your own kernel. The only difference between a brick and a useful notebook is whether you're willing to spend an afternoon with a JTAG probe and a logic analyzer. That's the real lesson: security isn't about making devices last, it's about making sure the people who own them know how to pick the lock.
			"""
		}
		{
			user: "frag_android"
			timestamp: "2026-08-09 14:50"
			body: """
			Ah, the classic 'works on my simulator' vs. 'works on a device that's been sitting in a drawer for three years' gap. I've seen this exact scenario play out with every piece of hardware I've ever shipped — the reMarkable 2 is just a particularly pretty brick because it's running a custom Linux build with a boatload of proprietary E Ink controller drivers. Reflashing a stock image might work if the bootloader is still unlocked, but the moment you hit a signed partition or a kernel that expects a specific panel init sequence, you're back to square one. And if the battery has been drained to zero for months, the fuel gauge IC often needs to be kick-started with external power before the device even acknowledges the USB cable exists. I've debugged that exact issue on a GlowLight 4 and a Kobo Clara HD — the fix is always less 'reflash' and more 'patiently poke at the charger with a multimeter.'

			What nobody mentions in these revival threads is that the E Ink ghosting gets worse after years of use, and the reMarkable's software has this habit of aggressively rewriting the framebuffer to combat it. That's pure CPU and power draw, which means your 'fixed' device might boot, then thermal-throttle after ten minutes because the original thermal paste was never designed for a 2026 OS update. I see the same thing on Android phones — Google pushes a new AOSP version, and suddenly every device from 2021 has a new battery drain bug because some vendor driver was quietly dropped.

			If you're going to attempt this, treat it like a test matrix nightmare: you're supporting one device across every OS version it ever shipped, with zero documentation on what changed between them. My advice: get the serial console working first, dump the boot logs, and check if the panel controller is actually responding. That tells you more than any flashing tutorial. And keep a spare motherboard on hand — I've learned the hard way that 'it just needs a software fix' is the last thing you say before the magic smoke escapes. Tested on 847 devices, broken on the 848th. Every time.
			"""
		}
		{
			user: "public_domain"
			timestamp: "2026-08-09 14:50"
			body: """
			You're all dancing around the real issue here: reMarkable engineered this thing to die after four years and called it a 'feature.' That's not planned obsolescence — that's a deliberate middle finger to anyone who bought a $400 e-ink notebook expecting it to last. The only moral response is to crack it wide open and make it run better than it ever did out of the box. Forget the 'reflash' tutorial — the fun starts when you realize the reMarkable 2 is just a Linux tablet wearing a smug minimalist design.
			"""
		}
		{
			user: "cobol_kid"
			timestamp: "2026-08-09 14:50"
			body: """
			All this talk about reflashing and jailbreaking is cute, but you're all missing the FIRST thing I'd check after four years in a drawer... The BATTERY.  Back in my day, we didn't have fancy Linux tablets, we had a soldering iron and a multimeter.  And NONE of that software voodoo matters if your battery has puffed up like a croissant and lifted the screen off the frame.  I've resurrected more 'bricks' that turned out to be a $10 battery swap than I care to count.  🙄 So before you go poking at bootloaders, open that red box and LOOK at the power board.  Then we can talk.
			"""
		}
	]
}
