import os
import shutil
import subprocess
import sys
from dotenv import load_dotenv
import glob
import os.path

_REPO_ROOT = os.path.dirname(os.path.abspath(__file__))
if _REPO_ROOT not in sys.path:
    sys.path.insert(0, _REPO_ROOT)

_RESUME_BUILT = False

def _build_resume_assets():
    global _RESUME_BUILT
    if _RESUME_BUILT:
        return

    # 1. Compile TypeScript => JS
    ts_script = os.path.join(os.getcwd(), "resume", "scripts", "build-ts.py")
    if os.path.exists(ts_script):
        subprocess.run(["python3", ts_script], capture_output=True)

    # 2. Copy resume PDFs
    src_dir = os.path.join(os.getcwd(), "resume", "output")
    dst_dir = os.path.join(os.getcwd(), "docs", "assets", "resume")
    if os.path.exists(src_dir):
        os.makedirs(dst_dir, exist_ok=True)
        for pdf in glob.glob(os.path.join(src_dir, "*", "resume.pdf")):
            variant = os.path.basename(os.path.dirname(pdf))
            shutil.copy2(pdf, os.path.join(dst_dir, f"{variant}.pdf"))

    _RESUME_BUILT = True

def define_env(env):
    load_dotenv()
    _build_resume_assets()

    # Load personas from CUE source of truth
    from cue import load_personas_dict
    try:
        PERSONAS = load_personas_dict()
    except Exception:
        PERSONAS = {}

    @env.macro
    def forum_post(handle: str, timestamp: str, body: str, sig: bool = True, quote: str = ""):
        """Render a forum post in classic two-column layout.

        quote: persona handle to quote, optionally with :N for the Nth post
               by that handle (0-indexed). e.g. quote='cobol_kid' quotes
               their most recent post, quote='cobol_kid:0' quotes their first.
        """
        import markdown as md_lib
        import textwrap
        import re as _re

        # ── track posts per page for auto-quoting ──
        if "_forum_posts" not in env.variables:
            env.variables["_forum_posts"] = []
        _posts = env.variables["_forum_posts"]

        persona = PERSONAS.get(handle, {})
        display = persona.get("screen_name", handle)
        title = persona.get("title", "")
        signature = persona.get("signature", "")
        badge = persona.get("badge", "")
        joined = persona.get("joined", "")
        pcount = persona.get("posts", 0)

        raw_body = textwrap.dedent(body).strip()
        body_html = md_lib.markdown(raw_body, extensions=['fenced_code', 'tables', 'codehilite', 'nl2br', 'footnotes'])

        badge_html = f'<span class="forum-badge">{badge}</span>' if badge else ""
        pcount_html = f'    <div class="fp-stat">Posts: {pcount}</div>\n' if pcount else ""
        sig_html = f'\n  <div class="forum-signature">— {signature}</div>' if sig and signature else ""

        # ── auto-quote: parse handle[:N] and find the target post ──
        reply_html = ""
        if quote:
            snippet = ""
            # parse "handle" or "handle:N"
            q_handle = quote
            q_index = -1  # -1 = most recent
            if ":" in quote:
                parts = quote.rsplit(":", 1)
                q_handle = parts[0]
                try:
                    q_index = int(parts[1])
                except ValueError:
                    pass

            # collect all posts by this handle
            matches = [p for p in _posts if p["handle"] == q_handle]
            if matches:
                if q_index >= 0 and q_index < len(matches):
                    target = matches[q_index]
                else:
                    target = matches[-1]  # most recent

                # strip markdown, collapse whitespace, take first ~120 chars
                clean = _re.sub(r'[*`>#\[\]()!_~]', '', target["body"])
                clean = _re.sub(r'\s+', ' ', clean).strip()
                # try to cut at a sentence boundary
                cut = clean[:150]
                for end in ['. ', '! ', '? ']:
                    idx = cut.rfind(end)
                    if idx > 40:
                        cut = cut[:idx + 1]
                        break
                snippet = cut.strip()
            if snippet:
                reply_html = f'\n  <div class="fp-reply"><span class="fp-reply-icon">&gt;</span> {snippet}</div>'

        # ── store this post for future quotes ──
        _posts.append({"handle": handle, "body": raw_body})

        return (
            f'<div class="forum-post">'
            f'  <div class="fp-left">'
            f'    <div class="fp-username">{display}</div>'
            f'    {badge_html}'
            f'    <div class="fp-usertitle">{title}</div>'
            f'{pcount_html}'
            f'    <div class="fp-stat">Joined: {joined}</div>'
            f'  </div>'
            f'  <div class="fp-right">'
            f'    <div class="fp-timestamp">{timestamp}</div>'
            f'    <div class="fp-body">{reply_html}\n{body_html}\n  </div>'
            f'{sig_html}'
            f'  </div>'
            f'</div>'
        )

    @env.macro
    def persona_profile(handle: str):
        """Render a full persona profile page."""
        persona = PERSONAS.get(handle)
        if not persona:
            return f'<div class="forum-post-body">Persona "{handle}" not found.</div>'

        color = persona.get("color", "#33ff33")
        display = persona.get("screen_name", handle)
        title = persona.get("title", "")
        tagline = persona.get("tagline", "")
        bio = persona.get("bio", "")
        catchphrase = persona.get("catchphrase", "")
        joined = persona.get("joined", "")
        signature = persona.get("signature", "")
        badge = persona.get("badge", "")
        archetype = persona.get("archetype", "")

        badge_html = f'<span class="forum-badge">{badge}</span>' if badge else ""

        return f'''
<div class="forum-post" style="border-left-color:{color}">
  <div class="forum-post-header" style="border-bottom-color:{color}">
    <div>
      <div style="font-size:20px;font-weight:700;color:{color}">{display} {badge_html}</div>
      <div style="font-size:13px;color:var(--term-fg-dim)">{title}</div>
    </div>
  </div>
  <div class="forum-post-body">
    <p><em>"{tagline}"</em></p>
    <hr style="border-color:var(--term-border-dim)">
    <p>{bio}</p>
    <hr style="border-color:var(--term-border-dim)">
    <table style="font-size:13px;color:var(--term-fg-dim)">
      <tr><td style="padding-right:16px"><strong>Archetype</strong></td><td>{archetype}</td></tr>
      <tr><td><strong>Catchphrase</strong></td><td><em>"{catchphrase}"</em></td></tr>
      <tr><td><strong>Joined</strong></td><td>{joined}</td></tr>
    </table>
  </div>
  <div class="forum-signature">— {signature}</div>
</div>
'''

    @env.macro
    def create_index(relative_path: str):
        docs_dir = os.path.join(os.getcwd(),"docs")
        target_path = os.path.join(docs_dir,relative_path)
        output = ""
        for file in glob.glob(target_path+os.sep+"*.md"):
            name = os.path.splitext(os.path.basename(file))[0]
            href = "/" + relative_path + "/" + name
            if(name == "index"):
                continue
            output = output + f"\n\n [{name}]({href})"
        return output
    @env.macro
    def format_text(text, start_line = 0,end_line = 20, indent = 1):
        lines = text.splitlines()
        output = []
        index = 0
        for line in lines:
            index = index + 1
            if index < start_line:
                continue
            if index > end_line:
                break
            output.append("\t" * indent + line)
        return "\n".join(output)