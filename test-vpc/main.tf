data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

module "ansible-sandbox-ds-vpc" {
  source = "../modules/vpc"
  environment = "test"
  app-name = "ansible-sandbox-ds"
  ip4-cidr-block = "10.0.0.0/16"
}

module "ansible-sandbox-onprem-vpc" {
  source = "../modules/vpc"
  environment = "test"
  app-name = "ansible-sandbox-onprem"
  ip4-cidr-block = "10.100.0.0/16"
}

resource "aws_subnet" "ds-vpc-subnet01" {
  vpc_id     = module.ansible-sandbox-ds-vpc.vpc_id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "ansible-sandbox-ds-vpc-subnet01"
  }

}

resource "aws_subnet" "ds-vpc-subnet02" {
  vpc_id     = module.ansible-sandbox-ds-vpc.vpc_id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "ansible-sandbox-ds-vpc-subnet02"
  }

}

resource "aws_subnet" "onprem-vpc-subnet01" {
  vpc_id     = module.ansible-sandbox-onprem-vpc.vpc_id
  cidr_block = "10.100.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "ansible-sandbox-onprem-vpc-subnet01"
  }

}

resource "aws_subnet" "onprem-vpc-subnet02" {
  vpc_id     = module.ansible-sandbox-onprem-vpc.vpc_id
  cidr_block = "10.100.1.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "ansible-sandbox-onprem-vpc-subnet02"
  }

}

resource "aws_internet_gateway" "ds-vpc-igw" {
  vpc_id = module.ansible-sandbox-ds-vpc.vpc_id

  tags = {
    Name = "ansible-sandbox-ds-vpc-igw"
  }
}

resource "aws_internet_gateway" "onprem-vpc-igw" {
  vpc_id = module.ansible-sandbox-onprem-vpc.vpc_id

  tags = {
    Name = "ansible-sandbox-onprem-vpc-igw"
  }
}

resource "aws_vpc_peering_connection" "peering-connection" {
  vpc_id        = module.ansible-sandbox-ds-vpc.vpc_id
  peer_vpc_id   = module.ansible-sandbox-onprem-vpc.vpc_id
  auto_accept = true
}

# data "aws_route_table" "test" {
#     vpc_id = module.ansible-sandbox-ds-vpc.vpc_id
# }

resource "aws_route" "ds-vpc-route1-info" {
    route_table_id = module.ansible-sandbox-ds-vpc.route_table
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ds-vpc-igw.id
}

resource "aws_route" "ds-vpc-route2-info" {
    route_table_id = module.ansible-sandbox-ds-vpc.route_table
    destination_cidr_block = "10.100.0.0/16"
    vpc_peering_connection_id = resource.aws_vpc_peering_connection.peering-connection.id
}

resource "aws_route" "onprem-vpc-route1-info" {
    route_table_id = module.ansible-sandbox-onprem-vpc.route_table
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.onprem-vpc-igw.id
}

resource "aws_route" "onprem-vpc-route2-info" {
    route_table_id = module.ansible-sandbox-onprem-vpc.route_table
    destination_cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = resource.aws_vpc_peering_connection.peering-connection.id
}

resource "aws_security_group" "vpc-ds-sg" {
    name = "vpc-ds-sg"
    vpc_id = module.ansible-sandbox-ds-vpc.vpc_id

    ingress {
      from_port       = 3389
      to_port         = 3389
      protocol        = "tcp"
      description     = "Remote desktop"
      cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    }
    ingress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      description     = "All local VPC traffic"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }    

}

