rm cambs-insight.pem
terraform output -raw private_key > cambs-insight.pem
ssh -i cambs-insight.pem ec2-user@$(terraform output -raw linux_ec2_ip)