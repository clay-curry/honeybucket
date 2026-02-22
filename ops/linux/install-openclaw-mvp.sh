#!/usr/bin/env bash
set -euo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required (22+)"
  exit 1
fi

node_major="$(node -p "process.versions.node.split('.')[0]")"
if (( node_major < 22 )); then
  echo "Node.js 22+ is required. Found: $(node --version)"
  exit 1
fi

curl -fsSL https://openclaw.ai/install.sh | bash

if ! command -v openclaw >/dev/null 2>&1; then
  echo "openclaw command not found after install"
  exit 1
fi

openclaw onboard --install-daemon
openclaw gateway status
openclaw health --json || true
openclaw channels status --probe || true

echo "MVP install complete. Next steps:"
echo "  openclaw dashboard"
echo "  openclaw security audit"
echo "  openclaw channels status --probe"
