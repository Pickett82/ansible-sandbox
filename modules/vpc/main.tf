module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.app-name}-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Application = "${var.app-name}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "ec2-sg" {
  name        = "${var.environment}-${var.app-name}-ec2-sg"
  description = "${var.environment} EC2 Security Group for ${var.app-name}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Telnet"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Http"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    description = "local rdp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  ingress {
    from_port = 5986
    to_port = 5986
    protocol = "tcp"
    description = "Winrm"
    self = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Application = "${var.app-name}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "lb-sg" {
  name = "${var.environment}-${var.app-name}-lb-sg"
  description = "${var.environment} load balancer group for ${var.app-name}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Application = "${var.app-name}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "${var.environment}-${var.app-name}-rds-sg"
  description = "${var.environment} RDS Security Group for ${var.app-name}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "MySQL"
    security_groups = [aws_security_group.ec2-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Application = "${var.app-name}"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
