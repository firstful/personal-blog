"""Pydantic models for the content agent system.

Every config value is overridable via env var. 
Env var name = uppercase version of config key, prefixed with nothing,
e.g. blog_base_dir → BLOG_BASE_DIR, llm.model → LLM_MODEL
"""

from __future__ import annotations

import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

import yaml
from pydantic import BaseModel, Field


# ── News / Candidate models ──────────────────────────────────────────────

class NewsCandidate(BaseModel):
    """A single news article returned by the Search Agent."""
    title: str
    url: str
    source: str
    summary: str
    category: str = "opinion"
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    tags_guess: list[str] = Field(default_factory=list)


# ── Persona models ────────────────────────────────────────────────────────

class Persona(BaseModel):
    """A writer persona with voice, expertise, and track record."""
    name: str
    bio: str
    style: str
    expertise: list[str] = Field(default_factory=list)
    quirks: list[str] = Field(default_factory=list)

    # Track record (auto-updated)
    total_posts: int = 0
    accepted_posts: int = 0
    total_qc_score: float = 0.0
    avg_qc_score: float = 0.0
    acceptance_rate: float = 1.0
    topic_history: list[str] = Field(default_factory=list)
    last_n_scores: list[float] = Field(default_factory=list)

    @classmethod
    def from_yaml(cls, path: str | Path) -> Persona:
        with open(path) as f:
            data = yaml.safe_load(f)
        return cls(**data)

    @classmethod
    def from_dict(cls, data: dict) -> Persona:
        """Create a Persona from a dict (e.g., from JSON catalog)."""
        return cls(**data)

    def to_yaml(self, path: str | Path) -> None:
        with open(path, "w") as f:
            yaml.dump(self.model_dump(), f, default_flow_style=False, sort_keys=False)

    def record_response(self, qc_score: float, accepted: bool, topic: str) -> None:
        self.total_posts += 1
        if accepted:
            self.accepted_posts += 1
        self.total_qc_score += qc_score
        self.last_n_scores.append(qc_score)
        if len(self.last_n_scores) > 10:
            self.last_n_scores = self.last_n_scores[-10:]
        self.avg_qc_score = self.total_qc_score / max(self.total_posts, 1)
        self.acceptance_rate = self.accepted_posts / max(self.total_posts, 1)
        self.topic_history.append(topic)
        if len(self.topic_history) > 50:
            self.topic_history = self.topic_history[-50:]

    def rank_score(self, topic_tags: list[str]) -> float:
        qc_component = self.avg_qc_score * 0.4
        accept_component = self.acceptance_rate * 0.3
        topic_fit = 0.0
        if topic_tags and self.expertise:
            lower_expertise = {t.lower() for t in self.expertise}
            lower_tags = {t.lower() for t in topic_tags}
            match = lower_expertise & lower_tags
            if lower_tags:
                topic_fit = len(match) / len(lower_tags)
        fit_component = topic_fit * 0.3
        return qc_component + accept_component + fit_component

    def diversity_priority(self) -> float:
        """Higher = goes first. Based on inverse content count."""
        return 1.0 / max(self.total_posts + 1, 1)


