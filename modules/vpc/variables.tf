variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "app-name" {
  description = "Name of application"
  type = string
}

variable "ip4-cidr-block" {
  description = "IPv4 CIDR block"
  type = string
}