#!/usr/bin/env bash
#
# Stage the public artifact for Azure Static Web Apps.
#
# WHY THIS EXISTS
# ---------------
# SWA's deploy takes a directory and publishes EVERYTHING in it. Deploying the
# repo root therefore published:
#
#   /.git/            -> the full git object store, including the CI
#                        GITHUB_TOKEN in .git/config (a live credential)
#   /resume/data/*.yaml -> personal resume data (email, phone, address)
#                           and per-employer job-application records
#   /AGENTS.md, /README.md, /.mailmap -> internal notes + personal emails
#   /.github/, /.gitea/   -> CI workflow definitions
#
# All of that was readable by anyone on the internet. This script builds a
# clean staging directory containing ONLY the files meant to be public, and
# deploys that. The API folder is staged separately because SWA treats it as
# the Functions app rather than static content.
#
# Usage: scripts/stage-public.sh <dest-dir>
#   Copies the public site into <dest-dir>/site and the Functions app into
#   <dest-dir>/api. Exits non-zero if anything required is missing.
set -euo pipefail

DEST="${1:?usage: stage-public.sh <dest-dir>}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SITE="$DEST/site"
API="$DEST/api"

echo "[stage-public] repo: $REPO_ROOT"
echo "[stage-public] dest: $DEST"

rm -rf "$SITE" "$API"
mkdir -p "$SITE" "$API"

# ---------------------------------------------------------------------------
# Static site: explicit allow-list. Anything not named here is NOT published.
# ---------------------------------------------------------------------------
copy_required() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    echo "[stage-public] FATAL: required file missing: $src" >&2
    exit 1
  fi
  cp -r "$src" "$dst"
}

copy_required "$REPO_ROOT/index.html"             "$SITE/index.html"
copy_required "$REPO_ROOT/staticwebapp.config.json" "$SITE/staticwebapp.config.json"
copy_required "$REPO_ROOT/assets"                 "$SITE/assets"
copy_required "$REPO_ROOT/data"                   "$SITE/data"
copy_required "$REPO_ROOT/LICENSE"                "$SITE/LICENSE"

# ---------------------------------------------------------------------------
# Functions app: the three proxies + their runtime manifest.
# node_modules is installed by CI (npm ci) before this runs, and is required
# for the Functions runtime, so it is carried over.
# ---------------------------------------------------------------------------
for f in overview.js services.js heatmap.js host.json package.json package-lock.json; do
  copy_required "$REPO_ROOT/api/$f" "$API/$f"
done
if [ -d "$REPO_ROOT/api/node_modules" ]; then
  cp -r "$REPO_ROOT/api/node_modules" "$API/node_modules"
fi

# local.settings.json holds local dev secrets and must never be published.
if [ -e "$API/local.settings.json" ]; then
  echo "[stage-public] removing api/local.settings.json (secrets)"
  rm -f "$API/local.settings.json"
fi

echo "[stage-public] staged static site:"
( cd "$SITE" && find . -type f | sort | sed 's/^/  /' )
echo "[stage-public] staged functions app:"
( cd "$API" && find . -maxdepth 1 -type f | sort | sed 's/^/  /' )
echo "[stage-public] done."
