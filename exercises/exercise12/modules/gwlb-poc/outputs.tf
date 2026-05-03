output "app_instance_public_ip" {
  value       = aws_instance.app.public_ip
  description = "The public IP of the application server"
}

output "security_instance_public_ip" {
  value       = aws_instance.ssecurity.public_ip
  description = "The public IP of the security instance (for SSH and validation)"
}
