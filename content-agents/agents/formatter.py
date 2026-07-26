"""Formatter — converts a thread session into a MkDocs-compatible markdown file."""

from __future__ import annotations

import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

from .models import AppConfig, ThreadSession


def slugify(title: str) -> str:
    """Convert a title to a URL-friendly slug."""
    slug = title.lower()
    slug = re.sub(r"[^\w\s-]", "", slug)
    slug = re.sub(r"[-\s]+", "-", slug)
    slug = slug.strip("-")
    return slug


def format_thread(
    session: ThreadSession,
    config: AppConfig,
) -> str:
    """Convert a completed thread session into a MkDocs markdown article."""
    topic = session.topic

    # Build frontmatter
    date_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    tags = topic.tags_guess or [topic.category]
    tags_yaml = ", ".join(tags)

    # Build description
    description = (
        f"A multi-perspective discussion on {topic.title} "
        f"featuring {', '.join(session.persona_order)}."
    )

    lines = [
        "---",
        f'title: "{topic.title}"',
        f"date: {date_str}",
        f"tags: [{tags_yaml}]",
        f"description: |",
        f"    {description}",
        "---",
        "",
        f"# {topic.title}",
        "",
        f"*This article was generated through an automated multi-agent discussion. "
        f"The following personas contributed: {', '.join(session.persona_order)}.*",
        "",
        "---",
        "",
    ]

    # Format each post
    for i, post in enumerate(session.thread):
        lines.append(f"## {post.persona_name}")
        if post.is_opening:
            lines.append(f"*Opening post*")
        else:
            lines.append(f"")
        lines.append("")
        lines.append(post.content.strip())
        lines.append("")
        if i < len(session.thread) - 1:
            lines.append("---")
            lines.append("")

    return "\n".join(lines)


def write_article(
    session: ThreadSession,
    config: AppConfig,
    base_dir: Optional[str | Path] = None,
) -> Path:
    """Write the formatted article to disk. Returns the output path."""
    if base_dir:
        output_dir = Path(base_dir) / config.output_dir
    else:
        output_dir = config.output_path

    output_dir.mkdir(parents=True, exist_ok=True)

    content = format_thread(session, config)
    slug = slugify(session.topic.title)
    out_path = output_dir / f"{slug}.md"

    out_path.write_text(content)
    print(f"  [formatter] Wrote {out_path}")
    return out_path
