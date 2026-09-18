#!/usr/bin/env python3
"""
Content Agents — Automated multi-agent article pipeline for Sutliff's blog.

Usage:
    python3 run.py generate            # Full pipeline (discover → write)
    python3 run.py discover            # Dry run: search + filter only
    python3 run.py generate "Topic"    # Manual topic, skip discovery
    python3 run.py personas            # List personas with stats
    python3 run.py rankings            # Show persona rankings

Env vars (all optional with sensible defaults):
    BLOG_BASE_DIR         — Path to blog repo root
    LLM_API_KEY           — API key for LLM provider
    LLM_BASE_URL          — API base URL (default: https://api.deepseek.com/v1)
    LLM_MODEL             — Model name (default: deepseek-chat)
    LLM_QA_MODEL          — Model for QA (default: same as LLM_MODEL)
    LLM_TEMPERATURE       — Generation temperature (default: 0.7)
    MAX_POSTS_PER_THREAD  — Max posts per thread (default: 8)
    MIN_POSTS_PER_THREAD  — Min posts per thread (default: 3)
    NUM_THREADS           — Number of threads per run (default: 3)
    SEARCH_WINDOW_HOURS   — Hours back for RSS search (default: 6)
    MAX_CANDIDATES        — Max candidates per search (default: 10)
    RSS_SOURCES           — Comma-separated RSS feed URLs
    OUTPUT_DIR            — Output directory relative to BLOG_BASE_DIR
"""

from __future__ import annotations

import asyncio
import json
import os
import sys
from pathlib import Path
from typing import List, Optional

sys.path.insert(0, str(Path(__file__).parent))

from agents.models import AppConfig, NewsCandidate, PersonaRegistry, ThreadSession
from agents.formatter import write_article


# ── Env loading ──────────────────────────────────────────────────────────

def load_env():
    """Load .env files in priority order."""
    # Load from standard locations
    env_paths = [
        Path.cwd() / ".env",
        Path.home() / ".hermes" / ".env",
        Path.home() / ".env",
        Path(__file__).parent / ".env",
    ]
    for p in env_paths:
        if p.exists():
            with open(p) as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith("#") or "=" not in line:
                        continue
                    key, _, val = line.partition("=")
                    key = key.strip()
                    val = val.strip().strip("'\"")
                    if key not in os.environ:
                        os.environ[key] = val


# ── LLM Client ───────────────────────────────────────────────────────────

def get_llm_client(config: AppConfig):
    """Create an OpenAI-compatible async LLM client."""
    from openai import AsyncOpenAI

    # Check multiple possible env var names for the API key
    api_key_env = config.llm.get("api_key_env", "LLM_API_KEY")
    api_key = os.environ.get(api_key_env)

    # Fallback: DEEPSEEK_API_KEY, OPENAI_API_KEY
    if not api_key:
        for fallback in ["DEEPSEEK_API_KEY", "OPENAI_API_KEY", "OPENCODE_GO_API_KEY"]:
            api_key = os.environ.get(fallback)
            if api_key:
                print(f"  [client] Using API key from {fallback}")
                break

    if not api_key:
        print("Error: No API key found. Set LLM_API_KEY, DEEPSEEK_API_KEY, or OPENAI_API_KEY")
        sys.exit(1)

    base_url = config.llm.get("base_url", "https://api.deepseek.com/v1")

    return AsyncOpenAI(
        api_key=api_key,
        base_url=base_url,
    )


def load_config(config_path: Optional[str] = None) -> AppConfig:
    """Load config from file, with override path."""
    if config_path:
        return AppConfig.from_yaml(config_path)

    candidates = [
        Path.cwd() / "config.yaml",
        Path(__file__).parent / "config.yaml",
        Path(__file__).parent.parent / "config.yaml",
        Path.home() / "content-agents" / "config.yaml",
    ]
    for p in candidates:
        if p.exists():
            print(f"  [config] Loaded from {p}")
            return AppConfig.from_yaml(p)

    print("Warning: No config.yaml found. Using defaults + env vars.")
    return AppConfig()


