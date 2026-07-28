"""Search Agent — polls RSS feeds for recent news in configured categories."""

from __future__ import annotations

import random
import re
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import List, Optional

import feedparser
import requests
import yaml

from .models import AppConfig, NewsCandidate


# ── RSS Sources YAML ──────────────────────────────────────────────────────

def load_rss_sources(yaml_path: Optional[str] = None) -> List[dict]:
    """Load RSS sources from YAML file with scores."""
    if yaml_path is None:
        yaml_path = str(Path(__file__).parent.parent / "rss_sources.yaml")
    
    path = Path(yaml_path)
    if not path.exists():
        print(f"  [search] Warning: {yaml_path} not found, using empty sources")
        return []
    
    with open(path) as f:
        data = yaml.safe_load(f)
    
    return data.get("sources", [])


def save_rss_sources(sources: List[dict], yaml_path: Optional[str] = None):
    """Save RSS sources with updated scores back to YAML."""
    if yaml_path is None:
        yaml_path = str(Path(__file__).parent.parent / "rss_sources.yaml")
    
    path = Path(yaml_path)
    data = {"sources": sources}
    
    with open(path, "w") as f:
        yaml.dump(data, f, default_flow_style=False, sort_keys=False)


def increment_source_score(url: str, yaml_path: Optional[str] = None):
    """Increment the score for a source when its content is used."""
    sources = load_rss_sources(yaml_path)
    for source in sources:
        if source["url"] == url:
            source["score"] = source.get("score", 1) + 1
            print(f"  [search] Incremented score for {source.get('name', url)}: {source['score']}")
            break
    save_rss_sources(sources, yaml_path)


def weighted_random_sources(sources: List[dict], count: int) -> List[dict]:
    """Select sources randomly, weighted by score."""
    if not sources:
        return []
    
    scores = [max(s.get("score", 1), 1) for s in sources]
    total = sum(scores)
    weights = [s / total for s in scores]
    
    selected = []
    remaining = sources.copy()
    remaining_weights = weights.copy()
    
    for _ in range(min(count, len(remaining))):
        r = random.random()
        cumulative = 0
        for i, w in enumerate(remaining_weights):
            cumulative += w
            if r <= cumulative:
                selected.append(remaining[i])
                remaining.pop(i)
                remaining_weights.pop(i)
                # Renormalize weights
                if remaining_weights:
                    total_w = sum(remaining_weights)
                    remaining_weights = [w / total_w for w in remaining_weights]
                break
    
    return selected


# ── RSS Fetching ──────────────────────────────────────────────────────────

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
            "source_url": url,
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
    return "daily"


# ── Main Search ───────────────────────────────────────────────────────────

async def search(config: AppConfig) -> List[NewsCandidate]:
    """Run the Search Agent — poll all configured RSS feeds for recent articles.
    
    Uses weighted random selection from rss_sources.yaml.
    Tolerates failures if at least 50% of sources return successfully.
    """
    window = config.search_window_hours
    
    # Load sources from YAML
    yaml_path = str(Path(__file__).parent.parent / "rss_sources.yaml")
    sources = load_rss_sources(yaml_path)
    
    if not sources:
        # Fallback to config sources
        sources = [{"url": u, "name": u, "score": 1} for u in config.sources.get("rss", [])]
    
    # Select sources weighted by score (pick ~60% of sources)
    num_to_fetch = max(3, len(sources) // 2)
    selected = weighted_random_sources(sources, num_to_fetch)
    
    print(f"  [search] Selected {len(selected)} sources from {len(sources)} total")
    
    # Fetch from all selected sources
    all_entries = []
    successes = 0
    failures = 0
    
    for source in selected:
        url = source["url"]
        try:
            entries = fetch_rss(url, window_hours=window)
            all_entries.extend(entries)
            successes += 1
        except Exception as e:
            print(f"  [search] Error fetching {source.get('name', url)}: {e}")
            failures += 1
    
    # Check failure tolerance: if <50% succeeded, that's still okay
    total = successes + failures
    success_rate = successes / total if total > 0 else 0
    print(f"  [search] Fetch results: {successes}/{total} succeeded ({success_rate:.0%})")
    
    if success_rate < 0.5:
        print(f"  [search] Warning: Less than 50% of sources returned successfully")
    
    # Deduplicate by title
    seen: set[str] = set()
    unique = []
    for e in all_entries:
        key = e["title"].lower().strip()
        if key not in seen:
            seen.add(key)
            unique.append(e)
    
    # Randomize within the time window (shuffle before limiting)
    random.shuffle(unique)
    
    candidates = unique[:config.max_candidates]
    
    return [NewsCandidate(**c) for c in candidates]
