#!/usr/bin/env python3
"""
MkDocs pre-build hook: validates CUE data and injects it into templates.

This replaces the need for individual .md blog post files. All content
is sourced from `/cue/*.cue` definitions.

Installation:
  1. Copy this to `hooks/cue_data.py` in the MkDocs repo
  2. Add `cue_data` to mkdocs.yml `hooks:` list (before macros plugin)
  3. Set `CUE_DIR` env var or pass via mkdocs.yml `extra: cue_dir: cue/`

Usage in templates:
  {{ cue.threads["the-0-01-that-justifies-anything"].title }}
  {{ cue.get_user("raid_zero").display }}
  {% for t in cue.recent_threads(5) %}
    {{ t.title }}
  {% endfor %}
"""

import logging
import os
import sys
from pathlib import Path

log = logging.getLogger("mkdocs.hooks.cue")

# Add cue_engine to path
_hook_dir = Path(__file__).parent
_cue_engine_dir = _hook_dir / ".." / "cue"  # or wherever cue_engine.py lives
if str(_cue_engine_dir) not in sys.path:
    sys.path.insert(0, str(_cue_engine_dir))

# Also check common locations
for p in [
    _hook_dir / ".." / "cue" / "cue_engine.py",
    _hook_dir / "cue" / "cue_engine.py",
    Path.cwd() / "cue" / "cue_engine.py",
    Path(os.environ.get("CUE_ENGINE", "")),
]:
    if p and p.suffix == ".py" and p.exists():
        _cue_engine_dir = p.parent
        if str(_cue_engine_dir) not in sys.path:
            sys.path.insert(0, str(_cue_engine_dir))
        break

from cue_engine import ContentStore

_store: ContentStore | None = None


def on_pre_build(config):
    """Pre-build hook: validate CUE data and load into memory."""
    global _store

    cue_dir = config.extra.get("cue_dir", os.environ.get("CUE_DIR", "cue"))
    cue_path = Path(config.get("docs_dir", "docs")).parent / cue_dir

    if not cue_path.exists():
        log.warning("CUE directory not found: %s — skipping CUE validation", cue_path)
        return

    _store = ContentStore(cue_path)

    # Validate
    if not _store.validate():
        log.error("CUE validation FAILED. Build aborted.")
        sys.exit(1)

    # Load data
    if not _store.load():
        log.error("CUE load FAILED. Build aborted.")
        sys.exit(1)

    log.info("CUE data loaded: %d users, %d threads",
             len(_store.users), len(_store.threads))


def on_page_markdown(markdown, page, config, files):
    """Post-process each page — we can inject CUE data or skip .md rendering
    for pages that are driven from CUE data."""
    # This hook runs for every .md file. If the page is a legacy .md file
    # that hasn't been converted to CUE, pass through unchanged.
    # In the future, CUE-driven pages won't have .md files at all —
    # they'll be generated entirely by the macros.
    return markdown


def define_env(env):
    """Make CUE data available to Jinja templates."""

    @env.macro
    def cue_store():
        """Get the full content store."""
        return _store

    @env.macro
    def cue_thread(slug: str):
        """Get a single thread by slug."""
        if _store:
            return _store.get_thread(slug)
        return None

    @env.macro
    def cue_user(user_id: str):
        """Get a single user by ID."""
        if _store:
            return _store.get_user(user_id)
        return None

    @env.macro
    def cue_threads(category: str | None = None, limit: int = 10):
        """Get threads, optionally filtered by category."""
        if not _store:
            return []
        if category:
            threads = _store.threads_by_category(category)
        else:
            threads = _store.recent_threads(limit)
        return threads[:limit]

    @env.macro
    def cue_today():
        """Get today's daily threads."""
        if _store:
            return _store.today_threads()
        return []

    @env.macro
    def forum_post(handle: str, timestamp: str, body: str, sig: bool = True, quote: str = ""):
        """Render a forum post block (legacy macro — now reads from CUE data).
        This macro is for backward compatibility with existing templates.
        New templates should render from CUE data directly."""
        user = _store.get_user(handle) if _store else None
        if user:
            display = user.get("display", handle)
            avatar = user.get("avatar", "")
            role = user.get("role", "")
        else:
            display = handle
            avatar = ""
            role = ""
        # Return dict for template rendering
        return {
            "handle": handle,
            "display": display,
            "avatar": avatar,
            "role": role,
            "timestamp": timestamp,
            "body": body,
            "sig": sig,
            "quote": quote,
        }

    @env.macro
    def cue_render_thread(slug: str):
        """Render a complete thread from CUE data as a forum thread page."""
        if not _store:
            return "<!-- CUE store not loaded -->"
        thread = _store.get_thread(slug)
        if not thread:
            return f"<!-- Thread '{slug}' not found -->"

        lines = [
            f"# {thread.get('title', slug)}",
            "",
            f"*A discussion in the **#{thread.get('category', 'general')}** channel.*",
            "",
            "---",
            "",
        ]
        for post in thread.get("posts", []):
            user = _store.get_user(post.get("user", ""))
            display = user.get("display", post["user"]) if user else post["user"]
            avatar = user.get("avatar", "") if user else ""
            lines.append(f"{{{{ forum_post('{post['user']}', "
                         f"'{post.get('timestamp', '')}', '''")
            lines.append(_store.format_post_body(post.get("body", "")))
            lines.append("''') }}")
            lines.append("")

        return "\n".join(lines)


def on_post_build(config):
    """Post-build hook: log success."""
    if _store:
        log.info("CUE build complete: %d threads rendered", len(_store.threads))
