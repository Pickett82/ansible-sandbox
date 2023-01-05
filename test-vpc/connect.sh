rm connection.pem
terraform output -raw private_key > connection.pem
ssh -i connection.pem ec2-user@$(terraform output -raw linux_public_ip)