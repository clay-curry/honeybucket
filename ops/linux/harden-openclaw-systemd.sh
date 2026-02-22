#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TEMPLATE_DIR="${REPO_ROOT}/ops/templates"
SCRIPT_SRC_DIR="${REPO_ROOT}/ops/scripts"
SCRIPT_DST_DIR="/usr/local/libexec/openclaw"
SYSTEMD_DIR="/etc/systemd/system"

OPENCLAW_USER="${OPENCLAW_USER:-openclaw}"
OPENCLAW_GROUP="${OPENCLAW_GROUP:-openclaw}"
OPENCLAW_HOME="${OPENCLAW_HOME:-/var/lib/openclaw}"
OPENCLAW_ETC="${OPENCLAW_ETC:-/etc/openclaw}"
OPENCLAW_LOG_DIR="${OPENCLAW_LOG_DIR:-/var/log/openclaw}"
OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-${OPENCLAW_HOME}/.openclaw}"
ENABLE_TIMERS="${ENABLE_TIMERS:-1}"

OPENCLAW_BIN="${OPENCLAW_BIN:-$(command -v openclaw || true)}"
if [[ -z "${OPENCLAW_BIN}" ]]; then
  for candidate in /usr/local/bin/openclaw /usr/bin/openclaw; do
    if [[ -x "${candidate}" ]]; then
      OPENCLAW_BIN="${candidate}"
      break
    fi
  done
fi

if [[ -z "${OPENCLAW_BIN}" ]]; then
  echo "openclaw command not found. Install OpenClaw first."
  exit 1
fi

if ! getent group "${OPENCLAW_GROUP}" >/dev/null 2>&1; then
  groupadd --system "${OPENCLAW_GROUP}"
fi

if ! id -u "${OPENCLAW_USER}" >/dev/null 2>&1; then
  useradd --system --create-home --home-dir "${OPENCLAW_HOME}" --shell /usr/sbin/nologin --gid "${OPENCLAW_GROUP}" "${OPENCLAW_USER}"
fi

mkdir -p "${OPENCLAW_ETC}" "${OPENCLAW_HOME}" "${OPENCLAW_STATE_DIR}" "${OPENCLAW_LOG_DIR}" /tmp/openclaw "${SCRIPT_DST_DIR}"
chown -R "${OPENCLAW_USER}:${OPENCLAW_GROUP}" "${OPENCLAW_HOME}" "${OPENCLAW_STATE_DIR}" "${OPENCLAW_LOG_DIR}" /tmp/openclaw
chmod 750 "${OPENCLAW_ETC}" "${OPENCLAW_HOME}" "${OPENCLAW_LOG_DIR}"
chmod 770 /tmp/openclaw

ENV_FILE="${OPENCLAW_ETC}/openclaw.env"
CFG_FILE="${OPENCLAW_ETC}/openclaw.json"

if [[ ! -f "${ENV_FILE}" ]]; then
  install -m 640 -o root -g "${OPENCLAW_GROUP}" "${TEMPLATE_DIR}/openclaw.env.example" "${ENV_FILE}"
fi

gateway_token="$(grep -E '^OPENCLAW_GATEWAY_TOKEN=' "${ENV_FILE}" | cut -d= -f2- || true)"
if [[ -z "${gateway_token}" || "${gateway_token}" == "REPLACE_WITH_LONG_RANDOM_VALUE" ]]; then
  gateway_token="$(openssl rand -hex 32)"
  sed -i "s|^OPENCLAW_GATEWAY_TOKEN=.*$|OPENCLAW_GATEWAY_TOKEN=${gateway_token}|" "${ENV_FILE}"
fi

channel_token="$(grep -E '^TELEGRAM_BOT_TOKEN=' "${ENV_FILE}" | cut -d= -f2- || true)"
if [[ -z "${channel_token}" || "${channel_token}" == "REPLACE_ME" ]]; then
  echo "TELEGRAM_BOT_TOKEN is missing in ${ENV_FILE}. Set it before running hardening."
  exit 1
fi

provider_token="$(grep -E '^(ANTHROPIC_API_KEY|OPENAI_API_KEY|GEMINI_API_KEY)=' "${ENV_FILE}" | cut -d= -f2- | grep -Ev '^(|REPLACE_ME)$' | head -n 1 || true)"
if [[ -z "${provider_token}" ]]; then
  echo "One provider key is required (ANTHROPIC_API_KEY or OPENAI_API_KEY or GEMINI_API_KEY) in ${ENV_FILE}."
  exit 1
