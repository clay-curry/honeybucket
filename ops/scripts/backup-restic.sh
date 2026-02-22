#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${OPENCLAW_LOG_DIR:-/var/log/openclaw}"
BACKUP_LOG="${LOG_DIR}/backup-restic.log"
mkdir -p "${LOG_DIR}"
touch "${BACKUP_LOG}"

emit_alert() {
  local level="$1"
  local message="$2"
  local now
  now="$(date -Iseconds)"

  logger -t openclaw-ops "[${level}] ${message}"

  if [[ -n "${OPENCLAW_ALERT_WEBHOOK_URL:-}" ]]; then
    if command -v jq >/dev/null 2>&1; then
      local payload
      payload="$(jq -nc --arg level "${level}" --arg message "${message}" --arg ts "${now}" '{level:$level,message:$message,timestamp:$ts,service:"openclaw-backup"}')"
      curl -fsS -m 10 -H 'content-type: application/json' -d "${payload}" "${OPENCLAW_ALERT_WEBHOOK_URL}" >/dev/null || true
    else
      curl -fsS -m 10 -H 'content-type: application/json' -d "{\"level\":\"${level}\",\"message\":\"${message}\",\"timestamp\":\"${now}\"}" "${OPENCLAW_ALERT_WEBHOOK_URL}" >/dev/null || true
    fi
  fi
}

if ! command -v restic >/dev/null 2>&1; then
  emit_alert "critical" "restic is not installed"
  exit 2
fi

if [[ -z "${RESTIC_REPOSITORY:-}" ]]; then
  emit_alert "critical" "RESTIC_REPOSITORY is not set"
  exit 2
fi

if [[ -z "${RESTIC_PASSWORD_FILE:-}" && -z "${RESTIC_PASSWORD:-}" ]]; then
  emit_alert "critical" "RESTIC_PASSWORD_FILE or RESTIC_PASSWORD must be set"
  exit 2
fi

OPENCLAW_ETC="${OPENCLAW_ETC:-/etc/openclaw}"
OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-/var/lib/openclaw/.openclaw}"

backup_paths=("${OPENCLAW_ETC}" "${OPENCLAW_STATE_DIR}" "/etc/systemd/system/openclaw-gateway.service")
existing_paths=()

for path in "${backup_paths[@]}"; do
  if [[ -e "${path}" ]]; then
    existing_paths+=("${path}")
  fi
done

if (( ${#existing_paths[@]} == 0 )); then
  emit_alert "critical" "no backup paths found"
  exit 2
fi

now="$(date -Iseconds)"
printf '%s backup start\n' "${now}" >>"${BACKUP_LOG}"

if ! restic snapshots >>"${BACKUP_LOG}" 2>&1; then
  restic init >>"${BACKUP_LOG}" 2>&1 || {
    emit_alert "critical" "restic init failed"
    exit 2
  }
fi

if restic backup "${existing_paths[@]}" --tag openclaw --host "$(hostname -s)" >>"${BACKUP_LOG}" 2>&1; then
  printf '%s backup complete\n' "$(date -Iseconds)" >>"${BACKUP_LOG}"
else
  emit_alert "critical" "restic backup failed"
  exit 2
fi

if [[ "${RESTIC_PRUNE_ON_BACKUP:-0}" == "1" ]]; then
  if ! restic forget --keep-daily 14 --keep-weekly 8 --keep-monthly 6 --prune >>"${BACKUP_LOG}" 2>&1; then
    emit_alert "warning" "restic prune failed"
  fi
fi

exit 0
