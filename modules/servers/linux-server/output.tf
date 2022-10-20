output "ec2_dns_name" {
  value = aws_instance.test_server.public_dns
}

output "ec2_ip" {
  value = aws_instance.test_server.public_ip
}

output "private_key" {
  value = tls_private_key._.private_key_pem
  sensitive = true
}