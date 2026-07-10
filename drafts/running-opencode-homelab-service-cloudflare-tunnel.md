---
title: "Running OpenCode as a Homelab Service Behind Cloudflare Tunnel"
date: 2026-07-09
tags: [Tutorial, opencode, homelab, Cloudflare, Podman, infrastructure]
description: |
    Run opencode as a headless containerized service on your homelab server,
    accessible from anywhere via Cloudflare Tunnel — with health checks,
    slot-swap deploys, and zero-downtime updates.
---

# Running OpenCode as a Homelab Service Behind Cloudflare Tunnel

I run AI coding agents on a $40/month server under my desk. Not because I can't afford cloud compute — because I want control over where my code lives, which models I use, and how much I spend. OpenCode is the first agent that made this practical. It's MIT-licensed, provider-agnostic, and has a client-server architecture that separates the agent logic from the interface — which means you can run it headless.

Here's how to deploy opencode as a containerized service on a homelab server, accessible from anywhere via Cloudflare Tunnel, with health checks and zero-downtime updates.

## The Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Homelab Server (Podman, $40/mo)                        │
│  ┌───────────────────────────────────────────────────┐  │
│  │  opencode-a (active slot)                          │  │
│  │  ┌──────────┐  ┌──────────────────────────────┐   │  │
│  │  │ Go TUI   │  │ Bun/Hono HTTP Server          │   │  │
│  │  │ (unused) │  │ :3000 → ACP endpoint          │   │  │
│  │  └──────────┘  └──────────────────────────────┘   │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  opencode-b (standby slot)                         │  │
│  └───────────────────────────────────────────────────┘  │
│                         │                                │
│              Cloudflare Tunnel → opencode.ffilt.us       │
└─────────────────────────────────────────────────────────┘
```

## Step 1: The Containerfile

```dockerfile
FROM oven/bun:1 AS build

# opencode needs Go for the TUI binary
RUN apt-get update && apt-get install -y golang-go git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

FROM oven/bun:1-slim
RUN apt-get update && apt-get install -y golang-go && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app /app

ENV OPENCODE_PORT=3000
ENV OPENCODE_HEADLESS=true
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["bun", "run", "start"]
```

The key flag is `OPENCODE_HEADLESS=true` — this tells opencode to start the HTTP server without launching the interactive TUI. We don't need a terminal; we need an API.

## Step 2: Agent-Stack Config

My homelab runs an agent-stack controller that manages all services via reconciliation loops. Here's the config:

```json
{
  "name": "opencode",
  "containers": [{
    "name": "opencode",
    "image": "ghcr.io/reedsutliff/opencode-headless:latest",
    "port": 3000,
    "healthCheck": { "path": "/health", "timeout": 5 },
    "strategy": { "type": "blue-green" },
    "expose": {
      "tunnel": "opencode.ffilt.us"
    },
    "env": {
      "OPENCODE_HEADLESS": "true",
      "ANTHROPIC_API_KEY": "{SECRETS.ANTHROPIC_API_KEY}",
      "OPENAI_API_KEY": "{SECRETS.OPENAI_API_KEY}",
      "DEEPSEEK_API_KEY": "{SECRETS.DEEPSEEK_API_KEY}"
    },
    "volumes": [{
      "source": "/srv/data/opencode",
      "target": "/app/data"
    }]
  }]
}
```

The `blue-green` strategy means the controller builds the new container in slot `b` while `a` is still running, health-checks it, then swaps traffic. Zero downtime.

## Step 3: Cloudflare Tunnel

The agent-stack controller handles Cloudflare tunnel creation automatically via the `expose.tunnel` field. It creates a named tunnel, points it at the container's port, and provisions DNS for `opencode.ffilt.us`. Behind the scenes, it's `cloudflared tunnel route dns` and a systemd sidecar.

If you're doing this manually:

```bash
cloudflared tunnel create opencode
cloudflared tunnel route dns opencode opencode.ffilt.us
cloudflared tunnel run --url http://localhost:3000 opencode
```

But the controller approach means this is declarative — if the tunnel goes down, the reconciliation loop restarts it.

## Step 4: Provider Configuration

OpenCode supports 20+ providers. For a homelab, the right mix is:

| Task | Provider | Model | Why |
|---|---|---|---|
| Hard problems | Anthropic | Claude Opus 4.6 | Best reasoning, most expensive |
| Routine coding | DeepSeek | V4 Pro | 80.6% SWE-bench at $3.48/MTok |
| Quick fixes | Ollama (local) | Qwen 2.5 Coder 32B | Zero cost, low latency |
| Large refactors | Google | Gemini 2.5 Pro | 1M token context window |

Configure these in `.opencode/config.yaml`:

```yaml
providers:
  anthropic:
    api_key: ${ANTHROPIC_API_KEY}
    default_model: claude-opus-4-6
  deepseek:
    api_key: ${DEEPSEEK_API_KEY}
    default_model: deepseek-v4-pro
  ollama:
    base_url: http://ollama:11434
    default_model: qwen2.5-coder:32b
```

The homelab economics change when you can route simple tasks to a local model that costs nothing and save the cloud models for problems that actually need them.

## Step 5: Verification

```bash
# Health check
curl https://opencode.ffilt.us/health
# {"status":"ok","uptime":342}

# Send a task via ACP
curl -X POST https://opencode.ffilt.us/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Review the PR at github.com/myorg/myrepo/pull/42 for security issues"}'

# Check deploy status
curl https://opencode.ffilt.us/api/v1/sessions/{session_id}
```

## Why This Matters

Running opencode on a homelab isn't about saving money — it's about control. Your code never leaves your infrastructure unless you choose to send it to a cloud model. You can switch providers based on task requirements, not vendor lock-in. And when the next model release drops, you add it to your config, not to your monthly bill.

The agent runs on your terms. That's the homelab promise, and opencode delivers it.
