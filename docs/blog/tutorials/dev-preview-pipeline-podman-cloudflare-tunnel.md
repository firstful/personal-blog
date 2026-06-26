---
tags:
    - Tutorial
    - Podman
    - Cloudflare
    - DevOps
    - Preview Environments
description: |
    A practical guide to building a lightweight dev preview pipeline using
    rootless Podman containers behind Cloudflare Tunnels — no Kubernetes
    required, full HTTPS, and zero-downtime deploys.
image: https://blog.ffilt.us/assets/logo.png
---

# Crafting a Dev Preview Pipeline with Podman + Cloudflare Tunnel

Every team I've been on has had the same problem: how do you show a stakeholder
a feature branch without deploying it to production, spinning up a staging
environment that costs $200/month, or asking them to install Docker and run
something locally? The answer is almost always "we'll just deploy to staging" —
and then the staging environment becomes a garbage dump of half-finished
branches, conflicting migrations, and the lingering ghost of that one PR from
three months ago that nobody remembers.

There's a better way. Rootless Podman containers behind a Cloudflare Tunnel
give you production-like preview environments with full HTTPS, custom domains,
and automatic cleanup — all running on a single $10 VM. I've been running this
exact setup for the agent-stack controller that manages my personal
infrastructure, and it's been remarkably boring (which is the highest praise an
infrastructure setup can receive).

## Why Podman Instead of Docker?

If you're on a server that you SSH into, you have two container runtime options:
Docker (rootful, with a daemon) or Podman (rootless, daemonless). I chose
Podman for three specific reasons:

**No daemon.** Podman doesn't need a background service. It forks a new process
for each container and lets it run as a child of your shell session — or more
practically, as a child of your systemd user service. This means no
`dockerd` to restart when it crashes, no socket file to manage, and no security
surface from a daemon listening on a Unix socket.

**Rootless by default.** Podman runs containers as your user. Not as root, not
through a privileged daemon — just your regular unprivileged user with mapped
UIDs. This is critical on a shared or multi-purpose server because a container
escape doesn't automatically mean root on the host. The `--userns=keep-id` flag
ensures files created inside the container have the same ownership as your host
user, which makes debugging permission issues dramatically simpler.

**Compatible CLI.** If you know Docker, you know Podman. `podman build`, `podman
run`, `podman ps`, `podman logs` — the commands are the same. I switched from
Docker to Podman by aliasing `docker=podman` and never noticed the difference.
When you hit a compatibility edge case (and you will), it's usually around
network configuration or volume mounts with SELinux, but for 95% of use cases
the migration is seamless.

## The Architecture

The pipeline has four layers:

```
Feature Branch → Build Image → Deploy Container → Expose via Cloudflare Tunnel
```

Each feature branch gets its own container with a deterministic hostname
derived from the branch name. The Cloudflare Tunnel routes traffic based on the
subdomain — so `pr-42.myapp.ffilt.us` maps to the container running branch
`pr-42`, while `main.myapp.ffilt.us` maps to the production slot.

Here's the core logic, distilled into a deploy script:

```bash
#!/usr/bin/env bash
# deploy-preview.sh — Build and expose a branch preview
set -euo pipefail

BRANCH="${1?Usage: $0 <branch-name>}"
SAFE_NAME="$(echo "$BRANCH" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-')"
DOMAIN="${SAFE_NAME}.myapp.ffilt.us"
IMAGE="myapp:${SAFE_NAME}"
CONTAINER="myapp--${SAFE_NAME}"

# Build the container image
podman build -t "$IMAGE" .

# Remove old container if it exists (idempotent deploy)
podman rm -f "$CONTAINER" 2>/dev/null || true

# Run with port auto-allocation
podman run -d \
    --name "$CONTAINER" \
    --network stack-net \
    --label "branch=$BRANCH" \
    --label "domain=$DOMAIN" \
    --restart no \
    "$IMAGE"
```

The key detail is the `--network stack-net` flag. All containers in the
preview pipeline share a single Podman network — this lets them communicate
with each other (essential for services that depend on a database or API
sidecar) while remaining isolated from the host network.

## Cloudflare Tunnel Integration

A Cloudflare Tunnel (`cloudflared`) creates an encrypted tunnel from your
server to Cloudflare's edge network. Traffic hits Cloudflare, gets routed
through the tunnel, and lands at a local address on your machine. The tunnel
configuration maps hostnames to ports — or more usefully, to port ranges.

Here's the trick that makes previews scalable: instead of defining every
preview in the tunnel config file (impossible when branches are dynamic), I run
a lightweight sidecar that watches for new containers and registers their ports
with the tunnel automatically.

In my setup, each container gets an auto-assigned port from the 4000-4999
range, and the tunnel config is generated dynamically by a reconciliation loop
similar to what agent-stack uses:

