#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${OPENCLAW_LOG_DIR:-/var/log/openclaw}"
AUDIT_LOG="${LOG_DIR}/security-audit.log"
OUTPUT_JSON="${LOG_DIR}/security-audit-last.json"

mkdir -p "${LOG_DIR}"
touch "${AUDIT_LOG}"

emit_alert() {
  local level="$1"
  local message="$2"
  local now
  now="$(date -Iseconds)"

  logger -t openclaw-ops "[${level}] ${message}"

  if [[ -n "${OPENCLAW_ALERT_WEBHOOK_URL:-}" ]]; then
    if command -v jq >/dev/null 2>&1; then
      local payload
      payload="$(jq -nc --arg level "${level}" --arg message "${message}" --arg ts "${now}" '{level:$level,message:$message,timestamp:$ts,service:"openclaw-security"}')"
      curl -fsS -m 10 -H 'content-type: application/json' -d "${payload}" "${OPENCLAW_ALERT_WEBHOOK_URL}" >/dev/null || true
    else
      curl -fsS -m 10 -H 'content-type: application/json' -d "{\"level\":\"${level}\",\"message\":\"${message}\",\"timestamp\":\"${now}\"}" "${OPENCLAW_ALERT_WEBHOOK_URL}" >/dev/null || true
    fi
  fi
}

if ! command -v openclaw >/dev/null 2>&1; then
  emit_alert "critical" "openclaw command not found while running security audit"
  exit 2
fi

now="$(date -Iseconds)"
printf '%s running security audit\n' "${now}" >>"${AUDIT_LOG}"

if openclaw security audit --json >"${OUTPUT_JSON}" 2>>"${AUDIT_LOG}"; then
  :
elif openclaw security audit >"${OUTPUT_JSON}" 2>>"${AUDIT_LOG}"; then
  :
else
  emit_alert "critical" "openclaw security audit command failed"
  exit 2
fi

critical_count=0
high_count=0

if command -v jq >/dev/null 2>&1 && jq empty "${OUTPUT_JSON}" >/dev/null 2>&1; then
  critical_count="$(jq -r '[.. | objects | .severity? | strings | ascii_downcase | select(. == "critical")] | length' "${OUTPUT_JSON}")"
  high_count="$(jq -r '[.. | objects | .severity? | strings | ascii_downcase | select(. == "high")] | length' "${OUTPUT_JSON}")"
else
  critical_count="$(grep -Eic 'critical' "${OUTPUT_JSON}" || true)"
  high_count="$(grep -Eic 'high' "${OUTPUT_JSON}" || true)"
fi

printf '%s audit findings critical=%s high=%s\n' "${now}" "${critical_count}" "${high_count}" >>"${AUDIT_LOG}"

if (( critical_count > 0 )); then
  emit_alert "critical" "security audit found ${critical_count} critical finding(s)"
  exit 2
fi

if (( high_count > 0 )); then
  emit_alert "warning" "security audit found ${high_count} high finding(s)"
fi

exit 0
