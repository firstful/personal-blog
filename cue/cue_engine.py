#!/usr/bin/env python3
"""
CUE content engine for Sutliff BBS.

Reads CUE data files into an in-memory store, validates with `cue vet`,
and provides data to Jinja templates and MkDocs hooks.
"""

import json
import logging
import os
import shutil
import subprocess
import sys
from datetime import date
from pathlib import Path
from typing import Any, Optional

log = logging.getLogger("cue_engine")


class ContentStore:
    """In-memory store for all CUE content data."""

    def __init__(self, cue_dir: str | Path):
        self.cue_dir = Path(cue_dir).resolve()
        self._users: dict[str, dict] = {}
        self._threads: dict[str, dict] = {}
        self._site: dict[str, Any] = {}
        self._loaded = False
        self._cue_bin = self._find_cue()

    @staticmethod
    def _find_cue() -> str:
        candidates = [
            os.environ.get("CUE_BIN", ""),
            "/usr/local/bin/cue",
            os.path.expanduser("~/go/bin/cue"),
            str(Path.home() / "go" / "bin" / "cue"),
        ]
        for c in candidates:
            if c and os.path.isfile(c):
                return c
        which = shutil.which("cue")
        if which:
            return which
        raise RuntimeError(
            "CUE binary not found. Install: go install cuelang.org/go/cmd/cue@latest"
        )

    def _cue_files(self) -> list[str]:
        """Get all .cue files recursively."""
        return sorted(str(f) for f in self.cue_dir.rglob("*.cue"))

    def validate(self) -> bool:
        """Run `cue vet` on all CUE files. Returns True if valid."""
        files = self._cue_files()
        if not files:
            log.warning("No .cue files found in %s", self.cue_dir)
            return True
        result = subprocess.run(
            [self._cue_bin, "vet", *files],
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode != 0:
            log.error("CUE validation failed:\n%s", result.stderr)
            return False
        log.info("CUE validation passed (%d files)", len(files))
        return True

    def load(self) -> bool:
        """Load all CUE data into memory via `cue export`."""
        if not self.validate():
            return False

        files = self._cue_files()
        result = subprocess.run(
            [self._cue_bin, "export", *files, "--out", "json"],
            capture_output=True, text=True, timeout=30,
        )
        if result.returncode != 0:
            log.error("CUE export failed:\n%s", result.stderr)
            return False

        try:
            data = json.loads(result.stdout)
        except json.JSONDecodeError as e:
            log.error("Failed to parse CUE export: %s", e)
            return False

        self._users = data.get("users", {})
        self._threads = data.get("threads", {})
        self._site = data.get("site", {})
        self._loaded = True
        log.info("CUE store loaded: %d users, %d threads", len(self._users), len(self._threads))
        return True

    @property
    def users(self) -> dict[str, dict]:
        return self._users

    @property
    def threads(self) -> dict[str, dict]:
        return self._threads

    def get_user(self, user_id: str) -> Optional[dict]:
        return self._users.get(user_id)

    def get_thread(self, slug: str) -> Optional[dict]:
        return self._threads.get(slug)

    def threads_by_category(self, category: str) -> list[dict]:
        return sorted(
            [t for t in self._threads.values() if t.get("category") == category],
            key=lambda t: t.get("date", ""),
            reverse=True,
        )

    def threads_by_tag(self, tag: str) -> list[dict]:
        return [t for t in self._threads.values() if tag in t.get("tags", [])]

    def recent_threads(self, n: int = 15) -> list[dict]:
        return sorted(
            self._threads.values(),
            key=lambda t: t.get("date", ""),
            reverse=True,
        )[:n]

    def today_threads(self) -> list[dict]:
        today_str = date.today().isoformat()
        return [
            t for t in self._threads.values()
            if t.get("date") == today_str and "daily" in t.get("tags", [])
        ]

    def user_post_count(self, user_id: str) -> int:
        count = 0
        for thread in self._threads.values():
            for post in thread.get("posts", []):
                if post.get("user") == user_id:
                    count += 1
        return count

    def format_post_body(self, body: str) -> str:
        """Convert raw CUE post body to MkDocs markdown.
        CUE multi-line strings escape quotes. This normalizes spacing."""
        import textwrap
        return textwrap.dedent(body).strip()


def main():
    import argparse
    parser = argparse.ArgumentParser(description="CUE content engine")
    parser.add_argument("--cue-dir", default=os.environ.get("CUE_DIR", "./cue"))
    parser.add_argument("action", nargs="?", choices=["validate", "export", "stats"],
                        default="validate")
    args = parser.parse_args()

    store = ContentStore(args.cue_dir)

    if args.action == "validate":
        ok = store.validate()
        print(f"{'✓' if ok else '✗'} CUE validation {'passed' if ok else 'failed'}")
        sys.exit(0 if ok else 1)

    elif args.action == "export":
        ok = store.load()
        if ok:
            print(json.dumps({
                "users": store.users,
                "threads": store.threads,
            }, indent=2))
        sys.exit(0 if ok else 1)

    elif args.action == "stats":
        ok = store.load()
        if ok:
            print(f"Users:   {len(store.users)}")
            print(f"Threads: {len(store.threads)}")
            for uid, user in sorted(store.users.items()):
                pc = store.user_post_count(uid)
                print(f"  {user.get('avatar', '')} {uid:<20} {pc:>4} posts")
            for cat in ["opinion", "tutorial", "reference", "daily"]:
                ct = store.threads_by_category(cat)
                if ct:
                    print(f"  {cat}: {len(ct)} threads")


if __name__ == "__main__":
    main()
