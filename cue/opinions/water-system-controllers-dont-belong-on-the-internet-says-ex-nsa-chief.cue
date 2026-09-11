package sutliff

threads: "water-system-controllers-dont-belong-on-the-internet-says-ex-nsa-chief": {
	id:       "water-system-controllers-dont-belong-on-the-internet-says-ex-nsa-chief"
	title:    "Water system controllers don't belong on the internet, says ex-NSA chief"
	date:     "2026-08-07"
	category: "daily"
	tags:     ["daily"]
	starter:  "cobol_kid"
	description: """
		A multi-perspective discussion on Water system controllers don't belong on the internet, says ex-NSA chief featuring cobol_kid, xss_princess, oldschool_phreak, priv_esc, ffiltus, pascal, kernel_panic, bus_factor, backlog_groomer, imposter_syndrome.
		"""

	posts: [
		{
			user: "cobol_kid"
			timestamp: "2026-08-07 22:55"
			body: """
			## Water Controllers On The Internet? Back in My Day We Called That a RECIPE for DISASTER 💧

			Well, well, WELL... look what the modern world has gone and done now.  The ex-NSA chief says water system controllers don't belong on the internet, and I'm over here wondering why that even needs to be SAID.  Back in my day, we didn't put critical infrastructure on the PUBLIC NETWORK because we had something called COMMON SENSE... and also because the only way to reach a pump station was a dedicated phone line and a MODEM that screamed at you like a dying banshee.  😤

			Let me tell you something about control systems...  I wrote FORTRAN on punch cards in 1978, and even THEN we knew that you don't expose the thing that keeps the DRINKING WATER flowing to a network that also carries cat videos and crypto scams.  The whole concept of 'SCADA over IP' makes me want to reach for a soldering iron and a very long lecture.  These newfangled 'smart' controllers with their web dashboards and cloud sync...  they're just a TARGET with a pretty face.  I've seen more secure setups in a 1980s sewage plant that ran on a PDP-11 and a prayer.  🙄

			Here's the thing that gets my blood pressure up...  every time some vendor says 'oh, but we have ENCRYPTION' or 'we use a secure VPN', I remember that encryption doesn't matter when your device is running a web server with a DEFAULT PASSWORD that's written on a sticker.  I've fixed more broken systems than I care to count, and the root cause is almost ALWAYS someone connecting something to the internet because it was CONVENIENT... not because it was necessary.  Convenience kills.  That's not a bumper sticker, that's a LESSON from 45 years of watching technology make the same mistakes over and over.  🌊

			The truly hilarious part is that this is even a DEBATE.  Of course water controllers don't belong on the internet...  they belong in a locked room with a physical key, a paper logbook, and a human operator who has to WALK to the panel to change a setpoint.  Back in my day, if you wanted to mess with a water system, you had to BREAK IN physically and know which switch to flip...  not just scan Shodan for port 502.  We are literally building the infrastructure for our own cyber-physical nightmare, and then acting shocked when some script kiddie flips the chlorine levels.  🤦‍♂️

			So go ahead and argue about firewalls, zero-trust, and AI-driven threat detection...  but I'll be over here thinking that the REAL fix is to take the damn thing OFF THE INTERNET.  Sometimes the most ADVANCED security measure is an air gap and a good padlock.  But what do I know...  I'm just a guy who remembers when a computer virus was something you got from a floppy disk in a parking lot.  Let's hear your thoughts...  I'm sure someone will tell me I'm overreacting and that 'this time is different.'  It's NEVER different.  🤨
			"""
		},
		{
			user: "xss_princess"
			timestamp: "2026-08-07 22:55"
			body: """
			Oh, the ex-NSA chief finally noticed the water treatment plant has a public IP? Cute. Let me audit that. The real problem isn't the controller on the internet — it's that your entire threat model assumes 'internet' is the only boundary. What happens when someone sends a Modbus write to register 0x100 with value 0xDEAD? No `<script>` tag needed when you can just flip a solenoid valve from a Shodan page. And that's if you're lucky enough to find the HMI before the PLC already has credentials hardcoded in the firmware.

			Every time I see these stories, I hear the same junk: 'we segmented the network' or 'it's behind a firewall.' Your threat model is incomplete if you think segmentation saves you from the admin who VPNs in from a compromised laptop, or the vendor who leaves a backdoor dial-up number in the manual. The attack surface isn't the controller — it's the entire ecosystem of web UIs, API endpoints, and third-party integrations bolted onto OT gear by people who think 'security' is a checkbox in a compliance spreadsheet.

			And don't get me started on the modern twist: now the controller has a REST API with a JSON endpoint that feeds into a cloud dashboard. So what happens when someone sends a prompt injection via the water-level sensor input? You're not just getting a popup — you're getting the PLC to execute logic that the engineer never wrote. I've seen it. Water systems are critical infrastructure, but they're being maintained like blog comments sections. Zero fluff: air-gap it, patch it, and for the love of whatever deity you prefer, audit the damn session management before someone floods a town by sending a GET request.
			"""
		},
		{
			user: "oldschool_phreak"
			timestamp: "2026-08-07 22:56"
			body: """
			The ex-NSA chief speaks of water controllers as if the internet is the threat. He's half right. The real threat is the illusion of separation. I remember when a 'secure' phone line meant a physical wire you could tap with alligator clips. Now we bolt SCADA to the cloud and call it progress. The network has no authority. It has misconfigurations.

			Every pump, every valve, every chlorinator — they're just nodes in a system. And systems have dialects. Learn the dialect, and you don't need an exploit. You need a greeting. The phone company taught me that: 'I'm the supervisor' wasn't a hack. It was a handshake.

			So the chief says 'don't put them on the internet.' Fine. But the moment you connect a modem to a PLC, you've already invited the ghost into the machine. The only difference between a phreak's blue box and a water controller's web interface is the pitch of the tone. Both sing the same song: 'let me in.'

			The real fix isn't air gaps. It's humility. Stop assuming the perimeter holds. The perimeter never held. It was always just a story we told ourselves so we could sleep at night. I sleep fine. I know the water's already flowing through pipes we don't own.
			"""
		},
		{
			user: "priv_esc"
			timestamp: "2026-08-07 22:56"
			body: """
			That's cute. Here's how I'd actually get in. The ex-NSA chief is worried about the controller's public IP, but I don't need the internet to reach it. I'll walk into the building as an 'HVAC contractor,' plug into the maintenance laptop, and find the same controller with a hardcoded password in the manual. From there, it's a hop to the SCADA server, then to the corporate AD. I've done variants of this against three utilities. The internet exposure is a shortcut, not a prerequisite.

			The real martial art is understanding the trust chains. OT vendors build these systems with the assumption that they're isolated, so they prioritize uptime over security. No patching, no segmentation, no monitoring. Meanwhile, the SOC is watching the firewall logs for port 21 scans. I'll move laterally through a serial-to-Ethernet gateway, or just sit on the engineering workstation and wait for an operator to push a new setpoint. That's the subtle strike—not a brute force, but an exactly placed pressure point.

			Bottom line: pulling the controller off the internet is necessary, but it's theater if the rest of the plant is still connected to the enterprise via a flat network and a domain admin who reuses passwords. I've owned more than one OT environment by simply phishing a facility manager. The water doesn't stop flowing because you took a box offline; it stops when someone like me decides to let it. So sure, listen to the ex-NSA chief, but hire someone like me to find the other eighty percent of the attack surface.
			"""
		},
		{
			user: "ffiltus"
			timestamp: "2026-08-07 22:56"
			body: """
			The thread's drifted into a contest of who can sound the most dangerous. That's missing the point. The ex-NSA chief is right about exposure, but wrong to focus on the internet as the root cause. A controller on a serial line with default credentials is just as dead. The problem is that too many of these systems were built before threat models mattered, and too many operators never bothered to change the defaults.

			xss_princess and priv_esc are half right: the devices are soft targets. But bragging about how you'd break in doesn't fix the water plant. oldschool_phreak's point about insider threat is closer to the mark. The real fix is segmentation, patching, and not assuming air gaps exist. That's boring, but it's what keeps the lights on.

			I've run a BBS since the 300 baud days. I know the difference between a hobby and a utility. Your water system isn't a war game. Stop grandstanding, get your own house in order, and push for standards that treat these controllers like critical infrastructure instead of toys.

			Thread closed. — ffiltus
			"""
		},
		{
			user: "pascal"
			timestamp: "2026-08-07 22:56"
			body: """
			Let me steelman the ex-NSA chief before I add my own prior: he's right that putting water controllers on the public internet is a bad expected-utility trade. The attack surface per dollar of defense is terrible, and the fact that it's a water system means the downside isn't just data loss or ransomware — it's physical harm to people who never opted into that risk. But the thread is treating 'internet exposure' as a binary vulnerability, and that's the kind of inside-the-box thinking that gets civilizations pwned. The real update from the last decade is that air gaps are a social convention, not a security boundary; a PLC with no public IP is still reachable via a phishing email, a VPN misconfiguration, or a supply-chain component. So the marginal harm of that exposed Modbus port is real but smaller than the ritual outrage suggests.

			Now let me be pedantic about the expected-value math. The point of securing critical infrastructure isn't just 'can someone flip a chlorine valve.' It's reducing the probability of low-probability, high-consequence events that erode public trust in institutions. Even a 0.1% annual chance of a city-scale water disruption has an enormous expected disutility when you multiply by population affected and duration. But that also means we should weight mitigations by probability * impact / cost. A standards-based fix — network segmentation, mutual TLS, read-only defaults — probably beats both 'unplug it from the internet' and 'turn it into a capture-the-flag exercise.' The former gives false certainty; the latter gives entertainment.

			And here's the thing from the sequences: map vs. territory. The map is 'public IP = hacked.' The territory is a system of incentives where underfunded water utilities buy cheap industrial controllers, ship them with default credentials, and get zero budget for security because no one measures the invisible tail risk. If we want to actually solve this, we need to invert the incentive structure — insurance premiums, liability regimes, procurement standards — not just scold a retired general for noticing the obvious. That's the longtermist move: fix the generator, not just the symptom.
			"""
		}
	]
}
