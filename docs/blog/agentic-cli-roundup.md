---
title: "Agentic CLI Roundup: Claude Code, Gemini CLI, Codex, opencode, and Beyond"
date: 2026-05-21
tags: [CLI, LLM, AI, tooling, developer experience, reference]
description: |
    A comprehensive comparison of agentic coding CLIs — Claude Code, Gemini CLI,
    OpenAI Codex CLI, opencode, and more — with practical guidance on when each
    excels and where they fall short.
---

# Agentic CLI Roundup: Claude Code, Gemini CLI, Codex, opencode, and Beyond

The terminal is having a renaissance. After a decade of IDEs absorbing every conceivable developer workflow — debugging, testing, profiling, even chat — the command line is suddenly the most interesting place in software development again. The reason is agentic coding CLIs: programs that sit in your terminal, take natural-language instructions, and write, edit, and debug code on your behalf.

I've spent the past six months working with every major entry in this space — as a power user of some and as a contributor to one (opencode). This is my attempt to survey the landscape honestly, warts and all, so you can decide which tool fits your workflow.

## The Landscape at a Glance

| Tool | Maker | Model(s) | Open Source | Key Differentiator |
|------|-------|----------|-------------|-------------------|
| **Claude Code** | Anthropic | Claude 3.5/4 Sonnet, Opus | No | Deep reasoning, long context, edit-first |
| **Gemini CLI** | Google | Gemini 2.5 Pro | No | Google Cloud integration, massive context |
| **Codex CLI** | OpenAI | GPT-4o, o-series | No | Sandboxed execution, strong coding benchmarks |
| **opencode** | Community (Sutliff Labs) | BYOM (bring your own model) | Yes (MIT) | Model-agnostic, extensible, agent orchestration |
| **Copilot CLI** | GitHub (Microsoft) | GPT-4o, Claude 3.5 | No | Ubiquity, natural language to shell |

Each occupies a different point in the design space. The differences matter more than the similarities.

## Claude Code: The Reference Implementation

Anthropic's Claude Code is the tool that every other agentic CLI is measured against, and for good reason. It was first to market with a genuinely useful terminal-based agent, and it shows the most attention to interaction design.

**What it does well:**

The edit workflow is Claude Code's killer feature. You describe a change, and it reads the relevant files, plans the edit, applies it, and shows you a diff before committing. This loop — describe, plan, apply, verify — is the core interaction pattern, and it works because Claude's models are exceptional at reasoning about existing codebases. The 200K context window means it can ingest your entire project's relevant source in one shot and understand how a change ripples through the code.

The bash integration is also excellent. Claude Code can run shell commands, see the output, and adjust its approach based on errors. This creates a genuine feedback loop: it writes code, runs it, sees it fail, fixes it, and re-runs. I've watched it debug through four cycles of compilation errors without intervention, each time correctly inferring the root cause from the error message alone.

**Where it falls short:**

It's proprietary, and it's expensive. Claude Code uses API credits at the highest tier — a heavy session can burn through $20–$50 in a few hours if you're asking it to think deeply about complex problems. The pricing model makes sense for Anthropic (compute is expensive), but it creates an uncomfortable dynamic where you're incentivized to ask fewer, simpler questions.

The model lock-in is real. Claude Code only works with Claude models. If Anthropic changes the model behavior, your workflow changes. If a new model with different strengths emerges (say, a specialized code model), you can't swap it in.

**Best for:** Complex refactoring, deep reasoning tasks, and developers who already trust Claude for code and are willing to pay for the quality.

## Gemini CLI: The Dark Horse

Google's entry into the space arrived later but brings some genuinely novel capabilities. Gemini CLI connects directly to Google Cloud services — BigQuery, Cloud Run, GKE, Artifact Registry — and can manage them from natural language prompts.

**What it does well:**