```yaml
# cloudflared/config.yml (generated)
tunnel: my-tunnel-id
credentials-file: /home/user/.cloudflared/credentials.json

ingress:
  - hostname: main.myapp.ffilt.us
    service: http://localhost:4000
  - hostname: pr-42.myapp.ffilt.us
    service: http://localhost:4001
  - hostname: staging.myapp.ffilt.us
    service: http://localhost:4002
  - hostname: "*"
    service: http_status:404
```

The controller I built watches for changes, regenerates this file, and sends a
SIGHUP to `cloudflared` (which reloads the config without dropping existing
connections). The whole cycle takes about two seconds.

## Slot Swap for Zero-Downtime Previews

Here's the part that separates a hobby setup from something you can show
stakeholders with confidence: zero-downtime deploys. Even for preview
environments, nobody wants to see a 502 error because you're rebuilding the
container.

The pattern is borrowed from blue-green deployment — but applied at the
preview level. Each branch gets two slots:

```bash
SLOT_A="myapp--${SAFE_NAME}--a"
SLOT_B="myapp--${SAFE_NAME}--b"
ACTIVE_SLOT_FILE="/tmp/stack.${SAFE_NAME}.slot"

# Determine which slot is active
if [ -f "$ACTIVE_SLOT_FILE" ]; then
    CURRENT=$(cat "$ACTIVE_SLOT_FILE")
    if [ "$CURRENT" = "a" ]; then
        IDLE_SLOT=$SLOT_B
        NEW_ACTIVE="b"
    else
        IDLE_SLOT=$SLOT_A
        NEW_ACTIVE="a"
    fi
else
    IDLE_SLOT=$SLOT_A
    NEW_ACTIVE="a"
fi

# Build and start the idle slot
podman build -t "$IMAGE" .
podman rm -f "$IDLE_SLOT" 2>/dev/null || true
podman run -d --name "$IDLE_SLOT" --network stack-net "$IMAGE"

# Wait for health check
for i in $(seq 1 30); do
    IP=$(podman inspect "$IDLE_SLOT" --format '{{.NetworkSettings.IPAddress}}')
    if curl -s -o /dev/null -w "%{http_code}" "http://${IP}:8080/health" | grep -q "200"; then
        break
    fi
    sleep 1
done

# Swap the traffic and clean up the old slot
echo "$NEW_ACTIVE" > "$ACTIVE_SLOT_FILE"
# Update tunnel config to point to the new container's port...
podman rm -f "$CURRENT_SLOT" 2>/dev/null || true
```

The critical insight: this isn't just for production. Preview environments that
stakeholders visit once and then refresh thirty seconds later need to *just
work*. A 502 during deploy erodes trust in the preview pipeline itself, and
once that trust is gone, stakeholders stop using it and you're back to
"deploy to staging and pray."

## Garbage Collection

The one thing every preview pipeline needs is automatic cleanup. Branches get
merged, stale previews accumulate, and suddenly you have forty containers
sitting on your server using disk space and memory.

I run a daily cron that does two things:

```bash
#!/usr/bin/env bash
# cleanup-previews.sh — Remove previews for merged/closed branches
set -euo pipefail

# Get all active GitHub branches (via the API or local git)
# ...
# For each preview, check if the branch still exists upstream.
# If not, remove the container, the image, and the tunnel entry.

podman ps --filter "label=branch" --format "{{.Label \"branch\"}} {{.ID}}" \
    | while read -r branch cid; do
    # Check if branch exists on origin
    if ! git ls-remote --heads origin "$branch" | grep -q .; then
        echo "Removing preview for merged branch: $branch"
        podman rm -f "$cid"
        podman rmi "myapp:${branch//\//-}" 2>/dev/null || true
    fi
done
```

This keeps your server tidy without manual intervention. The actual agent-stack
controller takes this further — it tracks build failures with exponential
backoff, monitors resource usage, and alerts before disk runs out.

## The Real Advantage

The beauty of this setup isn't any single component. It's the combination:
GitHub webhook triggers a build → Podman runs the container → Cloudflare
Tunnel exposes it with HTTPS → controller manages the lifecycle. The whole
pipeline runs on infrastructure that costs less than a coffee subscription per
month.

I've been running this for months on the machine that hosts this very blog,
with about fifteen active preview environments at any given time. The server
doesn't break a sweat. The only maintenance I ever need is when a container
leaks a port because of a crash during deploy — and the health check catches
that and recycles the slot.

If you're currently managing preview environments with a shared staging server
and a prayer, consider this: rootless Podman gives you the isolation of
containers without the overhead of Kubernetes, and Cloudflare Tunnel gives you
production-grade networking without a load balancer. The two together make
preview environments cheap enough to spin up for every PR — and cheap enough
to forget about until you need them.
