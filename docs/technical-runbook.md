---
title: Honeybucket Technical Runbook (OpenClaw)
---

# Honeybucket Technical Runbook (OpenClaw)

This runbook is designed for one operator and one primary assistant account.

For production host deployment automation, use:

- `docs/operations/production-gateway-runbook.md`
- `ops/README.md`

## 1) Environment prerequisites

- OS: macOS or Linux (Windows via WSL also works)
- Node.js: 22.11.0+ recommended
- Access: terminal access with permission to install global tooling
- Secrets ready:
  - LLM provider API key (OpenAI/Anthropic/Gemini)
  - Optional web search key (`OPENCLAW_WEBSEARCH_API_KEY`)
  - Messaging channel credentials (if required by your channel)

## 2) Install OpenClaw CLI and daemon

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
openclaw onboard --install-daemon
openclaw gateway status
```

Expected outcome:
- OpenClaw command available from shell
- Local gateway installed and running

## 3) Connect UI and channel

```bash
openclaw dashboard
openclaw channel login
```

Expected outcome:
- Dashboard opens and shows your gateway
- At least one channel is authenticated

## 4) Configure assistant safety and pairing

Use pairing so only authorized accounts can issue assistant commands.

```bash
openclaw pair <your_handle>
openclaw pairs
```

For pairing operations:

```bash
openclaw pair-message <messageId> approve
openclaw pair-message <messageId> reject
openclaw pair-message <messageId> blacklist
```

Audit approval queue (if enabled):

```bash
openclaw audit list
openclaw audit approve <auditId>
openclaw audit reject <auditId>
```

## 5) Baseline configuration

Set the following defaults in your OpenClaw configuration before exposing the assistant broadly:

- `pairingMode`: start with `all` (or stricter)
- `approvalMode`: use `code` or `all` during week 1-2
- `allowedCommands`: least privilege (avoid wide wildcards early)
- `allowedPaths`: narrow to your working directories
- Channel auto-authorization: keep disabled until stable

Optional web search:

```bash
export OPENCLAW_WEBSEARCH_API_KEY="<your_key>"
```

## 6) Create Honeybucket workspace conventions

- Create a dedicated working directory for assistant-managed tasks.
- Add a project-level `AGENTS.md` defining:
  - command allowlist
  - protected paths
  - escalation rules for risky actions
- Start a `memory.md` for user preferences, recurring tasks, and known good outputs.

## 7) Smoke-test checklist

Run these tests before active use:

1. Health: gateway status command returns healthy.
2. Message loop: send a simple request and get a response in channel.
3. File action: assistant creates and edits a safe test file.
4. Safety gate: a privileged command is blocked or requires approval.
5. Audit trail: pending approval appears in audit list when expected.

## 8) Weekly operational routine

- Monday: check gateway health and channel connection.
- Midweek: review approvals, denials, and failures.
- Friday: update OpenClaw CLI and restart daemon if needed.

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
openclaw gateway restart
openclaw gateway status
```

## 9) Exit criteria for setup completion

Technical setup is complete when:

1. Gateway has 7 consecutive days without unplanned downtime.
2. One channel can execute assistant tasks end-to-end.
3. Pairing/approval controls are actively enforced.
4. At least 3 high-value routines run successfully (e.g., daily summary, file triage, reminder workflow).

## 10) Production automation entrypoints

Linux VPS (preferred):

```bash
sudo bash ops/linux/provision-ubuntu.sh
bash ops/linux/install-openclaw-mvp.sh
sudo bash ops/linux/harden-openclaw-systemd.sh
sudo /usr/local/libexec/openclaw/validate-go-live.sh
```

Local alternatives:

- macOS: `bash ops/macos/bootstrap-local.sh`
- Docker: `bash ops/docker/docker-setup.sh`