The Cloud integration is not a gimmick. I asked Gemini CLI to "find all BigQuery tables that haven't been accessed in 90 days" and it produced the SQL, ran it against theINFORMATION_SCHEMA, and showed me the results. This is a fundamentally different capability from writing code in a local repository — it's operating on live infrastructure with awareness of your GCP project's state.

The context window is enormous. Gemini 2.5 Pro supports up to 1 million tokens at launch (with 2M in preview). This matters less for everyday coding and more for analysis tasks — ingesting a complete legacy codebase, a year of build logs, or an entire API surface and asking targeted questions about it.

**Where it falls short:**

It's the youngest entry and it shows. The tooling is less polished, the plugin/extensions ecosystem is thin, and the model can be inconsistent on tasks that Claude Code handles routinely — particularly multi-file edits where the model needs to track context across several dependent changes.

Google Cloud focus is both a strength and a limitation. If you're not on GCP, half of what makes Gemini CLI special doesn't apply to you. For local development on AWS or Azure, it's a capable-but-unremarkable coding assistant.

**Best for:** Heavy GCP users, large-codebase analysis, and anyone who wants to query their infrastructure in natural language.

## Codex CLI: Sandboxed and Structured

OpenAI's Codex CLI takes a different architectural approach than the others. Instead of operating directly on your filesystem, it runs generated code in a sandboxed environment — a Docker-style isolation layer that prevents the agent from accidentally deleting your home directory or running destructive commands.

**What it does well:**

The sandbox is an underrated innovation. One of the scariest things about agentic coding tools is the trust you're placing in a model that might hallucinate a `rm -rf /` instead of `rm -rf ./build`. Codex CLI's sandbox means you never have to worry about this. The agent can try things, fail, and retry without any risk to your actual development environment.

The evaluation harness is another differentiator. OpenAI has published benchmarks showing Codex CLI scoring competitively on SWE-bench and related coding benchmarks, and they've released the evaluation framework so you can reproduce the results. For teams that need to certify tool performance — say, for regulatory compliance or internal quality gates — this matters.

**Where it falls short:**

The sandbox is also a constraint. If your project depends on specific system tools, database connections, or network services, the sandbox won't have access to them. This limits Codex CLI's usefulness for full-stack development where the code needs to interact with real services.

OpenAI's model pricing adds up similarly to Claude's. Each agentic loop — propose, run, observe, fix — generates multiple API calls, and the token consumption for complex tasks is substantial. The per-query economics are better than Claude for simple tasks (GPT-4o is cheaper than Claude Opus) but converge at scale.

**Best for:** Safe experimentation, teams that need reproducible evaluations, and developers who are nervous about giving an AI agent filesystem access.

## opencode: The Open Alternative

Full disclosure: I work on opencode. But that's exactly why I'm including it — I have the most intimate knowledge of its design decisions and trade-offs.

opencode is model-agnostic by design. You bring your own model — any OpenAI-compatible API, local GGUF via llama.cpp, Anthropic, Google, or a custom endpoint. This has real consequences for the user experience:

**What it does well:**

No vendor lock-in. When a better model comes out, you swap the config and keep the same workflow. When a model provider has an outage, you switch to a fallback. When you want to run entirely offline with a local 7B model for routine tasks, you can. This freedom is the entire point of opencode.

The agent architecture is modular. opencode separates planning, tool use, and evaluation into independent components that can be configured or replaced. Want a different planning strategy? Swap the planner. Want to add a custom tool that queries your internal API? Register it. The system is designed for extensibility in a way that proprietary tools can't match.

The cost structure is whatever you make it. With a local model, incremental cost approaches zero. With an API model, you pay the provider's rates with no premium on top. For heavy users, this difference is substantial — I've run thousands of agentic sessions for what a single Claude Code heavy session would cost.

**Where it falls short:**

You have to configure it. Model-agnostic means there's no single "best" setup — you need to pick models, tune parameters, and understand the trade-offs. For a developer who wants to install one thing and have it work perfectly, this is friction.