fi

if [[ ! -f "${CFG_FILE}" ]]; then
  install -m 640 -o root -g "${OPENCLAW_GROUP}" "${TEMPLATE_DIR}/openclaw.json.template" "${CFG_FILE}"
fi

escaped_token="$(printf '%s' "${gateway_token}" | sed 's/[\/&]/\\&/g')"
sed -i "s|__OPENCLAW_GATEWAY_TOKEN__|${escaped_token}|g" "${CFG_FILE}"

for script in health-check.sh security-audit.sh restart-watch.sh credential-check.sh backup-restic.sh restore-restic.sh rollback-openclaw.sh validate-go-live.sh; do
  install -m 750 -o root -g "${OPENCLAW_GROUP}" "${SCRIPT_SRC_DIR}/${script}" "${SCRIPT_DST_DIR}/${script}"
done

render_template() {
  local src="$1"
  local dst="$2"

  sed \
    -e "s|__OPENCLAW_USER__|${OPENCLAW_USER}|g" \
    -e "s|__OPENCLAW_GROUP__|${OPENCLAW_GROUP}|g" \
    -e "s|__OPENCLAW_HOME__|${OPENCLAW_HOME}|g" \
    -e "s|__OPENCLAW_ETC__|${OPENCLAW_ETC}|g" \
    -e "s|__OPENCLAW_LOG_DIR__|${OPENCLAW_LOG_DIR}|g" \
    -e "s|__OPENCLAW_BIN__|${OPENCLAW_BIN}|g" \
    -e "s|__OPS_SCRIPT_DIR__|${SCRIPT_DST_DIR}|g" \
    "${src}" >"${dst}"
}

render_template "${TEMPLATE_DIR}/openclaw-gateway.service.template" "${SYSTEMD_DIR}/openclaw-gateway.service"
render_template "${TEMPLATE_DIR}/openclaw-healthcheck.service.template" "${SYSTEMD_DIR}/openclaw-healthcheck.service"
render_template "${TEMPLATE_DIR}/openclaw-security-audit.service.template" "${SYSTEMD_DIR}/openclaw-security-audit.service"
render_template "${TEMPLATE_DIR}/openclaw-credential-check.service.template" "${SYSTEMD_DIR}/openclaw-credential-check.service"
render_template "${TEMPLATE_DIR}/openclaw-backup.service.template" "${SYSTEMD_DIR}/openclaw-backup.service"
render_template "${TEMPLATE_DIR}/openclaw-restart-watch.service.template" "${SYSTEMD_DIR}/openclaw-restart-watch.service"

install -m 644 "${TEMPLATE_DIR}/openclaw-healthcheck.timer" "${SYSTEMD_DIR}/openclaw-healthcheck.timer"
install -m 644 "${TEMPLATE_DIR}/openclaw-security-audit.timer" "${SYSTEMD_DIR}/openclaw-security-audit.timer"
install -m 644 "${TEMPLATE_DIR}/openclaw-credential-check.timer" "${SYSTEMD_DIR}/openclaw-credential-check.timer"
install -m 644 "${TEMPLATE_DIR}/openclaw-backup.timer" "${SYSTEMD_DIR}/openclaw-backup.timer"
install -m 644 "${TEMPLATE_DIR}/openclaw-restart-watch.timer" "${SYSTEMD_DIR}/openclaw-restart-watch.timer"

systemctl daemon-reload
systemctl enable --now openclaw-gateway.service

if [[ "${ENABLE_TIMERS}" == "1" ]]; then
  systemctl enable --now openclaw-healthcheck.timer
  systemctl enable --now openclaw-security-audit.timer
  systemctl enable --now openclaw-credential-check.timer
  systemctl enable --now openclaw-backup.timer
  systemctl enable --now openclaw-restart-watch.timer
fi

systemctl status openclaw-gateway.service --no-pager || true

echo "Hardening completed. Validate with:"
echo "  ${SCRIPT_DST_DIR}/validate-go-live.sh"
echo "  systemctl list-timers --all | grep openclaw"
