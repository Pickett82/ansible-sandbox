module "ansible-sandbox-vpc" {
  source = "../../modules/vpc"
  environment = "test"
  app-name = "ansible-sandbox"
}