resource "aws_instance" "test_server" {
    
    ami           = "ami-06672d07f62285d1d" 
    instance_type = "t2.micro"
    key_name      = aws_key_pair._.key_name

    vpc_security_group_ids = ["${var.ec2_sg_id}"]
    subnet_id              = "${var.subnet_id1}"

    user_data = <<-EOF
      #!/bin/bash
      sudo amazon-linux-extras install ansible2
      EOF

    tags = {
      "Name" = "${var.server_name}"
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