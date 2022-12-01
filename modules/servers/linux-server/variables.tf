variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "server_name" {
  description = "The name of the server we're creating"
  type        = string
}

variable "ec2_sg_id" {
  type = string
  description = "The id of the EC2 security group"
}

variable "subnet_id1" {
  type = string
  description = "The id of the first subnet"
}

variable "windows_private_ip" {
  type = string
  description = "the private ip of the test windows server"
}

variable "windows_password" {
  type = string
  description = "the password of the test windows server"
}

