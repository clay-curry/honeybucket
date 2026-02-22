#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <snapshot-id|latest> <target-dir>"
  exit 1
fi

SNAPSHOT_ID="$1"
TARGET_DIR="$2"

if ! command -v restic >/dev/null 2>&1; then
  echo "restic not found"
  exit 1
fi

if [[ -z "${RESTIC_REPOSITORY:-}" ]]; then
  echo "RESTIC_REPOSITORY is not set"
  exit 1
fi

if [[ -z "${RESTIC_PASSWORD_FILE:-}" && -z "${RESTIC_PASSWORD:-}" ]]; then
  echo "RESTIC_PASSWORD_FILE or RESTIC_PASSWORD must be set"
  exit 1
fi

mkdir -p "${TARGET_DIR}"
restic restore "${SNAPSHOT_ID}" --target "${TARGET_DIR}"

echo "Restore completed into ${TARGET_DIR}"
