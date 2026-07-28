"""
Shared utilities for converting CUE thread data into MkDocs blog content
and article metadata (articles.json).

Keeps CUE as single source of truth — both generate-articles-json.py and
the MkDocs hook import from here instead of duplicating the conversion.
"""

from __future__ import annotations

import hashlib
import re
from datetime import datetime
from typing import Any

# Handles that map to specific #channel tags (from existing tag conventions)
_CHANNEL_MAP: dict[str, str] = {
    "ai": "ai",
    "devops": "devops",
    "infrastructure": "devops",
    "security": "security",
    "open-source": "open-source",
    "tooling": "dev-tools",
    "developer experience": "dev-tools",
    "engineering": "engineering",
    "languages": "languages",
    "process": "engineering",
}

_MOODS = ["heated", "spirited", "lively", "passionate", "no-holds-barred"]


def _channel_from_tags(tags: list[str]) -> str:
    for t in tags:
        t_lower = t.lower().strip()
        if t_lower in _CHANNEL_MAP:
            return _CHANNEL_MAP[t_lower]
    return tags[0].lower().replace(" ", "-") if tags else "random"


def _channel_preamble(tags: list[str]) -> str:
    channel = _channel_from_tags(tags)
    idx = int(hashlib.md5(",".join(tags).encode()).hexdigest(), 16) % len(_MOODS)
    return f"A {_MOODS[idx]} thread in the **#{channel}** channel."


def _escape_macro_body(text: str) -> str:
    text = text.replace("\\", "\\\\")
    text = text.replace("'", "\\'")
    return text


# ── Article metadata (for articles.json) ────────────────────────────────


def thread_to_article_meta(tid: str, thread: dict) -> dict | None:
    """Convert a CUE thread dict into the articles.json metadata format.

    Returns None if the thread has no title (invalid entry).
    """
    title = thread.get("title", "")
    if not title:
        return None

    date_raw = thread.get("date", "")
    if not date_raw:
        return None  # skip threads without a date (incomplete placeholders)

    try:
        parsed_date = datetime.strptime(str(date_raw)[:10], "%Y-%m-%d")
    except ValueError:
        parsed_date = None

    category = thread.get("category", "post")
    slug = thread.get("slug", tid)

    # Build the full slug matching the MkDocs blogging plugin path
    if category in ("opinion", "tutorial"):
        full_slug = f"{category}s/{slug}"
    elif category == "daily":
        full_slug = f"daily/{slug}"
    else:
        full_slug = slug

    posts_data = thread.get("posts", [])

    return {
        "title": title,
        "slug": full_slug,
        "date": parsed_date.isoformat() if parsed_date else date_raw,
        "tags": thread.get("tags", []),
        "description": thread.get("description", ""),
        "starter": thread.get("starter", posts_data[0]["user"] if posts_data else ""),
        "posts": len(posts_data),
        "category": category,
    }


# ── Markdown blog post content (for MkDocs hook) ───────────────────────


def thread_to_markdown(tid: str, thread: dict) -> str | None:
    """Generate a full blog post markdown string from CUE thread data.

    The output uses ``{{ forum_post(...) }}`` macros for each post,
    matching the existing blog post format.
    """
    title = thread["title"]
    date = thread.get("date", "")
    if not date:
        return None  # skip incomplete threads
    tags = thread.get("tags", [])
    description = thread.get("description", f"A discussion about {title}")
    posts = thread.get("posts", [])

    tags_str = ", ".join(tags)

    frontmatter = (
        "---\n"
        f'title: "{title}"\n'
        f"date: {date}\n"
        f"tags: [{tags_str}]\n"
        f"description: |\n"
        f"    {description}\n"
        "---\n"
    )

    lines = [frontmatter, "", f"# {title}", "", _channel_preamble(tags), "", "---", ""]

    for post in posts:
        handle = post["user"]
        timestamp = post.get("timestamp", f"{date} 12:00")
        body = _escape_macro_body(post["body"])
        quote = post.get("quote", "")

        if quote:
            lines.append(
                "{{{{ forum_post('{}', '{}', '\\n{}\\n', quote='{}') }}}}".format(
                    handle, timestamp, body, quote
                )
            )
        else:
            lines.append(
                "{{{{ forum_post('{}', '{}', '\\n{}\\n') }}}}".format(
                    handle, timestamp, body
                )
            )
        lines.append("")

    return "\n".join(lines)
