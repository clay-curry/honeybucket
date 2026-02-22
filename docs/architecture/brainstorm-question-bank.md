# Honeybucket Architecture Brainstorm Question Bank

Last updated: 2026-02-22

## Purpose

Use this question bank to run structured architecture workshops for the month-1 Honeybucket MVP and produce decision-ready HLD and LLD documents.

## Session setup

- HLD workshop timebox: 60 minutes
- LLD workshop timebox: 90 minutes
- Required inputs:
  - `docs/project-charter.md`
  - `docs/month-1-roadmap.md`
  - `docs/workflow-playbooks.md`
  - `docs/technical-runbook.md`
- Required outputs:
  - `docs/architecture/high-level-design.md`
  - `docs/architecture/low-level-design.md`
  - `docs/architecture/architecture-decisions.md`

## Priority and format legend

- Priority tags:
  - `Must answer`: required to proceed with implementation planning
  - `Should answer`: expected for high-confidence execution
  - `Optional`: useful for scale or post-month-1 planning
- Required answer formats:
  - `table`: contract, matrix, or comparison table
  - `bullet`: concise listed statements
  - `diagram`: component/context/sequence view
  - `decision`: explicit decision statement with rationale

## HLD question bank (60-minute workshop)

| ID | Priority | Question | Required answer format | Target output section |
|---|---|---|---|---|
| HLD-01 | Must answer | What business and operational outcomes must Honeybucket hit by March 22, 2026? | bullet | Goals and success criteria |
| HLD-02 | Must answer | What is in scope and out of scope for month 1? | table | Scope boundaries |
| HLD-03 | Must answer | Which actors and external systems interact with Honeybucket, and where is the system boundary? | diagram | System context |
| HLD-04 | Must answer | What core components are required and what is each component responsible for? | table | Component model |
| HLD-05 | Must answer | What are the primary end-to-end flows (interactive task, approval path, scheduled report, replay)? | diagram | Primary flows |
| HLD-06 | Must answer | Which interfaces to external systems are required and what are the contract-level expectations? | table | External interface boundaries |
| HLD-07 | Must answer | What non-functional requirements are binding for security, reliability, and reporting? | table | NFR constraints |
| HLD-08 | Should answer | What are the top architecture risks and the first mitigation for each? | table | Risks and mitigations |
| HLD-09 | Should answer | What rollout sequence reduces risk while preserving month-1 delivery? | bullet | Rollout narrative |
| HLD-10 | Should answer | What observability surfaces are required for stakeholder visibility? | bullet | Operability summary |
| HLD-11 | Optional | Which assumptions are likely to change in month 2? | bullet | Assumptions |
| HLD-12 | Must answer | Which unresolved design choices must move to the architecture decision log? | decision | Open decisions |

## LLD question bank (90-minute workshop)

| ID | Priority | Question | Required answer format | Target output section |
|---|---|---|---|---|
| LLD-01 | Must answer | How does each LLD subsystem map to a parent HLD component? | table | Traceability matrix |
| LLD-02 | Must answer | What is the normalized inbound request contract for a user message? | table | Contract catalog |
| LLD-03 | Must answer | What is the policy decision contract (allow, deny, approval_required)? | table | Contract catalog |
| LLD-04 | Must answer | What is the workflow execution contract including status and completion metadata? | table | Contract catalog |
| LLD-05 | Must answer | What are timeout and retry rules per contract and error class? | table | Failure handling |
| LLD-06 | Must answer | What is the exact sequence for an interactive request through approval and completion? | diagram | Critical path sequences |
| LLD-07 | Must answer | What is the exact sequence for the daily trend report automation? | diagram | Critical path sequences |
| LLD-08 | Must answer | What state and data entities are needed, and what retention applies? | table | Data model |
| LLD-09 | Must answer | How are configuration and secrets loaded, validated, and rotated? | table | Config and secrets |
| LLD-10 | Should answer | What log and metric schema is needed for dashboard replay and incident review? | table | Observability hooks |
| LLD-11 | Must answer | How are failure modes handled for channel, provider, context, and integration dependencies? | table | Failure handling |
| LLD-12 | Should answer | What tests prove readiness for week-4 hardening? | bullet | Testability and acceptance |
| LLD-13 | Should answer | What runbook actions are required for degradation, rollback, and recovery? | bullet | Operations hooks |
| LLD-14 | Must answer | Which low-level unknowns remain open and who owns closure? | decision | Open decisions |

## Facilitation checklist

1. Start with `Must answer` items and defer lower-priority questions if time runs short.
2. Convert unresolved answers into entries in `docs/architecture/architecture-decisions.md` during the session.
3. Record assumptions explicitly; do not leave implied behavior in narrative text.
4. Keep external systems as interface contracts only; do not model external internals.
5. End each workshop with action owners and target dates for open items.