# ── Main pipeline ────────────────────────────────────────────────────────

async def run_discovery(
    config: AppConfig,
    llm_client,
    session_topics: Optional[List[NewsCandidate]] = None,
) -> List[NewsCandidate]:
    """Run search → diversity → interest ranking.
    
    Args:
        session_topics: Topics already turned into articles this session,
                        passed to diversity agent for inclusion.
    
    Returns: ranked candidates.
    """
    print("\n=== Stage 1: Search Agent ===")
    from agents.search_agent import search
    candidates = await search(config)

    if not candidates:
        print("  No candidates found in the last 6 hours.")
        return []
    print(f"  Found {len(candidates)} candidates")

    print("\n=== Stage 2: Diversity Agent ===")
    from agents.diversity_agent import filter_candidates
    survivors = await filter_candidates(candidates, config, llm_client, session_topics)
    print(f"  {len(survivors)} survivors after diversity filter")

    if not survivors:
        print("  No candidates survived diversity filtering.")
        return []

    print("\n=== Stage 3: Interest Ranker ===")
    from agents.interest_ranker import rank_candidates
    ranked = await rank_candidates(survivors, config, llm_client)
    print(f"  {len(ranked)} candidates ranked")

    return ranked


async def run_single_thread(
    topic: NewsCandidate,
    config: AppConfig,
    registry: PersonaRegistry,
    llm_client,
) -> Optional[ThreadSession]:
    """Run the writing pipeline for one topic. Returns session or None."""
    print(f"\n{'='*60}")
    print(f"Thread: {topic.title}")
    print(f"{'='*60}")

    print("\n=== Stage 4: Writing Pipeline ===")
    from agents.orchestrator import run_persona_cycle
    session = await run_persona_cycle(topic, registry, config, llm_client)

    if session is None or session.status == "discarded":
        print("  Thread discarded (not enough engagement)")
        return None

    print(f"\n=== Stage 5: Quality Control ===")
    from agents.qa_agent import evaluate_thread
    accepted = await evaluate_thread(session, config, llm_client)

    if not accepted:
        print("  Thread rejected by QA")
        return None

    print(f"\n=== Stage 6: Formatter ===")
    path = write_article(session, config)

    # Update track record
    for post in session.thread:
        persona = registry.get(post.persona_name)
        persona.record_response(
            qc_score=post.qc_score if post.qc_score > 0 else 7.0,
            accepted=True,
            topic=topic.title,
            content=post.content,
        )

    registry.save_track_record(config.track_record_path)
    
    # Increment source score if we have a source URL
    if hasattr(topic, 'source_url') and topic.source_url:
        from agents.search_agent import increment_source_score
        increment_source_score(topic.source_url)
    
    print(f"  Published: {path}")
    return session


async def cmd_generate(args, config: AppConfig):
    """Run the full generation pipeline."""
    llm_client = get_llm_client(config)

    registry = PersonaRegistry(config.personas_path)
    registry.load_track_record(config.track_record_path)

    session_successes: List[NewsCandidate] = []  # topics that became articles this session

    if args.topic:
        topics = [
            NewsCandidate(
                title=args.topic,
                url="",
                source="Manual input",
                summary=args.topic,
                category=args.category or "opinion",
                tags_guess=[t.strip() for t in (args.tags or "").split(",") if t.strip()],
            )
        ]
        print(f"Manual topic: {args.topic}")
    else:
        topics = await run_discovery(config, llm_client, session_successes)
        if not topics:
            print("\nNo topics to write about. Exiting.")
            return

    num_threads = args.threads or config.num_threads
    written = 0

    while written < num_threads and topics:
        topic = topics.pop(0)
        session = await run_single_thread(topic, config, registry, llm_client)
        if session:
            written += 1
            session_successes.append(topic)

        if written < num_threads:
            if topics:
                print(f"\n--- {written}/{num_threads} threads written. Moving to next topic. ---")
            else:
                # Refill: re-run discovery with session successes for diversity
                print(f"\n--- Refilling topics (session has {len(session_successes)} articles) ---")
                new_topics = await run_discovery(config, llm_client, session_successes)
                if not new_topics:
                    print("No more topics available.")
                    break
                topics = new_topics

    print(f"\n{'='*60}")
    print(f"Done: {written} articles written to {config.output_path}")


