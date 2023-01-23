import os
from http.client import HTTPSConnection
from dotenv import load_dotenv
import glob
import os.path

def retrieve_file(password, owner, repo, path):
    conn = HTTPSConnection("api.github.com")
    headers = {
        'User-Agent' : "MkDocs Build Agent",
        'Authorization' : f"Bearer {password}",
        'Accept' : 'application/vnd.github.raw'
    }
    conn.request('GET',f"/repos/{owner}/{repo}/contents/{path}", headers=headers)
    response = conn.getresponse()
    return response.read().decode('utf-8')

def define_env(env):
    load_dotenv()
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
    @env.macro
    def retrieve_example(path):
        return retrieve_private_git("reedsutliff", "blog-examples", path)
    @env.macro
    def retrieve_private_git(owner,repo,path):
        pat = os.environ['MKDOCS_GITHUB_PAT']
        return retrieve_file(pat,owner,repo,path)