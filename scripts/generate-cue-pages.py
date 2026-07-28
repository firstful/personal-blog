#!/usr/bin/env python3
"""
Pre-build script: generate markdown blog pages from CUE thread data.

Writes to docs/_gen/blog/ (gitignored) — picked up by MkDocs blogging plugin
at build time. This keeps CUE as the single source of truth; no committed
markdown files needed for CUE-based articles.
"""

from __future__ import annotations

import os
import sys

_REPO_ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
if _REPO_ROOT not in sys.path:
    sys.path.insert(0, _REPO_ROOT)

from cue import load_threads_dict
from cue.articles import thread_to_markdown


OUTPUT_DIR = os.path.join(_REPO_ROOT, "docs", "_gen", "blog")
BLOG_DIR = os.path.join(_REPO_ROOT, "docs", "blog")


def _committed_md_path(slug: str, category: str) -> str:
    """Path where a committed markdown file would live."""
    category_dir = f"{category}s" if category != "daily" else "daily"
    return os.path.join(BLOG_DIR, category_dir, f"{slug}.md")


def main():
    threads = load_threads_dict()
    generated = 0
    committed_exists = 0
    skipped = 0

    for tid, thread in threads.items():
        category = thread.get("category", "")
        if category not in ("opinion", "tutorial", "daily"):
            continue

        slug = thread.get("slug", tid)
        content = thread_to_markdown(tid, thread)
        if content is None:
            skipped += 1
            continue

        # Build the src_uri matching where MkDocs expects it
        category_dir = f"{category}s" if category != "daily" else "daily"
        dest = os.path.join(OUTPUT_DIR, category_dir, f"{slug}.md")

        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "w", encoding="utf-8") as f:
            f.write(content)

        # Track if there's a committed markdown file this replaces
        committed = _committed_md_path(slug, category)
        if os.path.isfile(committed):
            committed_exists += 1

        generated += 1

    print(f"Generated {generated} CUE article pages to {OUTPUT_DIR}"
          f"{' (' + str(committed_exists) + ' replace committed files)' if committed_exists else ''}"
          f"{' (' + str(skipped) + ' skipped — incomplete)' if skipped else ''}")
    return generated


if __name__ == "__main__":
    main()
