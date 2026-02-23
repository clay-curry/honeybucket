# Honeybucket

Honeybucket is Clay's personal AI assistant built on OpenClaw.

This repository starts as a planning and execution workspace for the first 30 days (from February 22, 2026 to March 22, 2026).

## Project docs

- `docs/technical-runbook.md`: technical setup runbook for OpenClaw
- `docs/operations/production-gateway-runbook.md`: production host deployment runbook and cutover flow
- `docs/operations/host-provisioning-checklist.md`: Ubuntu VPS provisioning checklist
- `docs/operations/secrets-and-env-policy.md`: required env vars, storage, and rotation policy
- `docs/operations/validation-and-go-live-checklist.md`: validation tests and go-live criteria
- `docs/month-1-roadmap.md`: week-by-week build plan with effort estimates
- `docs/month-1-deliverables.csv`: importable tracker (Notion/Sheets/Jira)
- `docs/project-objectives.md`: month-1 PM charter (budget, objectives, success criteria, scope)
- `docs/project-objectives-tracker.csv`: charter tracker by workstream
- `docs/workflow-playbooks.md`: workflow specs and acceptance criteria
- `docs/architecture/brainstorm-question-bank.md`: structured question bank to drive HLD/LLD workshops
- `docs/architecture/high-level-design.md`: external-stakeholder HLD for month-1 Honeybucket MVP
- `docs/architecture/low-level-design.md`: implementation-level LLD with contracts, sequences, and ops hooks
- `docs/architecture/architecture-decisions.md`: architecture decision log with open items and next actions

## Planning workspace

- `plans/`: used for tracking draft plans toward milestone objectives
- `plans/weekly-status-template.md`: weekly RAG status report template (progress, risks, decisions, next-week plan)

## Operations automation

- `ops/linux/provision-ubuntu.sh`: baseline Ubuntu 24.04 provisioning (packages, Node 22, firewall, service account)
- `ops/linux/install-openclaw-mvp.sh`: minimum viable OpenClaw install and daemon bootstrap
- `ops/linux/harden-openclaw-systemd.sh`: hardened `systemd` service + timer setup
- `ops/scripts/`: health check, security audit, backup, restore, rollback, and go-live validation scripts
- `ops/templates/`: hardened gateway config and `systemd` unit templates
- `ops/macos/bootstrap-local.sh`: local macOS alternative bootstrap
- `ops/docker/`: Docker alternative (`docker-compose.yml`, Dockerfile, and setup script)
- `ops/aws/`: Terraform-based AWS EC2 baseline provisioning (`configure-ec2-baseline.sh`)
- `docker-setup.sh`: root-level wrapper for `ops/docker/docker-setup.sh`

## Suggested execution cadence

- Sunday planning: pick weekly goals and lock scope
- Daily async check-in: update `status` in `docs/month-1-deliverables.csv`
- Friday validation: demo outcomes vs acceptance criteria
- Sunday retro: adjust estimates for next week

## Success target for month 1

By March 22, 2026, Honeybucket should:

1. Run reliably as an OpenClaw gateway service.
2. Handle one primary messaging channel end-to-end.
3. Use safe pairing and approval controls.
4. Complete at least 10 real user tasks with >80% success.
