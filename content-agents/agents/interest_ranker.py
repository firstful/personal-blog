"""Interest Ranker — ranks remaining candidates by interest/importance."""
from __future__ import annotations

from typing import List

from .llm_helpers import llm_json
from .models import AppConfig, NewsCandidate


async def rank_candidates(
    candidates: List[NewsCandidate],
    config: AppConfig,
    llm_client,
) -> List[NewsCandidate]:
    if not candidates:
        return []

    articles = ""
    for i, c in enumerate(candidates, 1):
        articles += f"\n[{i}] {c.title}\n    Source: {c.source}\n    Summary: {c.summary[:200]}\n    Category: {c.category}\n"

    system = "You are an interest ranking agent. Output ONLY valid JSON. No explanations, no markdown."
    user = f"""Rank these candidate news articles by interest for a developer/ops audience. Discard boring/tasteless/unsourced ones.

## Candidates
{articles}

Output: {{"ranked": [{{"rank": 1, "title": "...", "reasoning": "..."}}], "discarded": [{{"title": "...", "reason": "..."}}]}}
"""

    model = config.llm.get("model", "deepseek-v4-flash")

    try:
        result = await llm_json(llm_client, system, user, model, temperature=0.3)
    except Exception as e:
        print(f"  [interest] LLM error: {e}")
        return candidates

    title_map = {c.title: c for c in candidates}
    ranked = []
    for entry in result.get("ranked", []):
        title = entry.get("title", "")
        if title in title_map:
            ranked.append(title_map[title])

    for entry in result.get("discarded", []):
        print(f"  [interest] DISCARDED: {entry.get('title', '?')} — {entry.get('reason', '')}")

    # Append any candidates not mentioned in ranked or discarded
    seen = {r.title for r in ranked}
    seen.update(d.get("title", "") for d in result.get("discarded", []))
    for c in candidates:
        if c.title not in seen:
            ranked.append(c)

    print(f"  [interest] {len(ranked)} kept, {len(result.get('discarded', []))} discarded")
    return ranked
