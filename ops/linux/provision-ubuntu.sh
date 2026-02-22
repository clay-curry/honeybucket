#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "This script is intended for Ubuntu hosts. Detected: ${ID:-unknown}"
    exit 1
  fi
else
  echo "Cannot detect OS type"
  exit 1
fi

INSTALL_TAILSCALE="${INSTALL_TAILSCALE:-1}"
OPENCLAW_USER="${OPENCLAW_USER:-openclaw}"
OPENCLAW_HOME="${OPENCLAW_HOME:-/var/lib/openclaw}"
OPENCLAW_ETC="${OPENCLAW_ETC:-/etc/openclaw}"
OPENCLAW_LOG_DIR="${OPENCLAW_LOG_DIR:-/var/log/openclaw}"

apt update && apt -y upgrade
apt install -y curl ca-certificates gnupg jq ufw fail2ban git unzip tar restic

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

node --version
npm --version

if ! getent group "${OPENCLAW_USER}" >/dev/null 2>&1; then
  groupadd --system "${OPENCLAW_USER}"
fi

if ! id -u "${OPENCLAW_USER}" >/dev/null 2>&1; then
  useradd --system --create-home --home-dir "${OPENCLAW_HOME}" --shell /usr/sbin/nologin --gid "${OPENCLAW_USER}" "${OPENCLAW_USER}"
fi

mkdir -p "${OPENCLAW_ETC}" "${OPENCLAW_HOME}" "${OPENCLAW_HOME}/.openclaw" "${OPENCLAW_LOG_DIR}" /tmp/openclaw
chown -R "${OPENCLAW_USER}:${OPENCLAW_USER}" "${OPENCLAW_HOME}" "${OPENCLAW_LOG_DIR}" /tmp/openclaw
chmod 750 "${OPENCLAW_ETC}" "${OPENCLAW_HOME}" "${OPENCLAW_LOG_DIR}"
chmod 770 /tmp/openclaw

ufw --force default deny incoming
ufw --force default allow outgoing
ufw --force allow OpenSSH
ufw --force enable
ufw status verbose

if [[ "${INSTALL_TAILSCALE}" == "1" ]]; then
  curl -fsSL https://tailscale.com/install.sh | sh
  echo "Tailscale installed. Run: sudo tailscale up"
fi

echo "Provisioning complete. Next: bash ops/linux/install-openclaw-mvp.sh"
