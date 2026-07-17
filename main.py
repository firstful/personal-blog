import os
import shutil
import subprocess
from dotenv import load_dotenv
import glob
import os.path

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

    # Load personas
    import json
    personas_path = os.path.join(os.getcwd(), "personas", "personas.json")
    try:
        with open(personas_path) as f:
            PERSONAS = json.load(f)
    except:
        PERSONAS = {}

    @env.macro
    def forum_post(handle: str, timestamp: str, body: str, sig: bool = True):
        """Render a forum post from a persona. Set sig=False to omit signature."""
        persona = PERSONAS.get(handle, {})
        display = persona.get("screen_name", handle)
        avatar = persona.get("avatar", "●")
        color = persona.get("color", "#33ff33")
        title = persona.get("title", "")
        signature = persona.get("signature", "")
        badge = persona.get("badge", "")

        body = body.strip().replace("\n", "\n    ")

        badge_html = f'<span class="forum-badge">{badge}</span>' if badge else ""

        sig_html = ""
        if sig and signature:
            sig_html = f'\n  <div class="forum-signature">— {signature}</div>'

        return (
            f'<div class="forum-post">'
            f'  <div class="forum-post-header">'
            f'    <span class="forum-avatar" style="color:{color}">{avatar}</span>'
            f'    <span class="forum-author" style="color:{color}">{display}</span>'
            f'    {badge_html}'
            f'    <span class="forum-title">· {title}</span>'
            f'    <span class="forum-timestamp">· {timestamp}</span>'
            f'  </div>'
            f'  <div class="forum-post-body">\n{body}\n  </div>'
            f'{sig_html}'
            f'</div>'
        )

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