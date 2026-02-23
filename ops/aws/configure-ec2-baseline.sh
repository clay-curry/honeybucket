#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/terraform"
RUNTIME_TFVARS="${TF_DIR}/runtime.auto.tfvars"

ACTION=""
PROJECT_NAME="${PROJECT_NAME:-honeybucket}"
REGION="${REGION:-us-east-1}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.small}"
VPC_CIDR="${VPC_CIDR:-10.42.0.0/16}"
SUBNET_CIDR="${SUBNET_CIDR:-10.42.10.0/24}"
AWS_PROFILE_NAME="${AWS_PROFILE:-}"
AUTO_APPROVE=0

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") --action <plan|apply|destroy> [options]

Options:
  --action <plan|apply|destroy>   Required action.
  --project <name>                Project/resource prefix (default: honeybucket).
  --region <aws-region>           AWS region (default: us-east-1).
  --instance-type <type>          EC2 instance type (default: t3.small).
  --vpc-cidr <cidr>               VPC CIDR (default: 10.42.0.0/16).
  --subnet-cidr <cidr>            Public subnet CIDR (default: 10.42.10.0/24).
  --aws-profile <profile>         Optional AWS profile name.
  --auto-approve                  Skip confirmation for apply/destroy.
  -h, --help                      Show this help message.

Examples:
  $(basename "$0") --action plan
  $(basename "$0") --action apply --project honeybucket --region us-east-1 --auto-approve
  $(basename "$0") --action destroy --aws-profile prod
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --action)
      ACTION="$2"
      shift 2
      ;;
    --project)
      PROJECT_NAME="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --instance-type)
      INSTANCE_TYPE="$2"
      shift 2
      ;;
    --vpc-cidr)
      VPC_CIDR="$2"
      shift 2
      ;;
    --subnet-cidr)
      SUBNET_CIDR="$2"
      shift 2
      ;;
    --aws-profile)
      AWS_PROFILE_NAME="$2"
      shift 2
      ;;
    --auto-approve)
      AUTO_APPROVE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${ACTION}" ]]; then
  echo "Error: --action is required"
  usage
  exit 1
fi

case "${ACTION}" in
  plan|apply|destroy)
    ;;
  *)
    echo "Error: --action must be one of: plan, apply, destroy"
    exit 1
    ;;
esac

if ! command -v terraform >/dev/null 2>&1; then
  echo "Error: terraform is required"
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: aws CLI is required"
  exit 1
fi

if [[ -n "${AWS_PROFILE_NAME}" ]]; then
  export AWS_PROFILE="${AWS_PROFILE_NAME}"
fi

load_aws_login_credentials() {
  # Keep explicitly provided credentials intact.
  if [[ -n "${AWS_ACCESS_KEY_ID:-}" && -n "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    return 0
  fi

  local export_cmd=(aws configure export-credentials --format env)
  if [[ -n "${AWS_PROFILE:-}" ]]; then
    export_cmd+=(--profile "${AWS_PROFILE}")
  fi

  local exported_credentials=""
  if exported_credentials="$("${export_cmd[@]}" 2>/dev/null)" && [[ -n "${exported_credentials}" ]]; then
    # The AWS CLI emits trusted `export KEY=VALUE` lines for the selected profile.
    eval "${exported_credentials}"
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
    if [[ -n "${AWS_PROFILE:-}" ]]; then
      echo "Loaded AWS session credentials for profile ${AWS_PROFILE}"
    else
      echo "Loaded AWS session credentials from default profile"
    fi
  fi
}

load_aws_login_credentials

export TF_IN_AUTOMATION=1
export AWS_SDK_LOAD_CONFIG=1

if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "Error: AWS credentials are not configured or not valid"
  echo "Hint: run 'aws login' and retry."
  exit 1
fi

cat > "${RUNTIME_TFVARS}" <<EOF_TFVARS
project_name  = "${PROJECT_NAME}"
region        = "${REGION}"
instance_type = "${INSTANCE_TYPE}"
vpc_cidr      = "${VPC_CIDR}"
subnet_cidr   = "${SUBNET_CIDR}"

tags = {
  environment = "production"
  stack       = "ec2-baseline"
}
EOF_TFVARS

echo "Wrote ${RUNTIME_TFVARS}"

terraform -chdir="${TF_DIR}" init -input=false

case "${ACTION}" in
  plan)
    terraform -chdir="${TF_DIR}" plan \
      -input=false \
      -var-file="${RUNTIME_TFVARS}" \
      -out="${TF_DIR}/tfplan"
    ;;
  apply)
    terraform -chdir="${TF_DIR}" plan \
      -input=false \
      -var-file="${RUNTIME_TFVARS}" \
      -out="${TF_DIR}/tfplan"

    if [[ "${AUTO_APPROVE}" -eq 1 ]]; then
      terraform -chdir="${TF_DIR}" apply -input=false -auto-approve "${TF_DIR}/tfplan"
    else
      terraform -chdir="${TF_DIR}" apply -input=false "${TF_DIR}/tfplan"
    fi
    ;;
  destroy)
    if [[ "${AUTO_APPROVE}" -eq 1 ]]; then
      terraform -chdir="${TF_DIR}" destroy -input=false -auto-approve -var-file="${RUNTIME_TFVARS}"
    else
      terraform -chdir="${TF_DIR}" destroy -input=false -var-file="${RUNTIME_TFVARS}"
    fi
    ;;
esac

echo "Completed action: ${ACTION}"
