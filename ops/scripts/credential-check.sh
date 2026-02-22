#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${OPENCLAW_LOG_DIR:-/var/log/openclaw}"
CHECK_LOG="${LOG_DIR}/credential-check.log"
mkdir -p "${LOG_DIR}"
touch "${CHECK_LOG}"

emit_alert() {
  local level="$1"
  local message="$2"
  local now
  now="$(date -Iseconds)"

  logger -t openclaw-ops "[${level}] ${message}"

  if [[ -n "${OPENCLAW_ALERT_WEBHOOK_URL:-}" ]]; then
    if command -v jq >/dev/null 2>&1; then
      local payload
      payload="$(jq -nc --arg level "${level}" --arg message "${message}" --arg ts "${now}" '{level:$level,message:$message,timestamp:$ts,service:"openclaw-credential-check"}')"
      curl -fsS -m 10 -H 'content-type: application/json' -d "${payload}" "${OPENCLAW_ALERT_WEBHOOK_URL}" >/dev/null || true
    else
      curl -fsS -m 10 -H 'content-type: application/json' -d "{\"level\":\"${level}\",\"message\":\"${message}\",\"timestamp\":\"${now}\"}" "${OPENCLAW_ALERT_WEBHOOK_URL}" >/dev/null || true
    fi
  fi
}

if ! command -v openclaw >/dev/null 2>&1; then
  emit_alert "critical" "openclaw command not found for credential check"
  exit 2
fi

now="$(date -Iseconds)"
printf '%s credential check start\n' "${now}" >>"${CHECK_LOG}"

if openclaw models status --check >>"${CHECK_LOG}" 2>&1; then
  printf '%s credential check success\n' "$(date -Iseconds)" >>"${CHECK_LOG}"
  exit 0
fi

emit_alert "critical" "credential/provider check failed"
exit 2
