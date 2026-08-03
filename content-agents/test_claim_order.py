#!/usr/bin/env python3
"""Verify the ordered_for_claim fix against real persona data.

Parses cue/users.cue (name + expertise), applies the track record, and
checks claim ordering for the two topics that were previously mis-claimed
by inappropriate personas.
"""
import json
import re
import sys

sys.path.insert(0, "content-agents")
from agents.models import Persona

# ── Parse cue/users.cue for name + expertise ───────────────────────────
src = open("cue/users.cue").read()
# Split on top-level persona blocks: "    ffiltus: {"
blocks = re.findall(r"\n    ([a-z0-9_]+): \{\n(.*?)\n    \}", src, re.DOTALL)

personas = {}
for name, body in blocks:
    exp_match = re.search(r"expertise:\s*\[(.*?)\]", body, re.DOTALL)
    expertise = []
    if exp_match:
        expertise = [t.strip().strip('"') for t in exp_match.group(1).split(",") if t.strip().strip('"')]
    bio_match = re.search(r'bio:\s*"((?:[^"\\]|\\.)*)"', body)
    style_match = re.search(r'style:\s*"((?:[^"\\]|\\.)*)"', body)
    personas[name] = {
        "name": name,
        "bio": bio_match.group(1) if bio_match else "",
        "style": style_match.group(1) if style_match else "",
        "expertise": expertise,
    }

print(f"Parsed {len(personas)} personas from users.cue")

# ── Apply track record ────────────────────────────────────────────────
tr = json.load(open("content-agents/track_record.json"))
registry_personas = {}
for name, pdata in personas.items():
    rec = tr.get(name, {})
    p = Persona(
        name=name,
        bio=pdata["bio"],
        style=pdata["style"],
        expertise=pdata["expertise"],
        total_posts=rec.get("total_posts", 0),
        accepted_posts=rec.get("accepted_posts", 0),
        avg_qc_score=rec.get("avg_qc_score", 0),
        acceptance_rate=rec.get("acceptance_rate", 1.0),
    )
    registry_personas[name] = p

def ordered_for_claim(people, topic_tags):
    return sorted(people.values(), key=lambda p: (-p.topic_fit(topic_tags), -p.diversity_priority()))

def ordered_by_diversity_old(people, topic_tags):
    return sorted(people.values(), key=lambda p: (-p.diversity_priority(), -p.rank_score(topic_tags)))

# ── Scenario 1: CCTV / SBC self-hosting topic ─────────────────────────
print("\n=== Scenario 1: 'Show HN: CheapSecurity – Self-Hosted CCTV for Linux SBCs' ===")
tags1 = ["self-hosting", "homelab", "security", "linux", "cctv"]
print("Topic tags:", tags1)
print("\n-- OLD (ordered_by_diversity) --")
for i, p in enumerate(ordered_by_diversity_old(registry_personas, tags1)[:6], 1):
    print(f"  {i}. {p.name:<22} fit={p.topic_fit(tags1):.2f} posts={p.total_posts}")
print("\n-- NEW (ordered_for_claim) --")
for i, p in enumerate(ordered_for_claim(registry_personas, tags1)[:6], 1):
    print(f"  {i}. {p.name:<22} fit={p.topic_fit(tags1):.2f} posts={p.total_posts}")

# ── Scenario 2: AI coding agents topic ────────────────────────────────
print("\n=== Scenario 2: 'Show HN: Boffin – Staff-engineer layer for AI coding agents' ===")
tags2 = ["ai", "coding", "agents", "llm", "developer-tools"]
print("Topic tags:", tags2)
print("\n-- OLD (ordered_by_diversity) --")
for i, p in enumerate(ordered_by_diversity_old(registry_personas, tags2)[:6], 1):
    print(f"  {i}. {p.name:<22} fit={p.topic_fit(tags2):.2f} posts={p.total_posts}")
print("\n-- NEW (ordered_for_claim) --")
for i, p in enumerate(ordered_for_claim(registry_personas, tags2)[:6], 1):
    print(f"  {i}. {p.name:<22} fit={p.topic_fit(tags2):.2f} posts={p.total_posts}")

# ── Scenario 3: gate behavior ─────────────────────────────────────────
print("\n=== Scenario 3: fit gate (simulated claim) ===")
p1 = registry_personas["ffiltus"]
p2 = registry_personas["xss_princess"]
print(f"ffiltus fit on tags1: {p1.topic_fit(tags1):.2f} — gate would {'REJECT' if p1.topic_fit(tags1) <= 0 else 'ACCEPT'}")
print(f"xss_princess fit on tags1: {p2.topic_fit(tags1):.2f} — gate would {'REJECT' if p2.topic_fit(tags1) <= 0 else 'ACCEPT'}")

# Assertions
first1 = ordered_for_claim(registry_personas, tags1)[0]
first2 = ordered_for_claim(registry_personas, tags2)[0]
ok1 = first1.topic_fit(tags1) > 0
ok2 = first2.topic_fit(tags2) > 0
print(f"\nASSERT: top claimer for CCTV topic has expertise overlap: {ok1} ({first1.name})")
print(f"ASSERT: top claimer for Boffin topic has expertise overlap: {ok2} ({first2.name})")
sys.exit(0 if (ok1 and ok2) else 1)
