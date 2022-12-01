module "ansible-sandbox-vpc" {
  source = "../modules/vpc"
  environment = "test"
  app-name = "ansible-sandbox"
}



module "windows-vm" {
    source = "../modules/servers/windows-server"
    environment = "test"
    server_name = "ansible-sandbox-windows"
    ec2_sg_id = module.ansible-sandbox-vpc.ec2_sg_id
    subnet_id1 = module.ansible-sandbox-vpc.subnet_id1
}

module "linux-vm" {
    source = "../modules/servers/linux-server"
    environment = "test"
    server_name = "ansible-sandbox-linux"
    ec2_sg_id = module.ansible-sandbox-vpc.ec2_sg_id
    subnet_id1 = module.ansible-sandbox-vpc.subnet_id1
    windows_private_ip = module.windows-vm.private_ip
    windows_password = module.windows-vm.windows_password
}