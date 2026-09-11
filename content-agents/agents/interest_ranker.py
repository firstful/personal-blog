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

Output: {{"ranked": [{{"index": 1, "reasoning": "..."}}], "discarded": [{{"index": 2, "reason": "..."}}]}}

Use the candidate's [index] number — do NOT retype titles.
"""

    model = config.llm.get("model", "auto")

    try:
        result = await llm_json(llm_client, system, user, model, temperature=0.3)
    except Exception as e:
        print(f"  [interest] LLM error: {e}")
        return candidates

    by_index = {i + 1: c for i, c in enumerate(candidates)}
    title_map = {c.title: c for c in candidates}
    ranked = []
    for entry in result.get("ranked", []):
        cand = None
        try:
            cand = by_index.get(int(entry.get("index", 0)))
        except (TypeError, ValueError):
            pass
        if cand is None:
            cand = title_map.get(entry.get("title", ""))
        if cand:
            ranked.append(cand)

    for entry in result.get("discarded", []):
        print(f"  [interest] DISCARDED: {entry.get('reason', '')[:100]}")

    # Append any candidates not mentioned in ranked or discarded
    seen = {c.title for c in ranked}
    for entry in result.get("discarded", []):
        try:
            c = by_index.get(int(entry.get("index", 0)))
            if c:
                seen.add(c.title)
        except (TypeError, ValueError):
            pass
    for c in candidates:
        if c.title not in seen:
            ranked.append(c)

    print(f"  [interest] {len(ranked)} kept, {len(result.get('discarded', []))} discarded")
    return ranked
