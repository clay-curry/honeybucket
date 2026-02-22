# Honeybucket Architecture Decisions

Last updated: 2026-02-22

## Purpose

Track architecture decisions and unresolved design choices for the month-1 Honeybucket MVP. Every open item must include owner, dates, and a concrete next action.

## Decision register

| ID | Status | Topic | Decision or unresolved question | Owner | Date opened | Target decision date | Next action | Related docs |
|---|---|---|---|---|---|---|---|---|
| ADR-001 | Decided | External system modeling | Model OpenClaw, channel, providers, and integrations as interface contracts only. Do not design external internals. | Clay | 2026-02-22 | 2026-02-22 | Apply this boundary rule across HLD/LLD updates. | `docs/architecture/high-level-design.md` |
| ADR-002 | Decided | Month-1 channel scope | Operate with one primary messaging channel for month 1. | Clay | 2026-02-22 | 2026-02-22 | Revisit only after month-1 KPI review. | `docs/project-charter.md` |
| ADR-003 | Open | LLM provider selection | Which provider should be the default production path (OpenAI, Anthropic, or Gemini) for week-2 workflow stability? | Clay | 2026-02-22 | 2026-02-28 | Run a side-by-side benchmark on routine workflows and compare latency, cost, and output quality. | `docs/architecture/low-level-design.md` |
| ADR-004 | Open | Week-3 integration choice | Which single external integration should be prioritized for highest user value in month 1? | Clay | 2026-02-22 | 2026-03-05 | Rank candidate integrations by frequency of need and setup effort, then choose one. | `docs/month-1-roadmap.md` |
| ADR-005 | Open | Event storage backend | Should replay/event storage remain file-based for month 1 or move to SQLite for query reliability? | Clay | 2026-02-22 | 2026-03-08 | Run a one-week volume test and compare replay query speed and operational overhead. | `docs/architecture/low-level-design.md` |
| ADR-006 | Open | Approval tuning policy | What thresholds and command classes can safely move from approval-required to auto-allow after week-2 evidence? | Clay | 2026-02-22 | 2026-03-10 | Analyze approval queue outcomes and define safe auto-allow criteria with rollback rules. | `docs/technical-runbook.md` |
| ADR-007 | Deferred | Multi-channel expansion | When should Honeybucket support additional channels beyond the primary channel? | Clay | 2026-02-22 | 2026-03-22 | Reassess after month-1 retrospective and KPI review. | `docs/project-charter.md` |

## New decision template

Use this template for each new decision entry:

| ID | Status | Topic | Decision or unresolved question | Owner | Date opened | Target decision date | Next action | Related docs |
|---|---|---|---|---|---|---|---|---|
| ADR-XXX | Open | Topic name | Clear decision statement or question | Name | YYYY-MM-DD | YYYY-MM-DD | One concrete action | Path(s) |
