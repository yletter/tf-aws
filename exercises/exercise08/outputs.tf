output "domain_fqdn" {
  value = local.domain_name
}

output "domain_netbios" {
  value = local.domain_netbios_name
}

output "domain_computer_ou" {
  value = local.domain_computer_ou
}

output "windows_instance_public_ip" {
  value = aws_instance.server.public_ip
}

#CAUTION - doing this for demo purposes only
output "windows_admin_password" {
  value     = rsadecrypt(aws_instance.server.password_data, file("${aws_key_pair.key_pair.key_name}.pem"))
  sensitive = true
}

#CAUTION - doing this for demo purposes only
output "domain_admin_password" {
  value     = random_password.ad_admin_password.result
  sensitive = true
}

