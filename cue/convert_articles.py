#!/usr/bin/env python3
"""
Convert existing MkDocs blog articles to CUE format.

Reads all .md files from docs/blog/ and generates CUE thread data.
Handles both legacy single-author articles and forum_post-style threads.
"""

import os
import re
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from cue_engine import ContentStore


def parse_frontmatter(content: str) -> dict:
    """Extract YAML frontmatter from markdown content."""
    match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return {}
    import yaml
    try:
        return yaml.safe_load(match.group(1)) or {}
    except Exception:
        return {}


def parse_forum_posts(body: str) -> list[dict]:
    """Extract forum_post macros from markdown body."""
    posts = []
    pattern = r"\{\{\s*forum_post\s*\(\s*'([^']+)'\s*,\s*'([^']+)'\s*,\s*'''(.*?)'''\s*(?:,\s*sig=(True|False))?\s*(?:,\s*quote='([^']*)')?\s*\)\s*\}\}"
    for match in re.finditer(pattern, body, re.DOTALL):
        posts.append({
            "user": match.group(1),
            "timestamp": match.group(2),
            "body": match.group(3).strip(),
            "quote": match.group(5) or None,
        })
    return posts


def slug_from_path(path: Path, base_dir: Path) -> str:
    """Generate a thread slug from file path."""
    rel = path.relative_to(base_dir)
    stem = rel.with_suffix("")
    return str(stem).replace("/", "-").lower()


def guess_starter(posts: list[dict]) -> str:
    """Guess the thread starter from posts."""
    if posts:
        return posts[0].get("user", "ffiltus")
    return "ffiltus"


def article_to_cue(path: Path, base_dir: Path) -> str | None:
    """Convert a markdown article to a CUE thread definition."""
    content = path.read_text()
    fm = parse_frontmatter(content)

    title = fm.get("title", path.stem.replace("-", " ").title())
    date = fm.get("date", "")
    if hasattr(date, "isoformat"):
        date = date.isoformat()
    tags = fm.get("tags", [])
    if isinstance(tags, str):
        tags = [tags]

    # Determine category from path
    rel_path = str(path.relative_to(base_dir))
    if "/opinions/" in rel_path:
        category = "opinion"
    elif "/tutorials/" in rel_path:
        category = "tutorial"
    elif "/daily/" in rel_path:
        category = "daily"
    else:
        category = "opinion"

    # Remove frontmatter
    body = re.sub(r"^---\s*\n.*?\n---\s*\n?", "", content, flags=re.DOTALL).strip()

    # Check for forum_post macros
    posts = parse_forum_posts(body)

    slug = path.stem.lower()
    description = fm.get("description", "")

    if posts:
        # Forum-style article
        starter = guess_starter(posts)
        body_content = "\n".join(
            f'        {{\n'
            f'            user: "{p["user"]}"\n'
            f'            timestamp: "{p["timestamp"]}"\n'
            f'            body: """\n'
            f'{_indent(_escape_body(p["body"]), 12).rstrip()}\n'
            f'            """\n'
            f'        }}'
            for p in posts
        )
    else:
        # Legacy single-author article
        starter = "ffiltus"
        body_content = (
            f'        {{\n'
            f'            user: "ffiltus"\n'
            f'            timestamp: "{date} 09:00"\n'
            f'            body: """\n'
            f'{_indent(_escape_body(body), 12).rstrip()}\n'
            f'            """\n'
            f'        }}'
        )

    desc_cue = ""
    if description:
        desc_cue = f'\n    description: """\n        {description.strip()}\n        """'

    return f"""package sutliff

threads: "{slug}": {{
    id:       "{slug}"
    title:    "{_escape_cue(title)}"
    date:     "{date}"
    category: "{category}"
    tags:     [{', '.join(f'"{t}"' for t in tags)}]
    starter:  "{starter}"{desc_cue}

    posts: [{body_content}
    ]
}}
"""


def _escape_cue(s: str) -> str:
    """Escape special characters for CUE title strings."""
    return s.replace("\\", "\\\\").replace('"', '\\"')

def _escape_body(body: str) -> str:
    """Escape body text for CUE multi-line strings."""
    return body.replace("\\", "\\\\")


def _indent(text: str, spaces: int) -> str:
    """Indent each line of text."""
    prefix = " " * spaces
    return "\n".join(prefix + line if line.strip() else line for line in text.split("\n"))


def convert_all(blog_dir: str, output_dir: str) -> int:
    """Convert all articles from blog_dir to CUE files in output_dir."""
    blog_path = Path(blog_dir)
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    converted = 0
    for md_file in sorted(blog_path.rglob("*.md")):
        if "/daily/" in str(md_file):
            continue  # skip daily articles (generated separately)
        try:
            cue = article_to_cue(md_file, blog_path)
            if cue:
                slug = md_file.stem.lower()
                cue_file = out_path / f"{slug}.cue"
                cue_file.write_text(cue)
                converted += 1
                print(f"  ✓ {cue_file.name}")
        except Exception as e:
            print(f"  ✗ {md_file.name}: {e}")

    return converted


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Convert blog articles to CUE")
    parser.add_argument("--blog-dir", help="Blog articles directory",
                        default=os.environ.get("BLOG_DIR"), required=True)
    parser.add_argument("--output", "-o", help="Output CUE directory", default="threads")
    args = parser.parse_args()

    print(f"Converting articles from {args.blog_dir}...")
    count = convert_all(args.blog_dir, args.output)
    print(f"\nConverted {count} articles to CUE format.")


if __name__ == "__main__":
    main()
