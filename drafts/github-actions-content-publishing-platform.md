---
tags:
    - Tutorial
    - Github Actions
    - MkDocs
    - Content Strategy
description: |
    How to turn GitHub Actions into a full content publishing platform — scheduled
    posts, preview environments, RSS generation, content validation, and lessons
    from running this blog.
image: https://blog.ffilt.us/assets/logo.png
---

# GitHub Actions as a Content Publishing Platform

Every developer I know has a side project that starts with "I'll just write some markdown files and push them." Then the requirements creep: scheduled posts, preview environments before publishing, RSS feeds that update themselves, broken-link checks, analytics that don't cost a mortgage payment. Before long, you're either maintaining a Wordpress instance with five plugins or you've given up and accepted that content operations are a second-class concern.

I've been there. Multiple times. The solution that's stuck for me — and the one powering this very blog — is GitHub Actions used not as a CI tool with content bolted on, but as a genuine content publishing platform.

## Why Not the Obvious Choices?

Let me start with the trade-offs, because I've made each of these mistakes personally.

**Static site generators (MkDocs, Hugo, Jekyll) on their own** are fine for building, but they don't solve scheduling, preview, or validation. You need a pipeline around them.

**Headless CMS platforms (Contentful, Sanity, Strapi)** solve content management but introduce a network dependency for what is fundamentally a bunch of markdown files. They also cost money and add a UI layer you may not need.

**Netlify/Vercel** have great built-in preview deployments and form handling, but their publish scheduling requires either a cron job elsewhere or their Pro plans.

GitHub Actions hits a sweet spot: it's already where your code lives, it's free for public repositories, and its event system maps surprisingly well to content operations once you stop thinking of it as "just a CI runner."

## The Core Pattern: Content as Data

The key insight is that content follows the same lifecycle as code:

```
Edit → Commit → Validate → Preview → Publish → Monitor
```

Replace "commit" with "merge a PR" and you have a standard CI/CD pipeline. Replace "unit test" with "spell check" and "integration test" with "broken-link checker." The only addition is scheduling, which GitHub Actions handles natively.

Here's the minimal workflow that powers this blog:

```yaml
name: Publish Blog

on:
  push:
    branches: [main]
    paths:
      - "docs/**"
      - "mkdocs.yml"
      - "overrides/**"

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install mkdocs-material
      - run: mkdocs build
      - uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_TOKEN }}
          action: upload
          app_location: site
```

That's the skeleton. Everything else layers on top of it.

## Scheduled Publishing: The Tricky Part

Static sites don't have a cron daemon. If you want an article to go live at 9 AM on Tuesday, something external has to trigger the build. GitHub Actions has `schedule` events powered by cron:

```yaml
on:
  schedule:
    - cron: "0 14 * * *"  # 7 AM Pacific, daily
  workflow_dispatch:  # manual trigger for testing
```

The workflow checks whether any scheduled posts are due. For this blog, I use a MkDocs hook that checks dates in article frontmatter and only includes posts whose `date` has passed:

```python
# hooks/scheduled_posts.py
import re
from datetime import datetime

def on_page_markdown(markdown, page, config, files):
    """Exclude pages with future dates from the build."""
    if page.meta.get("date") and page.meta.get("draft"):
        post_date = datetime.fromisoformat(page.meta["date"])
        if post_date > datetime.now():
            return ""  # Return empty markdown to skip rendering
    return markdown
```

The hook runs during `mkdocs build`, filtering out posts whose `draft: true` combined with a future date. On the scheduled date, the build picks them up and they appear. No database, no cron service, no manual flipping of switches.

## Preview Deployments: The Game Changer

The single biggest quality improvement for my writing came from preview deployments on PRs. Before this, every article went directly to main and I caught typos after they were live. Now:

1. I write in a branch
2. Open a PR
3. GitHub Actions builds a preview on Azure SWA staging
4. I review the rendered version with real URLs
5. Merge when it looks right

```yaml
name: Preview Blog

on:
  pull_request:
    branches: [main]
    paths:
      - "docs/**"
      - "mkdocs.yml"

jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pip install mkdocs-material
      - run: mkdocs build --strict  # fail on warnings
      - uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_TOKEN }}
          action: upload
          skip_app_build: true
          environment: pr-${{ github.event.number }}
```

