# Repo: personal-blog

## Service Config

This is the homelab dashboard deployed to Azure Static Web Apps at blog.ffilt.us.

## Architecture

- **Frontend**: Vanilla HTML/CSS/JS SPA at repo root
- **API**: Azure Functions v4 in `/api` directory, proxying dash.ffilt.us and gitea.ffilt.us
- **Data**: Recent work entries in `/data/recent-work.json` (updated daily by cron)
- **Deploy**: Gitea push → mirror to GitHub → Azure SWA deploy

## Environment Variables (set in SWA settings)

- `DASH_URL` — homelab dashboard backend
- `GITEA_URL` — Gitea instance URL
- `CF_ACCESS_CLIENT_ID` / `CF_ACCESS_CLIENT_SECRET` — Cloudflare Access service tokens

## Making Changes

1. Edit files, test locally with `python3 -m http.server 8000`
2. Commit and push to main
3. Gitea mirrors to GitHub → triggers SWA deploy

## Key Files

- `index.html` — SPA shell
- `assets/style.css` — Dark theme styling
- `assets/app.js` — Frontend logic (fetch, cache, render)
- `api/src/functions/*.js` — Azure Functions proxies
- `data/recent-work.json` — Activity feed data
- `resume/` — LaTeX resume builder (do not modify)