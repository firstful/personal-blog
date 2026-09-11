"""Orchestrator — LangGraph turn-based persona writing pipeline.

Real LangGraph StateGraph flow:

    score ──► select ──(initiator?)──► opening ──► respond ──(conditional)─┐
                │                                            ▲            │
                └─(nobody ≥ min relevance → END/discard)     └────────────┘

Improvements over the previous hand-rolled loop:
- Phase 1 relevance scoring fans out in parallel (asyncio.gather) instead of
  10+ sequential LLM calls.
- Responders see the actual conversation: last 3 posts verbatim plus brief
  summaries of the rest (the old code gave everyone only 120-char snippets,
  which is where the generic filler came from).
- Low-relevance personas get an explicit pass bias (score < 6 → default pass),
  fixing adjacent-expertise bots drifting off-topic.
- All LLM JSON handling is centralised in llm_helpers with retries.
"""

from __future__ import annotations

import asyncio
from typing import Optional, TypedDict

from langgraph.graph import END, StateGraph

from .llm_helpers import llm_json
from .models import (
    AppConfig,
    NewsCandidate,
    Persona,
    PersonaRegistry,
    ThreadPost,
    ThreadSession,
)

MAX_TOKENS_WRITE = 4000


def bio_short(persona: Persona) -> str:
    return (
        f"- Bio: {persona.bio}\n"
        f"- Expertise: {', '.join(persona.expertise)}\n"
        f"- Style: {persona.style}\n"
        f"- Quirks: {'; '.join(persona.quirks)}"
    )


