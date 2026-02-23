# Honeybucket Docs Site

This app is the Fumadocs presentation layer for repository content in `../docs`.

## Commands

```bash
npm install
npm run dev
```

The site is available at [http://localhost:3000](http://localhost:3000).

## Validation

```bash
npm run types:check
npm run lint
npm run build
```

## Content model

- Markdown and MDX source: `../docs`
- Sidebar and ordering: `../docs/meta.json` (+ nested `meta.json`)
- CSV tracker views: `../docs/trackers/*.mdx` via `site/components/trackers/csv-table.tsx`

## Environment

- Optional: `NEXT_PUBLIC_SITE_URL` for canonical metadata base URL.
