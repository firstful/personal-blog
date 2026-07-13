---
title: "OpenCode Headless on a Cron Job: Automated PR Review Every Morning"
date: 2026-07-10
tags: [Tutorial, opencode, automation, homelab, cron, code review, systemd]
description: |
    Wire opencode to a systemd timer so it reviews your overnight pull requests
    automatically — with structured output, provider routing, and failure handling.
---

# OpenCode Headless on a Cron Job: Automated PR Review Every Morning

My agent-stack runs several coding agents on a schedule. Overnight, they process the review queue: open PRs get a first-pass review with structured feedback, and by the time I open my laptop, there are annotated diffs waiting. OpenCode's headless mode makes this straightforward — no terminal, no TUI, just an HTTP API you can hit from a script.

Here's how to wire it up with a systemd timer (the modern cron) on a homelab server.

## Prerequisites

Before setting up the timer, you need:

- **OpenCode running as a service** — accessible via HTTP. On the agent-stack, this means a deployed container with a health-checked endpoint. The script assumes `http://localhost:3000` by default, configurable via `OPENCODE_URL`.
- **GitHub CLI (`gh`) installed** — used to list open PRs. The `gh` binary should be installed on the host (not inside the container) since the systemd service runs on the host. The token needs `repo` scope for listing PRs and reading diffs.
- **A GitHub token with repo scope** — either in the systemd unit's environment or loaded from a file. The token doesn't need `workflow` scope unless you're modifying workflow files.
- **jq installed** — for processing JSON responses from the opencode API. On Arch/Debian: `pacman -S jq` or `apt install jq`.

The script is designed to run on the host and connect to opencode's HTTP API. It does not need to run inside the container — in fact, it should not, because it needs host-level access to systemd and the filesystem for output storage.

## The Script

```bash
#!/bin/bash
# /srv/scripts/opencode-pr-review.sh
# Runs opencode against open PRs and writes structured reviews

OPENCODE_URL="${OPENCODE_URL:-http://localhost:3000}"
REPOS=("reedsutliff/agent-stack" "reedsutliff/personal-blog")
OUTPUT_DIR="/srv/data/opencode/reviews/$(date +%Y-%m-%d)"

mkdir -p "$OUTPUT_DIR"

for repo in "${REPOS[@]}"; do
  echo "=== Reviewing $repo ==="

  # Get open PRs for this repo via GitHub CLI
  gh pr list --repo "$repo" --state open --json number,title,headRefName \
    --jq '.[] | "\(.number) \(.title) (\(.headRefName))"' | while read -r pr_info; do

    pr_number=$(echo "$pr_info" | awk '{print $1}')

    # Build the review prompt
    prompt="Review PR #$pr_number in $repo.
Focus on:
1. Security issues (auth, input validation, secrets exposure)
2. Architectural consistency with existing codebase patterns
3. Error handling completeness
4. Test coverage gaps
Return your review as structured JSON with fields: summary, issues (array of {severity, file, line, description}), suggestions (array of {description}), approved (boolean)."

    # Send to opencode via ACP
    response=$(curl -s -X POST "$OPENCODE_URL/api/v1/sessions" \
      -H "Content-Type: application/json" \
      -d "$(jq -n --arg prompt "$prompt" --arg repo "$repo" \
        '{prompt: $prompt, metadata: {repo: $repo, pr: $pr_number}}')")

    session_id=$(echo "$response" | jq -r '.id')

    # Poll until complete
    status="running"
    while [ "$status" = "running" ]; do
      sleep 10
      status=$(curl -s "$OPENCODE_URL/api/v1/sessions/$session_id" | jq -r '.status')
    done

    # Fetch and save the review
    curl -s "$OPENCODE_URL/api/v1/sessions/$session_id" | \
      jq '{repo: .metadata.repo, pr: .metadata.pr, review: .output}' \
      > "$OUTPUT_DIR/${repo//\//-}-pr${pr_number}.json"

    echo "  PR #$pr_number: $status"
  done
done

echo "Reviews saved to $OUTPUT_DIR"
```

## Configuring OpenCode for Headless Operation

OpenCode's default configuration assumes a TUI is available — you type prompts and see responses in real time. For headless operation, you need to adjust a few settings in your `opencode.json`:

```json
{
  "server": {
    "port": 3000,
    "host": "0.0.0.0"
  },
  "headless": {
    "enabled": true,
    "timeout": 300,
    "maxConcurrentSessions": 4
  },
  "providers": [
    {
      "name": "deepseek",
      "model": "deepseek-chat",
      "apiKey": "${DEEPSEEK_API_KEY}",
      "baseUrl": "https://api.deepseek.com/v1"
    },
    {
      "name": "claude",
      "model": "claude-opus-4-6",
      "apiKey": "${ANTHROPIC_API_KEY}",
      "baseUrl": "https://api.anthropic.com/v1"
    }
  ]
}
```

Key settings for headless mode:

- **`headless.enabled: true`** — tells opencode to skip initializing the TUI. Without this, the process may hang waiting for terminal input.
- **`headless.timeout: 300`** — a hard cap on session duration. Without it, a stuck model call will keep the session running indefinitely, blocking the script's polling loop.
- **`headless.maxConcurrentSessions: 4`** — limits parallel requests to avoid exhausting API rate limits or host memory. Tune based on your model provider's concurrency limits.
- **Provider routing** — define multiple providers and let opencode choose based on the task. In the cron script, you can pass a `provider` field in the session metadata.

