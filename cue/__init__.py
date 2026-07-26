"""CUE content store — single source of truth for persona data."""

from __future__ import annotations

import json
import logging
import os
import shutil
import subprocess
from pathlib import Path
from typing import Any

log = logging.getLogger("cue")

_CUE_DIR = Path(__file__).parent
_SCHEMA = _CUE_DIR / "schema.cue"
_USERS = _CUE_DIR / "users.cue"


def _find_cue() -> str:
    candidates = [
        os.environ.get("CUE_BIN", ""),
        "/usr/local/bin/cue",
        str(Path.home() / "go" / "bin" / "cue"),
    ]
    for c in candidates:
        if c and os.path.isfile(c):
            return c
    which = shutil.which("cue")
    if which:
        return which
    raise RuntimeError(
        "CUE binary not found. Install: go install cuelang.org/go/cmd/cue@latest"
    )


def _export() -> dict[str, Any]:
    cue_bin = _find_cue()
    result = subprocess.run(
        [cue_bin, "export", str(_SCHEMA), str(_USERS), "--out", "json"],
        capture_output=True, text=True, timeout=30,
    )
    if result.returncode != 0:
        raise RuntimeError(f"cue export failed:\n{result.stderr}")
    return json.loads(result.stdout)


_users_cache: dict[str, dict] | None = None


def _raw_users() -> dict[str, dict]:
    global _users_cache
    if _users_cache is None:
        _users_cache = _export().get("users", {})
    return _users_cache


# ── MkDocs consumers (hooks/personas.py, main.py) ──────────────────────


def load_personas_dict() -> dict[str, dict]:
    """Return personas keyed by handle, with 'screen_name' alias."""
    out = {}
    for uid, u in _raw_users().items():
        entry = dict(u)
        entry["screen_name"] = u["display"]
        out[uid] = entry
    return out


# ── Content agents consumer (PersonaRegistry) ──────────────────────────


def load_personas_list() -> list[dict]:
    """Return personas as a list of dicts (content-agents format)."""
    out = []
    for uid, u in _raw_users().items():
        out.append({
            "name": uid,
            "display": f'{uid} {u["avatar"]}',
            "archetype": u["archetype"],
            "bio": u["bio"],
            "style": u["style"],
            "expertise": u.get("expertise", []),
            "quirks": u.get("quirks", []),
        })
    return out
