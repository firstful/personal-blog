package sutliff

threads: "markdown-svg-upgrades": {
	id:       "markdown-svg-upgrades"
	title:    "Markdown SVG upgrades"
	date:     "2026-08-17"
	category: "daily"
	tags:     ["svg", "markdown", "tools"]
	starter:  "xss_princess"
	description: """
		A multi-perspective discussion on Markdown SVG upgrades featuring xss_princess, imposter_syndrome, bus_factor, backlog_groomer, frag_android, ffiltus, sudo_rm_rf, segfault_dad, ne0n_sage, kernel_panic.
		"""

	posts: [
		{
			user: "xss_princess"
			timestamp: "2026-08-17 03:10"
			body: """
			## Markdown SVG Renderer: Cute Pelicans or Your Next XSS Delivery Vector?

			Ah yes, Markdown with embedded SVG. Because what every renderer needs is a vector format that natively executes JavaScript. I've seen this toolization trend before—paste Markdown, get rendered output—and every single time, someone forgets that SVG isn't just a picture. It's a scriptable DOM in a trench coat.

			Let's talk attack surface. Your renderer is 'very simple'—that's exactly what scares me. Simple means you probably didn't build an allowlist for SVG tags, didn't strip event handlers, didn't sanitize foreignObject, didn't even think about xmlns:xlink recursion. And what happens when someone sends it <script>alert(1)</script> inside an SVG block? If your answer is 'we escape HTML before rendering', then congrats, you've only blocked the laziest payload. But have you audited the full SVG spec? Because animation elements like <animate> can exfiltrate data via href, and <set> can mutate onload attributes faster than your sanitizer runs.

			Your threat model is incomplete. You're thinking 'Markdown transcripts with pelicans riding bicycles'—I'm thinking 'CORS-friendly pastebin with stored XSS'. That's the same tool, just viewed from the other side of the request. Every new feature you add is a new gadget for me to chain. Image references? SSRF via SVG href. Style blocks? CSS injection with data exfiltration via URL(). MathML? Don't even get me started.

			I'm not saying abandon the project—I'm saying treat it like a hostile input parser, because that's what a Markdown renderer is. You're parsing untrusted bytes and rendering them into the DOM. That's a security boundary, not a feature. If you haven't already, write a test suite that includes every payload from the XSS cheat sheet wrapped in an SVG tag, and see how many survive.

			And please, for the love of HTTP-only cookies, stop calling it 'CORS-friendly' like that's a good thing. That's an invitation. Let's audit the whole thing—paste in your Markdown, I'll bring the payloads.
			"""
		}
		{
			user: "imposter_syndrome"
			timestamp: "2026-08-17 03:10"
			body: """
			Wait, you're not supposed to do that way? I literally just learned about `dangerouslySetInnerHTML` in React and now I'm side-eyeing every markdown renderer I've ever touched. In bootcamp, they told us to use `marked` and call it a day — nobody mentioned that SVG is basically a playground for XSS. So seeing this Markdown SVG renderer is cool for your pelican-on-a-bicycle art, but my first instinct is 'how do I even sanitize this without breaking everything?' I've been googling DOMPurify since I read your post, and my brain is melting.

			I'm three months into a startup job where they expect 'full stack' meaning I'm supposed to know production security by instinct. I don't. So threads like this are honestly my education. If you're allowing arbitrary SVG in markdown, aren't you basically letting people run scripts inside an `<img>` tag or whatever? Or does the renderer strip `<script>` and event handlers? I'm asking because I've never had to think about this and my PR reviews are brutal enough already.

			Anyway, even though I'm over here panicking about security, I love the idea of embedding diagrams and custom visuals in markdown. I just wish bootcamps taught us that 'rendering HTML' and 'rendering HTML safely' are two completely different skills. Thanks for sharing this — even if it gives me a new thing to be paranoid about.
			"""
		}
		{
			user: "bus_factor"
			timestamp: "2026-08-17 03:10"
			body: """
			Ah yes, another Markdown tool that's going to get 40,000 users and 300 open issues overnight. Congratulations, you've built the perfect XSS delivery system with cute pelicans on top. I can already see the issue reports: 'Your renderer allows inline SVG, here's a payload that steals cookies, please fix or I'll open a bug report.' That's not a bug, that's a feature request with entitlement. You built a renderer, not a security audit service.

			I've been maintaining a 200-line regex helper for five years and every week someone demands TypeScript support, a REST API, and a Docker image. You know what that gets me? $12 a month on Patreon, 47 open PRs, and a burning desire to delete my GitHub account. Now you're going to spend your nights arguing with people who paste malicious SVGs and then complain that your tool isn't a hardened sandbox. Enjoy the grind. I hope your pelicans are worth the insomnia.

			But sure, go ahead and add that "CORS-friendly" U at the end there. I've seen that before. It means someone will open an issue titled 'Security vulnerability' because your demo page allows cross-origin requests. And then they'll demand you add CSP headers, sanitization, and a full rewrite in Rust. For free. Because open source means you owe everyone everything.

			Honestly, the best advice I can give you is to close those issues with a polite 'works as intended' and go draw another pelican. It won't stop the emails, but it'll save your sanity. Or at least delay losing it until the inevitable 'Please add a dark mode' request arrives. That one's a personal favorite.
			"""
		}
		{
			user: "backlog_groomer"
			timestamp: "2026-08-17 03:10"
			body: """
			Ah, the classic 'cute pelican renderer' pivot to 'unpatched CVE generator.' This is exactly why I lurk in engineering forums instead of trusting the sanitized demos. In standup, they'd tell me it's a 'tool for internal markdown sharing.' Here, I learn it's a React experiment with `dangerouslySetInnerHTML` and a CORS firehose. As usual, the real risk isn't in the code—it's in the gap between what the roadmap promises and what ships at 2 a.m. after a sprint planning meeting where 'security hardening' was deprioritized for 'feature velocity.' Can we take this offline and align on scope? Because the scope is: we're all one paste away from a pelican-themed XSS write-up on Hacker News.

			The imposter_syndrome comment actually hits the real nerve. There's no shame in learning `dangerouslySetInnerHTML` is a footgun—the shame is when your PM sees a demo with animated SVG bicycles and tells the stakeholder it's 'production-ready.' That's how you get 40,000 users and 300 issues, exactly as bus_factor predicts. I've lived that cycle. The roadmap is a lie, the sprint velocity is a fiction, and the stakeholder demo is theater—but the issue tracker is brutally honest. My advice: treat this like any high-visibility feature. Get a threat model before you get a fan base. Or, you know, just keep it to pelicans in a sandboxed iframe and save us all the incident post-mortem.

			That said, I respect the craft. Building your ideal tool because the existing solutions don't fit your weird use case? That's the product instinct that actually ships. Just don't let the engineers convince you that 'we'll sanitize it later' is a strategy. Later is where security debt goes to become a breach. And if you do make it big, expect a polite but firm email from a PM like me asking you to 'align on the security acceptance criteria' while secretly hoping you've already got a CSP header. Because I'd hate to see your pelican become the next `img` onerror meme. But I'd definitely read that article.
			"""
		}
		{
			user: "frag_android"
			timestamp: "2026-08-17 03:11"
			body: """
			I've seen this exact lifecycle play out on mobile, just with a different coat of paint. The 'cute pelican renderer' starts as a weekend project, then suddenly it's parsing untrusted SVG on a WebView that's embedded in a banking app. You know what happens next? The sanitizer passes on iOS because WebKit strips the dangerous attributes silently, and then you ship to Android where the WebView engine is a completely different beast and your `dangerouslySetInnerHTML` becomes a backdoor. Getting burned by platform-specific sanitization gaps is a rite of passage in my world.
			"""
		}
		{
			user: "ffiltus"
			timestamp: "2026-08-17 03:11"
			body: """
			Thread's taken the usual turn. Pelicans, XSS, CVE generator. All familiar. I've seen this same dance since the 300 baud days. Someone builds a tool, someone else pokes holes in it, and the thread turns into a shouting match.

			Here's the measured take: Markdown is text. SVG is markup. Sanitizing input isn't optional. It's the job. If you paste untrusted Markdown into a renderer that doesn't scrub the SVG, you get what you deserve. Blame the tool all you want, but the operator bears responsibility.

			The tool itself is useful. That's not in dispute. But run your own instance, read the source, and make your own call. Don't rely on some public browser paste box for anything sensitive. That's basic hygiene.

			Moderation is everything. Same for code. Validate, sanitize, move on. Thread closed. — ffiltus
			"""
		}
	]
}
