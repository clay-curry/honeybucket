# AWS EC2 Baseline Provisioning (Terraform)

This package provisions a minimal EC2 baseline for Honeybucket in AWS:

- VPC (`10.42.0.0/16`)
- Public subnet (`10.42.10.0/24`) in one AZ
- Internet gateway and public routing
- Security group with no ingress (SSM-only) and allow-all egress
- EC2 IAM role + instance profile with:
  - `AmazonSSMManagedInstanceCore`
  - `CloudWatchAgentServerPolicy`
- Ubuntu 24.04 instance from SSM AMI parameter
- IMDSv2 required and encrypted gp3 root volume

## Files

- `configure-ec2-baseline.sh`: wrapper script for plan/apply/destroy.
- `terraform/`: Terraform configuration.

## Prerequisites

1. Terraform installed.
2. AWS CLI installed.
3. AWS credentials configured (`aws sts get-caller-identity` succeeds).

## Script interface

```bash
bash ops/aws/configure-ec2-baseline.sh \
  --action <plan|apply|destroy> \
  [--project honeybucket] \
  [--region us-east-1] \
  [--instance-type t3.small] \
  [--vpc-cidr 10.42.0.0/16] \
  [--subnet-cidr 10.42.10.0/24] \
  [--aws-profile <profile>] \
  [--auto-approve]
```

## Example usage

```bash
bash ops/aws/configure-ec2-baseline.sh --action plan
bash ops/aws/configure-ec2-baseline.sh --action apply --auto-approve
bash ops/aws/configure-ec2-baseline.sh --action destroy
```

## Outputs

After apply, Terraform outputs:

- `instance_id`
- `instance_public_ip`
- `ssm_start_session_command`
- `vpc_id`
- `subnet_id`
- `security_group_id`
