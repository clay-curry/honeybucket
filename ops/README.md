# OpenClaw Gateway Operations Kit

This directory implements the host-based production plan for Honeybucket's OpenClaw gateway.

## Paths

- `linux/`: Ubuntu VPS provisioning and hardening scripts (primary path)
- `macos/`: local macOS alternative bootstrap
- `docker/`: Docker alternative for local/portable runs
- `scripts/`: health checks, security audits, backups, rollback, validation
- `templates/`: config and `systemd` unit templates

## Minimum viable setup path (Linux VPS)

1. `sudo bash ops/linux/provision-ubuntu.sh`
2. `bash ops/linux/install-openclaw-mvp.sh`
3. Pair and connect channel:
   - `openclaw dashboard`
   - `openclaw channels status --probe`
4. `openclaw security audit`

## Production-hardening path (Linux VPS)

1. Ensure `ops/templates/openclaw.env.example` values are copied into `/etc/openclaw/openclaw.env`.
2. `sudo bash ops/linux/harden-openclaw-systemd.sh`
3. Verify:
   - `sudo systemctl status openclaw-gateway.service --no-pager`
   - `openclaw gateway status --json`
   - `openclaw channels status --probe`

## Operational routines

- Every minute: `openclaw-healthcheck.timer`
- Every 6 hours: `openclaw-security-audit.timer`
- Daily at 03:00: `openclaw-credential-check.timer`
- Every hour: `openclaw-restart-watch.timer`
- Daily at 02:00: `openclaw-backup.timer`

## Safety notes

- Core gateway is host-based only; do not deploy runtime to Cloudflare Workers/Pages.
- Keep gateway binding loopback-only (`127.0.0.1`) and access via SSH tunnel or Tailscale.
- Use pairing and approval gates before enabling broad access.
