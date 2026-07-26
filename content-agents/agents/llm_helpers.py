"""LLM helper — consistent JSON extraction from any OpenAI-compatible API.

Handles:
- DeepSeek (reasoning models — reasoning tokens consume output budget)
- Regular chat models
- Models that wrap JSON in markdown code fences
- Truncated responses (finish_reason="length")
"""

import json
import re
from typing import Any


async def llm_json(
    client: Any,
    system: str,
    user: str,
    model: str,
    temperature: float = 0.3,
    max_tokens: int = 2000,
) -> dict:
    """Call an LLM and parse JSON from its response."""
    resp = await client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        temperature=temperature,
        max_tokens=max_tokens,
    )

    content = resp.choices[0].message.content.strip()
    finish_reason = resp.choices[0].finish_reason

    # Strip markdown code fences
    content = re.sub(r'^```(?:json)?\s*', '', content)
    content = re.sub(r'\s*```$', '', content)
    content = content.strip()

    # Strategy 1: Direct JSON parse
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        pass

    # Strategy 2: Find first { ... } block (may be nested)
    brace_depth = 0
    start = -1
    for i, ch in enumerate(content):
        if ch == '{':
            if start == -1:
                start = i
            brace_depth += 1
        elif ch == '}':
            brace_depth -= 1
            if brace_depth == 0 and start >= 0:
                try:
                    return json.loads(content[start:i+1])
                except json.JSONDecodeError:
                    # This block failed, but there might be another
                    start = -1
        elif ch == '\n' and start >= 0 and brace_depth == 0:
            # Reset on newlines when we're not in braces (false start)
            start = -1

    # Strategy 3: If truncated, try with added closing brace
    if finish_reason == "length" or content.rstrip().endswith(","):
        repaired = content.rstrip().rstrip(",").rstrip(" ")
        if not repaired.endswith("}"):
            repaired += "}"
        try:
            return json.loads(repaired)
        except json.JSONDecodeError:
            pass

    # Strategy 4: Extract any JSON object by trying substrings
    for start_idx in range(len(content)):
        if content[start_idx] == '{':
            for end_idx in range(len(content), start_idx, -1):
                try:
                    candidate = content[start_idx:end_idx]
                    # Try with closing brace added
                    if not candidate.endswith("}"):
                        candidate += "}"
                    return json.loads(candidate)
                except (json.JSONDecodeError, ValueError):
                    continue

    # Strategy 5: Find [ ... ] block (arrays)
    match = re.search(r'\[.*\]', content, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(0))
        except json.JSONDecodeError:
            pass

    raise ValueError(
        f"Could not parse JSON from response (finish_reason={finish_reason}): "
        f"{content[:500]}"
    )


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
    return resp.choices[0].message.content.strip()
