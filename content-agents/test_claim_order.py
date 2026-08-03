#!/usr/bin/env python3
"""Verify the LLM-driven relevance-scoring claim selection.

The orchestrator now asks EVERY persona to score the topic's relevance to
its own expertise on a scale of 1-10 (LLM judgment), then:
  - the MAX score becomes the thread initiator
  - the TOP HALF of scorers become the possible discussion members

This test:
1. Parses the real persona catalog from cue/users.cue (name + expertise).
2. Simulates LLM relevance scores with a well-calibrated model: score =
   topic_fit mapped onto the 1-10 scale, plus a small honest-noise factor,
   with a hard floor of 1 for anyone not in-lane (LLM personas stay
   honest per the prompt).
3. Runs select_participants() and asserts the initiator is the persona the
   LLM scored highest, the pool is the top half, and an out-of-lane persona
   can only lead if the LLM actually scored it highest (LLM-driven).

Run: python3 content-agents/test_claim_order.py   (exit 0 = pass)
"""
import json
import re
import sys

sys.path.insert(0, "content-agents")
from agents.models import Persona, PersonaRegistry
from agents.orchestrator import select_participants

# ── Parse cue/users.cue for name + expertise ───────────────────────────
src = open("cue/users.cue").read()
blocks = re.findall(r"\n    ([a-z0-9_]+): \{\n(.*?)\n    \}", src, re.DOTALL)

personas = {}
for name, body in blocks:
    exp_match = re.search(r"expertise:\s*\[(.*?)\]", body, re.DOTALL)
    expertise = []
    if exp_match:
        expertise = [t.strip().strip('"') for t in exp_match.group(1).split(",") if t.strip().strip('"')]
    personas[name] = {"name": name, "expertise": expertise}

print(f"Parsed {len(personas)} personas from users.cue")

# ── Build registry (no track record needed for selection logic) ───────
reg = PersonaRegistry.__new__(PersonaRegistry)
reg.personas = {}
for name, pdata in personas.items():
    p = Persona(name=name, bio="", style="", expertise=pdata["expertise"])
    reg.personas[name] = p


def simulate_llm_scores(tags, rng_seed=42):
    """Well-calibrated LLM scores. A real LLM reading a persona's expertise
    scores squarely-in-lane topics high (7-9) even with partial tag overlap;
    out-of-lane personas stay low (1-2). Maps fit -> 1..10 bands."""
    import random
    rng = random.Random(rng_seed)
    scores = {}
    for name, p in reg.personas.items():
        fit = p.topic_fit(tags)
        if fit <= 0:
            scores[name] = rng.choice([1, 1, 2])  # honest pass
        elif fit >= 0.4:
            scores[name] = rng.randint(7, 9)      # squarely in lane
        elif fit >= 0.2:
            scores[name] = rng.randint(5, 6)      # adjacent but real
        else:
            scores[name] = rng.randint(3, 4)      # edge of lane
    return scores


# ── Scenario 1: homelab/CCTV topic ────────────────────────────────────
print("\n=== Scenario 1: 'Show HN: CheapSecurity – Self-Hosted CCTV for Linux SBCs' ===")
tags1 = ["self-hosting", "homelab", "security", "linux", "cctv"]
scores1 = simulate_llm_scores(tags1)
init1, pool1 = select_participants(scores1, reg, tags1)

top = sorted(scores1.items(), key=lambda kv: -kv[1])[:5]
print("Top LLM scores:")
for n, s in top:
    print(f"  {n:<22} relevance={s}  fit={reg.get(n).topic_fit(tags1):.2f}")
print(f"INITIATOR: {init1} (score {scores1[init1]})")
print(f"POOL ({len(pool1)}): {', '.join(pool1)}")

# ── Scenario 2: AI coding agents topic ────────────────────────────────
print("\n=== Scenario 2: 'Show HN: Boffin – Staff-engineer layer for AI coding agents' ===")
tags2 = ["ai", "coding", "agents", "llm", "developer-tools"]
scores2 = simulate_llm_scores(tags2)
init2, pool2 = select_participants(scores2, reg, tags2)

top2 = sorted(scores2.items(), key=lambda kv: -kv[1])[:5]
print("Top LLM scores:")
for n, s in top2:
    print(f"  {n:<22} relevance={s}  fit={reg.get(n).topic_fit(tags2):.2f}")
print(f"INITIATOR: {init2} (score {scores2[init2]})")
print(f"POOL ({len(pool2)}): {', '.join(pool2)}")

# ── Scenario 3: nobody finds it relevant → discard ────────────────────
print("\n=== Scenario 3: all personas score low → thread discarded ===")
scores3 = {name: 1 for name in reg.personas}
init3, pool3 = select_participants(scores3, reg, ["random", "unrelated"])
print(f"INITIATOR: {init3} (expect None — all scored 1/low)")
print(f"POOL: {pool3} (expect [])")

# ── Scenario 4: tie between two in-lane personas → deterministic ──────
print("\n=== Scenario 4: tie between two in-lane personas ===")
scores4 = {name: 1 for name in reg.personas}
scores4["raid_zero"] = 9
scores4["xss_princess"] = 9
init4, pool4 = select_participants(scores4, reg, tags1)
print(f"INITIATOR: {init4} (tie raid_zero/xss_princess; fit tiebreak)")
print(f"  raid_zero fit={reg.get('raid_zero').topic_fit(tags1):.2f}, xss_princess fit={reg.get('xss_princess').topic_fit(tags1):.2f}")
assert init4 in ("raid_zero", "xss_princess")

# ── Assertions ────────────────────────────────────────────────────────
ok = True

# Initiator must be the max LLM score (not the least-published persona).
assert scores1[init1] == max(scores1.values()), "initiator1 is not the max LLM score"
assert scores2[init2] == max(scores2.values()), "initiator2 is not the max LLM score"

# Discussion pool must be the top half of the roster, min 2.
assert len(pool1) == max(2, (len(scores1) + 1) // 2), f"pool1 size wrong: {len(pool1)}"
assert len(pool2) == max(2, (len(scores2) + 1) // 2), f"pool2 size wrong: {len(pool2)}"
assert pool1[0] == init1 and pool2[0] == init2, "initiator must be first in pool"

# Out-of-lane personas (fit 0) can only be in the pool if the LLM scored them
# into the top half — with calibrated scores they should NOT be initiator.
assert init1 not in {n for n, s in scores1.items() if s == 1 and reg.get(n).topic_fit(tags1) == 0}, \
    "out-of-lane persona became initiator on homelab topic"
assert init2 not in {n for n, s in scores2.items() if s == 1 and reg.get(n).topic_fit(tags2) == 0}, \
    "out-of-lane persona became initiator on AI topic"

# Discard path.
assert init3 is None and pool3 == [], "all-low scores should discard"

# Sanity: with honest LLM scores, the homelab initiator is a real fit.
assert reg.get(init1).topic_fit(tags1) > 0, f"{init1} has no homelab fit but initiated"

print("\nALL ASSERTIONS PASSED")
sys.exit(0)
