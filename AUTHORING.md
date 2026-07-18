# Sutliff BBS — Authoring Guide

This document covers everything you need to know to write, publish, and maintain content on the Sutliff BBS blog at **blog.ffilt.us**.

## Table of Contents

1. [Concept](#concept)
2. [Personas](#personas)
3. [Writing Articles as Forum Threads](#writing-articles-as-forum-threads)
4. [Daily Automated Articles](#daily-automated-articles)
5. [Authoring Tips](#authoring-tips)
6. [Site Features](#site-features)
7. [Build Pipeline](#build-pipeline)
8. [Content Organization](#content-organization)

---

## Concept

The site is a **retro BBS / forum** — not a blog. Everything is styled like a 90s dial-up bulletin board:

- CRT terminal green-on-black theme with scanline overlay
- Boot sequence on first visit per tab (session cookie)
- Forum-style article layout (two-column, monochrome)
- Console tray at the bottom of every page with `/help`, `nav`, `clear`, `echo`
- Sticky header showing "ONLINE" status and node location
- Footer disclaimer: "NOT EVERYTHING ON THE INTERNET IS REAL. THESE USERS ARE NOT REAL."

---

## Personas

All articles are written as forum conversations between **fictional sock-puppet personas**. The full roster is defined in `personas/personas.json` — handles, titles, bios, signatures, post rates, and usage roles. That file is the single source of truth.

Each persona has a profile page at `/personas/<handle>/` with their bio, join date, and post count.

### Post Counts

Post counts are **calculated dynamically** at build time as `post_rate × days_since(join_date)`. They climb naturally each day.

### Persona Usage Rules

- Any persona can post **multiple times** in the same thread (rebuttals, clarifications, jokes)
- Threads can use **as few personas as makes sense** — a heated debate between just ffiltus and hype_cycle is fine
- Choose personas that fit the topic tone (see `role` field in personas.json):
  - Technical debates → hype_cycle, cobol_kid, kernel_panic
  - Futurist takes → ne0n_sage
  - Security angles → xss_princess
  - Comic relief → segfault_dad, sudo_rm_rf, vibecoder
  - Infrastructure reality checks → raid_zero
  - Rationalist / EA → pascal
  - Neuroscience / BCI → wetware
  - OSS maintainer struggles → bus_factor
  - Product / stakeholder perspective → backlog_groomer
  - Junior dev perspective → imposter_syndrome
  - Narrative steering → ffiltus (use his admin badge sparingly — it loses impact if overused)

---

## Writing Articles as Forum Threads

### Article Format

Each article is a markdown file with standard frontmatter followed by `forum_post()` macro calls:

```
---
title: "Hot take: reconciliation loops > event-driven everything, and I have receipts"
date: 2026-07-17
tags: [infrastructure, DevOps, Kubernetes]
description: "Short summary shown in thread list and SEO."
---

# Title

*A heated thread in the **#channel-name** channel.*

---

{{ forum_post('kernel_panic', '2026-07-17 08:30', '
Post body here. Keep it short — 2-4 paragraphs.
Use **bold**, *italic*, `code`, and [links](url) normally.
Use bullet lists for comparisons or lists.
') }}

{{ forum_post('cobol_kid', '2026-07-17 08:38', '
Counterpoint here.
') }}

{{ forum_post('kernel_panic', '2026-07-17 08:42', '
Rebuttal with a reply quote from cobol_kid.
', quote='cobol_kid') }}

{{ forum_post('ffiltus', '2026-07-17 09:20', '
Wrap up with a summary and close the thread.
Thread closed. — ffiltus
') }}
```

### Macro Reference

```
{{ forum_post(handle, timestamp, body, sig=True, quote='') }}
```

- `handle` — persona handle from personas.json
- `timestamp` — display string (use `2026-07-17 14:23` format)
- `body` — post content (markdown — rendered via Python `markdown` library with fenced_code, tables, codehilite, nl2br, footnotes extensions)
- `sig` — optional, default True. Set `sig=False` to hide signature on a specific post
- `quote` — optional, default empty. A persona handle to quote. The macro automatically extracts a snippet from that persona's post and renders it as a reply block (`>`) above the post body. Use `quote='handle'` to quote their most recent post, or `quote='handle:N'` to quote their Nth post (0-indexed) when they've posted multiple times in the thread.

### Escaping Apostrophes

The body text is passed as a single-quoted Jinja2 string. Any apostrophe inside the body **must** be escaped as `\'` or the build will fail with a macro syntax error.

```markdown
{{ forum_post('cobol_kid', '2026-07-17 10:22', '
Don\'t get me started on YAML.  It\'s not configuration — it\'s a hostage negotiation with your indent level.
') }}
```

Common contractions to watch for: `it's`, `don't`, `doesn't`, `isn't`, `can't`, `won't`, `that's`, `I'm`, `you're`, `we've`, `they're`, `let's`, `I've`, `you've`, `I'd`, `you'd`, `it'll`. Every one of these needs the backslash.

This does **not** apply to the frontmatter title or description — only to text inside `forum_post()` body strings.

### Writing Tips

- **Keep posts short** — 2-4 paragraphs max. Think forum comment, not blog post
- **No tables** — use bullet lists or narrative instead. Tables feel fake in forum convos
- **Natural language** — contractions, sentence fragments, interruptions, typos are fine
- **Vary post length** — some posts are one-line zingers, others are thoughtful 3-paragraph takes
- **Personas can post multiple times** — let them rebut, clarify, or joke
- **ffiltus closes threads** — his admin interjection should summarize the discussion and add the author's intended takeaway. End with "Thread closed. — ffiltus"
- **Markdown is supported** in post bodies: bold, italic, links, code, bullet lists, numbered lists, fenced code blocks, blockquotes. Everything gets rendered properly.
- **Use `quote` for replies** — when a persona is directly responding to another's point, pass their handle as the `quote` parameter (e.g. `quote='cobol_kid'`). The macro extracts a snippet from that persona's most recent post automatically. This creates visual threading and enables parallel conversations where multiple personas argue different sub-threads simultaneously.

### Title Conventions

Article titles should sound like forum thread titles, not blog headlines. More conversational:

- ✅ "What agentic CLI are you actually using day-to-day?"
- ✅ "Hot take: reconciliation loops > event-driven everything, and I have receipts"
- ✅ "Configuration as Code is a lie and I'm tired of pretending it's not"
- ❌ "A Comprehensive Guide to Agentic CLIs"
- ❌ "The Case for Reconciliation Loops in Modern Infrastructure"

### Persona Writing Styles

Each persona has a distinct voice that should be reflected in their posts (see `tagline` and `catchphrase` fields in personas.json for quick reference). Key patterns:

| Persona | Style Guide |
|---|---|
| **ne0n_sage** | Enthusiastic! Loves exclamation marks! Words like "incredible," "amazing," "revolutionary." Asks rhetorical questions. Optimistic tone. |
| **hype_cycle** | Acerbic, sarcastic, cutting. Dry humor. "I'm sure that will work great in production." Dismissive of hype. Backs up skepticism with data. |
| **cobol_kid** | Boomer ellipsis everywhere... Double space after every sentence. RANDOM CAPITALIZATION for emphasis. Misuses emojis. References "his day." Condescending but sometimes right. |
| **kernel_panic** | Practical, no-nonsense, data-driven. Concrete metrics and timeframes. "I've been running X for Y months." Explains things simply. The voice of reason. |
| **xss_princess** | Sharp, technical, precise. Focuses on edge cases and attack surfaces. Uses technical jargon accurately. "Let me audit that." Blunt about security issues. |
| **vibecoder** | ALL LOWERCASE. Misspells things. Stream of consciousness. Uses emojis. Claims to build things fast but nothing works. Dunning-Kruger personified. |
| **oldschool_phreak** | Cryptic, philosophical. References 80s/90s tech. Zen-like aphorisms. Short, punchy, wise. |
| **sudo_rm_rf** | Random CAPITALIZATION. Lots of question marks??? Confused rambling. "wait so if I..." "pls help." Follows tutorials exactly and breaks everything. |
| **segfault_dad** | Dad jokes. Punctuation that sets up the punchline. No real technical contribution. Replies are always groaners. |
| **raid_zero** | Overly detailed rambling about hardware specs. Parenthetical asides about his basement rack. "You could just self-host that..." Always mentions the electricity bill. |
| **pascal** | Calibrated, evidence-driven. "Let me steelman that." References expected utility, priors, Bayesian reasoning. Pedantic but rigorous. |
| **wetware** | Technical depth on neuroscience. Corrects sloppy analogies. "Actually, the synapse is the better analog because..." Compares biological and artificial architectures. |
| **bus_factor** | Exhausted, bitter, relatable. "That's not a bug, that's a feature request with entitlement." 300 open issues. Patreon makes $12/month. |
| **backlog_groomer** | Corporate jargon deployed with self-awareness. "Can we take this offline and align on scope?" Translates between eng and business. |
| **imposter_syndrome** | Eager, confused, trying hard. "Wait, you're not supposed to do it that way?" Googles basic concepts. Asks the questions everyone else is afraid to ask. |
| **ffiltus** | Authoritative, concise, measured. Short sentences. No wasted words. Summarizes the thread impartially then adds the author's intended takeaway. Ends with "Thread closed. — ffiltus" |

### Writing Tips

## Daily Automated Articles

See `DAILY_ARTICLES.md` for the full guide. These are filler threads generated by a cron agent that react to the previous day's tech news. They keep the site feeling alive between hand-crafted articles.

Key differences from hand-crafted articles:
- Generated automatically, once per day, by an LLM agent
- 4-6 posts, quick takes, no deep resolution
- Tagged `daily`, live in `docs/blog/daily/`
- ffiltus posts a brief neutral summary (no "Thread closed")
- Topic sourced from HN, Reddit, tech publications

## Site Features

### Boot Sequence

A CRT terminal boot animation plays on first page load per tab session. Shows:
- Memory check, kernel load, service start
- Network connect to FFILT.US BBS
- Auth (SYSOP level)
- Fades to reveal content

Subsequent navigations within the same tab skip the animation via a `bbs_booted` session cookie. New tab = new boot.

### Header

Sticky BBS header showing:
- Site name ("SUTLIFF BBS v1.0")
- Status indicator ("● ONLINE")
- User info ("USER: REED [SYSOP]")
- Node location ("COLUMBUS, OH")
- Navigation menu: Read, Opinions, Tutorials, Tags, Users, About

### Homepage Thread List

The homepage renders a forum-style thread list fetched from `/assets/articles.json` (generated at build time). Shows:
- **UNREAD** section — threads you haven't clicked (green, bold, ▶ icon, blinking [NEW] badge)
- **READ** section — threads you've visited (dimmed, ● icon)
- Click a thread → marks it read in `bbs_read` cookie → navigates to article

### Console Tray

Fixed terminal bar at the bottom of every page:
- Command prompt: `ffilt.us:~$`
- **Link interception** — clicking any article link types `nav <slug>` in the tray before navigating
- **Commands**: `/help`, `nav <path>`, `clear`, `echo`
- Command history via Arrow Up/Down

### Forum Post Layout

Classic two-column vBulletin/phpBB style:
- **Left column** (150px): avatar, username, title, post count, joined date
- **Right column**: timestamp, post body, signature
- **Monochrome** — no per-user colors, all terminal green
- **Responsive**: stacks vertically on mobile (avatar + username inline)

### Footer

- Server info (baud rate, connection status)
- Copyright
- ⚠ NOT EVERYTHING ON THE INTERNET IS REAL. THESE USERS ARE NOT REAL.

---

## Build Pipeline

The build runs via GitHub Actions on every push to `main`:

```
npm run build:ts        # esbuild: src/ts/* → docs/assets/js/main.js
npm run build:css       # postcss: src/css/* → docs/assets/theme.css
npm run build:articles  # python3: docs/blog/**/*.md → docs/assets/articles.json
npm run build:site      # mkdocs build → site/
                     # (requires mkdocs — runs in CI)
swa deploy site/        # Deploy to Azure Static Web Apps
```

### articles.json

Generated at build time by `scripts/generate-articles-json.py`. Scans `docs/blog/` for markdown files, parses frontmatter, extracts thread info, and writes the latest 50 articles as JSON.

Each entry includes: title, slug, date, tags, description, starter persona, post count, category.

The homepage JS fetches this on load and renders the thread list.

---

## Content Organization

### Published Articles

`docs/blog/` — organized by category:
- `docs/blog/` — default blog posts (flat)
- `docs/blog/opinions/` — opinion pieces
- `docs/blog/tutorials/` — tutorials
- `docs/blog/daily/` — automated daily current-events threads (see `DAILY_ARTICLES.md`)

### Drafts / Archive

`drafts/` — works in progress (not published)
`archived/` — articles that need to be rewritten as forum threads before republishing

### Static Assets

- `docs/assets/theme.css` — built CSS
- `docs/assets/js/main.js` — built JS
- `docs/assets/articles.json` — article metadata (build-time generated)
- `docs/assets/*.svg`, `.png` — logo, icons

### Source

- `src/ts/*.ts` — TypeScript sources (esbuild bundles to main.js)
- `src/css/*.css` — CSS sources (postcss bundles to theme.css)
- `theme/partials/*.html` — MkDocs theme overrides (header, footer, nav, toc)
- `main.py` — mkdocs-macros plugin (defines `forum_post()`, `persona_profile()` macros)
- `hooks/scheduled_posts.py` — future-dated post handling
- `personas/personas.json` — persona data (bios, signatures, rates)
- `scripts/generate-articles-json.py` — article metadata JSON generator

### Nav Menu Links

| Key | Label | Path |
|---|---|---|
| R | Read | `/` |
| O | Opinions | `/blog/opinions/` |
| T | Tutorials | `/blog/tutorials/` |
| G | Tags | `/tags/` |
| U | Users | `/personas/` |
| A | About | `/resume/` |
| RSS | RSS Feed | `/feed_rss_created.xml` |
