# Build commands

Build everything (CSS + TS + site):
```
npm run build
```

Watch CSS:
```
npm run dev:css
```

Serve locally:
```
npm run dev:site
```

# CSS

Source: `src/css/*.css` (PostCSS partials with @import)
Output: `docs/assets/theme.css` (minified)
Compiler: postcss-cli + autoprefixer + cssnano + postcss-import
Config: `postcss.config.js`

# TypeScript

Source: `src/ts/*.ts` (ES module imports/exports)
Output: `docs/assets/js/main.js` (bundled, single IIFE)
Compiler: esbuild (fast, handles TS natively)
Build step: `esbuild src/ts/main.ts --bundle --outfile=docs/assets/js/main.js`

The output is loaded via `extra_javascript` in `mkdocs.yml` as a plain `<script>` tag (no `type="module"` needed since esbuild bundles into an IIFE).
