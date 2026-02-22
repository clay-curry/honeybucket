#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <openclaw-version>"
  exit 1
fi

TARGET_VERSION="$1"
OPENCLAW_ETC="${OPENCLAW_ETC:-/etc/openclaw}"
OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-/var/lib/openclaw/.openclaw}"
BACKUP_ROOT="${BACKUP_ROOT:-/var/backups/openclaw}"
TS="$(date +%Y%m%d-%H%M%S)"
ROLLBACK_DIR="${BACKUP_ROOT}/rollback-${TS}"

mkdir -p "${ROLLBACK_DIR}"

if command -v openclaw >/dev/null 2>&1; then
  openclaw --version >"${ROLLBACK_DIR}/openclaw-version-before.txt" 2>&1 || true
fi

tar -czf "${ROLLBACK_DIR}/openclaw-config.tgz" "${OPENCLAW_ETC}" "${OPENCLAW_STATE_DIR}" /etc/systemd/system/openclaw-gateway.service

echo "Installing openclaw@${TARGET_VERSION}"
npm install -g "openclaw@${TARGET_VERSION}"

systemctl daemon-reload
systemctl restart openclaw-gateway.service
sleep 3

if systemctl is-active --quiet openclaw-gateway.service && openclaw gateway status >/dev/null 2>&1; then
  echo "Rollback completed. Backup snapshot: ${ROLLBACK_DIR}"
  exit 0
fi

echo "Rollback attempted but service did not become healthy. Restore files from ${ROLLBACK_DIR}"
exit 2
