"""Diversity Agent — filters candidates against already-published articles
       AND any articles produced in the current session.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import List, Optional

import yaml

from .llm_helpers import llm_json
from .models import AppConfig, NewsCandidate


def list_published_articles(config: AppConfig) -> List[dict]:
    """List all published articles from CUE source of truth."""
    import sys
    _repo = str(config.blog_path.resolve())
    if _repo not in sys.path:
        sys.path.insert(0, _repo)
    from cue import load_threads_dict
    from cue.articles import thread_to_article_meta

    articles = []
    try:
        threads = load_threads_dict()
    except Exception as e:
        print(f"  [diversity] Warning: could not load CUE threads: {e}")
        return articles

    for tid, thread in threads.items():
        meta = thread_to_article_meta(tid, thread)
        if meta:
            articles.append({
                "path": f"cue/opinions/{tid}.cue",
                "title": meta["title"],
                "tags": meta["tags"],
                "description": meta["description"],
            })

    return articles


def _parse_frontmatter(path: Path) -> dict:
    content = path.read_text()
    match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return {}
    try:
        return yaml.safe_load(match.group(1)) or {}
    except Exception:
        return {}


def _read_article_content(path: str | Path) -> str:
    return Path(path).read_text()


def _make_diversity_prompt(
    candidate: NewsCandidate,
    published: List[dict],
    session_titles: Optional[List[str]] = None,
) -> tuple[str, str]:
    """Build system and user prompts for diversity evaluation."""
    published_list = "\n".join(
        f"- {a['title']} (tags: {', '.join(a.get('tags', []))})"
        for a in published[-30:]
    )

    session_section = ""
    if session_titles:
        items = [f"- {t} (produced earlier this session)" for t in session_titles]
        session_section = "\n".join(items)

    system = "You are a content diversity evaluator. Output ONLY valid JSON. No explanations, no markdown."

    session_block = ""
    if session_section:
        session_block = f"## Already Produced This Session\n{session_section}"

    user = f"""Evaluate whether this candidate news story is sufficiently different from already-published articles (and session articles) to discuss.

## Candidate Story
**Title:** {candidate.title}
**Source:** {candidate.source}
**Category:** {candidate.category}
**Summary:** {candidate.summary}
**Tags:** {', '.join(candidate.tags_guess)}

## Already Published Articles (last 30)
{published_list}
{session_block}

## Criteria
1. Direct rehash -> strike
2. Same topic, new angle -> keep (describe the new angle)
3. New topic -> keep

If uncertain, set ingest_request to the exact article title to read.

Output: {{"verdict": "keep"|"strike", "confidence": 1-10, "reasoning": "...", "new_angle": "..."|null, "ingest_request": "..."|null}}
"""

    return system, user


async def filter_candidates(
    candidates: List[NewsCandidate],
    config: AppConfig,
    llm_client,
    session_topics: Optional[List[NewsCandidate]] = None,
) -> List[NewsCandidate]:
    published = list_published_articles(config)
    session_titles = [t.title for t in (session_topics or [])]

    if not published and not session_titles:
        return candidates

    model = config.llm.get("model", "deepseek-v4-flash")
    survivors = []

    for candidate in candidates:
        system, user = _make_diversity_prompt(candidate, published, session_titles)

        try:
            result = await llm_json(llm_client, system, user, model, temperature=0.3)
        except Exception as e:
            print(f"  [diversity] LLM error for '{candidate.title}': {e}")
            survivors.append(candidate)
            continue

        # Handle ingest request
        if result.get("ingest_request"):
            for a in published:
                if a["title"].lower().strip() == result["ingest_request"].lower().strip():
                    content = _read_article_content(a["path"])
                    user2 = user + f"\n\nFull content of '{a['title']}':\n{content[:3000]}"
                    try:
                        result = await llm_json(llm_client, system, user2, model, temperature=0.3)
                    except Exception:
                        pass
                    break

        if result.get("verdict") == "keep":
            survivors.append(candidate)
            print(f"  [diversity] KEPT: {candidate.title} — {result.get('new_angle', '')}")
        else:
            print(f"  [diversity] STRUCK: {candidate.title} — {result.get('reasoning', '')}")

    return survivors