resource "aws_security_group" "vpc-onprem-sg" {
    name = "vpc-onprem-sg"
    vpc_id = module.ansible-sandbox-onprem-vpc.vpc_id

    ingress {
      from_port       = 3389
      to_port         = 3389
      protocol        = "tcp"
      description     = "Remote desktop"
      cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    }
    ingress {
      from_port       = 53
      to_port         = 53
      protocol        = "tcp"
      description     = "DNS"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 88
      to_port         = 88
      protocol        = "tcp"
      description     = "Kerberos"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 389
      to_port         = 389
      protocol        = "tcp"
      description     = "LDAP"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 464
      to_port         = 464
      protocol        = "tcp"
      description     = "Kerberos change / set password"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 445
      to_port         = 445
      protocol        = "tcp"
      description     = "SMB / CIFS"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 135
      to_port         = 135
      protocol        = "tcp"
      description     = "Replication"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 636
      to_port         = 636
      protocol        = "tcp"
      description     = "LDAP SSL"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 49152
      to_port         = 65535
      protocol        = "tcp"
      description     = "RPC"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 3268
      to_port         = 3269
      protocol        = "tcp"
      description     = "LDAP GC & LDAP GC SSL"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 53
      to_port         = 53
      protocol        = "udp"
      description     = "DNS"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 88
      to_port         = 88
      protocol        = "udp"
      description     = "Kerberos"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 123
      to_port         = 123
      protocol        = "udp"
      description     = "Windows Time"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 389
      to_port         = 389
      protocol        = "udp"
      description     = "LDAP"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 464
      to_port         = 464
      protocol        = "udp"
      description     = "Kerberos change / set password"
      cidr_blocks = ["10.0.0.0/16"]
    }  
    ingress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      description     = "All local VPC traffic"
      cidr_blocks = ["10.100.0.0/16"]
    }  
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }    

}

resource "aws_directory_service_directory" "as-directory" {
  edition  = "Standard"
  name = "corp.example.com"
  short_name = "corp"
  type     = "MicrosoftAD"
  password = "SuperSecretPassw0rd"

  vpc_settings {
    vpc_id = module.ansible-sandbox-ds-vpc.vpc_id
    subnet_ids = [ resource.aws_subnet.ds-vpc-subnet01.id, resource.aws_subnet.ds-vpc-subnet02.id ]
  }
}

resource "aws_vpc_dhcp_options" "aws-ds-dhcp" {
  domain_name = "corp.example.com"
  domain_name_servers = resource.aws_directory_service_directory.as-directory.dns_ip_addresses

  tags = {
    Name = "AWS DS DHCP"
  }
}

resource "aws_vpc_dhcp_options_association" "aws-ds-dhcp-assoc" {
  vpc_id          = module.ansible-sandbox-ds-vpc.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.aws-ds-dhcp.id
}

resource "aws_iam_policy" "domain_join_iam_policy" {
  path        = "/"
  description = "Domain join policy"
  policy = file("iam_policy.json")
}

resource "aws_iam_role" "domain_join_iam_role" {
  assume_role_policy = file("role_policy.json")
  tags = {
    "Name" = "Domain join role"
  }
}

resource "aws_iam_instance_profile" "domain_join_profile" {
  name = "ad-instance-profile"
  role = aws_iam_role.domain_join_iam_role.name
}

resource "aws_iam_role_policy_attachment" "assign-policy-to-role-attach" {
  role       = aws_iam_role.domain_join_iam_role.name
  policy_arn = aws_iam_policy.domain_join_iam_policy.arn
  depends_on = [aws_iam_policy.domain_join_iam_policy]
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

resource "aws_instance" "windows-test-server" {
    ami = "ami-0e322684a5a0074ce"
    instance_type = "t2.micro"
    subnet_id = resource.aws_subnet.ds-vpc-subnet01.id
    vpc_security_group_ids = [resource.aws_security_group.vpc-ds-sg.id]
    associate_public_ip_address = true
    key_name = aws_key_pair._.key_name
    get_password_data = true
    
}

resource "aws_ssm_document" "ssm_document" {
  name          = "corp.example.com"
  document_type = "Command"
  content       = <<DOC
{
    "schemaVersion": "1.0",
    "description": "Automatic Domain Join Configuration",
    "runtimeConfig": {
        "aws:domainJoin": {
            "properties": {
                "directoryId": "${aws_directory_service_directory.as-directory.id}",
                "directoryName": "corp.example.com",
                "dnsIpAddresses": ${jsonencode(resource.aws_directory_service_directory.as-directory.dns_ip_addresses)}
            }
        }
    }
}
DOC
}

resource "aws_ssm_association" "associate_ssm" {
  name        = aws_ssm_document.ssm_document.name
  instance_id = aws_instance.windows-test-server.id
}