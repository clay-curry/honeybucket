# Secrets and Env Policy

## Required and optional variables

| Variable | Required | Purpose | Storage method | Rotation policy |
|---|---|---|---|---|
| `OPENCLAW_GATEWAY_TOKEN` | Yes | Gateway auth for control/API access | `/etc/openclaw/openclaw.env` (`640`, `root:openclaw`) | Every 90 days and immediately on exposure |
| `ANTHROPIC_API_KEY` (or chosen provider key) | Yes | LLM inference | `/etc/openclaw/openclaw.env` + external encrypted source | Every 60-90 days and on auth anomaly |
| `TELEGRAM_BOT_TOKEN` | Yes | Primary channel connectivity | `/etc/openclaw/openclaw.env` | Every 90 days or provider recommendation |
| `OPENCLAW_HOME` | Recommended | Service runtime home | `/etc/openclaw/openclaw.env` | Change only during controlled migration |
| `OPENCLAW_STATE_DIR` | Recommended | Runtime state path | `/etc/openclaw/openclaw.env` | Change only with backup + migration |
| `OPENCLAW_CONFIG_PATH` | Recommended | Deterministic config path | `/etc/openclaw/openclaw.env` | Change only with controlled rollout |
| `OPENCLAW_WEBSEARCH_API_KEY` | Optional | Enrichment/search workflows | `/etc/openclaw/openclaw.env` or secret manager | Every 90 days if enabled |
| `OPENCLAW_LOG_LEVEL` | Optional | Runtime verbosity | `/etc/openclaw/openclaw.env` temporary override | Reset after incident handling |
| `RESTIC_REPOSITORY` | Required for backup | Backup target location | `/etc/openclaw/openclaw.env` | Rotate backend credentials per provider |
| `RESTIC_PASSWORD_FILE` | Required for backup | Encryption key file path | root-owned file outside repo | Rotate every 90 days |

## Storage rules

1. Never commit secrets to this repository.
2. Keep `/etc/openclaw/openclaw.env` ownership `root:openclaw` and mode `640`.
3. Keep restic password file ownership `root:openclaw` and mode `640` or stricter.
4. Keep an encrypted source-of-truth copy in a secret manager (SOPS, Vault, or 1Password CLI).

## Rotation procedure

1. Update value in source-of-truth secret manager.
2. Update `/etc/openclaw/openclaw.env`.
3. Restart service: `sudo systemctl restart openclaw-gateway.service`.
4. Validate:
   - `openclaw models status --check`
   - `openclaw health --json`
   - `openclaw channels status --probe`
5. Record rotation date in ops log.
