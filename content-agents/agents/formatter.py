"""Formatter — converts a thread session into a MkDocs-compatible markdown file
and a CUE thread definition file."""

from __future__ import annotations

import re
from dataclasses import dataclass
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


@dataclass(frozen=True)
class ArticleMeta:
    """Shared metadata computed once, used by both markdown and CUE formatters."""
    slug: str
    date: str
    tags: list[str]
    description: str
    starter: str

    @classmethod
    def from_session(cls, session: ThreadSession) -> ArticleMeta:
        topic = session.topic
        return cls(
            slug=slugify(topic.title),
            date=datetime.now(timezone.utc).strftime("%Y-%m-%d"),
            tags=topic.tags_guess or [topic.category],
            description=(
                f"A multi-perspective discussion on {topic.title} "
                f"featuring {', '.join(session.persona_order)}."
            ),
            starter=session.persona_order[0] if session.persona_order else "ffiltus",
        )


def _escape_cue_string(s: str) -> str:
    """Escape special characters for CUE single-line strings."""
    return s.replace("\\", "\\\\").replace('"', '\\"')


def _cue_indent(text: str, level: int) -> str:
    """Indent each line of text for CUE multi-line strings."""
    prefix = "\t" * level
    return "\n".join(prefix + line if line.strip() else line for line in text.split("\n"))


def format_thread(session: ThreadSession, meta: ArticleMeta) -> str:
    """Convert a completed thread session into a MkDocs markdown article."""
    topic = session.topic
    lines = [
        "---",
        f'title: "{topic.title}"',
        f"date: {meta.date}",
        f"tags: [{', '.join(meta.tags)}]",
        f"description: |",
        f"    {meta.description}",
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

    for i, post in enumerate(session.thread):
        lines.append(f"## {post.persona_name}")
        if post.is_opening:
            lines.append("*Opening post*")
        else:
            lines.append("")
        lines.append("")
        lines.append(post.content.strip())
        lines.append("")
        if i < len(session.thread) - 1:
            lines.append("---")
            lines.append("")

    return "\n".join(lines)


def format_thread_cue(session: ThreadSession, meta: ArticleMeta) -> str:
    """Convert a completed thread session into a CUE thread definition."""
    topic = session.topic

    post_lines = []
    for post in session.thread:
        body_text = post.content.strip().replace("\\", "\\\\")
        indented_body = _cue_indent(body_text, 3)
        ts_str = post.timestamp.strftime("%Y-%m-%d %H:%M")
        post_lines.append(
            f'\t\t{{\n'
            f'\t\t\tuser: "{post.persona_name}"\n'
            f'\t\t\ttimestamp: "{ts_str}"\n'
            f'\t\t\tbody: """\n'
            f'{indented_body}\n'
            f'\t\t\t"""\n'
            f'\t\t}}'
        )

    posts_block = "\n".join(post_lines)
    tags_cue = ", ".join(f'"{_escape_cue_string(t)}"' for t in meta.tags)

    return f'''package sutliff

threads: "{meta.slug}": {{
\tid:       "{meta.slug}"
\ttitle:    "{_escape_cue_string(topic.title)}"
\tdate:     "{meta.date}"
\tcategory: "{topic.category}"
\ttags:     [{tags_cue}]
\tstarter:  "{meta.starter}"
\tdescription: """
\t\t{_escape_cue_string(meta.description)}
\t\t"""

\tposts: [
{posts_block}
\t]
}}
'''


def write_article(session: ThreadSession, config: AppConfig) -> Path:
    """Write both the markdown article and CUE thread definition. Returns the markdown path."""
    meta = ArticleMeta.from_session(session)
    output_dir = config.output_path
    output_dir.mkdir(parents=True, exist_ok=True)

    md_path = output_dir / f"{meta.slug}.md"
    md_path.write_text(format_thread(session, meta))
    print(f"  [formatter] Wrote {md_path}")

    cue_dir = config.cue_path / "opinions"
    cue_dir.mkdir(parents=True, exist_ok=True)
    cue_path = cue_dir / f"{meta.slug}.cue"
    cue_path.write_text(format_thread_cue(session, meta))
    print(f"  [formatter] Wrote CUE: {cue_path}")

    return md_path
