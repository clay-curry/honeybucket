output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.gateway.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.gateway.public_ip
}

output "ssm_start_session_command" {
  description = "Command to start an SSM session"
  value       = "aws ssm start-session --target ${aws_instance.gateway.id} --region ${var.region}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.baseline.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security group ID for the gateway host"
  value       = aws_security_group.gateway.id
}