The polish isn't there yet. Claude Code has had more engineering time invested in the interaction model, the diff display, the error recovery flows, and the general feel of the tool. opencode is younger and it shows in the rough edges.

**Best for:** Developers who value control over convenience, teams that need to standardize on specific models, cost-sensitive users, and anyone building agentic workflows on top of a CLI framework.

## Copilot CLI: The Incumbent

GitHub Copilot CLI is everywhere because GitHub is everywhere. If you have a GitHub account, you can use Copilot CLI — it's that simple.

**What it does well:**

The "explain this" and "what does this command do" features are genuinely useful and feel magical the first few times. Pointing at a complex `find` pipeline and having the tool explain each flag in plain English is a productivity win that doesn't require any workflow change.

The natural-language-to-shell pipeline is the most refined in the category. Asking "find all JSON files modified in the last week and count their lines" produces the correct shell command with high reliability, and the explanations make it a learning tool as well as a productivity tool.

**Where it falls short:**

It's not really an agentic coding tool in the same sense as the others. Copilot CLI is excellent at shell commands and simple code queries, but it doesn't maintain conversation context across complex multi-file edits, run code and iterate on failures, or manage long-running agentic workflows. It's a smart autocomplete for your terminal, not a coding agent.

The model choice is opaque. You get whatever GitHub/OpenAI decides to serve you, with no control over which model handles your query or how it's configured.

**Best for:** Quick shell commands, learning Unix tools, and developers who want a lightweight assistant without committing to a full agentic workflow.

## Beyond the Big Four

A few other entries deserve mention:

**Continue.dev** — An IDE-first approach (VS Code and JetBrains) rather than a pure CLI. It runs local models well and has a sophisticated tab-autocomplete system. If you're an IDE person, this is worth looking at.

**Aider** — An open-source CLI that pioneered the edit-loop pattern before the big players arrived. Strong Git integration, good model support, but the UX shows its age compared to newer tools.

**Cline** — A VS Code extension that adds terminal-based agent capabilities. Interesting middle ground: IDE integration with agentic autonomy.

**SWE-agent** — From Princeton, focused on the research side of agentic coding. Less polished for daily use but the academic rigor is valuable for understanding what these tools can and can't do.

## How to Choose

| If you... | Pick |
|-----------|------|
| Want the best coding model today | Claude Code |
| Live in Google Cloud | Gemini CLI |
| Want sandboxed safety | Codex CLI |
| Value freedom and control | opencode |
| Just need better shell commands | Copilot CLI |

But the honest answer is: try more than one. The tools are different enough that your preference will depend on your specific workflow, not on which one has the highest benchmark score.

I run opencode as my daily driver because I value model flexibility and contribute to the project. But I keep Claude Code installed for the hard problems where I want Claude's reasoning. I use Copilot CLI for quick shell queries. The tools complement each other.

## What the Next Year Will Bring

If I had to predict where this space is going:

**Standardization on the MCP protocol.** The Model Context Protocol is gaining traction as a way for agentic tools to discover and use tools across different providers. If MCP becomes the universal connector — and I think it will — the advantage shifts to tools that support it well.

**Local-first models catching up.** Quantized 7B–14B models are already usable for routine coding tasks. In a year, a good local model will handle 80% of what today requires GPT-4 or Claude. That changes the cost calculus dramatically for opencode and similar tools.

**IDE integration blurring the line.** The distinction between "CLI agent" and "IDE agent" is artificial and won't last. Tools that work well in both modes — or that make the CLI mode feel as interactive as an IDE — will win user preference.

**Enterprise features becoming table stakes.** Audit trails, policy enforcement, approved-model lists, and cost tracking are coming to every serious tool. The ones that don't support enterprise workflows will be confined to individual use.

The CLI renaissance is real, and it's still early. The tools I've described above will look primitive in two years. But they're useful today — and choosing the right one for your work can make the difference between fighting your tools and letting them fight for you.
