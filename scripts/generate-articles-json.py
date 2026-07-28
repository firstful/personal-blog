#!/usr/bin/env python3
"""
Generate docs/assets/articles.json from CUE thread data + markdown files.

CUE threads are the primary source. Markdown files in docs/blog/ that lack
a CUE counterpart (e.g. daily posts) are still scanned as a fallback.

Only the latest 50 articles (by date) are included.
"""
import json
import os
import re
import sys
import glob
from datetime import datetime

_REPO_ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
if _REPO_ROOT not in sys.path:
    sys.path.insert(0, _REPO_ROOT)
from cue import load_threads_dict
from cue.articles import thread_to_article_meta

DOCS_DIR = os.path.join(_REPO_ROOT, "docs")
BLOG_DIR = os.path.join(DOCS_DIR, "blog")
OUTPUT = os.path.join(DOCS_DIR, "assets", "articles.json")
MAX_ARTICLES = 50

# ── CUE-based articles (primary) ──────────────────────────────────────


def scan_cue_articles() -> dict[str, dict]:
    """Read CUE threads and return {slug: article_meta}."""
    result = {}
    try:
        threads = load_threads_dict()
    except Exception as e:
        print(f"Warning: could not load CUE threads: {e}", file=sys.stderr)
        return result

    for tid, thread in threads.items():
        meta = thread_to_article_meta(tid, thread)
        if meta:
            result[meta["slug"]] = meta
    return result


# ── Markdown-based articles (fallback for content without CUE) ─────────


def parse_frontmatter(filepath: str) -> dict | None:
    """Parse YAML-like frontmatter from a markdown file. Returns dict or None."""
    with open(filepath, encoding="utf-8") as f:
        content = f.read()

    m = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if not m:
        return None

    front = m.group(1)
    meta = {}

    lines = front.split("\n")
    current_key = None
    current_val = []

    for line in lines:
        if current_key and (line.startswith(" ") or line.startswith("\t") or line.strip() == ""):
            current_val.append(line.strip())
            continue
        if current_key:
            val = "\n".join(current_val).strip().strip("'\"")
            if val:
                meta[current_key] = val
        kv = re.match(r"^(\w[\w_]*):\s*(.*)", line)
        if kv:
            current_key = kv.group(1)
            current_val_str = kv.group(2).strip()
            current_val = [current_val_str] if current_val_str else []
        else:
            current_key = None
            current_val = []

    if current_key:
        val = "\n".join(current_val).strip().strip("'\"")
        if val:
            meta[current_key] = val

    raw_date = meta.get("date", "")
    parsed_date = None
    if raw_date:
        for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%Y/%m/%d"):
            try:
                parsed_date = datetime.strptime(str(raw_date)[:10], fmt[:10])
                break
            except ValueError:
                continue

    rel_path = os.path.relpath(filepath, BLOG_DIR)
    slug = rel_path.replace(".md", "").replace("\\", "/")

    tags_raw = meta.get("tags", "")
    tags = re.findall(r"[\w\-#]+", tags_raw) if isinstance(tags_raw, str) else []

    starter = ""
    posts = 0
    with open(filepath, encoding="utf-8") as f:
        raw = f.read()
    for line in raw.split("\n"):
        m_s = re.search(r"\{\{\s*forum_post\('(\w+)'", line)
        if m_s:
            posts += 1
            if not starter:
                starter = m_s.group(1)

    return {
        "title": meta.get("title", ""),
        "slug": slug,
        "date": parsed_date.isoformat() if parsed_date else "",
        "tags": tags,
        "description": meta.get("description", ""),
        "starter": starter,
        "posts": posts,
        "category": "opinion" if slug.startswith("opinions/") or "/opinions/" in slug
                    else "tutorial" if slug.startswith("tutorials/") or "/tutorials/" in slug
                    else "post",
    }


def scan_markdown_articles(cue_slugs: set[str]) -> list[dict]:
    """Scan docs/blog/ for markdown articles WITHOUT a CUE counterpart."""
    articles = []
    for filepath in glob.glob(os.path.join(BLOG_DIR, "**", "*.md"), recursive=True):
        if "/." in filepath or "/mobile/" in filepath or filepath.endswith("_nav.md"):
            continue
        meta = parse_frontmatter(filepath)
        if meta and meta["title"] and meta["slug"] not in cue_slugs:
            articles.append(meta)
    return articles


# ── Merge & output ─────────────────────────────────────────────────────


def main():
    cue_articles = scan_cue_articles()
    cue_slugs = set(cue_articles.keys())
    md_articles = scan_markdown_articles(cue_slugs)

    # CUE articles first, then markdown-only articles
    merged = list(cue_articles.values()) + md_articles

    # Sort by date descending, newest first (CUE-only fallback for missing dates)
    def sort_key(a: dict) -> str:
        return a.get("date") or "0000"
    merged.sort(key=sort_key, reverse=True)

    merged = merged[:MAX_ARTICLES]

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=2, ensure_ascii=False)

    print(f"Generated {OUTPUT} with {len(merged)} articles "
          f"({len(cue_articles)} from CUE + {len(md_articles)} markdown-only)")


if __name__ == "__main__":
    main()
