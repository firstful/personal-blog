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


def select_participants(
    scores: dict[str, int],
    registry: PersonaRegistry,
    topic_tags: list[str] | None = None,
    min_relevance: int = 4,
) -> tuple[Optional[str], list[str]]:
    """Pick the thread initiator and discussion pool from LLM relevance scores.

    - Initiator = persona with the highest relevance score. Ties are broken by
      programmatic topic fit, then diversity priority (under-published wins).
    - Pool = top half of the roster by score (rounded up, min 2), so only the
      most relevant personas converse.
    - Returns (None, []) if nobody reached min_relevance — the scoring rubric
      says 1-3 means "outside my expertise, pass", so a topic whose best score
      is 3 or below has no legitimate leader and the thread is discarded.

    The LLM provides the scores; this function only selects deterministically
    from them, so the outcome stays LLM-driven but reproducible.
    """
    if not scores:
        return None, []
    taglist = topic_tags or []
    scored = [(name, sc) for name, sc in scores.items()]
    scored.sort(
        key=lambda kv: (
            -kv[1],
            -registry.get(kv[0]).topic_fit(taglist),
            -registry.get(kv[0]).diversity_priority(),
        )
    )
    if scored[0][1] < min_relevance:
        return None, []
    pool_size = max(2, (len(scores) + 1) // 2)
    pool = [name for name, _ in scored[:pool_size]]
    return scored[0][0], pool


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

    # ── PHASE 1: Relevance scoring → initiator + discussion pool ──
    # Every persona scores the topic's relevance to its own expertise (1-10).
    # The LLM is the judge; we only pick the max as the thread initiator and
    # the top half of scorers as the possible discussion members.
    claimer: Optional[Persona] = None
    scores: dict[str, int] = {}
    scoring_order = [p.name for p in registry.ordered_by_diversity(topic.tags_guess)]
    print(f"  [orchestrator] Scoring relevance for {len(scoring_order)} personas...")

    for name in scoring_order:
        persona = registry.get(name)
        system = f"You are {persona.name}, a blog writer. Output ONLY valid JSON. No explanations."
        user = f"""You are {persona.name}.

{bio_short(persona)}

A topic is up for discussion. Score how relevant this topic is to YOUR expertise on a scale of 1-10.

- 10 = squarely in my expertise, I have strong opinions
- 7-9 = in my lane, I can write a substantive opening
- 4-6 = adjacent, I could add a perspective but shouldn't lead
- 1-3 = outside my expertise, pass

Be honest and calibrated. Only score high if the topic genuinely matches your expertise — inflating your score ruins the discussion.

## Topic
**Title:** {topic.title}
**Source:** {topic.source}
**Summary:** {topic.summary}

Output: {{"action": "claim"|"pass", "relevance": 1-10, "reason": "one line"}}
"""

        print(f"  [orchestrator] Asking {persona.name} to score relevance...")
        try:
            result = await llm_json(llm_client, system, user, model, temperature=temp, max_tokens=400)
        except Exception as e:
            print(f"  [orchestrator] LLM error for {persona.name}: {str(e)[:200]}")
            scores[name] = 0
            continue

        try:
            rel = int(result.get("relevance", 0))
        except (TypeError, ValueError):
            rel = 0
        rel = max(0, min(rel, 10))
        scores[name] = rel
        print(f"  [orchestrator] {persona.name} relevance={rel} ({result.get('reason', '')[:80]})")

    # Deterministic selection from LLM scores
    initiator_name, pool = select_participants(scores, registry, topic.tags_guess)

    if initiator_name is None:
        print(f"  [orchestrator] No persona scored high enough (min relevance 4) — discarding")
        session.status = "discarded"
        return None

    session.persona_order = pool
    claimer = registry.get(initiator_name)
    print(f"  [orchestrator] Initiator: {initiator_name} (relevance={scores[initiator_name]})")
    print(f"  [orchestrator] Discussion pool ({len(pool)}): {', '.join(pool)}")

    # Ask the initiator to write the opening post
    system = f"You are {claimer.name}, a blog writer. Output ONLY valid JSON. No explanations."
    user = f"""You are {claimer.name}.

{bio_short(claimer)}

You scored the topic {scores[claimer.name]}/10 relevant to your expertise, the highest of all personas. You are leading the discussion.

## Topic
**Title:** {topic.title}
**Source:** {topic.source}
**Summary:** {topic.summary}

Write an opening post (3-5 paragraphs) that sets up the discussion in your voice.

Output: {{"headline": "...", "content": "..."}}
"""

    print(f"  [orchestrator] Asking {claimer.name} to write the opening post...")
    try:
        result = await llm_json(llm_client, system, user, model, temperature=temp, max_tokens=4000)
    except Exception as e:
        print(f"  [orchestrator] LLM error for {claimer.name}: {str(e)[:200]}")
        session.status = "discarded"
        return None

    content = result.get("content", "")
    headline = result.get("headline", topic.title)
    post = ThreadPost(
        persona_name=claimer.name,
        content=f"## {headline}\n\n{content}",
        is_opening=True,
    )
    session.thread.append(post)
    session.claimed_by = claimer.name
    print(f"  [orchestrator] {claimer.name} opened the thread: {headline}")

    # ── PHASE 2: Response cycle (discussion pool only) ──
    claimer_idx = session.persona_order.index(claimer.name)
    current_idx = (claimer_idx + 1) % len(session.persona_order)
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
            current_idx = (current_idx + 1) % len(session.persona_order)
            turns_without_new_post += 1
            if turns_without_new_post >= len(session.persona_order):
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

        current_idx = (current_idx + 1) % len(session.persona_order)

        if turns_without_new_post >= len(session.persona_order):
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