async def cmd_discover(args, config: AppConfig):
    """Dry run — search and filter only."""
    llm_client = get_llm_client(config)
    topics = await run_discovery(config, llm_client)

    if topics:
        print(f"\n=== Ranked Topics ===")
        for i, t in enumerate(topics, 1):
            print(f"  {i}. [{t.category}] {t.title}")
            print(f"     Source: {t.source}")
            print(f"     Tags: {', '.join(t.tags_guess)}")
            print()


def cmd_personas(args, config: AppConfig):
    """List personas with stats."""
    registry = PersonaRegistry(config.personas_path)
    registry.load_track_record(config.track_record_path)

    print(f"\n{'Name':<25} {'Posts':>6} {'Accepted':>9} {'Avg QC':>7} {'Accept Rate':>12} {'Priority':>8}")
    print("-" * 70)
    for p in registry.ordered_by_diversity():
        print(
            f"{p.name:<25}"
            f"{p.total_posts:>6} "
            f"{p.accepted_posts:>9} "
            f"{p.avg_qc_score:>7.2f} "
            f"{p.acceptance_rate:>11.0%} "
            f"{p.diversity_priority():>8.3f}"
        )
    print()


def cmd_rankings(args, config: AppConfig):
    """Show persona rankings."""
    registry = PersonaRegistry(config.personas_path)
    registry.load_track_record(config.track_record_path)

    print(f"\n{'Rank':<5} {'Name':<25} {'QC×0.4':>8} {'Accept×0.3':>10} {'Fit×0.3':>8} {'Total':>6}")
    print("-" * 65)
    for i, p in enumerate(registry.ordered_by_rank(), 1):
        qc_part = p.avg_qc_score * 0.4
        ac_part = p.acceptance_rate * 0.3
        fit_part = 0.0
        total = qc_part + ac_part + fit_part
        print(
            f"{i:<5} {p.name:<25} {qc_part:>8.2f} {ac_part:>10.2f} {fit_part:>8.2f} {total:>6.2f}"
        )
    print()


# ── CLI ──────────────────────────────────────────────────────────────────

def main():
    import argparse

    load_env()

    parser = argparse.ArgumentParser(description="Content Agents — Blog article pipeline")
    parser.add_argument("--config", help="Path to config.yaml")
    parser.add_argument("--blog-dir", help="Override BLOG_BASE_DIR")

    sub = parser.add_subparsers(dest="command", required=True)

    # generate
    gen = sub.add_parser("generate", help="Run full pipeline or manual topic")
    gen.add_argument("topic", nargs="?", help="Manual topic (skip discovery)")
    gen.add_argument("--category", "-c", default="opinion", help="Category for manual topic")
    gen.add_argument("--tags", "-t", help="Comma-separated tags for manual topic")
    gen.add_argument("--threads", type=int, help="Number of threads per run")
    gen.add_argument("--preview", action="store_true", help="Print to stdout instead of writing")

    # discover
    sub.add_parser("discover", help="Dry run: search + filter only")

    # personas
    sub.add_parser("personas", help="List personas with stats")

    # rankings
    sub.add_parser("rankings", help="Show persona rankings")

    args = parser.parse_args()

    config = load_config(args.config)
    if args.blog_dir:
        config.blog_base_dir = args.blog_dir

    blog_path = config.blog_path
    if not blog_path.exists():
        print(f"Warning: BLOG_BASE_DIR {blog_path} does not exist")

    config.output_path.mkdir(parents=True, exist_ok=True)

    if args.command == "generate":
        asyncio.run(cmd_generate(args, config))
    elif args.command == "discover":
        asyncio.run(cmd_discover(args, config))
    elif args.command == "personas":
        cmd_personas(args, config)
    elif args.command == "rankings":
        cmd_rankings(args, config)


if __name__ == "__main__":
    main()
