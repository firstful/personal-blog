"""LLM helper — consistent JSON extraction from any OpenAI-compatible API.

Handles:
- Reasoning models whose visible content may be None (reasoning tokens consume
  the completion budget) — retried with a larger budget instead of scraped.
- Models that wrap JSON in markdown code fences.
- Truncated responses (finish_reason="length") — retried, not "repaired".
- Transient failures — exponential-backoff retry (2 attempts).

Parsing policy: strict is the default. The old substring-scrape fallbacks
(grabbing any {...} out of chatty prose) produced mangled JSON that silently
corrupted scores and posts; a clean strict-retry loop is safer.
"""

import asyncio
import json
import re
from typing import Any


def _extract_json(content: str) -> dict | None:
    """Extract a JSON object from free text that should be just JSON."""
    content = content.strip()
    # Strip markdown code fences
    content = re.sub(r"^```(?:json)?\s*", "", content)
    content = re.sub(r"\s*```$", "", content).strip()
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        pass
    # Fenced/trailing prose: first balanced {...} that begins the content
    start = content.find("{")
    if start == 0:
        depth = 0
        for i, ch in enumerate(content):
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    try:
                        return json.loads(content[: i + 1])
                    except json.JSONDecodeError:
                        break
    return None


async def _call(client, system, user, model, temperature, max_tokens):
    resp = await client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        temperature=temperature,
        max_tokens=max_tokens,
    )
    choice = resp.choices[0]
    msg = choice.message
    content = (msg.content or "").strip() if msg.content is not None else ""
    return content, choice.finish_reason


async def llm_json(
    client: Any,
    system: str,
    user: str,
    model: str,
    temperature: float = 0.3,
    max_tokens: int = 2000,
    attempts: int = 3,
) -> dict:
    """Call an LLM and parse JSON from its response, with retries.

    - finish_reason "length" (usually reasoning tokens eating the budget):
      retry with 4x token budget.
    - Parse failure: retry with a pointed "ONLY raw JSON" reminder.
    - Transient errors: exponential backoff.
    """
    nudge = (
        "Your previous reply could not be parsed as JSON. "
        "Reply with ONLY a single valid JSON object, no prose, no markdown."
    )
    err: Exception | None = None
    for attempt in range(attempts):
        sys_now = system
        usr_now = user
        if attempt > 0:
            sys_now = system + "\n" + nudge
        budget = max_tokens * (4 if attempt >= 1 else 1)
        try:
            content, finish = await _call(
                client, sys_now, usr_now, model, temperature, budget
            )
        except Exception as e:  # noqa: BLE001 — transient gateway/API errors
            err = e
            await asyncio.sleep(2 ** attempt)
            continue
        if not content and finish == "length":
            # Reasoning tokens consumed the budget without emitting content.
            print(f"  [llm] empty content with finish_reason=length, retrying with {budget*4} tokens")
            try:
                content, finish = await _call(
                    client, sys_now, usr_now, model, temperature, budget * 4
                )
            except Exception as e:  # noqa: BLE001
                err = e
                continue
        if not content:
            err = ValueError(f"empty response (finish_reason={finish})")
            await asyncio.sleep(2 ** attempt)
            continue
        parsed = _extract_json(content)
        if isinstance(parsed, dict):
            return parsed
        err = ValueError(f"not JSON (finish_reason={finish}): {content[:200]}")
        # fall through to retry
    raise ValueError(f"llm_json failed after {attempts} attempts: {err}")


async def llm_text(
    client: Any,
    system: str,
    user: str,
    model: str,
    temperature: float = 0.7,
    max_tokens: int = 2000,
) -> str:
    """Call an LLM and return the text content."""
    resp = await client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        temperature=temperature,
        max_tokens=max_tokens,
    )
    return (resp.choices[0].message.content or "").strip()
