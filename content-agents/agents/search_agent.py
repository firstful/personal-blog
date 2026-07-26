"""Search Agent — polls RSS feeds for recent news in configured categories."""

from __future__ import annotations

import re
import time
from datetime import datetime, timedelta, timezone
from typing import List

import feedparser
import requests

from .models import AppConfig, NewsCandidate


def fetch_rss(url: str, window_hours: int = 6) -> List[dict]:
    """Fetch entries from an RSS feed within the time window.
    
    Uses requests (with timeout) to fetch the feed, then feedparser to parse,
    avoiding feedparser's own network layer which can hang.
    """
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
    parsed = feedparser.parse(resp.text)

    cutoff = datetime.now(timezone.utc) - timedelta(hours=window_hours)
    entries = []

    for entry in parsed.entries:
        pub_dt = None
        if hasattr(entry, "published_parsed") and entry.published_parsed:
            pub_dt = datetime.fromtimestamp(time.mktime(entry.published_parsed), tz=timezone.utc)
        elif hasattr(entry, "updated_parsed") and entry.updated_parsed:
            pub_dt = datetime.fromtimestamp(time.mktime(entry.updated_parsed), tz=timezone.utc)
        else:
            continue

        if pub_dt < cutoff:
            continue

        summary = ""
        if hasattr(entry, "summary"):
            summary = entry.summary
        elif hasattr(entry, "description"):
            summary = entry.description
        summary = re.sub(r"<[^>]+>", "", summary)[:500]

        tags = []
        if hasattr(entry, "tags"):
            tags = [t.get("term", "") for t in entry.tags if t.get("term")]
        category = guess_category(tags, entry.title, summary)

        entries.append({
            "title": entry.get("title", "Untitled"),
            "url": entry.get("link", ""),
            "source": parsed.feed.get("title", url),
            "summary": summary.strip(),
            "category": category,
            "timestamp": pub_dt.isoformat(),
            "tags_guess": tags[:5],
        })

    return entries


def guess_category(tags: list[str], title: str, summary: str) -> str:
    text = (title + " " + summary).lower()
    if any(w in text for w in ["how to", "guide", "tutorial", "walkthrough", "step-by-step", "setup"]):
        return "tutorial"
    if any(w in text for w in ["opinion", "why", "think", "should", "problem with", "unpopular"]):
        return "opinion"
    if any(w in text for w in ["spec", "standard", "rfc", "protocol", "api", "reference"]):
        return "reference"
    return "opinion"


async def search(config: AppConfig) -> List[NewsCandidate]:
    """Run the Search Agent — poll all configured RSS feeds for recent articles."""
    window = config.search_window_hours
    sources = config.sources.get("rss", [])
    all_entries = []

    for url in sources:
        try:
            entries = fetch_rss(url, window_hours=window)
            all_entries.extend(entries)
        except Exception as e:
            print(f"  [search] Error fetching {url}: {e}")

    seen: set[str] = set()
    unique = []
    for e in all_entries:
        key = e["title"].lower().strip()
        if key not in seen:
            seen.add(key)
            unique.append(e)

    unique.sort(key=lambda x: x["timestamp"], reverse=True)
    candidates = unique[:config.max_candidates]

    return [NewsCandidate(**c) for c in candidates]
