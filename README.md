# Reed Sutliff — Homelab Dashboard

A public-facing dashboard showcasing my self-hosted infrastructure, AI agent activity, and real-time cluster monitoring.

**Live:** [blog.ffilt.us](https://blog.ffilt.us)

## Architecture

- **Frontend**: Vanilla HTML/CSS/JS single-page app (no frameworks)
- **API**: Azure Functions v4 (Node.js) proxying backend services through Cloudflare Access
- **Hosting**: Azure Static Web Apps
- **Data Sources**:
  - Cluster status: `dash.ffilt.us` (FastAPI on k3s)
  - Gitea contributions: `gitea.ffilt.us`
  - Recent work: Daily-updated JSON committed by cron job

## Sections

1. **Hero** — Introduction and links to other services
2. **Recent Work** — Dated activity cards from autonomous agents and projects
3. **Cluster Status** — Live node, deployment, and service health monitoring
4. **Gitea Contributions** — 6-month commit heatmap (GitHub-style green squares)

## Local Development

```bash
# Serve static files
python3 -m http.server 8000

# With Azure Functions locally
cd api && npm install
npx func start
```

## Deploy

Push to `main` → mirror to GitHub → Azure SWA build → staging → production.

## Related Services

- [Research Lab](https://research.ffilt.us) — Research tools and data
- [Applications](https://apps.ffilt.us) — Self-hosted web apps
- [Gitea](https://gitea.ffilt.us/reeds) — Source code

## License

MIT