---
tags:
    - Tutorial
    - MkDocs
    - PostCSS
    - esbuild
    - TypeScript
description: |
    How to build a custom MkDocs theme with PostCSS for CSS and esbuild for
    TypeScript — complete with custom icons, dark mode, and a build pipeline.

---

# Building a Personal MkDocs Theme with PostCSS + esbuild

MkDocs with the Material theme is already a beautiful documentation platform out of the box. But if you're using it as a personal blog — like this one — you quickly run into its limits. The stock colour palette doesn't feel like *you*. The typography is generic. The icons are shared with every other Material-themed site on the internet.

The solution isn't to abandon MkDocs. It's to build a custom theme layer on top of it — with PostCSS for maintainable, modular CSS and esbuild for TypeScript that actually does something useful. Here's how.

## Why PostCSS Instead of Sass or Tailwind?

If you're coming from the React world, you probably reach for Tailwind by default. For a documentation site, though, Tailwind is overkill. You aren't building dozens of component variants; you're setting a colour palette, some typography, and a handful of interactive elements.

PostCSS with `postcss-import` gives you the CSS variable architecture and file-splitting that makes large stylesheets maintainable, without adding a new syntax you have to teach your editors and contributors. The pipeline is dead simple:

```
src/css/
├── _variables.css      ← colour palette, fonts, spacing scale
├── _animations.css     ← keyframes, transitions
├── _components.css     ← custom element overrides
└── main.css            ← entry point — just @import statements
```

The entry point is exactly three lines:

```css
@import "_variables.css";
@import "_animations.css";
@import "_components.css";
```

That's it. `postcss-import` inlines them, `autoprefixer` adds vendor prefixes, and `cssnano` (production only) minifies the output. Every piece lives in its own file, each smaller than a hundred lines, and you can add new partials without touching the build configuration.

### The Config

```js
// postcss.config.js
module.exports = {
  plugins: [
    require('postcss-import'),
    require('autoprefixer'),
    ...(process.env.NODE_ENV === 'production' ? [require('cssnano')] : []),
  ],
};
```

Three plugins, zero configuration beyond that. If you've ever wrestled with a Tailwind config that runs longer than your actual CSS, this is a breath of fresh air.

## esbuild: TypeScript Without the Ceremony

For JavaScript, esbuild is the obvious choice. It's fast — benchmarked at 10–100× faster than Webpack for equivalent bundles — and it has no configuration file. A single npm script is all you need:

```json
{
  "scripts": {
    "build:ts": "esbuild src/ts/main.ts --bundle --outfile=docs/assets/js/main.js"
  }
}
```

The blog's TypeScript source is organised into focused modules:

```
src/ts/
├── main.ts          ← entry point, imports everything
├── theme.ts         ← dark/light mode toggle with localStorage persistence
├── hero.ts          ← home page hero animation
├── progress.ts      ← reading-progress bar
├── confetti.ts      ← celebratory confetti on certain pages
├── ripple.ts        ← Material-style click ripple effect
└── console-easter.ts← dev console easter egg
```

Each module is under 80 lines, independently testable, and imported into `main.ts` with standard ES module syntax. esbuild bundles them into a single production file with tree-shaking and minification built in — no plugins required.

### The Watch Mode Trick

During development, run both watchers in parallel:

```bash
npm run dev:ts   &  # esbuild --watch
npm run dev:css  &  # postcss --watch
npm run dev:site     # mkdocs serve
```

MkDocs's livereload picks up the rebuilt assets automatically. The whole cycle — edit CSS, save, see result — takes under 200 milliseconds. You spend more time deciding what colour the link should be than waiting for the build.

## Custom Icons Without a Designer

Material for MkDocs supports custom icons via the `theme/.icons/custom/` directory. Any SVG file you place there becomes available as `custom/icon-name` in your templates and frontmatter.

The blog uses this for brands that Material doesn't ship — Azure, Azure Functions, UiPath, OpenAPI, AsyncAPI, and MkDocs itself. Each SVG is a single path with `viewBox="0 0 24 24"`, roughly 300 bytes, drawn as a filled monoline icon.

To use one, add it to your `mkdocs.yml`:

```yaml
theme:
  icon:
    tag:
      mkdocs: custom/mkdocs
      openapi: custom/openapi
```

Then reference it in frontmatter tags:

```yaml
tags: [MkDocs, Tutorial]
```

The tag badge renders with your custom icon, not the generic Material tag symbol. It's a small touch, but it makes the site feel like it belongs to you.

## Theme Overrides Without Forking Material

The `theme/` directory in your project root is MkDocs's custom override directory. Any file you place at the same relative path as a Material template file overrides it. You don't fork the theme — you just patch the bits you need.

The blog currently overrides two things:

```
theme/
├── main.html                 ← injects custom <head> elements and post-body scripts
├── partials/
│   └── source-file.html      ← custom source link display
└── .icons/
    └── custom/               ← custom SVG icons (see above)
```

The `main.html` override extends the base template and adds blocks for the custom CSS and JS that esbuild and PostCSS produce:

```html
{% extends "base.html" %}

{% block extrahead %}
  <link rel="stylesheet" href="{{ config.site_url }}assets/theme.css" />
{% endblock %}

{% block scripts %}
  {{ super() }}
  <script src="{{ config.site_url }}assets/js/main.js" defer></script>
{% endblock %}
```

No need to rebuild the entire theme — just extend what exists and layer your additions on top.

## The Full Build Pipeline

Here's the complete npm script that ties it all together for production:

```json
{
  "scripts": {
    "build:ts": "esbuild src/ts/main.ts --bundle --outfile=docs/assets/js/main.js",
    "build:css": "postcss src/css/main.css -o docs/assets/theme.css --env production",
    "build:site": "mkdocs build",
    "build": "npm run build:ts && npm run build:css && npm run build:site"
  }
}
```

Run `npm run build` and you get:

1. **TypeScript** → bundled, minified, single `main.js`
2. **CSS** → imported, autoprefixed, minified `theme.css`
3. **Site** → full MkDocs build with RSS, tags, search indexes, and scheduled posts

The whole thing takes about two seconds. On Azure Static Web Apps, the GitHub Action runs this build, and the deployment is live in under a minute.

## What You Get

A custom MkDocs theme built with PostCSS and esbuild gives you:

- **Full control over appearance** — colours, typography, spacing, animations
- **Modular, maintainable code** — CSS partials and TypeScript modules, not monolithic spaghetti
- **Sub-second rebuilds** — PostCSS and esbuild are fast enough that watch-mode feels instant
- **Zero lock-in** — the pipeline is three npm packages and a handful of scripts. If you outgrow MkDocs, the CSS and TS move with you
- **A site that actually looks like yours** — not another Material cookie-cutter

The barrier to entry is absurdly low. If you already have a MkDocs site, adding PostCSS and esbuild to it takes about fifteen minutes. The hardest part is deciding what colour you want your links to be.

And honestly? That's exactly the kind of problem you should be spending your time on.
