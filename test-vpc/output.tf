output "private_key" {
  value = tls_private_key._.private_key_pem
  sensitive = true
}
output "windows_public_ip" {
    value = aws_instance.windows-test-server.public_ip
}
output "windows_private_ip" {
    value = aws_instance.windows-test-server.private_ip
}
output "linux_public_ip" {
  value = aws_instance.test_server.public_ip
}


output "windows_password" {
  value = rsadecrypt(aws_instance.windows-test-server.password_data,tls_private_key._.private_key_pem)
  sensitive = true
}