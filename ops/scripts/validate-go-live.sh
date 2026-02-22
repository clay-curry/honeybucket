#!/usr/bin/env bash
set -euo pipefail

checks_failed=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  checks_failed=$((checks_failed + 1))
}

run_check() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "${name}"
  else
    fail "${name}"
  fi
}

run_check "service active" systemctl is-active --quiet openclaw-gateway.service
run_check "gateway status" openclaw gateway status --json
run_check "gateway health" openclaw health --json
run_check "channel probe" openclaw channels status --probe
run_check "security audit command" openclaw security audit

if command -v ss >/dev/null 2>&1; then
  listener_lines="$(ss -ltn '( sport = :18789 )' | awk 'NR>1 {print $4}')"
  if [[ -z "${listener_lines}" ]]; then
    fail "port 18789 listener exists"
  else
    non_loopback_lines="$(printf '%s\n' "${listener_lines}" | grep -Ev '^(127\.0\.0\.1|\[::1\]):18789$' || true)"
    if [[ -n "${non_loopback_lines}" ]]; then
      fail "gateway bind is loopback-only"
    else
      pass "gateway bind is loopback-only"
    fi
  fi
else
  echo "WARN: ss command not found, skipping bind verification"
fi

run_check "healthcheck timer active" systemctl is-enabled --quiet openclaw-healthcheck.timer
run_check "security audit timer active" systemctl is-enabled --quiet openclaw-security-audit.timer
run_check "credential check timer active" systemctl is-enabled --quiet openclaw-credential-check.timer
run_check "restart watch timer active" systemctl is-enabled --quiet openclaw-restart-watch.timer
run_check "backup timer active" systemctl is-enabled --quiet openclaw-backup.timer

if (( checks_failed > 0 )); then
  echo "Validation failed with ${checks_failed} failing check(s)."
  exit 1
fi

echo "Validation passed."
exit 0
