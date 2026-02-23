#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
LAST_STATUS=0
LAST_OUTPUT=""

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $1"
  if [[ -n "${LAST_OUTPUT}" ]]; then
    echo "--- command output ---"
    printf '%s\n' "${LAST_OUTPUT}"
    echo "----------------------"
  fi
  exit 1
}

pass() {
  echo "PASS: $1"
}

run_and_capture() {
  local output_file="${TEST_ROOT}/command.out"

  set +e
  "$@" >"${output_file}" 2>&1
  LAST_STATUS=$?
  set -e

  LAST_OUTPUT="$(cat "${output_file}")"
}

assert_status() {
  local expected="$1"
  if [[ "${LAST_STATUS}" -ne "${expected}" ]]; then
    fail "expected exit status ${expected}, got ${LAST_STATUS}"
  fi
}

assert_contains() {
  local expected="$1"
  if [[ "${LAST_OUTPUT}" != *"${expected}"* ]]; then
    fail "expected output to contain: ${expected}"
  fi
}

assert_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "${expected}" "${file}"; then
    LAST_OUTPUT="$(cat "${file}")"
    fail "expected ${file} to contain: ${expected}"
  fi
}

test_shell_syntax() {
  while IFS= read -r file; do
    bash -n "${file}"
  done < <(find "${REPO_ROOT}/ops" -type f -name '*.sh' | sort)

  pass "all ops shell scripts parse"
}

test_configure_ec2_arg_validation() {
  local aws_tmp="${TEST_ROOT}/aws-arg-validation"
  cp -R "${REPO_ROOT}/ops/aws" "${aws_tmp}"

  local script="${aws_tmp}/configure-ec2-baseline.sh"

  run_and_capture "${script}"
  assert_status 1
  assert_contains "--action is required"

  run_and_capture "${script}" --action invalid
  assert_status 1
  assert_contains "--action must be one of"

  run_and_capture "${script}" --help
  assert_status 0
  assert_contains "Usage:"

  pass "configure-ec2 argument checks"
}

test_configure_ec2_plan_with_stubs() {
  local aws_tmp="${TEST_ROOT}/aws-plan"
  local stub_dir="${TEST_ROOT}/aws-stubs"

  cp -R "${REPO_ROOT}/ops/aws" "${aws_tmp}"
  mkdir -p "${stub_dir}"

  cat >"${stub_dir}/terraform" <<'STUB_TERRAFORM'
#!/usr/bin/env bash
set -euo pipefail
exit 0
STUB_TERRAFORM

  cat >"${stub_dir}/aws" <<'STUB_AWS'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "configure" && "${2:-}" == "export-credentials" ]]; then
  exit 0
fi

if [[ "${1:-}" == "sts" && "${2:-}" == "get-caller-identity" ]]; then
  exit 0
fi

exit 0
STUB_AWS

  chmod +x "${stub_dir}/terraform" "${stub_dir}/aws"

  run_and_capture env PATH="${stub_dir}:${PATH}" "${aws_tmp}/configure-ec2-baseline.sh" \
    --action plan \
    --project smoke-honeybucket \
    --region us-west-2 \
    --instance-type t3.micro \
    --vpc-cidr 10.52.0.0/16 \
    --subnet-cidr 10.52.10.0/24

  assert_status 0
  assert_contains "Completed action: plan"

  local tfvars="${aws_tmp}/terraform/runtime.auto.tfvars"
  [[ -f "${tfvars}" ]] || fail "expected ${tfvars} to be generated"

  assert_file_contains "${tfvars}" 'project_name  = "smoke-honeybucket"'
  assert_file_contains "${tfvars}" 'region        = "us-west-2"'
  assert_file_contains "${tfvars}" 'instance_type = "t3.micro"'

  pass "configure-ec2 plan flow with command stubs"
}

test_restore_restic_guards_and_success() {
  local script="${REPO_ROOT}/ops/scripts/restore-restic.sh"
  local stub_dir="${TEST_ROOT}/restic-stubs"
  local restic_log="${TEST_ROOT}/restic-calls.log"
  local target_dir="${TEST_ROOT}/restored-data"

  mkdir -p "${stub_dir}"

  cat >"${stub_dir}/restic" <<'STUB_RESTIC'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "${RESTIC_LOG}"
exit 0
STUB_RESTIC

  chmod +x "${stub_dir}/restic"

  run_and_capture env PATH="${stub_dir}:${PATH}" RESTIC_LOG="${restic_log}" "${script}" latest "${target_dir}"
  assert_status 1
  assert_contains "RESTIC_REPOSITORY is not set"

  run_and_capture env PATH="${stub_dir}:${PATH}" RESTIC_LOG="${restic_log}" RESTIC_REPOSITORY='s3://bucket/repo' "${script}" latest "${target_dir}"
  assert_status 1
  assert_contains "RESTIC_PASSWORD_FILE or RESTIC_PASSWORD must be set"

  run_and_capture env \
    PATH="${stub_dir}:${PATH}" \
    RESTIC_LOG="${restic_log}" \
    RESTIC_REPOSITORY='s3://bucket/repo' \
    RESTIC_PASSWORD='test-secret' \
    "${script}" latest "${target_dir}"

  assert_status 0
  assert_contains "Restore completed into ${target_dir}"
  [[ -d "${target_dir}" ]] || fail "expected restore target directory to exist"

  assert_file_contains "${restic_log}" "restore latest --target ${target_dir}"

  pass "restore-restic validation and happy-path command invocation"
}

test_validate_go_live_fails_closed_without_runtime() {
  local script="${REPO_ROOT}/ops/scripts/validate-go-live.sh"

  run_and_capture "${script}"
  assert_status 1
  assert_contains "Validation failed with"

  pass "validate-go-live fails closed when dependencies are unavailable"
}

main() {
  test_shell_syntax
  test_configure_ec2_arg_validation
  test_configure_ec2_plan_with_stubs
  test_restore_restic_guards_and_success
  test_validate_go_live_fails_closed_without_runtime

  echo "All ops smoke tests passed"
}

main "$@"
