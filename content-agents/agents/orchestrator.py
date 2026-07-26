"""Orchestrator — LangGraph-style turn-based persona writing pipeline.

Note: This uses function calls, not the full LangGraph runtime, to keep
dependencies minimal and make each piece easy to modify independently.
"""

from __future__ import annotations

from typing import Optional

from .llm_helpers import llm_json
from .models import (
    AppConfig,
    NewsCandidate,
    Persona,
    PersonaRegistry,
    ThreadPost,
    ThreadSession,
)


def bio_short(persona: Persona) -> str:
    return f"""- Bio: {persona.bio}
- Expertise: {', '.join(persona.expertise)}
- Style: {persona.style}
- Quirks: {'; '.join(persona.quirks)}"""


async def run_persona_cycle(
    topic: NewsCandidate,
    registry: PersonaRegistry,
    config: AppConfig,
    llm_client,
) -> Optional[ThreadSession]:
    """Run the full persona writing cycle for one topic.
    Returns ThreadSession if successful, None if discarded.
    """
    session = ThreadSession(topic=topic)
    model = config.llm.get("model", "deepseek-v4-flash")
    temp = config.llm.get("temperature", 0.7)

    # Order personas by inverse content count (diversity priority)
    ordered = registry.ordered_by_diversity(topic.tags_guess)
    session.persona_order = [p.name for p in ordered]
    print(f"  [orchestrator] Persona order: {', '.join(session.persona_order)}")

    # ── PHASE 1: Claim ──
    claimer: Optional[Persona] = None
    for persona in ordered:
        system = f"You are {persona.name}, a blog writer. Output ONLY valid JSON. No explanations."
        user = f"""You are {persona.name}.

{bio_short(persona)}

A topic is up for discussion. Would you like to claim it?

## Topic
**Title:** {topic.title}
**Source:** {topic.source}
**Summary:** {topic.summary}

If you claim it, write an opening post (3-5 paragraphs) that sets up the discussion in your voice.
If not interested, pass.

Output: {{"action": "claim"|"pass", "headline": "..."(if claiming), "content": "..."(if claiming)}}
"""

        print(f"  [orchestrator] Asking {persona.name} to claim...")
        try:
            result = await llm_json(llm_client, system, user, model, temperature=temp, max_tokens=4000)
        except Exception as e:
            print(f"  [orchestrator] LLM error for {persona.name}: {str(e)[:200]}")
            continue

        if result.get("action") == "claim":
            content = result.get("content", "")
            headline = result.get("headline", topic.title)
            post = ThreadPost(
                persona_name=persona.name,
                content=f"## {headline}\n\n{content}",
                is_opening=True,
            )
            session.thread.append(post)
            session.claimed_by = persona.name
            claimer = persona
            print(f"  [orchestrator] {persona.name} claimed: {headline}")
            break
        else:
            print(f"  [orchestrator] {persona.name} passed on claiming")

    if claimer is None:
        print(f"  [orchestrator] No one claimed this topic")
        session.status = "discarded"
        return None

    # ── PHASE 2: Response cycle ──
    claimer_idx = session.persona_order.index(claimer.name)
    current_idx = (claimer_idx + 1) % len(ordered)
    turns_without_new_post = 0

    while len(session.thread) < config.max_posts_per_thread:
        persona_name = session.persona_order[current_idx]
        persona = registry.get(persona_name)

        system = f"You are {persona_name}, a blog writer. Output ONLY valid JSON. No explanations."
        user = f"""You are {persona_name}.

{bio_short(persona)}

A discussion is in progress: **{topic.title}**
{topic.summary}

## What's been said so far
{session.post_summaries()}

Would you like to respond? If yes, write 2-4 paragraphs in your voice adding new perspective.
If you have nothing to add, pass.

Output: {{"action": "respond"|"pass", "content": "..."(if responding)}}
"""

        print(f"  [orchestrator] Asking {persona_name} to respond ({len(session.thread)}/{config.max_posts_per_thread})...")
        try:
            result = await llm_json(llm_client, system, user, model, temperature=temp, max_tokens=4000)
        except Exception as e:
            print(f"  [orchestrator] LLM error for {persona_name}: {str(e)[:200]}")
            current_idx = (current_idx + 1) % len(ordered)
            turns_without_new_post += 1
            if turns_without_new_post >= len(ordered):
                break
            continue

        if result.get("action") == "respond":
            content = result.get("content", "")
            post = ThreadPost(persona_name=persona_name, content=content)
            session.thread.append(post)
            turns_without_new_post = 0
            print(f"  [orchestrator] {persona_name} responded ({len(session.thread)} posts)")
        else:
            turns_without_new_post += 1
            print(f"  [orchestrator] {persona_name} passed")

        current_idx = (current_idx + 1) % len(ordered)

        if turns_without_new_post >= len(ordered):
            print(f"  [orchestrator] All personas passed consecutively")
            break

    # ── PHASE 3: Min posts check ──
    if len(session.thread) < config.min_posts_per_thread:
        print(f"  [orchestrator] Only {len(session.thread)} posts (min {config.min_posts_per_thread}) — discarding")
        session.status = "discarded"
        return None

    session.status = "completed"
    print(f"  [orchestrator] Thread complete: {len(session.thread)} posts")
    return session
