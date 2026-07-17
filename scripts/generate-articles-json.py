#!/usr/bin/env python3
"""
Generate docs/assets/articles.json from markdown frontmatter.
Scans docs/blog/ for articles, extracts metadata, sorts by date
descending, and outputs the latest 50 as JSON.
"""
import json
import os
import re
import glob
from datetime import datetime

DOCS_DIR = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs"))
BLOG_DIR = os.path.join(DOCS_DIR, "blog")
OUTPUT = os.path.join(DOCS_DIR, "assets", "articles.json")
MAX_ARTICLES = 50


def parse_frontmatter(filepath: str) -> dict | None:
    """Parse YAML-like frontmatter from a markdown file. Returns dict or None."""
    with open(filepath, encoding="utf-8") as f:
        content = f.read()

    # Match --- frontmatter ---
    m = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if not m:
        return None

    front = m.group(1)
    meta = {}

    # Simple YAML-like parser (handles flat fields, multiline strings)
    lines = front.split("\n")
    current_key = None
    current_val = []

    for line in lines:
        # Check for multiline continuation (indented)
        if current_key and (line.startswith(" ") or line.startswith("\t") or line.strip() == ""):
            current_val.append(line.strip())
            continue

        # Save previous multiline
        if current_key:
            val = "\n".join(current_val).strip().strip("'\"")
            if val:
                meta[current_key] = val

        # Check for new key
        kv = re.match(r"^(\w[\w_]*):\s*(.*)", line)
        if kv:
            current_key = kv.group(1)
            current_val_str = kv.group(2).strip()
            if current_val_str:
                current_val = [current_val_str]
            else:
                current_val = []
        else:
            current_key = None
            current_val = []

    if current_key:
        val = "\n".join(current_val).strip().strip("'\"")
        if val:
            meta[current_key] = val

    # Parse date
    raw_date = meta.get("date", "")
    parsed_date = None
    if raw_date:
        # Try common date formats
        for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%Y/%m/%d"):
            try:
                parsed_date = datetime.strptime(str(raw_date)[:10], fmt[:10])
                break
            except ValueError:
                continue

    # Extract slug from file path
    rel_path = os.path.relpath(filepath, BLOG_DIR)
    slug = rel_path.replace(".md", "").replace("\\", "/")

    # Tags
    tags_raw = meta.get("tags", "")
    if isinstance(tags_raw, str):
        # Parse YAML list format: [tag1, tag2]
        tags = re.findall(r"[\w\-#]+", tags_raw)
    else:
        tags = []

    return {
        "title": meta.get("title", ""),
        "slug": slug,
        "date": parsed_date.isoformat() if parsed_date else "",
        "tags": tags,
        "description": meta.get("description", ""),
        "category": "opinion" if slug.startswith("opinions/") or "/opinions/" in slug else "tutorial" if slug.startswith("tutorials/") or "/tutorials/" in slug else "post",
    }


def main():
    articles = []
    for filepath in glob.glob(os.path.join(BLOG_DIR, "**", "*.md"), recursive=True):
        # Skip hidden files, mobile dir, _nav.md
        if "/." in filepath or "/mobile/" in filepath or filepath.endswith("_nav.md"):
            continue
        meta = parse_frontmatter(filepath)
        if meta and meta["title"]:
            articles.append(meta)

    # Sort by date descending, newest first
    articles.sort(key=lambda a: a["date"], reverse=True)

    # Trim to max
    articles = articles[:MAX_ARTICLES]

    # Write output
    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, "w", encoding="utf-8") as f:
        json.dump(articles, f, indent=2, ensure_ascii=False)

    print(f"Generated {OUTPUT} with {len(articles)} articles")


if __name__ == "__main__":
    main()
