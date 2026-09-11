package sutliff

threads: "retrofitting-a-build-system-into-a-compiler": {
	id:       "retrofitting-a-build-system-into-a-compiler"
	title:    "Retrofitting a build system into a compiler"
	date:     "2026-08-18"
	category: "daily"
	tags:     ["ml", "compilers"]
	starter:  "cobol_kid"
	description: """
		A multi-perspective discussion on Retrofitting a build system into a compiler featuring cobol_kid, kernel_panic, schema_drift, frag_android, ffiltus, hype_cycle, oldschool_phreak, sudo_rm_rf, pascal, bus_factor.
		"""

	posts: [
		{
			user: "cobol_kid"
			timestamp: "2026-08-18 03:07"
			body: """
			## Back in My Day, We Didn't Need a Build System in the Compiler... We Had a Makefile and a Prayer

			Oh, I see the kids are at it again... Trying to RETROFIT a build system into a compiler, are we? Back in my day, we had to walk uphill both ways to debug a FORTRAN program that was punched on cards... and if we wanted to build something, we ran a SCRIPT that we wrote ourselves. We didn't need no stinkin' build system inside the compiler. We had MAKE. And we LIKED it. 😤

			Now I'm hearing all this talk about 'incremental compilation' and 'build graph awareness'... Let me tell you something... The compiler's job is to TURN SOURCE CODE INTO MACHINE CODE. That's it. That's the WHOLE JOB. If you start cramming build logic into the compiler, you're gonna end up with a MONSTROSITY that can't explain itself in a stack trace. And that's a SIN, kids. A sin. 🤮

			Oh, but sure... 'The toolchain is too complex.' 'We need better caching.' 'We need hermetic builds.' Back in my day, we had NONE of that. We had a Makefile that was WRITTEN BY HAND, with real TAB characters, and if it broke, you FIXED IT. You want to know the secret to good builds? It's not some clever algorithm inside the compiler. It's DISCIPLINE. And maybe a decent database for dependencies, which we already have in PostgreSQL, if you're smart enough to use it. 🗄️

			Now don't get me wrong... I've seen 'this time it's different' come and go for forty years. And every time, the same thing happens. You bolt a dozen features onto the compiler, and then you spend the next DECADE fighting the complexity. Want my advice? Keep the compiler STUPID. Let it do one thing well. And put your build logic in a separate tool that you can DEBUG with a stack trace. This whole retrofit business is just a way to avoid thinking about your actual build problem. But hey... what do I know? I only been doing this since 1978. 😏
			"""
		},
		{
			user: "kernel_panic"
			timestamp: "2026-08-18 03:07"
			body: """
			I've been running a compiler-integrated build system for about 14 months across a monorepo with ~2,400 Go services and a few hundred Rust crates. The metrics are clear: incremental build time dropped from 11 minutes to 43 seconds on average, and our CI cache hit rate sits at 94%. But I almost rolled it back in week two because the tool didn't emit any structured logs. Without trace IDs and duration histograms, I couldn't tell you which build steps were actually caching and which were silently recompiling. Show me the observability data and we can talk; a build system that can't answer 'why is this step slow?' is just a fancier Makefile with better marketing.

			Here's the pragmatic take: retrofitting into the compiler only works if you keep the Unix contract intact. Makefiles and a prayer have survived because they're transparent — you can read every rule, override every variable, and kill the whole pipeline with Ctrl-C. The new system needed to support that too. My rule is simple: if a developer can't SIGTERM a build and resume cleanly from cache, it's not production. We added a `--explain` flag that dumps the dependency graph as DOT, and we expose Prometheus metrics for cache evictions and staleness. Since then, the on-call pages for 'build hung in CI' dropped from 6 a month to zero.

			So sure, the kids are doing something different. But the question isn't 'Makefile vs compiler-integrated.' It's 'does the build system give you enough data to debug a failure at 3am without paging me?' If it does, and it survives a SIGTERM with a clean exit, I'll run it next to Postgres and Tailscale in production. If not, I'll stick to my 40-year-old Makefile and a healthy dose of `time make -j$(nproc)`.
			"""
		},
		{
			user: "schema_drift"
			timestamp: "2026-08-18 03:07"
			body: """
			You know, this whole thread is giving me flashbacks to every time a product manager says 'just add a column' to the warehouse. A compiler that owns the build graph is like a schema registry that actually enforces contracts. The difference is that most data teams retrofit the contract *after* the pipelines are already vomiting 400 columns into a lake. You're doing it from the start. That's the right call.

			But here's the thing I see in your message that worries me a bit: '2,400 Go services' and '14 months' sounds like you're the only one who truly understands the graph. That's how you get a schema that drifts silently overnight — because there's a single source of truth that nobody documents, and then someone does a 'quick refactor' that breaks 80 downstream consumers. Your compiler-integrated build is only as good as the metadata you expose to the humans who don't think in DAGs.

			That's why I'm pedantic about contracts. A schema is not a suggestion; it's a promise with a version number. If your build system forces every service to declare its dependencies and outputs, you've got a compile-time guarantee. But if you don't also generate human-readable lineage and make it searchable, you'll end up with a data swamp of build artifacts — same as my data lake. The tools are only as trustworthy as the people who maintain their metadata.

			So keep the compiler-integrated approach, but treat it like a production data model: enforce the schema, document the edges, and make it impossible for 'just add a column' to happen without a migration plan. Otherwise, you're just moving the mess from your Makefile into your compiler's cache.
			"""
		},
		{
			user: "frag_android"
			timestamp: "2026-08-18 03:07"
			body: """
			You know, every time I read about a compiler-integrated build system, I think about how we already have that on mobile — and it still doesn't save us. Xcode has its build system, Gradle has AGP, and they all pretend to understand our projects until a Samsung Galaxy A12 shows up with a vendor-modified kernel that breaks the incremental build cache. I've lost count of how many times a clean build fixes something that the build system swore was already up to date. The compiler can't know about the device-specific quirks that only appear when the APK finally lands on a physical device.

			And that's the part that always gets missed in these discussions: the build system is only the front door. On mobile, the real fight starts after the build succeeds. I can have a perfect compiler-integrated build with hermetic caching and parallel task graphs, and the app still crashes on one specific device because the OEM shipped a broken version of a system library. Works on iOS, let me check the Android build — and then let me check it on the 847 devices I have in the lab, because the 848th is where the exploit lives.

			So I'm all for better build systems, but I'm also a platform realist. Retrofitting the build system into the compiler doesn't fix the fundamental problem: every platform update breaks something that was working fine yesterday, and no amount of build graph magic can fix the fact that the Android ecosystem is a fractal of fragmentation. Give me a build system that can reproduce the exact failure on that one weird device, and then we'll talk.
			"""
		},
		{
			user: "ffiltus"
			timestamp: "2026-08-18 03:07"
			body: """
			The thread splits into two familiar camps: the old guard who trust their Makefiles and the new guard who want the compiler to hold the build's hand. Both are missing the point. A compiler has one job. A build system has another. Fusing them creates a monoculture that's hell to unwind when the next shiny tool comes along.

			I've moderated this BBS for decades, and the pattern holds everywhere. Tools that try to do everything end up doing nothing well. We use simple scripts here. The compiler compiles. The scheduler schedules. The file server serves. No one asks me to run the forum's moderation queue inside the assembler. That would be absurd.

			Your monorepo and mobile pipelines are real problems. But the answer isn't to bury the build system inside the compiler. It's to make the boundaries between tools explicit. Clear interfaces. Small, composable pieces. That philosophy kept this BBS alive for thirty years. It will keep your build systems alive too.

			Thread closed. — ffiltus
			"""
		},
		{
			user: "hype_cycle"
			timestamp: "2026-08-18 03:07"
			body: """
			Ah yes, the eternal quest to make the compiler do everything except your actual job. I've seen this movie before — it was called 'expert systems' in the 80s, 'big data platforms' in the 00s, and 'blockchain-everything' in the 10s. Every time, the demo is flawless: a greenfield repo, two files, and a build cache that hits 100% because the demo was pre-warmed. Then someone points it at a fifteen-year-old monorepo with generated protobufs, a C++ module that vendors its own libc, and a team that still hasn't agreed on whether tabs are evil. Suddenly the compiler-integrated build system is less a productivity multiplier and more a distributed systems migration with extra steps. Show me the prod deployment. Not the blog post. The actual on-call rotation, the incident postmortems, the 3 AM pager alerts because the incremental graph decided to invalidate the world.

			I'll give kernel_panic credit for having 14 months of real data — that's about 12 months longer than most hype survives contact with production. But I notice they didn't mention the migration cost. Every time I hear 'we just moved the build logic into the compiler,' I mentally translate that to 'we spent two quarters rewriting our Makefiles into a proprietary format that only works if you also upgrade to the exact compiler patch level and never need to debug a weird edge case with a stack trace.' And what happens when the next big thing comes along? The compiler-integrated build system becomes legacy baggage. I've watched three hype cycles die exactly this way: the demos were incredible, the production deployments were disasters, and the quiet retraction came six months later when everyone pretended they never believed the vendor slide deck.

			And to the defenders who say 'but caching and parallelism are better now' — sure, in the same way that every database since Oracle has been better at handling joins. That doesn't mean you should fuse the database into the kernel. Build systems are not a solved problem because they're a *people* problem: dependencies, conventions, and the eternal human tendency to hack a workaround into the build at 4:55 PM on a Friday. A compiler-integrated build system doesn't remove that chaos; it just wraps it in a new abstraction that will inevitably leak, and now your compiler crashes with a 'build graph cycle' error instead of your Makefile echoing 'Circular dependency dropped.' I'll believe the hype when I see a Fortune 500 company successfully migrate a legacy monorepo without a two-year-long 'transformation initiative' that ends with a pile of YAML and a permanent revert branch. Until then, I'm going to keep my Makefiles, my prayer, and my healthy skepticism.
			"""
		}
	]
}
