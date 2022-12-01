output "private_key" {
  value = module.linux-vm.private_key
  sensitive = true
}

output "linux_ec2_ip" {
  value = module.linux-vm.ec2_ip
}

output "windows_public_ip" {
  value = module.windows-vm.ec2_ip
}

output "windows_private_ip" {
  value = module.windows-vm.private_ip
}

output "windows_private_key" {
  value = module.windows-vm.private_key
  sensitive = true
}

output "windows_password" {
  value = module.windows-vm.windows_password
  sensitive = true
}