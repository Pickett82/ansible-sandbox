resource "aws_instance" "test_server" {
    
    ami           = "ami-06672d07f62285d1d" 
    instance_type = "t2.micro"
    key_name      = aws_key_pair._.key_name

    vpc_security_group_ids = ["${var.ec2_sg_id}"]
    subnet_id              = "${var.subnet_id1}"

    user_data = <<-EOF
      #!/bin/bash
      touch /home/ec2-user/test.ini
      sudo amazon-linux-extras install python3.8 -y
      sudo yum update -y
      pip3.8 install ansible
      pip3.8 install pywinrm
      #pip3 install ansible
      #pip3 install pywinrm
      EOF

    tags = {
      "Name" = "${var.server_name}"
    }

    provisioner "file" {
      source      = "${path.module}/../../../ansible/ansible.cfg"
      destination = "/home/ec2-user/ansible.cfg"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = tls_private_key._.private_key_pem
        host        = self.public_ip
      }
    }

    provisioner "file" {
      content     = templatefile("${path.module}/inventory.tftpl", { test_ip = var.windows_private_ip, test_password = var.windows_password })
      destination = "/home/ec2-user/inventory.ini"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = tls_private_key._.private_key_pem
        host        = self.public_ip
      }
    }
}

resource "tls_private_key" "_" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "_" {
  public_key = tls_private_key._.public_key_openssh
  tags = {
    "Application" = "ansible-sandbox"
  }
}