GitHub shows the preview URL right in the PR conversation. And yes — `--strict` catches broken links before they become broken links on prod.

## Content Validation: Better Than a Second Pair of Eyes

I'm a terrible proofreader of my own writing. GitHub Actions can't fix that entirely, but it can catch the mechanical errors so I focus on the substantive ones:

```yaml
- name: Spell check
  uses: crate-ci/typos@master
  with:
    files: ./docs/

- name: Check internal links
  run: |
    pip install mkdocs-material
    mkdocs build --strict

- name: Check external links
  run: |
    pip install linkchecker
    linkchecker --check-extern site/
```

The `--strict` flag on `mkdocs build` is the unsung hero. It catches:
- Broken internal links (`[foo](./nonexistent.md)`)
- Missing image references (`![alt](./missing.png)`)
- Undefined anchor links (`[bar](#missing-section)`)
- Template rendering errors

I've had PRs where the build failed because I renamed a section heading and forgot to update a cross-reference. The CI caught it before the merge button was ever in reach.

## RSS Without a Plugin (or Why I Regret Not Using One)

This blog generates RSS via the MkDocs `mkdocs-rss-plugin`. But I want to be honest about a limitation: because this is a static site on Azure SWA, RSS feeds only update when a build runs. If you publish a post at 9:00 AM and a subscriber's reader polls at 8:59 AM, they won't see it until the next build cycle.

The workaround (which I use) is a morning schedule trigger that rebuilds the site daily, ensuring feeds refresh at worst every 24 hours:

```yaml
on:
  schedule:
    - cron: "0 14 * * *"  # Daily rebuild for RSS freshness
```

It's not real-time. For a personal blog, that's fine. For a news site, you'd want a different architecture.

## The "Write in Drafts, Publish by Moving" Workflow

Here's the concrete workflow I've settled on after a year of iterations:

```
drafts/my-new-article.md       # Write here, commit freely
    ↓
docs/blog/tutorials/my-new-article.md  # Move to docs/ when ready
    ↓
git commit -m "Publish: my new article"
    ↓
PR → preview → merge → build → deploy
```

The `drafts/` directory is tracked in git but excluded from `mkdocs` builds. Moving a file from `drafts/` to `docs/` is the publishing act. No config changes, no date flipping, no ceremony.

For scheduled posts, I add `draft: true` to the frontmatter and set a future `date`. The MkDocs hook takes care of the rest.

## Lessons Learned

After running this blog on GitHub Actions + Azure SWA for long enough that I've lost count, here's what surprised me:

**1. The bottleneck is writing, not deploying.**
I spent weeks optimizing build times (down to 47 seconds from initial push to live). That saved maybe 10 hours total. I should have spent those weeks writing more articles. Premature optimization of the pipeline is real.

**2. Build failures are publishing failures.**
When the action fails, nothing goes live. I've had a Tuesday-morning post miss its slot because a transitive Python dependency broke. Now I pin dependencies and test the build locally before relying on a schedule.

**3. Preview environments change how you write.**
Knowing you'll see a rendered version before publishing makes you more willing to experiment. Tables, diagrams, embedded content — you try things you'd skip if the first review was "push to main and pray."

**4. GitHub Actions is not a CMS.**
It's a CI/CD system that happens to be really good at content pipelines. The distinction matters when you need editorial workflows, draft approvals, or multi-author publishing. For a solo blog, it's perfect. For a team of ten, you'd want something purpose-built.

## The Decision: Should You Do This?

| Your situation | Verdict |
|---|---|
| Solo technical blog | ✅ Perfect fit |
| Small team, markdown-savvy | ✅ Works with conventions |
| Non-technical authors | ❌ Use a CMS with a GUI |
| Real-time publishing needs | ❌ Needs server-side infra |
| You already use GitHub | ✅ No-brainer |
| You use GitLab/Bitbucket | ✅ Similar patterns available |

If you're already comfortable with markdown and git, GitHub Actions as a content platform eliminates more complexity than it adds. The pipeline becomes invisible — you write, you commit, it publishes. The moments you notice it are the moments it saves you from yourself: catching a broken link, building a preview branch, publishing a post while you're asleep.

That's the bar for a good platform, isn't it? You shouldn't have to think about it.
