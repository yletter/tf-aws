output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "ec2_security_group_id" {
  description = "The security group ID of the EC2 instance"
  value       = aws_security_group.ec2.id
}

output "iam_role_name" {
  description = "The IAM role name for EC2 SSM access"
  value       = aws_iam_role.ec2_ssm_role.name
}

output "ssm_endpoint_id" {
  description = "The ID of the SSM VPC endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ec2_messages_endpoint_id" {
  description = "The ID of the EC2 Messages VPC endpoint"
  value       = aws_vpc_endpoint.ec2_messages.id
}

output "ssm_messages_endpoint_id" {
  description = "The ID of the SSM Messages VPC endpoint"
  value       = aws_vpc_endpoint.ssm_messages.id
}

output "ssm_login_command" {
  description = "Command to login to EC2 instance via SSM"
  value       = "aws ssm start-session --target ${aws_instance.main.id} --region ${var.aws_region}"
}