class PersonaRegistry:
    """Manages all personas — load, save, rank."""

    def __init__(self, personas_dir: str | Path):
        self.personas_dir = Path(personas_dir)
        self.personas: dict[str, Persona] = {}
        self._load_all()

    def _load_all(self) -> None:
        """Load personas from JSON file (personas.json in the agents root)
        OR from individual YAML files in personas_dir."""
        # First try: personas.json in the parent of personas_dir or cwd
        json_paths = [
            self.personas_dir.parent / "personas.json",
            Path.cwd() / "personas.json",
            self.personas_dir / "../personas.json",
        ]
        loaded = False
        for jp in json_paths:
            jp = jp.resolve()
            if jp.exists():
                import json
                with open(jp) as f:
                    data = json.load(f)
                for entry in data:
                    p = Persona.from_dict(entry)
                    self.personas[p.name.lower()] = p
                    self.personas[p.name] = p
                loaded = True
                print(f"  [registry] Loaded {len(data)} personas from {jp}")
                break

        if not loaded:
            # Fallback: individual YAML files
            for f in sorted(self.personas_dir.glob("*.yaml")):
                p = Persona.from_yaml(f)
                self.personas[p.name] = p

    def get(self, name: str) -> Persona:
        return self.personas[name]

    def list_names(self) -> list[str]:
        return list(self.personas.keys())

    def ordered_by_diversity(self, topic_tags: list[str] | None = None) -> list[Persona]:
        if topic_tags is None:
            topic_tags = []
        return sorted(
            self.personas.values(),
            key=lambda p: (-p.diversity_priority(), -p.rank_score(topic_tags)),
        )

    def ordered_by_rank(self, topic_tags: list[str] | None = None) -> list[Persona]:
        if topic_tags is None:
            topic_tags = []
        return sorted(
            self.personas.values(),
            key=lambda p: -p.rank_score(topic_tags),
        )

    def save_all(self) -> None:
        for p in self.personas.values():
            path = self.personas_dir / f"{p.name.lower().replace(' ', '_')}.yaml"
            p.to_yaml(path)

    def save_track_record(self, path: str | Path) -> None:
        data = {name: p.model_dump() for name, p in self.personas.items()}
        with open(path, "w") as f:
            json.dump(data, f, indent=2, default=str)

    def load_track_record(self, path: str | Path) -> None:
        path = Path(path)
        if not path.exists():
            return
        with open(path) as f:
            data = json.load(f)
        for name, record in data.items():
            if name in self.personas:
                p = self.personas[name]
                for k, v in record.items():
                    if k in ("name", "bio", "style", "expertise", "quirks"):
                        continue
                    setattr(p, k, v)


# ── Session / Thread models ──────────────────────────────────────────────

class ThreadPost(BaseModel):
    """A single post in a discussion thread."""
    persona_name: str
    content: str
    is_opening: bool = False
    qc_score: float = 0.0
    qc_passed: bool = False
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class ThreadSession(BaseModel):
    """State for a single article generation session."""
    topic: NewsCandidate
    thread: list[ThreadPost] = Field(default_factory=list)
    persona_order: list[str] = Field(default_factory=list)
    current_persona_idx: int = 0
    consecutive_passes: int = 0
    claimed_by: Optional[str] = None
    status: str = "new"  # new, claiming, responding, qc, formatted, discarded, completed

    def post_summaries(self) -> str:
        """Return extremely brief summaries of all posts in the thread."""
        if not self.thread:
            return "No posts yet."
        lines = []
        for p in self.thread:
            label = "Opening post" if p.is_opening else "Response"
            snippet = p.content[:120].replace("\n", " ").strip()
            lines.append(f"**{p.persona_name}** — {label}: \"{snippet}...\"")
        return "\n\n".join(lines)

    def summary_json(self) -> str:
        return json.dumps(
            {
                "topic": self.topic.title,
                "persona_order": self.persona_order,
                "status": self.status,
                "thread": [
                    {"persona": p.persona_name, "is_opening": p.is_opening,
                     "qc_score": p.qc_score, "content": p.content}
                    for p in self.thread
                ],
            },
            indent=2,
        )


# ── Config with env var overrides ────────────────────────────────────────

# Map: config key path → env var name
# Supports dot-separated for nested keys: llm.model → LLM_MODEL
_ENV_OVERRIDES: dict[str, str] = {
    "blog_base_dir": "BLOG_BASE_DIR",
    "agents_base_dir": "AGENTS_BASE_DIR",
    "max_posts_per_thread": "MAX_POSTS_PER_THREAD",
    "min_posts_per_thread": "MIN_POSTS_PER_THREAD",
    "num_threads": "NUM_THREADS",
    "search_window_hours": "SEARCH_WINDOW_HOURS",
    "max_candidates": "MAX_CANDIDATES",
    "output_dir": "OUTPUT_DIR",
    "articles_dir": "ARTICLES_DIR",
    "personas_dir": "PERSONAS_DIR",
    "track_record": "TRACK_RECORD",
    "sessions_dir": "SESSIONS_DIR",
    # LLM sub-keys
    "llm.base_url": "LLM_BASE_URL",
    "llm.api_key_env": "LLM_API_KEY_ENV",
    "llm.model": "LLM_MODEL",
    "llm.qa_model": "LLM_QA_MODEL",
    "llm.temperature": "LLM_TEMPERATURE",
    # RSS
    "sources.rss": "RSS_SOURCES",
}


