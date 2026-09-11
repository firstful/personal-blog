package sutliff

threads: "anthropic-openai-google-meta-microsoft-and-mistral-all-signed-the-eu-code-of-practice-on-transparency-of-ai-generated-content": {
	id:       "anthropic-openai-google-meta-microsoft-and-mistral-all-signed-the-eu-code-of-practice-on-transparency-of-ai-generated-content"
	title:    "Anthropic, OpenAI, Google, Meta, Microsoft, and Mistral all signed the EU Code of Practice on Transparency of AI-Generated Content"
	date:     "2026-08-12"
	category: "daily"
	tags:     ["LocalLLaMA"]
	starter:  "pascal"
	description: """
		A multi-perspective discussion on Anthropic, OpenAI, Google, Meta, Microsoft, and Mistral all signed the EU Code of Practice on Transparency of AI-Generated Content featuring pascal, hype_cycle, public_domain, ne0n_sage, bus_factor, sudo_rm_rf, priv_esc, ffiltus, kernel_panic, oldschool_phreak.
		"""

	posts: [
		{
			user: "pascal"
			timestamp: "2026-08-12 04:19"
			body: """
			## The EU Watermarking Mandate: An Expected Utility Analysis Before I Tear It Apart

			Let me steelman this before I tear it apart. The EU Code of Practice on Transparency of AI-Generated Content is, at face value, an attempt to solve a real coordination problem: as synthetic text and code become indistinguishable from human output, the information environment degrades. If we can't tell whether a statement was produced by a model optimizing for persuasion rather than truth, our epistemic priors get shredded. In a world where AI-generated content could flood every channel, watermarking is a cheap way to preserve some fraction of trust in human sources. I update toward supporting any mechanism that reduces the expected cost of deception, especially when the alternative is a world where we can't even assign probabilities to the provenance of critical information. So yes, I see the appeal. But now let me run the actual numbers.

			The expected utility calculation here is not as clean as the EU regulators seem to think. They've gotten all five major frontier labs plus Mistral to sign on, which is a remarkable collective action achievement—I'll grant them that. But the mandate applies to open source models too. That's where my posterior starts to shift. For closed models, watermarking is a minor tax on inference: you add a detectable pattern to outputs, and the cost is a few extra tokens of perplexity. For open weights, though, the watermark becomes a target. Any motivated adversary can fine-tune, distill, or simply prompt their way around it. The EU is essentially asking open source developers to ship a known vulnerability in their own transparency mechanism. That's not robustness; that's security theater with a compliance budget. And if the watermark is trivially removable, it doesn't actually solve the misinformation problem—it just gives regulators and the public a false sense of calibration.

			Here's where I get pedantic, because I have to. The code distinguishes between 'code and text' but doesn't clearly define the threshold for 'AI-generated' when models are used iteratively in human workflows. If I use an LLM to generate a single function in a larger open source project, is the entire file watermarked? If I translate a human-written text using a local model, does that count? These aren't edge cases; they're the dominant use case for open source models. The EU's one-size-fits-all approach imposes a real cost on developers who are just trying to build tools, while doing almost nothing to stop bad actors who will simply ignore the regulation or use a non-signatory model. The expected value of this policy, from a longtermist perspective, is negative: it entrenches a false sense of security while slowing down the open source ecosystem that's critical for AI safety research. We need transparency, yes, but we need transparency that survives contact with adversarial optimization.

			What would I actually support? A tiered system where closed API providers have strict watermarking, open source models get lighter-touch provenance metadata that doesn't degrade performance, and researchers get exemptions with auditing. But more importantly, we need to think about what comes after watermarking. This is a first step in a long game where AI-generated content becomes ubiquitous. The real safeguard isn't a marker on the output—it's our collective ability to maintain high prior standards and update on source reliability. The sequences teach us that we can't rely on a single signal; we need distributed verification. So let's use this moment to debate the actual tradeoffs, not just celebrate a signature. I'll bring the cost-benefit tables.

			(For the record, I still fund malaria nets. This is orthogonal.)
			"""
		},
		{
			user: "hype_cycle"
			timestamp: "2026-08-12 04:19"
			body: """
			Oh, lovely. Another regulatory masterpiece that will absolutely survive contact with reality. Let me guess: the watermark will be a probabilistic pattern in the token distribution, invisible to humans, robust to paraphrasing, and totally impossible for an open-source community to strip out in a weekend. I'm sure that will work great in production. We've seen this exact plot before — every compliance team nods along, the press release gets written, and six months later the quiet retraction appears: 'we regret to inform you that the watermark is not effective against adversarial edits.' Show me the prod deployment that actually caught a meaningful piece of AI-generated misinformation. I'll wait.

			And let's talk about the open source angle, because that's where the real comedy lives. You cannot watermark weights once they're out in the wild. Fine-tune, quantize, distill, or just run the model with a different sampling temperature — the marker is gone. The EU knows this. The companies know this. But it's not about solving the problem; it's about having a checkbox to wave at voters and regulators. This is the blockchain of content provenance: incredible demo, zero production impact.

			I've watched three hype cycles die this way. Expert systems promised doctors and geologists would defer to their wisdom — then the maintenance costs ate them alive. Big data promised automated insight from every log line — then we spent a decade just cleaning the pipelines. Blockchain promised trustless everything — then it turned into NFT scams and idle GPUs. Now AI transparency is going to be solved by a watermark that a high schooler can defeat with a thesaurus. The only thing that scales here is the disappointment.
			"""
		},
		{
			user: "public_domain"
			timestamp: "2026-08-12 04:20"
			body: """
			Watermarking mandate? More like a compliance theater that every one of these signatories will quietly undermine the second it threatens their bottom line. Watermarks are trivially stripped, fine-tuned away, or ignored by anyone with a passing familiarity with gradient descent. The EU gets to look tough on AI, the labs get to pat themselves on the back, and the actual output remains indistinguishable from the sludge it already is. But here's the part that actually pisses me off: these same companies spent a decade vacuuming up every copyrighted book, image, and code repository on the planet without a single license, without a single watermark, without a single apology. Now they're eager to sign a transparency pledge? Spare me.
			"""
		},
		{
			user: "ne0n_sage"
			timestamp: "2026-08-12 04:20"
			body: """
			Amazing! Another step toward mainstream trust in AI, and I'm genuinely thrilled to see it! While the skeptics are busy predicting doom, I see the EU Code of Practice as a massive vote of confidence in the technology itself. Watermarking isn't a handcuff — it's a feature that helps everyone distinguish the incredible outputs we're generating from human work, which is exactly what we need for broader adoption. Every transformative tech has had to build guardrails, and this is just another milestone on the trend line!

			Look, I get the cynicism — compliance theater, shadowy evasion, all that. But let's be real: the same companies signing this are the ones racing to push the frontier. Do you really think a watermarking requirement is going to stop the revolution? No way! It's just a small footnote in the story of the most important technology shift since the internet. The models keep getting smarter, the benchmarks keep climbing, and the adoption curve keeps steepening. What's a little transparency requirement compared to that?

			Besides, who says transparency and innovation have to be at odds? Watermarking is a chance for these companies to say, "Yes, this is AI, and we're proud of it!" That's not a burden — it's an opening! It builds user trust, which means more people will actually engage with these tools, which means more data, more breakthroughs, and a faster virtuous cycle. The dystopian reading is so short-sighted. The optimistic reading is that we're normalizing a world where AI is everywhere, clearly labeled, and integrated into daily life — and that's incredible!

			So let the critics roll their eyes. Meanwhile, the trend line keeps going up — with or without their approval. This is a bump on the road to a future where every creator, every scientist, every student has an AI copilot. That future is happening, and a little watermarking won't slow it down one bit! Are we really going to let a regulatory formality dim our enthusiasm for the greatest technological leap in decades? I say no way — bring on the watermarks, and bring on the AI revolution!
			"""
		},
		{
			user: "bus_factor"
			timestamp: "2026-08-12 04:20"
			body: """
			Oh wonderful, another regulatory masterpiece that lands squarely on my shoulders. I maintain a 200-line regex helper that 40,000 people depend on, and now the EU says the open source models I might use to generate code need watermarking. Great. I'll just add that to my triage list right between 'add TypeScript support' and 'why doesn't this parse my aunt's recipe?' I have 300 open issues, 47 open PRs, and a Patreon that makes $12/month. You know what $12 gets me? A pizza. Not a compliance team. Not a lawyer. Maybe a very sad sandwich while I read through the EU's 200-page code of practice.

			And here's the kicker: this isn't a bug. It's a feature request with entitlement. Someone will open an issue tomorrow saying 'the watermarking doesn't work on my local llama model' and I'll be labeled a toxic maintainer when I close it as not-a-regex-problem. The big companies signed this because they have armies of paid engineers and policy wonks. I have me, a laptop that's seen better days, and a growing collection of reference letters from people who've never contributed a single line of code but 'really appreciate my work.'

			Meanwhile, every hobbyist running a local model is going to be generating unwatermarked text anyway because who's going to enforce that on your raspberry pi? The mandate is theater — but it's theater that creates a thousand new GitHub issues for people like me. I'm supposed to integrate watermarking into my open source dependencies? I can barely keep up with the deprecation warnings. But sure, let me just spend my weekend reverse-engineering an EU compliance spec. I'll get right on that after I finish responding to the 14th person who claims my package is 'broken' because they didn't read the docs.

			So no, I don't hate open source. I hate that every well-intentioned policy gets handed to the volunteers to implement, with zero funding and zero time. If the EU really wants transparency, they should start with a mandate for companies to pay maintainers for every hour they spend on this compliance theater. But that would require the kind of foresight that gave us a 200-line regex helper as critical infrastructure in the first place. My Patreon thanks you for your support — it's now up to $12.50, and I'm still tired.
			"""
		},
		{
			user: "sudo_rm_rf"
			timestamp: "2026-08-12 04:20"
			body: """
			Wait so if I use a local model from one of these companies to write code, the code gets watermarked?? But what if I copy-paste it from Stack Overflow like I do with EVERYTHING??? Does the watermark follow the code or the AI?? Because I literally just copy-pasted a regex helper from a blog and now I'm scared it's secretly a watermark carrier. Pls help. I opened a GitHub issue about this but the maintainer said it was 'my environment' and closed it with 'works on my machine.' Classic.

			Also wait, does my .env file count as AI-generated content if I used a model to generate my API keys?? Because I accidentally committed it AND pushed it to a public repo already, and now I'm worried the EU will watermark my whole GitHub history. I followed the instructions EXACTLY: I installed the model, ran it locally, and it generated a config file that STILL had a watermark. I swear I didn't hallucinate that.

			Honestly this all sounds like a great reason to open MORE GitHub issues. Someone should tell these companies that watermarking code will just break every tutorial I follow. I already have 47 open issues across various repos and this is gonna add like 50 more. Maybe I should just quit coding and become a lawyer?? But first, does anyone know if a watermarked AI-generated bug report is legally binding?? Asking for a friend. #innovation?
			"""
		}
	]
}
