# Fumadocs Presentation Layer Plan

## Goal

Create a documentation presentation layer for the existing `docs/` content using Fumadocs, without changing the current docs authoring workflow.

## Current-state summary

- Source content already exists in `docs/` as Markdown plus two CSV trackers.
- Content is structured into three logical groups:
  - Core docs (root of `docs/`)
  - Architecture docs (`docs/architecture/`)
  - Operations docs (`docs/operations/`)
- Markdown uses:
  - GFM tables
  - Code fences (mostly `bash`)
  - Mermaid diagrams (`mermaid` fences in architecture docs)

## Success criteria

1. All Markdown files in `docs/` are published as navigable pages.
2. Mermaid, tables, and code blocks render correctly.
3. CSV trackers are visible in the site (either rendered as tables or linked as downloadable artifacts).
4. Sidebar/IA mirrors the existing folder structure with predictable ordering.
5. Site build is repeatable in CI and deployable to a static or SSR host.

## Architecture and information design

### Content model

- Keep `docs/` as the single source of truth.
- Add only minimal metadata needed for docs UX:
  - `title`
  - `description` (optional)
  - `order` (optional)
- Avoid duplicating docs into a second content directory.

### Proposed site IA

- `/`:
  - Honeybucket docs landing page
- `/docs`:
  - Technical Runbook
  - Project Charter
  - Month 1 Roadmap
  - Workflow Playbooks
- `/docs/architecture`:
  - High-Level Design
  - Low-Level Design
  - Architecture Decisions
  - Brainstorm Question Bank
- `/docs/operations`:
  - Production Gateway Runbook
  - Host Provisioning Checklist
  - Secrets and Env Policy
  - Validation and Go-Live Checklist
- `/docs/trackers`:
  - Month-1 Deliverables (from CSV)
  - Project Charter Tracker (from CSV)

## Implementation phases

## Phase 1: Scaffold Fumadocs app

1. Create a docs app (recommended path: `site/`).
2. Install and configure Fumadocs per official starter pattern.
3. Set app metadata/branding (`Honeybucket`, favicon from `assets/honeybucket.png`).
4. Add baseline docs layout, sidebar, and content routes.

## Phase 2: Connect existing content from `docs/`

1. Configure content loading to point to repository `docs/`.
2. Define route slugs that preserve existing structure.
3. Add explicit ordering for sidebar groups/pages.
4. Add frontmatter only where necessary for ordering and display.

## Phase 3: Rendering support and UX polish

1. Enable GFM table support for all current tables.
2. Enable Mermaid rendering for architecture diagrams.
3. Ensure syntax highlighting for shell/code blocks.
4. Turn on per-page table of contents for long runbooks.
5. Add previous/next navigation and breadcrumbs.

## Phase 4: CSV tracker strategy

1. Choose rendering approach:
   - Option A: Convert CSV to Markdown/MDX tables during build.
   - Option B: Keep CSV files and render interactive tables from parsed data.
2. Implement `/docs/trackers` pages using the chosen approach.
3. Add download links to raw CSV for portability.

## Phase 5: Quality gates and CI

1. Add checks:
   - Typecheck/lint
   - Build validation
   - Internal link validation
2. Add smoke-test checklist:
   - Open 3 representative pages (runbook, architecture, operations)
   - Verify Mermaid renders
   - Verify tracker pages render
3. Add CI workflow to run checks on push/PR.

## Phase 6: Deploy and operate

1. Choose deployment target (Cloudflare Pages, Vercel, or equivalent).
2. Add deployment config/environment variables.
3. Publish preview deployments for PRs.
4. Publish production docs site.

## Task breakdown (execution-ready)

1. Scaffold `site/` with Next.js + Fumadocs.
2. Wire Fumadocs source to `../docs`.
3. Create landing page and global nav.
4. Build sidebar groups for root/architecture/operations/trackers.
5. Add Markdown features (GFM + Mermaid + code highlighting).
6. Normalize page metadata (frontmatter only where needed).
7. Implement CSV presentation pages.
8. Add docs search (local or provider-backed).
9. Add CI checks (lint/type/build/links).
10. Deploy preview + production.

## Risks and mitigations

- Risk: Mermaid rendering mismatch or plugin conflicts.
  - Mitigation: Validate Mermaid in two existing architecture files first before broad rollout.
- Risk: CSV formatting drift over time.
  - Mitigation: Add schema/header validation in build step for both CSV files.
- Risk: Broken links after route normalization.
  - Mitigation: Add automated link check in CI and route regression smoke tests.
- Risk: Docs metadata churn.
  - Mitigation: Keep metadata minimal and infer defaults from file names/headings.

## Suggested implementation order

1. Phases 1-2 in one PR (scaffold + content wiring).
2. Phase 3 in second PR (rendering + UX).
3. Phase 4 in third PR (CSV tracker pages).
4. Phases 5-6 in final PR (CI + deploy).

