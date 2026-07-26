"""Auto-generate persona profile pages and the persona index from
`cue/users.cue` (via the `cue` package loader).

Each CUE user becomes:
  - /personas/<handle>/  — a full profile page (rendered via the
    `persona_profile` macro defined in main.py)
  - /personas/           — an index page with a styled card grid

Pages are created as in-memory generated files (MkDocs 1.6+ File.generated),
so no stub markdown needs to live in docs/personas/.
"""

import logging
import os
import sys

# Ensure repo root is importable so `cue` package resolves
_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _REPO_ROOT not in sys.path:
    sys.path.insert(0, _REPO_ROOT)

from cue import load_personas_dict
from mkdocs.structure.files import File

log = logging.getLogger("mkdocs.hooks")

# Groupings for the index, in display order. Handles not listed fall into
# "Community". "public_domain" and any handle in _HIDDEN are skipped entirely.
_CORE = [
    "ffiltus",
    "ne0n_sage",
    "hype_cycle",
    "cobol_kid",
    "kernel_panic",
    "xss_princess",
]
_HIDDEN = {"public_domain"}


def _detail_markdown(handle, persona):
    title = persona.get("title", "")
    display = persona.get("screen_name", handle)
    desc = persona.get("tagline", "") or f"{display} — Sutliff BBS user profile"
    heading = f"{display} — {title}" if title else display
    return (
        "---\n"
        f'title: "{display} — {title}"\n'
        f"description: {desc}\n"
        "search:\n"
        "  exclude: true\n"
        "hide:\n"
        "  - navigation\n"
        "  - toc\n"
        "---\n\n"
        '<a class="persona-back" href="../">&larr; back to all users</a>\n\n'
        f"# {heading}\n\n"
        f"{{{{ persona_profile('{handle}') }}}}\n"
    )


def _index_card(handle, persona):
    color = persona.get("color", "#33ff33")
    avatar = persona.get("avatar", "")
    display = persona.get("screen_name", handle)
    title = persona.get("title", "")
    tagline = persona.get("tagline", "")
    badge = persona.get("badge", "")
    badge_html = (
        f'<span class="persona-card-badge">{badge}</span>' if badge else ""
    )
    avatar_html = f'<img class="persona-card-avatar-img" src="/assets/avatars/{handle}.jpg" alt="{display}" onerror="this.parentElement.innerHTML=\'{avatar}\'">'
    return (
        f'<a class="persona-card" href="{handle}/" style="--persona-color:{color}">'
        f'<span class="persona-card-avatar">{avatar_html}</span>'
        f'<span class="persona-card-main">'
        f'<span class="persona-card-name">{display}{badge_html}</span>'
        f'<span class="persona-card-title">{title}</span>'
        f'<span class="persona-card-tagline">{tagline}</span>'
        f"</span>"
        f"</a>"
    )


def _index_markdown(personas):
    core, community = [], []
    for handle, persona in personas.items():
        if handle in _HIDDEN:
            continue
        (core if handle in _CORE else community).append((handle, persona))

    # Keep core in the explicit order defined above
    core.sort(key=lambda kv: _CORE.index(kv[0]))

    parts = [
        "---\n"
        "title: Personas\n"
        "description: Sutliff BBS user profiles\n"
        "search:\n"
        "  exclude: true\n"
        "hide:\n"
        "  - navigation\n"
        "  - toc\n"
        "---\n\n"
        "# Sutliff BBS — User Profiles\n\n"
        "These are the regulars you'll see arguing in the threads.\n\n"
    ]

    if core:
        parts.append('<div class="persona-section-label">// staff &amp; core</div>\n')
        parts.append('<div class="persona-grid">\n')
        parts.extend(_index_card(h, p) + "\n" for h, p in core)
        parts.append("</div>\n\n")

    if community:
        parts.append('<div class="persona-section-label">// community</div>\n')
        parts.append('<div class="persona-grid">\n')
        parts.extend(_index_card(h, p) + "\n" for h, p in community)
        parts.append("</div>\n")

    return "".join(parts)


def on_files(files, config):
    try:
        personas = load_personas_dict()
    except Exception as e:  # noqa: BLE001
        log.warning(f"[personas] could not load CUE users: {e}")
        personas = {}
    if not personas:
        return files

    docs_dir = config["docs_dir"]

    # Remove any pre-existing (hand-written) persona files so the generated
    # versions are the single source of truth.
    for f in list(files):
        if f.src_uri.startswith("personas/") and f.src_uri.endswith(".md"):
            files.remove(f)

    # Index page
    files.append(
        File.generated(
            config,
            "personas/index.md",
            content=_index_markdown(personas),
        )
    )

    # Detail pages
    count = 0
    for handle, persona in personas.items():
        if handle in _HIDDEN:
            continue
        files.append(
            File.generated(
                config,
                f"personas/{handle}.md",
                content=_detail_markdown(handle, persona),
            )
        )
        count += 1

    log.info(f"[personas] generated index + {count} profile pages")
    return files
