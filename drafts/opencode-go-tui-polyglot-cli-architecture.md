---
title: "OpenCode's Go TUI: Why Polyglot CLI Architecture Works"
date: 2026-07-14
tags: [opencode, Go, TypeScript, CLI, architecture, Bun, TUI]
description: |
    OpenCode runs a Go terminal UI alongside a TypeScript HTTP server. That sounds
    like unnecessary complexity — but it's actually a sophisticated bet on using
    the right runtime for the right job. Here's why it works.
---

# OpenCode's Go TUI: Why Polyglot CLI Architecture Works

When you run `opencode` in a terminal, two things start simultaneously: a TypeScript HTTP server on Bun, and a Go binary that renders the terminal UI. The server handles everything — model inference, tool execution, ACP protocol, session management. The Go binary handles exactly one thing: drawing text on a screen.

This sounds like overengineering. Why not just use a TypeScript TUI library and keep everything in one language? The answer reveals something interesting about CLI tool design in 2026 — and about why the right runtime for terminal interaction might not be the right runtime for agent logic.

## The Two-Process Architecture

```
┌─────────────────────────────────────────┐
│  opencode CLI (single command)          │
│                                         │
│  ┌─────────────────┐  ACP over HTTP    │
│  │  Go TUI Process  │◄────────────────►│
│  │  (Bubble Tea)    │   localhost:3000  │
│  └─────────────────┘                   │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  Bun HTTP Server (TypeScript)       ││
│  │  • Model inference                  ││
│  │  • Tool execution                   ││
│  │  • Session management               ││
│  │  • Provider routing                 ││
│  │  • ACP / MCP protocol handling      ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

The two processes communicate over localhost via ACP (Agent Client Protocol). The Go TUI sends user input as ACP messages. The Bun server processes them and streams responses back. The TUI renders the streaming output. They're separate processes with separate lifecycles, connected by a protocol.

This design has three advantages that aren't obvious until you've built a terminal agent.

## Advantage 1: Terminal Rendering Is a Different Performance Profile

Terminal UIs have a unique constraint: they must render at 60fps to feel responsive, but the actual rendering work is tiny — colored text, boxes, scrollable buffers. The bottleneck is not compute; it's I/O scheduling and signal handling.

Go's runtime is built for this. Goroutines are cheap, the scheduler is cooperative, and the standard library's terminal handling (signals, raw mode, escape sequences) is mature. Go's garbage collector has sub-millisecond pause times, which matters when you're rendering 60 times per second.

Bun/Node's event loop is also fast, but terminal rendering creates a specific tension: you need to poll for terminal resize signals (SIGWINCH), handle raw input byte-by-byte (escape sequences for arrow keys, mouse), and maintain a render loop that doesn't block the event loop during I/O. Node can do all of this — libraries like `blessed` and `ink` prove it — but it requires careful management of the event loop that adds complexity to an already complex application.

By separating the TUI into a Go process, opencode isolates the rendering concerns. The Go binary doesn't know about LLM providers, tool execution, or session state. It receives structured data over ACP and renders it. That's the entire job. The separation means rendering performance never competes with model inference for CPU time.

## Advantage 2: Headless Mode Is Free

Because the TUI and server are separate processes connected by a protocol, running opencode in headless mode requires zero code changes. You just don't start the Go binary.

```
# Interactive mode: starts both Go TUI + Bun server
opencode

# Headless mode: starts only the Bun server
opencode --headless

# Or: OPENCODE_HEADLESS=true opencode
```

This is the architecture's killer feature. Every other AI coding CLI has to either run in a terminal or awkwardly expose a separate API mode. OpenCode's headless mode is the same server that powers the TUI — same endpoints, same session management, same provider routing. The TUI is just one possible client.

This matters for infrastructure. When I deploy opencode as a containerized service on my homelab, the Containerfile only needs the Bun runtime. The Go binary doesn't even ship in the production image. The Dockerfile can be:

```dockerfile
FROM oven/bun:1-slim
# No Go runtime needed for headless deployment
COPY --from=build /app/server /app
CMD ["bun", "run", "start:server"]
```

The Go TUI lives on developer machines. The Bun server lives everywhere.

## Advantage 3: The Protocol Boundary Forces Clean Architecture

The hardest problem in CLI agent design is keeping the interface and the logic separate. When both live in the same process, it's tempting to have the TUI directly call model functions, or have the model output directly manipulate terminal state. The result is spaghetti — changing the TUI layout breaks model inference, and adding a new provider requires touching rendering code.

OpenCode's ACP boundary prevents this. The Go binary can only communicate via structured protocol messages. It can't call `provider.anthropic.complete()` directly. It can't access the session store. It sends a prompt and receives streaming tokens. Every interaction goes through the server's API.

This constraint means:
- The TUI can be rewritten in any language (Rust, Swift, Kotlin) without touching the server
- The server API is the same whether the client is a Go TUI, a VS Code extension, or a curl command
- Testing the server doesn't require a terminal — it's a standard HTTP API
- ACP becomes the universal interface: any editor, any agent, same protocol

## The Polyglot Bet

OpenCode's architecture bets that the best runtime for terminal interaction (Go) is different from the best runtime for agent logic (TypeScript on Bun). Bun was chosen for the server because the AI SDK ecosystem is TypeScript-first — Vercel AI SDK, model providers, MCP libraries are all JS/TS. Go was chosen for the TUI because Bubble Tea (the Go TUI framework) is the most mature terminal UI library across any language, and Go's runtime characteristics match terminal rendering requirements.

This bet pays off in ways that aren't visible in a demo. When Anthropic releases a new model, opencode adds a TypeScript provider — the Go TUI doesn't change. When someone wants an iOS client, they implement ACP in Swift — the Bun server doesn't change. The protocol is the product; the runtimes are implementation details.

## The Lesson for CLI Tool Design

The conventional wisdom is "pick one language for your CLI tool." OpenCode's architecture suggests a different rule: **pick the right language for each concern, and connect them with a protocol.** The cost of running two processes is negligible on modern hardware. The benefit — clean separation, free headless mode, language-appropriate runtimes — compounds with every feature you add.

Your terminal UI shouldn't know about LLM providers. Your model server shouldn't know about terminal escape sequences. Put a protocol between them and let each side use the runtime it needs.
