#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required on macOS"
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  brew install node@22
fi

node_major="$(node -p "process.versions.node.split('.')[0]")"
if (( node_major < 22 )); then
  echo "Upgrading Node to 22+"
  brew install node@22
fi

npm install -g openclaw@latest
openclaw --version
openclaw onboard --install-daemon
openclaw gateway status

echo "Local macOS setup complete"
