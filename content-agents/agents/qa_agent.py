"""QA Agent — evaluates threads, fact-checks via web search."""
from __future__ import annotations

from typing import Optional

from .llm_helpers import llm_json, llm_text
from .models import AppConfig, ThreadSession


def _make_qa_prompt(session: ThreadSession) -> tuple[str, str]:
    posts = ""
    for i, p in enumerate(session.thread, 1):
        label = "OPENING POST" if p.is_opening else "RESPONSE"
        posts += f"\n--- Post {i} ({label}) by {p.persona_name} ---\n{p.content}\n"

    system = "You are a strict quality control agent. Output ONLY valid JSON. No explanations, no markdown."
    user = f"""Evaluate whether this completed discussion thread is good enough to publish.

## Thread Topic
{session.topic.title}

## Source Summary
{session.topic.summary}

## Thread Posts
{posts}

## Rejection criteria
- Boring: no new insight, generic rehash
- Offensive: attacks, bad faith, hateful
- Nonsensical: doesn't cohere, contradicting without resolution
- Poorly-sourced: unsupported factual claims

## Fact-checking
If you suspect a claim is false, set fact_check_request to the claim text. I'll search and re-prompt.

Output: {{"verdict": "accept"|"reject", "confidence": 1-10, "reasoning": "...", "fact_check_request": "..."|null, "suggestions": "..."|null}}
"""
    return system, user


async def evaluate_thread(
    session: ThreadSession,
    config: AppConfig,
    llm_client,
) -> bool:
    model = config.llm.get("qa_model", config.llm.get("model", "deepseek-v4-flash"))
    max_attempts = 3
    fact_checks_used = 0
    max_fact_checks = 2

    for attempt in range(max_attempts):
        system, user = _make_qa_prompt(session)

        try:
            result = await llm_json(llm_client, system, user, model, temperature=0.3, max_tokens=1500)
        except Exception as e:
            print(f"  [qa] LLM error: {e}")
            return False

        fc = result.get("fact_check_request")
        if fc and fact_checks_used < max_fact_checks:
            fact_checks_used += 1
            print(f"  [qa] Fact-checking ({fact_checks_used}/{max_fact_checks}): {fc}")
            fc_result = await _web_fact_check(fc)
            session.topic.summary += f"\n[Fact-check for '{fc}']: {fc_result[:300]}"
            print(f"  [qa] Fact-check result: {fc_result[:200]}...")
            continue

        if result.get("verdict") == "accept":
            print(f"  [qa] ACCEPTED (confidence: {result.get('confidence', '?')}/10)")
            print(f"  [qa] Reasoning: {result.get('reasoning', '')}")
            return True
        else:
            print(f"  [qa] REJECTED (confidence: {result.get('confidence', '?')}/10)")
            print(f"  [qa] Reasoning: {result.get('reasoning', '')}")
            if result.get("suggestions"):
                print(f"  [qa] Suggestions: {result['suggestions']}")
            return False

    return False


async def _web_fact_check(claim: str) -> str:
    """Simple web search for fact-checking."""
    import httpx

    search_url = f"https://html.duckduckgo.com/html/?q={claim.replace(' ', '+')}"
    headers = {"User-Agent": "Mozilla/5.0 (compatible; BlogContentAgent/1.0; +https://blog.ffilt.us)"}

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(search_url, headers=headers)
            if resp.status_code == 200:
                import re
                snippets = re.findall(r'class="result__snippet">(.*?)</(?:a|span)', resp.text, re.DOTALL)
                if snippets:
                    results = "\n".join(f"- {re.sub(r'<[^>]+>', '', s).strip()}" for s in snippets[:5])
                    return f"Web results:\n{results}"
                return "No specific results found."
            return f"Search error (status {resp.status_code})"
    except Exception as e:
        return f"Search error: {e}"
