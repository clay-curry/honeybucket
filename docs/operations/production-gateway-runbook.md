# Production Gateway Runbook (Host-Based OpenClaw)

Scope: single operator, one primary channel, host-based deployment (Linux VPS preferred).

## 1) Recommended architecture

1. Core runtime: OpenClaw gateway on Ubuntu VPS 24.04 under dedicated `openclaw` user.
2. Access: loopback-only gateway (`127.0.0.1:18789`) accessed through SSH tunnel or Tailscale.
3. Security: pairing enabled, mention gating enabled, dangerous tools denied, workspace-only filesystem.
4. Observability: `systemd` service + timer-driven health/security/restart/backup checks.
5. Adjunct: Cloudflare Workers/Pages allowed only for non-core dashboard/report fan-out.

### Minimum viable setup path

1. `sudo bash ops/linux/provision-ubuntu.sh`
2. `bash ops/linux/install-openclaw-mvp.sh`
3. Pair and verify:
   - `openclaw dashboard`
   - `openclaw channels status --probe`
   - `openclaw security audit`

### Production-hardening path

1. Fill secrets in `/etc/openclaw/openclaw.env` (from `ops/templates/openclaw.env.example`).
2. `sudo bash ops/linux/harden-openclaw-systemd.sh`
3. Validate:
   - `sudo /usr/local/libexec/openclaw/validate-go-live.sh`
   - `sudo systemctl list-timers --all | grep openclaw`

## 2) Week-by-week implementation plan (4 weeks)

1. Week 1 (Feb 23-Mar 1, 2026): provision VPS, install OpenClaw daemon, connect one channel, enforce pairing.
2. Week 2 (Mar 2-Mar 8, 2026): apply hardened config/systemd, lock tool/path policy, add SSH tunnel/Tailscale-only access.
3. Week 3 (Mar 9-Mar 15, 2026): enable timers/alerts, backup + restore drills, rollback scripting and version pin.
4. Week 4 (Mar 16-Mar 22, 2026): 7-day burn-in, metric tracking, go-live signoff, frozen config.

## 3) Host provisioning checklist (OS/packages/firewall/users)

1. OS baseline:
   - `sudo apt update && sudo apt -y upgrade`
   - `sudo apt install -y curl ca-certificates gnupg jq ufw fail2ban git unzip tar restic`
2. Node 22+:
   - `curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -`
   - `sudo apt install -y nodejs`
3. Service account/directories:
   - `sudo useradd --system --create-home --home-dir /var/lib/openclaw --shell /usr/sbin/nologin openclaw`
   - `sudo mkdir -p /etc/openclaw /var/lib/openclaw/.openclaw /var/log/openclaw /tmp/openclaw`
4. Firewall:
   - `sudo ufw default deny incoming`
   - `sudo ufw default allow outgoing`
   - `sudo ufw allow OpenSSH && sudo ufw enable`
5. Optional remote mesh:
   - `curl -fsSL https://tailscale.com/install.sh | sh`
   - `sudo tailscale up`

## 4) Gateway install/run configuration (systemd)

1. Install MVP gateway:
   - `curl -fsSL https://openclaw.ai/install.sh | bash`
   - `openclaw onboard --install-daemon`
2. Hardened service install:
   - `sudo bash ops/linux/harden-openclaw-systemd.sh`
3. Service checks:
   - `sudo systemctl status openclaw-gateway.service --no-pager`
   - `openclaw gateway status --json`
   - `openclaw health --json`

## 5) Secrets and env vars

See `docs/operations/secrets-and-env-policy.md` for required vs optional variables, storage locations, and rotation intervals.

## 6) Observability and alerting

1. Health checks: `openclaw-healthcheck.timer` (every minute).
2. Security checks: `openclaw-security-audit.timer` (every 6 hours).
3. Credential/provider checks: `openclaw-credential-check.timer` (daily).
4. Restart-rate checks: `openclaw-restart-watch.timer` (hourly).
5. Backup checks: `openclaw-backup.timer` (daily at 02:00 local).
6. Logs:
   - `journalctl -u openclaw-gateway`
   - `/var/log/openclaw/*.log`

## 7) Backup, rollback, and DR

1. Daily backup: `sudo /usr/local/libexec/openclaw/backup-restic.sh`
2. Restore drill: `RESTIC_REPOSITORY=... RESTIC_PASSWORD_FILE=... sudo /usr/local/libexec/openclaw/restore-restic.sh latest /tmp/openclaw-restore`
3. Rollback: `sudo /usr/local/libexec/openclaw/rollback-openclaw.sh <known_good_version>`
4. DR target:
   - RPO: 24 hours
   - RTO: 2 hours

## 8) Validation test plan and go-live checklist

1. Run automated gate:
   - `sudo /usr/local/libexec/openclaw/validate-go-live.sh`
2. Execute manual checklist in `docs/operations/validation-and-go-live-checklist.md`.
3. Require 7 consecutive days with zero critical incidents.

## 9) Risks, assumptions, and open decisions

1. Risks:
   - Channel auth expiry.
   - Policy misconfiguration widening blast radius.
   - Single-host failure domain.
2. Assumptions:
   - Single operator and one channel in month 1.
   - Ubuntu VPS is primary target.
   - Cloudflare remains adjunct-only.
3. Open decisions:
   - Warm standby host in month 2.
   - Immediate vs post-burn-in secret manager migration.
   - Optional Cloudflare report fan-out after stability.

## Prioritized task list for this week

1. Run `ops/linux/provision-ubuntu.sh` on the VPS.
2. Run `ops/linux/install-openclaw-mvp.sh` and connect channel.
3. Create `/etc/openclaw/openclaw.env` from template with real secrets.
4. Run `ops/linux/harden-openclaw-systemd.sh`.
5. Validate with `validate-go-live.sh` and resolve all failing checks.
6. Configure restic repository and run first backup + restore drill.
7. Start burn-in log and track critical incidents daily.
