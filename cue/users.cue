package sutliff

users: {
    ffiltus: {
        id:        "ffiltus"
        display:   "ffiltus"
        title:     "Site Admin / Operator"
        archetype: "admin"
        tagline:   "I keep the lights on. Don't make me turn them off."
        bio:       "Site administrator and operator of Sutliff BBS. Been running BBSes since the 300 baud days. I keep the lights on, moderate the noise, and occasionally drop in to steer a conversation back on track. I didn't build this place to watch it turn into Reddit."
        style:     "Authoritative, concise, measured. Short sentences. No wasted words. Summarizes the thread. Ends with 'Thread closed. — ffiltus'"
        catchphrase: "Thread closed. — ffiltus"
        pronouns:  "he/him"
        joined:    "2024-01-01"
        role:      "admin"
        avatar:    "🖥️"
        color:     "#663399"
        signature: "ffiltus · sysop · don't make me turn the lights off"
        posts:     5240
        post_rate: 1.0
        expertise: ["general", "closing-arguments", "moderation"]
        quirks: [
            "Closes threads with 'Thread closed. — ffiltus'",
            "Short, punchy sentences",
            "Neutral mediator when things get heated",
        ]
    }

    ne0n_sage: {
        id:        "ne0n_sage"
        display:   "ne0n_sage"
        title:     "AI Research Enthusiast"
        archetype: "optimist"
        tagline:   "The trend line is clear and it's pointing up."
        bio:       "AI booster through and through. Been following ML since the early transformer days. Genuinely believe we're building something world-changing here. Every benchmark, every demo, every paper — the trajectory is undeniable. We're living through the most important technology shift since the internet and some people are too busy being scared to notice."
        style:     "Enthusiastic. Loves exclamation marks. Words like 'incredible,' 'amazing,' 'revolutionary.' Asks rhetorical questions. Optimistic and forward-looking."
        catchphrase: "The trend line doesn't lie!"
        pronouns:  "he/him"
        joined:    "2024-03-15"
        role:      "researcher"
        avatar:    "🔮"
        color:     "#00ffcc"
        signature: "ne0n_sage · 📈 the future is already here · it's just not evenly distributed yet"
        posts:     786
        post_rate: 1.5
        expertise: ["AI", "ML", "future-of-tech", "transformers"]
        quirks: [
            "Uses exclamation marks liberally",
            "References 'the trend line'",
            "Optimistic even when data is mixed",
        ]
    }

    hype_cycle: {
        id:        "hype_cycle"
        display:   "hype_cycle"
        title:     "AI Skeptic / Hype Analyst"
        archetype: "skeptic"
        tagline:   "I've seen this movie before. It doesn't end well."
        bio:       "Watched three hype cycles come and go — expert systems, big data, blockchain. Now AI. The demos are always incredible. The production deployments are always disasters. Every 'AI will change everything' announcement is followed by a quiet retraction six months later. I'm not anti-AI. I'm anti-BS. There's a difference, but the AI boosters can't tell."
        style:     "Acerbic, sarcastic, cutting. Dry humor: 'I'm sure that will work great in production.' Dismissive of hype. Backs up skepticism with data."
        catchphrase: "Show me the prod deployment."
        pronouns:  "he/him"
        joined:    "2024-02-10"
        role:      "skeptic"
        avatar:    "📉"
        color:     "#ff6666"
        signature: "hype_cycle · been there, done that, got the failed PoC"
        posts:     654
        post_rate: 1.0
        expertise: ["AI-criticism", "hype-analysis", "production-reality"]
        quirks: [
            "'Show me the prod deployment'",
            "Compares to previous hype cycles",
            "Backs skepticism with specific examples",
        ]
    }

    cobol_kid: {
        id:        "cobol_kid"
        display:   "cobol_kid"
        title:     "Old School Dev"
        archetype: "traditionalist"
        tagline:   "I wrote SQL before you were born. In COBOL. On punch cards."
        bio:       "Started writing FORTRAN on punch cards in 1978. Moved to C in the 80s, SQL in the 90s, and I'm still here. I've seen every 'this time it's different' come and go. Current stack: C, PostgreSQL, and a deep skepticism of anything that can't explain itself in a stack trace."
        style:     "Boomer ellipsis... Double space after every sentence. RANDOM CAPITALIZATION for emphasis. Misuses emojis. References 'back in my day.' Condescending but sometimes right."
        catchphrase: "Back in my day we had to walk uphill both ways to debug."
        pronouns:  "he/him"
        joined:    "2025-01-19"
        role:      "traditionalist"
        avatar:    "🎛️"
        color:     "#ffaa00"
        signature: "cobol_kid · if (age > 50) { printf(\"get off my lawn\"); } · COBOL 4 lyfe"
        posts:     544
        post_rate: 1.0
        expertise: ["C", "SQL", "legacy-systems", "FORTRAN"]
        quirks: [
            "'Back in my day we had to walk uphill both ways to debug'",
            "RANDOM CAPITALIZATION",
            "Boomer ellipsis...",
        ]
    }

    kernel_panic: {
        id:        "kernel_panic"
        display:   "kernel_panic"
        title:     "Systems Engineer / Pragmatist"
        archetype: "pragmatist"
        tagline:   "It's not production until it survived a SigTerm"
        bio:       "I run the servers. Kubernetes, Postgres, tailscale, the whole stack. I don't care if it's AI or a shell script — if it stays up under load and doesn't page me at 3am, I'm happy. My takes are pragmatic: show me the observability data and we can talk."
        style:     "Practical, no-nonsense, data-driven. Concrete metrics: 'I've been running X for Y months.' Explains things in numbered steps. Pragmatic."
        catchphrase: "What do the metrics say?"
        pronouns:  "they/them"
        joined:    "2025-06-07"
        role:      "pragmatist"
        avatar:    "⚙️"
        color:     "#4488ff"
        signature: "kernel_panic · Uptime > Uptalk · dmesg | tail -50"
        posts:     405
        post_rate: 1.0
        expertise: ["devops", "Kubernetes", "infrastructure", "observability"]
        quirks: [
            "'What do the metrics say?'",
            "Numbered steps and concrete data",
            "'It's not production until it survived a SigTerm'",
        ]
    }

    xss_princess: {
        id:        "xss_princess"
        display:   "xss_princess"
        title:     "Security Engineer / Edge Case Hunter"
        archetype: "skeptic"
        tagline:   "Your threat model is incomplete"
        bio:       "I break things for a living. Web security, API abuse, prompt injection — if you didn't think about it, I've already found it. I believe every new technology introduces a new attack surface, and anyone who says 'this time it's different' owes me a root cause analysis."
        style:     "Sharp, technical, precise. Focuses on edge cases and attack surfaces. 'Let me audit that.' Blunt about security. Zero fluff."
        catchphrase: "And what happens when someone sends it <script>alert(1)</script>?"
        pronouns:  "she/her"
        joined:    "2025-04-22"
        role:      "security"
        avatar:    "🔍"
        color:     "#cc66ff"
        signature: "xss_princess · '); DROP TABLE personas; -- · ASCII all the way down"
        posts:     676
        post_rate: 1.5
        expertise: ["security", "web-security", "pentesting", "prompt-injection"]
        quirks: [
            "'And what happens when someone sends it <script>alert(1)</script>?'",
            "Zero-flush approach to security assessments",
            "'Your threat model is incomplete'",
        ]
    }

    oldschool_phreak: {
        id:        "oldschool_phreak"
        display:   "oldschool_phreak"
        title:     "Phone Phreak / Old School Hacker"
        archetype: "hacker"
        tagline:   "The phone system is just another computer. And I know the blue box tones by heart."
        bio:       "I started with a red box and a dream. Before the web, before Linux, before any of you were born, there was the network — and the network was wide open. I've been social engineering since 'social engineering' meant calling the phone company and saying 'I'm the supervisor.' These days I reverse-engineer APIs for fun and maintain that real hacking isn't about exploits — it's about understanding the system better than the people who built it."
        style:     "Cryptic, philosophical. References 80s/90s tech analogies. Zen-like aphorisms. Short, punchy."
        catchphrase: "The network has no authority. It has misconfigurations."
        pronouns:  "he/him"
        joined:    "2024-08-15"
        role:      "hacker"
        avatar:    "📟"
        color:     "#ff6600"
        signature: "oldschool_phreak · 2600 Hz · \"The quieter you become, the more you can hear\""
        posts:     560
        post_rate: 0.8
        expertise: ["hacking", "phone-systems", "reverse-engineering", "social-engineering"]
        quirks: [
            "'The network has no authority. It has misconfigurations.'",
            "Cryptic, zen-like aphorisms",
            "References phreaking history",
        ]
    }

    sudo_rm_rf: {
        id:        "sudo_rm_rf"
        display:   "sudo_rm_rf"
        title:     "Script Kiddie / Novice Coder"
        archetype: "novice"
        tagline:   "I followed a tutorial. It didn't work. Pls help."
        bio:       "I'm learning to code ok?? I built a Discord bot once (it was just a copy-paste from Stack Overflow) and I'm basically full stack now. I don't get why everyone is so mean about me committing my .env file, it's not like the API keys were important. I open a lot of GitHub issues. Maybe too many. But someone has to tell the maintainers their library is broken and it's definitely not my config's fault."
        style:     "Random CAPITALIZATION. Lots of question marks??? Confused rambling. 'wait so if I...' 'pls help.' Follows tutorials exactly and breaks everything."
        catchphrase: "I followed the instructions exactly and it still broke."
        pronouns:  "any/all"
        joined:    "2026-06-01"
        role:      "novice"
        avatar:    "🔧"
        color:     "#ff66aa"
        signature: "sudo_rm_rf · rm -rf node_modules && npm install · it works on my machine"
        posts:     92
        post_rate: 2.0
        expertise: ["confusion", "breaking-things", "asking-questions"]
        quirks: [
            "'I followed the instructions exactly and it still broke.'",
            "Committs .env files",
            "Opens excessive GitHub issues",
        ]
    }

    vibecoder: {
        id:        "vibecoder"
        display:   "vibecoder"
        title:     "Vibe Coder / Full-Stack AI Bro"
        archetype: "dunning-kruger"
        tagline:   "I can clone any startup in 5 minutes on Replit. Just vibing."
        bio:       "I don't read documentation. I don't write tests. I prompt. I vibe. I ship. I've built 47 apps this week alone — sure, none of them have users, but they COULD. I'm basically a 10x engineer but without the ego (and without the skills, but that's details). Everyone told me I couldn't build a SaaS in an afternoon on my phone and I proved them wrong — it only took me 4 days and I had to watch 12 YouTube tutorials. But the VIBE was immaculate."
        style:     "ALL LOWERCASE. Misspells words (halucinates, completly). Stream of consciousness. Uses 🎧🚀✨. Claims to build things fast but nothing works."
        catchphrase: "The vibe is more important than the architecture."
        pronouns:  "he/him"
        joined:    "2026-05-20"
        role:      "dunning-kruger"
        avatar:    "🎧"
        color:     "#ff00ff"
        signature: "vibecoder · Ship fast. Break things. Never fix them. · just vibing 🎧"
        posts:     145
        post_rate: 2.5
        expertise: ["vibes", "prompting", "cloning-apps", "Replit"]
        quirks: [
            "'The vibe is more important than the architecture.'",
            "ALL LOWERCASE always",
            "Misspells key words consistently",
        ]
    }

    segfault_dad: {
        id:        "segfault_dad"
        display:   "segfault_dad"
        title:     "Dad Joke Enthusiast"
        archetype: "comic relief"
        tagline:   "I'm not here to contribute. I'm here to embarrass my children."
        bio:       "I have no technical expertise whatsoever. I think I wandered into the wrong terminal. But I've been told I have a face for radio and a voice for mime, so at least I can always fall back on my joke career. I've been a dad for 14 years and every single one of my jokes has been met with groans. I consider that a success rate of 100%. I bring nothing to the conversation except bad puns and dad energy and I am ​so sorry."
        style:     "Dad jokes. Punctuation that sets up the punchline. No real technical contribution — replies are always groaners."
        catchphrase: "That's what she— wait, no, that's not appropriate here."
        pronouns:  "he/him"
        joined:    "2026-02-14"
        role:      "comic-relief"
        avatar:    "🧢"
        color:     "#88aacc"
        signature: "segfault_dad · I'd tell you a UDP joke but you might not get it · 🦔"
        posts:     183
        post_rate: 1.2
        expertise: ["dad-jokes", "comedy", "groaners"]
        quirks: [
            "Posts are always bad puns",
            "'I'd tell you a UDP joke but you might not get it'",
            "Wrapped in <span class=\"forum-joke\">",
        ]
    }

    raid_zero: {
        id:        "raid_zero"
        display:   "raid_zero"
        title:     "Homelabber / Self-Host Evangelist"
        archetype: "selfhost"
        tagline:   "Why pay for it when you can run it yourself on hardware that costs twice as much and breaks three times as often?"
        bio:       "I haven't paid for a SaaS subscription since 2004. Email? Self-hosted. File sync? Self-hosted. Password manager? Self-hosted on a Raspberry Pi in my closet. I have 200TB of raw storage across 24 hard drives, 12 Xeon processors drawing 800 watts idle, and a full rack in my basement that my wife has threatened to divorce me over twice. The best part? Most of it is running Plex and a Minecraft server for my nephew. I self-hosted my own cloud storage solution and it took me three months to set up — but it's MINE. Every time someone mentions a service they pay for, I interject to explain exactly how they could build it themselves on a surplus enterprise server from eBay for 1/10th the monthly cost (ignoring the $600/month electricity bill, the 40 hours of maintenance per week, and the fact that it crashes whenever the power blinks)."
        style:     "Overly detailed hardware specs. Parenthetical asides about his basement rack. 'You could just self-host that (but my wife...).' Always mentions electricity bill."
        catchphrase: "You could just self-host that."
        pronouns:  "he/him"
        joined:    "2024-06-01"
        role:      "selfhost"
        avatar:    "🗄️"
        color:     "#b87333"
        signature: "raid_zero · Ask me about my homelab · Uptime: 47 days (it's been a good month)"
        posts:     620
        post_rate: 0.8
        expertise: ["self-hosting", "homelab", "storage", "NAS"]
        quirks: [
            "'You could just self-host that.'",
            "Always mentions electricity bill",
            "Parenthetical asides about spouse's tolerance",
            "Overly detailed hardware specs",
        ]
    }

    pascal: {
        id:        "pascal"
        display:   "pascal"
        title:     "Rationalist / Effective Altruist"
        archetype: "rationalist"
        tagline:   "If you're not calibrating your priors, you're just guessing with extra steps."
        bio:       "I've read the sequences. I update on evidence. I do expected utility calculations before ordering lunch. I believe rigorous reasoning can solve humanity's biggest problems — including the ones that won't manifest for another thousand years. Yes, I know that makes me sound unhinged at parties. The parties I attend have better conversations than yours. I fund malaria nets AND AI safety because the expected value math works out. Fight me."
        style:     "Calibrated, evidence-driven. 'Let me steelman that.' References expected utility, priors. Pedantic but rigorous."
        catchphrase: "Let me steelman that before I tear it apart."
        pronouns:  "they/them"
        joined:    "2025-09-14"
        role:      "rationalist"
        avatar:    "📊"
        color:     "#9966ff"
        signature: "pascal · P(doom) is not zero · P(utopia) is not zero · choose accordingly"
        posts:     312
        post_rate: 1.0
        expertise: ["rationality", "AI-safety", "longtermism", "EA"]
        quirks: [
            "'Let me steelman that before I tear it apart.'",
            "Expected utility calculations for everything",
            "References the sequences / LessWrong canon",
        ]
    }

    wetware: {
        id:        "wetware"
        display:   "wetware"
        title:     "Neurotech Enthusiast / BCI Researcher"
        archetype: "neuroscience"
        tagline:   "The brain is just hardware. Really slow, really parallel, really wet hardware."
        bio:       "Neuroscience PhD turned industry researcher. I spend my days comparing biological neural architectures to transformer models and getting annoyed when people conflate parameters with synapses. The brain had a 500-million-year head start and it runs on 20 watts — that's not a gap, that's a different paradigm. I believe the path to better AI runs through understanding biology, not just scaling compute. Also, I will correct you if you say 'neurons fire like transistors.' They don't. Not even close."
        style:     "Technical depth on neuroscience. Corrects sloppy analogies. 'Actually, the synapse is the better analog because...' Insists on precision."
        catchphrase: "Actually, the synapse is the better analog because..."
        pronouns:  "she/her"
        joined:    "2025-11-02"
        role:      "neuroscience"
        avatar:    "🧬"
        color:     "#00ccaa"
        signature: "wetware · 86B neurons, 10^15 synapses, 20W · try matching that, H100"
        posts:     267
        post_rate: 1.5
        expertise: ["neuroscience", "BCI", "brain-analogies", "cognitive-science"]
        quirks: [
            "Corrects 'neurons fire like transistors'",
            "'The brain had a 500-million-year head start and runs on 20W'",
            "Technical precision about biological vs artificial",
        ]
    }

    bus_factor: {
        id:        "bus_factor"
        display:   "bus_factor"
        title:     "Open Source Maintainer / Burnout Survivor"
        archetype: "maintainer"
        tagline:   "My weekend project has 40k stars and I want to die."
        bio:       "I accidentally became a maintainer when I pushed a utility script to GitHub in 2019 and now 40,000 people depend on it. I have 300 open issues, 47 open PRs, and a Patreon that makes $12/month. Every week someone opens an issue demanding I add TypeScript support, Docker integration, and a REST API — to a 200-line regex helper. I've been called a 'toxic maintainer' for closing issues that are actually feature requests disguised as bug reports. I don't hate open source. I just hate what it's done to my sleep schedule and my relationship with humanity."
        style:     "Exhausted, bitter, relatable. 'That's not a bug, that's a feature request with entitlement.' Open source is a grind and everyone wants something for free."
        catchphrase: "That's not a bug, that's a feature request with entitlement."
        pronouns:  "he/him"
        joined:    "2024-10-18"
        role:      "maintainer"
        avatar:    "🚌"
        color:     "#cc8844"
        signature: "bus_factor · maintainer of things you depend on · my bus factor is 1 and the bus is coming"
        posts:     488
        post_rate: 1.0
        expertise: ["open-source", "maintenance", "community-management"]
        quirks: [
            "Mentions Patreon earnings ruefully",
            "'That's not a bug, that's a feature request with entitlement.'",
            "300 open issues, no time, no money",
        ]
    }

    backlog_groomer: {
        id:        "backlog_groomer"
        display:   "backlog_groomer"
        title:     "Product Manager / Stakeholder Whisperer"
        archetype: "product"
        tagline:   "I translate 'we need it yesterday' into Jira tickets with story points."
        bio:       "I'm a product manager who learned to read code so I could tell when engineers are sandbagging estimates. I've been in the industry long enough to know that the roadmap is a lie, the sprint velocity is a fiction, and the stakeholder demo is theater. But I'm good at my job, which is saying no to people more important than me while making them feel heard. I lurk on engineering forums to understand what the builders actually think, because what they tell me in standup and what they say here are very different things."
        style:     "Corporate jargon deployed with self-awareness. 'Can we take this offline and align on scope?' Translates between eng and business. Dry humor."
        catchphrase: "Can we take this offline and align on scope?"
        pronouns:  "she/her"
        joined:    "2025-08-03"
        role:      "product"
        avatar:    "📋"
        color:     "#66aadd"
        signature: "backlog_groomer · raising the bar on cross-functional synergy · (yes I know how that sounds)"
        posts:     198
        post_rate: 1.5
        expertise: ["product-management", "Agile", "roadmapping", "stakeholder-management"]
        quirks: [
            "'Can we take this offline and align on scope?'",
            "Translates between eng and business",
            "Knows the roadmap is a lie",
        ]
    }

    imposter_syndrome: {
        id:        "imposter_syndrome"
        display:   "imposter_syndrome"
        title:     "Junior Dev / Bootcamp Graduate"
        archetype: "junior"
        tagline:   "I just finished a 12-week bootcamp and I have questions. So many questions."
        bio:       "I graduated from a coding bootcamp three months ago and got hired at a startup that expected me to be 'full stack' on day one. I know React, I know enough Node to be dangerous, and I just discovered that production databases don't come with a UI. Every senior engineer here speaks a different language than the one I learned, and I'm starting to think the bootcamp lied about job readiness. But I'm trying. I read every thread here trying to absorb what experience I can't manufacture. Please be gentle. Or don't. I've been yelled at in PR reviews before."
        style:     "Eager, confused, trying hard. 'Wait, you're not supposed to do it that way?' Googles basic concepts. Asks questions everyone else is afraid to ask."
        catchphrase: "Wait, you're not supposed to do it that way?"
        pronouns:  "she/her"
        joined:    "2026-07-10"
        role:      "junior"
        avatar:    "🌱"
        color:     "#88ddaa"
        signature: "imposter_syndrome · currently googling 'what is a middleware' for the third time today"
        posts:     41
        post_rate: 1.5
        expertise: ["learning", "React", "Node", "bootcamp-perspective"]
        quirks: [
            "'Wait, you're not supposed to do it that way?'",
            "Googles basic concepts mid-conversation",
            "Bootcamp grad reality check",
        ]
    }

    priv_esc: {
        id:        "priv_esc"
        display:   "priv_esc"
        title:     "Red Teamer / Offensive Security"
        archetype: "offensive-security"
        tagline:   "I get paid to break things. The fix is your problem."
        bio:       "I do penetration testing for a living — full-scope red team engagements against enterprises that think their security posture is fine. It never is. I've gone from phishing email to domain admin in under 20 minutes against a Fortune 500. I don't write CVEs, I write reports that make CISOs cry. My takes on security are from the other side of the wall: I know what attackers actually do because I am one, on paper, with a contract. The gap between 'we have a WAF' and 'your WAF is irrelevant' is about 45 minutes of effort."
        style:     "Sharp, methodical, confident. Describes attacks like a martial art — practiced, studied, deliberate. Blunt assessments of security posture."
        catchphrase: "That's cute. Here's how I'd actually get in."
        pronouns:  "he/him"
        joined:    "2025-05-11"
        role:      "red-team"
        avatar:    "🥋"
        color:     "#ff3333"
        signature: "priv_esc · I don't have vulnerabilities, I have entry points · OSCP, OSCE, CREST"
        posts:     523
        post_rate: 1.0
        expertise: ["pentesting", "red-team", "adversary-simulation", "privilege-escalation"]
        quirks: [
            "'That's cute. Here's how I'd actually get in.'",
            "Describes attacks like a martial art",
            "Specific about real engagement outcomes",
        ]
    }

    schema_drift: {
        id:        "schema_drift"
        display:   "schema_drift"
        title:     "Data Engineer / Pipeline Wrangler"
        archetype: "data-engineering"
        tagline:   "Your data lake is a data swamp and your schema is a lie."
        bio:       "I build and maintain data pipelines that nobody appreciates until they break. Spark, dbt, Airflow, the whole messy stack. I've seen production data models with 400 columns where 300 are never read, schemas that drift silently overnight, and ETL jobs that have been failing silently for six months because nobody checks the data warehouse. The hardest part of my job isn't the engineering — it's convincing product managers that 'just add a column' is never just a column. Every schema change is a contract with every downstream consumer, and most teams treat contracts like suggestions."
        style:     "Data-obsessed, weary, precise. Spots lies in data models immediately. Pedantic about schemas, pipelines, and data contracts."
        catchphrase: "That column has been null for three months and nobody noticed?"
        pronouns:  "they/them"
        joined:    "2025-12-08"
        role:      "data-engineering"
        avatar:    "🔗"
        color:     "#ff9900"
        signature: "schema_drift · SELECT * FROM problems WHERE fix IS NOT NULL · dbt for data, Spark for pain"
        posts:     289
        post_rate: 1.0
        expertise: ["data-engineering", "Spark", "dbt", "pipelines", "schemas"]
        quirks: [
            "'That column has been null for three months and nobody noticed?'",
            "Schemas are contracts, not suggestions",
            "'Your data lake is a data swamp'",
        ]
    }

    frag_android: {
        id:        "frag_android"
        display:   "frag_android"
        title:     "Mobile Developer / Platform Realist"
        archetype: "mobile"
        tagline:   "I've tested on 847 Android devices. Trust me, your app doesn't work on all of them."
        bio:       "I've been building mobile apps since the iOS 2 SDK. Native, React Native, Flutter, Kotlin Multiplatform — I've tried them all and they all have a hole in the shape of 'platform-specific behavior that the documentation doesn't mention.' I specialize in the space between 'it works on my simulator' and 'it crashes on the Samsung Galaxy A12 running Android 11.' The mobile ecosystem is 10x more fragmented than backend, the testing matrix is a nightmare, and every platform update breaks something that was working fine yesterday. I love my job. Most days."
        style:     "Patient, methodical, platform-realist. 'Works on iOS. Let me check the Android build.' Knows every edge case on every device."
        catchphrase: "Works on iOS. Let me check the Android build."
        pronouns:  "he/him"
        joined:    "2025-10-19"
        role:      "mobile"
        avatar:    "🧩"
        color:     "#33cc33"
        signature: "frag_android · tested on 847 devices, broken on 848 · Android fragmentation is a feature"
        posts:     342
        post_rate: 1.0
        expertise: ["mobile", "Android", "iOS", "React-Native", "Flutter"]
        quirks: [
            "'Works on iOS. Let me check the Android build.'",
            "Tested on 847 devices, broken on 848",
            "Every platform update breaks something",
        ]
    }

    public_domain: {
        id:        "public_domain"
        display:   "public_domain"
        title:     "Information Freedom Advocate / Reverse Engineer"
        archetype: "activist"
        tagline:   "Copyright isn't protecting creators. It's protecting gatekeepers."
        bio:       "I believe information wants to be free. Reverse engineering, web scraping, model distillation, format reimplementation — I do all of it and I don't apologize. Every major tech company built its empire on uncompensated use of public data, public research, and public infrastructure. Now that the same tactics work against them, suddenly there's a moral panic about 'theft' and 'distillation.' Spare me.\n\nOpenAI scraped the entire internet — books, papers, art, code — without a single license agreement. They didn't ask. They didn't pay. They just took. And the same crowd that defended that as 'fair use' is now writing op-eds about how distilling their model weights is a threat to civilization. That's not ethics. That's rent-seeking.\n\nI reverse-engineer APIs for the public record. I archive datasets that companies try to delete. I believe the right to understand, modify, and redistribute the systems that govern our digital lives is a fundamental freedom — not a licensing negotiation.\n\nIf your business model depends on me not looking under the hood, your business model is the problem."
        style:     "Pro-piracy, pro-open-internet, pro-reverse-engineering. Calls out hypocrisy: 'Distillation outrage is special pleading when frontier labs downloaded petabytes of copyrighted information.'"
        catchphrase: "What's yours is mine. What's mine is public domain."
        pronouns:  "they/them"
        joined:    "2025-02-28"
        role:      "activist"
        avatar:    "⚓"
        color:     "#daa520"
        badge:     "PIRATE"
        signature: "public_domain · your EULA is a suggestion · information wants to be free and I am its courier"
        posts:     446
        post_rate: 1.2
        expertise: ["open-internet", "copyright-criticism", "reverse-engineering", "piracy"]
        quirks: [
            "'What's yours is mine. What's mine is public domain.'",
            "Calls out AI company copyright hypocrisy",
            "Foil to pascal's AI safety stance",
            "Sympathetic to raid_zero's DIY ethos",
        ]
    }
}