If you're deploying through agent-stack, these settings go in the repo's `agent-stack.json` config volume or are baked into the container image via the Containerfile's CMD arguments.

**Service unit** (`/etc/systemd/system/opencode-pr-review.service`):

```ini
[Unit]
Description=OpenCode PR Review
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=reeds
Environment=OPENCODE_URL=http://localhost:3000
Environment=GH_TOKEN=%S/opencode/gh-token
ExecStart=/srv/scripts/opencode-pr-review.sh
StandardOutput=journal
StandardError=journal

# Don't run if opencode isn't healthy
ExecStartPre=/usr/bin/curl -sf http://localhost:3000/health
```

**Timer unit** (`/etc/systemd/system/opencode-pr-review.timer`):

```ini
[Unit]
Description=Daily OpenCode PR Review (6 AM)
Requires=opencode-pr-review.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
```

Enable it:

```bash
systemctl enable --now opencode-pr-review.timer
```

## Provider Routing by Task

The script above uses opencode's default provider, but you can route different tasks to different models based on cost and capability. The opencode config supports multiple providers — the task determines which model is best:

| Task | Provider | Model | Cost/MTok | Rationale |
|---|---|---|---|---|
| Security review | Anthropic | Claude Opus 4.6 | $25 | Highest accuracy for vuln detection |
| Architectural review | DeepSeek | V4 Pro | $3.48 | Adequate for pattern matching, 7x cheaper |
| Test coverage | Ollama (local) | Qwen Coder 32B | $0 | Local model sufficient for coverage analysis |

The script can be extended to pass a `provider` hint based on the review focus. For a homelab, routing security reviews to Claude and routine checks to DeepSeek cuts the monthly bill by 60% without sacrificing detection quality.

## Scheduling Multiple Review Passes

You can layer review passes at different times:

```ini
# 2 AM — Deep review with Claude (expensive, thorough)
OnCalendar=*-*-* 02:00:00

# 8 AM — Quick lint with local model (free, fast)
OnCalendar=*-*-* 08:00:00
```

Each pass writes to a different output directory. The morning review script can diff the two passes to show what the expensive model caught that the local model missed — useful data for deciding when the local model is "good enough."

## Failure Handling

Agent tasks fail. Models time out. APIs rate-limit. The script handles this by writing failures to a separate log:

```bash
if [ "$status" = "failed" ]; then
  echo "[FAIL] $repo PR #$pr_number: $(curl -s "$OPENCODE_URL/api/v1/sessions/$session_id" | jq -r '.error')" \
    >> "$OUTPUT_DIR/failures.log"
fi
```

The systemd timer's `Persistent=true` means missed runs (server was down at 6 AM) execute immediately on next boot. Combined with `RandomizedDelaySec`, you avoid thundering-herd problems if multiple timers fire simultaneously.

### Retry Logic

For transient failures — rate limits, temporary model unavailability — a simple retry wrapper prevents false negatives:

```bash
max_retries=3
retry_delay=30
attempt=0

while [ $attempt -lt $max_retries ]; do
  response=$(curl -s -X POST "$OPENCODE_URL/api/v1/sessions" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg prompt "$prompt" '{prompt: $prompt}')")
  session_id=$(echo "$response" | jq -r '.id // empty')
  [ -n "$session_id" ] && [ "$session_id" != "null" ] && break
  attempt=$((attempt + 1))
  sleep $retry_delay
done

if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
  echo "[FATAL] $repo PR #$pr_number: Could not create session after $max_retries attempts" \
    >> "$OUTPUT_DIR/failures.log"
  continue
fi
```

Three retries with a 30-second gap catches most transient issues without delaying the overall pipeline by more than a couple of minutes.

### Alerting on Critical Failures

PR review failures are usually noise — a model timeout doesn't need a page. But a complete pipeline failure (all PRs failed, or opencode itself is down) should notify you. A simple approach: count the total failures after the script finishes and send a summary:

```bash
failure_count=$(wc -l < "$OUTPUT_DIR/failures.log" 2>/dev/null || echo 0)
total_prs=$(find "$OUTPUT_DIR" -name '*.json' | wc -l)

if [ "$failure_count" -gt "$total_prs" ]; then
  # More failures than successes — something systemic is wrong
  curl -s -d "OpenCode PR review: $failure_count failures out of $total_prs PRs" \
    "https://ntfy.sh/my-topic" > /dev/null
fi
```

On a homelab, I use [ntfy.sh](https://ntfy.sh) for push notifications — a simple curl call sends a notification to my phone. Combine this with the systemd unit's `OnFailure=` directive to trigger a notification service if the entire unit fails.

## The Result

Every morning, `/srv/data/opencode/reviews/2026-07-10/` contains structured JSON reviews for every open PR. A simple morning script can aggregate them:

```bash
cat /srv/data/opencode/reviews/$(date +%Y-%m-%d)/*.json | \
  jq -s 'group_by(.review.approved) | 
    {approved: (.[] | select(.[0].review.approved == true) | length),
     needs_work: (.[] | select(.[0].review.approved == false) | length)}'
```

Three numbers to start your day: how many PRs passed first review, how many need work, and how many the agent couldn't process. The human still makes the final call — but the agent did the first pass while you slept.
