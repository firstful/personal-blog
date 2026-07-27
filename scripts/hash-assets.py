#!/usr/bin/env python3
"""
Post-build asset hashing for cache busting.

After mkdocs build, renames theme.css and main.js with content hashes
and updates all HTML references in the site/ output directory.

Usage: python3 scripts/hash-assets.py [site_dir]
Default site_dir: site/
"""

import hashlib
import os
import re
import sys

SITE_DIR = sys.argv[1] if len(sys.argv) > 1 else 'site'

ASSETS = [
    ('assets/theme.css',),
    ('assets/js/main.js',),
    ('assets/articles.json',),
]


def hash_file(path: str) -> str:
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()[:12]


def rename_asset(rel_path: str) -> str | None:
    full = os.path.join(SITE_DIR, rel_path)
    if not os.path.exists(full):
        print(f"  [SKIP] {rel_path} — not found")
        return None

    h = hash_file(full)
    base, ext = os.path.splitext(rel_path)
    new_rel = f"{base}.{h}{ext}"

    # Handle nested dirs: assets/js/main.js -> assets/js/main.{hash}.js
    new_full = os.path.join(SITE_DIR, new_rel)
    os.rename(full, new_full)
    print(f"  {rel_path} → {new_rel}")
    return new_rel


def update_html_references(old_rel: str, new_rel: str):
    """Replace all references to the old asset path in site/*.html and site/**/*.js

    Handles both relative references (assets/theme.css) and
    absolute references (/assets/theme.css) found in HTML/JS.
    """
    count = 0
    variants = set()
    variants.add(old_rel)     # e.g. assets/theme.css
    variants.add('/' + old_rel)  # e.g. /assets/theme.css
    variants.add(old_rel.replace('assets/', './assets/', 1))  # e.g. ./assets/theme.css

    for root, _dirs, files in os.walk(SITE_DIR):
        for fn in files:
            if not (fn.endswith('.html') or fn.endswith('.js')):
                continue
            fp = os.path.join(root, fn)
            with open(fp, 'r') as f:
                content = f.read()
            modified = False
            for variant in variants:
                new_variant = variant.replace(old_rel, new_rel, 1)
                if variant in content:
                    content = content.replace(variant, new_variant)
                    modified = True
            if modified:
                with open(fp, 'w') as f:
                    f.write(content)
                count += 1
                rel = os.path.relpath(fp, SITE_DIR)
                print(f"  Updated {rel}")
    return count


def main():
    abs_site = os.path.join(os.getcwd(), SITE_DIR) if not os.path.isabs(SITE_DIR) else SITE_DIR
    if not os.path.isdir(abs_site):
        print(f"Error: site directory '{abs_site}' not found. Run mkdocs build first.")
        sys.exit(1)

    print(f"Hashing assets in {abs_site} …")

    for asset_paths in ASSETS:
        old_path = asset_paths[0]
        new_path = rename_asset(old_path)
        if new_path:
            # Update HTML references — the function handles both
            # relative (assets/theme.css) and absolute (/assets/theme.css)
            n = update_html_references(old_path, new_path)
            print(f"  → Updated {n} HTML files")

    print("Done.")


if __name__ == '__main__':
    main()