def select_participants(
    scores: dict[str, int],
    registry: PersonaRegistry,
    topic_tags: list[str] | None = None,
    min_relevance: int = 4,
) -> tuple[Optional[str], list[str]]:
    """Pick the thread initiator and discussion pool from LLM relevance scores.

    - Initiator = highest relevance score; ties broken by topic fit, then
      diversity priority (under-published wins).
    - Pool = top half of the roster by score (rounded up, min 2).
    - Returns (None, []) if nobody reached min_relevance — 1-3 means
      "outside my expertise, pass", so a topic whose best score is ≤3 has no
      legitimate leader and the thread is discarded.
    """
    if not scores:
        return None, []
    taglist = topic_tags or []
    scored = sorted(
        scores.items(),
        key=lambda kv: (
            -kv[1],
            -registry.get(kv[0]).topic_fit(taglist),
            -registry.get(kv[0]).diversity_priority(),
        ),
    )
    if scored[0][1] < min_relevance:
        return None, []
    pool_size = max(2, (len(scored) + 1) // 2)
    pool = [name for name, _ in scored[:pool_size]]
    return scored[0][0], pool


# ── LangGraph state ────────────────────────────────────────────────────────


class ThreadState(TypedDict, total=False):
    topic: dict  # serialised NewsCandidate
    scores: dict  # persona name → relevance 0-10
    initiator: str
    pool: list[str]
    thread: list[dict]  # {persona_name, content, is_opening}
    next_idx: int
    passes: int
    discarded: bool


def _topic_from_state(state: ThreadState) -> NewsCandidate:
    return NewsCandidate(**state["topic"])


def _thread_context(thread: list[dict]) -> str:
    """Full text for the 3 most recent posts; one-line summaries for older."""
    parts = []
    old = thread[:-3]
    recent = thread[-3:]
    for p in old:
        label = "Opening post" if p["is_opening"] else "Response"
        snippet = p["content"][:120].replace("\n", " ").strip()
        parts.append(f"**{p['persona_name']}** — {label}: \"{snippet}...\"")
    if old and recent:
        parts.append("## Recent posts (verbatim)")
    for p in recent:
        label = "OPENING POST" if p["is_opening"] else "RESPONSE"
        parts.append(f"--- {label} by {p['persona_name']} ---\n{p['content']}")
    return "\n\n".join(parts)


def build_thread_graph(
    registry: PersonaRegistry,
    config: AppConfig,
    llm_client,
):
    model = config.llm.get("model", "auto")
    temp = config.llm.get("temperature", 0.5)
    max_posts = config.max_posts_per_thread
    min_posts = config.min_posts_per_thread

    # ── nodes ─────────────────────────────────────────────────────────────

    async def score_one(persona: Persona, topic: NewsCandidate) -> tuple[str, int]:
        system = f"You are {persona.name}, a blog writer. Output ONLY valid JSON. No explanations."
        user = (
            f"You are {persona.name}.\n\n{bio_short(persona)}\n\n"
            "A topic is up for discussion. Score how relevant this topic is to "
            "YOUR expertise on a scale of 1-10.\n\n"
            "- 10 = squarely in my expertise, I have strong opinions\n"
            "- 7-9 = in my lane, I can write a substantive opening\n"
            "- 4-6 = adjacent, I could add a perspective but shouldn't lead\n"
            "- 1-3 = outside my expertise, pass\n\n"
            "Be honest and calibrated. Only score high if the topic genuinely "
            "matches your expertise — inflating your score ruins the discussion.\n\n"
            f"## Topic\n**Title:** {topic.title}\n**Source:** {topic.source}\n"
            f"**Summary:** {topic.summary}\n\n"
            'Output: {"action": "claim"|"pass", "relevance": 1-10, "reason": "one line"}'
        )
        try:
            result = await llm_json(
                llm_client, system, user, model, temperature=temp, max_tokens=400
            )
        except Exception as e:  # noqa: BLE001 — one bad persona must not kill the run
            print(f"  [orchestrator] LLM error for {persona.name}: {str(e)[:200]}")
            return persona.name, 0
        try:
            rel = int(result.get("relevance", 0))
        except (TypeError, ValueError):
            rel = 0
        rel = max(0, min(rel, 10))
        print(
            f"  [orchestrator] {persona.name} relevance={rel} "
            f"({str(result.get('reason', ''))[:80]})"
        )
        return persona.name, rel

    async def score_node(state: ThreadState) -> dict:
        topic = _topic_from_state(state)
        order = [p.name for p in registry.ordered_by_diversity(topic.tags_guess)]
        print(f"  [orchestrator] Scoring relevance for {len(order)} personas (parallel)...")
        results = await asyncio.gather(
            *[score_one(registry.get(name), topic) for name in order],
            return_exceptions=True,
        )
        scores: dict[str, int] = {}
        for r in results:
            if isinstance(r, Exception):
                print(f"  [orchestrator] scoring task error: {r!r}")
                continue
            name, rel = r
            scores[name] = rel
        return {"scores": scores}

    async def select_node(state: ThreadState) -> dict:
        topic = _topic_from_state(state)
        initiator_name, pool = select_participants(
            state["scores"], registry, topic.tags_guess
        )
        if initiator_name is None:
            print("  [orchestrator] No persona scored high enough (min relevance 4) — discarding")
            return {"discarded": True}
        print(
            f"  [orchestrator] Initiator: {initiator_name} "
            f"(relevance={state['scores'][initiator_name]})"
        )
        print(f"  [orchestrator] Discussion pool ({len(pool)}): {', '.join(pool)}")
        start = pool.index(initiator_name)
        return {"initiator": initiator_name, "pool": pool, "next_idx": (start + 1) % len(pool)}

    async def opening_node(state: ThreadState) -> dict:
        topic = _topic_from_state(state)
        claimer = registry.get(state["initiator"])
        system = f"You are {claimer.name}, a blog writer. Output ONLY valid JSON. No explanations."
        user = (
            f"You are {claimer.name}.\n\n{bio_short(claimer)}\n\n"
            f"You scored the topic {state['scores'][claimer.name]}/10 relevant to "
            "your expertise, the highest of all personas. You are leading the "
            "discussion.\n\n"
            f"## Topic\n**Title:** {topic.title}\n**Source:** {topic.source}\n"
            f"**Summary:** {topic.summary}\n\n"
            "Write an opening post (3-5 paragraphs) that sets up the discussion "
            "in your voice. Reference the specific claims and details from the "
            "summary — do NOT write generic musings about the general subject.\n\n"
            'Output: {"headline": "...", "content": "..."}'
        )
        print(f"  [orchestrator] Asking {claimer.name} to write the opening post...")
        result = await llm_json(
            llm_client, system, user, model, temperature=temp, max_tokens=MAX_TOKENS_WRITE
        )
        content = result.get("content", "")
        headline = result.get("headline", topic.title)
        return {
            "thread": [
                {
                    "persona_name": claimer.name,
                    "content": f"## {headline}\n\n{content}",
                    "is_opening": True,
                }
            ],
            "passes": 0,
        }

    async def respond_node(state: ThreadState) -> dict:
        topic = _topic_from_state(state)
        pool = state["pool"]
        persona_name = pool[state["next_idx"] % len(pool)]
        persona = registry.get(persona_name)
        rel = state["scores"].get(persona_name, 0)
        already_spoken = sum(
            1 for p in state["thread"] if p["persona_name"] == persona_name
        )
        system = f"You are {persona_name}, a blog writer. Output ONLY valid JSON. No explanations."
        user = (
            f"You are {persona_name}.\n\n{bio_short(persona)}\n\n"
            f"A discussion you scored {rel}/10 relevant to your expertise is in "
            f"progress:\n\n**{topic.title}**\n{topic.summary}\n\n"
            f"## What's been said so far\n{_thread_context(state['thread'])}\n\n"
            "Respond ONLY if you can add a genuinely new perspective in your "
            "voice (2-4 paragraphs), grounded in the topic's specifics or in "
            "the recent posts. Pass if your relevance score is below 6, if you "
            "have nothing substantive to add, or if you would just repeat the "
            "conversation.\n\n"
            'Output: {"action": "respond"|"pass", "content": "..." (only if responding)}'
        )
        print(
            f"  [orchestrator] Asking {persona_name} (relevance {rel}, "
            f"{already_spoken} prior posts) to respond ({len(state['thread'])}/{max_posts})..."
        )
        try:
            result = await llm_json(
                llm_client, system, user, model, temperature=temp, max_tokens=MAX_TOKENS_WRITE
            )
        except Exception as e:
            print(f"  [orchestrator] LLM error for {persona_name}: {str(e)[:200]}")
            return {
                "passes": state["passes"] + 1,
                "next_idx": (state["next_idx"] + 1) % len(pool),
            }
        if result.get("action") == "respond":
            thread = state["thread"] + [
                {
                    "persona_name": persona_name,
                    "content": result.get("content", ""),
                    "is_opening": False,
                }
            ]
            print(f"  [orchestrator] {persona_name} responded ({len(thread)} posts)")
            return {"thread": thread, "passes": 0, "next_idx": (state["next_idx"] + 1) % len(pool)}
        print(f"  [orchestrator] {persona_name} passed")
        return {"passes": state["passes"] + 1, "next_idx": (state["next_idx"] + 1) % len(pool)}

    # ── edges ─────────────────────────────────────────────────────────────

    def route_after_select(state: ThreadState) -> str:
        return END if state.get("discarded") else "opening"

    def route_after_respond(state: ThreadState) -> str:
        if len(state.get("thread", [])) >= max_posts:
            return END
        if state.get("passes", 0) >= len(state.get("pool", []) or [1]):
            return END
        return "respond"

    graph = StateGraph(ThreadState)
    graph.add_node("score", score_node)
    graph.add_node("select", select_node)
    graph.add_node("opening", opening_node)
    graph.add_node("respond", respond_node)
    graph.set_entry_point("score")
    graph.add_edge("score", "select")
    graph.add_conditional_edges("select", route_after_select, {END: END, "opening": "opening"})
    graph.add_edge("opening", "respond")
    graph.add_conditional_edges("respond", route_after_respond, {END: END, "respond": "respond"})
    return graph.compile()


async def run_persona_cycle(
    topic: NewsCandidate,
    registry: PersonaRegistry,
    config: AppConfig,
    llm_client,
) -> Optional[ThreadSession]:
    """Run the full persona writing cycle for one topic via the LangGraph graph.

    Returns ThreadSession if successful, None if discarded.
    """
    app = build_thread_graph(registry, config, llm_client)
    init: ThreadState = {
        "topic": topic.model_dump(),
        "scores": {},
        "thread": [],
        "next_idx": 0,
        "passes": 0,
    }
    final = await app.ainvoke(init, {"recursion_limit": 80})
    thread = [ThreadPost(**p) for p in final.get("thread", [])]
    if final.get("discarded") or not thread:
        session = ThreadSession(topic=topic)
        session.status = "discarded"
        return None
    if len(thread) < config.min_posts_per_thread:
        print(
            f"  [orchestrator] Only {len(thread)} posts "
            f"(min {config.min_posts_per_thread}) — discarding"
        )
        session = ThreadSession(topic=topic)
        session.status = "discarded"
        return None
    session = ThreadSession(
        topic=topic,
        thread=thread,
        persona_order=final.get("pool", []),
        claimed_by=final.get("initiator"),
    )
    session.status = "completed"
    print(f"  [orchestrator] Thread complete: {len(thread)} posts")
    return session
