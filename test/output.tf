output "private_key" {
  value = module.linux-vm.private_key
  sensitive = true
}