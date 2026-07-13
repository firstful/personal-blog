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

## Secrets Management

API keys are the trickiest part of running an AI agent as a service. You can't bake them into the container image — that violates every security practice and means rebuilding on every key rotation. You can't use env vars at build time either, because the image might be cached and the key leaks into the layer history.

The pattern I use is a **vault service** — a lightweight container on the same podman network that stores secrets and serves them to services on startup. The agent-stack config references secrets with placeholders:

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "{SECRETS.ANTHROPIC_API_KEY}",
    "DEEPSEEK_API_KEY": "{SECRETS.DEEPSEEK_API_KEY}"
  }
}
```

At deploy time, the controller resolves `{SECRETS.*}` tokens by calling the vault API, then passes the resolved values to the container. The vault itself is a simple encrypted JSON store with a single HTTP endpoint — small enough to audit, no moving parts.

If you aren't using a vault, the fallback is a `.env` file mounted from a host path:

```json
{
  "env_file": "/srv/secrets/opencode.env"
}
```

This keeps keys off the image and out of version control. The tradeoff is that the `.env` file becomes part of your backup strategy — lose the file, lose access to the service.

## Troubleshooting

A few things that have gone wrong running opencode headless:

**Health check timing.** The default health check interval is 30s with a 5s timeout. If opencode takes longer to start — slow model downloads, dependency installs on first boot — the health check fails and the blue-green swap aborts. Fix: increase the `startPeriod` to 60s in the health check config, or pre-warm the container with a dummy request.

**Port conflicts.** If you're running multiple services on the homelab, the auto-port range (4000-4999 in agent-stack) can collide. Run `sudo -u reeds podman ps` to check what's already bound, or pin the port explicitly in the config.

**Cloudflare tunnel goes stale.** The cloudflared sidecar can lose its connection after a network interruption. The reconciliation loop handles this — it detects the tunnel process is down and restarts it within 5 seconds — but you'll see a brief blip in availability. Add a retry in your client code for tolerance.

**Model provider rate limits.** When running headless, the agent processes tasks as fast as the API allows. If you're sending multiple PR reviews in parallel, you'll hit provider rate limits quickly. The solution is a simple token-bucket rate limiter in the provider config, or queueing tasks through a sidecar with a configurable concurrency limit.

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

The economics are real too. At $3.48/MTok for open-weight models like DeepSeek V4 Pro, the cost per task is fractions of a cent for routine reviews. Routing simple tasks to a local Ollama model costs zero. The homelab pays for itself once you're processing more than a few hundred agent tasks a month — which, if you're using coding agents daily, you almost certainly are.

The broader point is that agent infrastructure is just infrastructure. The same patterns that keep a web service running — health checks, blue-green deploys, reconciliation loops, secrets management — keep an agent running too. Once you treat the agent like any other service in your stack, the operational complexity drops to near zero.

The agent runs on your terms. That's the homelab promise, and opencode delivers it.