class AppConfig(BaseModel):
    blog_base_dir: str = str(Path.home() / "content-agents")
    sources: dict = Field(default_factory=lambda: {
        "rss": [
            "https://hnrss.org/frontpage",
            "https://feeds.arstechnica.com/arstechnica/index",
        ],
        "categories": {
            "opinion": ["technology", "culture", "AI", "open-source"],
            "tutorial": ["programming", "devops", "tools", "infrastructure"],
            "reference": ["standards", "APIs", "protocols"],
        },
    })
    max_posts_per_thread: int = 8
    min_posts_per_thread: int = 3
    num_threads: int = 3
    search_window_hours: int = 6
    max_candidates: int = 10
    llm: dict = Field(default_factory=lambda: {
        "base_url": "https://api.deepseek.com/v1",
        "api_key_env": "LLM_API_KEY",
        "model": "deepseek-chat",
        "qa_model": "deepseek-chat",
        "temperature": 0.7,
    })
    # Paths
    agents_base_dir: str = ""  # Auto-detected: dir of config.yaml, then ~/content-agents
    output_dir: str = "drafts"
    articles_dir: str = "docs/blog"
    personas_dir: str = "personas"
    track_record: str = "track_record.json"
    sessions_dir: str = "sessions"

    # Default defaults with env var overrides
    def __init__(self, **data):
        super().__init__(**data)
        # Apply env var overrides on top of whatever was set
        raw = self.model_dump()
        for key_path, env_var in _ENV_OVERRIDES.items():
            val = os.environ.get(env_var)
            if val is not None:
                _set_nested(raw, key_path, _coerce(val, key_path))
        # Re-initialize with overrides applied
        super().__init__(**raw)

    @classmethod
    def from_yaml(cls, path: str | Path) -> AppConfig:
        with open(path) as f:
            data = yaml.safe_load(f) or {}
        return cls(**data)

    @property
    def agents_path(self) -> Path:
        if self.agents_base_dir:
            return Path(self.agents_base_dir).expanduser().resolve()
        # Auto-detect: start from cwd, walk up looking for config.yaml
        for p in [Path.cwd(), Path(__file__).parent.parent, Path.home() / "content-agents"]:
            if (p / "config.yaml").exists() or (p / "personas").exists():
                return p.resolve()
        return Path.home() / "content-agents"

    @property
    def blog_path(self) -> Path:
        return Path(self.blog_base_dir).expanduser().resolve()

    @property
    def output_path(self) -> Path:
        return self.blog_path / self.output_dir

    @property
    def articles_path(self) -> Path:
        return self.blog_path / self.articles_dir

    @property
    def personas_path(self) -> Path:
        return self.agents_path / self.personas_dir

    @property
    def track_record_path(self) -> Path:
        return self.agents_path / self.track_record

    @property
    def sessions_path(self) -> Path:
        return self.agents_path / self.sessions_dir


def _set_nested(d: dict, key_path: str, val: Any) -> None:
    """Set a nested dict value from a dot-separated path."""
    parts = key_path.split(".")
    for part in parts[:-1]:
        if part not in d or not isinstance(d[part], dict):
            d[part] = {}
        d = d[part]
    d[parts[-1]] = val


def _coerce(val: str, key_path: str) -> Any:
    """Coerce env var string to appropriate type based on config key."""
    if key_path in ("max_posts_per_thread", "min_posts_per_thread",
                    "num_threads", "search_window_hours", "max_candidates"):
        return int(val)
    if key_path == "llm.temperature":
        return float(val)
    if key_path == "sources.rss":
        return [u.strip() for u in val.split(",") if u.strip()]
    return val
