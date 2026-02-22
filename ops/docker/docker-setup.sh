#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${SCRIPT_DIR}/state" "${SCRIPT_DIR}/logs" "${SCRIPT_DIR}/config"

if [[ ! -f "${SCRIPT_DIR}/.env" ]]; then
  cp "${SCRIPT_DIR}/.env.example" "${SCRIPT_DIR}/.env"
  echo "Created ${SCRIPT_DIR}/.env; fill in real secret values before starting containers."
fi

if [[ ! -f "${SCRIPT_DIR}/config/openclaw.json" ]]; then
  cp "${SCRIPT_DIR}/../templates/openclaw.json.template" "${SCRIPT_DIR}/config/openclaw.json"
  sed -i.bak 's/__OPENCLAW_GATEWAY_TOKEN__/REPLACE_WITH_LONG_RANDOM_VALUE/' "${SCRIPT_DIR}/config/openclaw.json"
  rm -f "${SCRIPT_DIR}/config/openclaw.json.bak"
  echo "Created ${SCRIPT_DIR}/config/openclaw.json"
fi

echo "Docker setup complete. Next:"
echo "  cd ${SCRIPT_DIR}"
echo "  docker compose up -d openclaw-gateway"
echo "  docker compose run --rm openclaw-cli dashboard --no-open"
