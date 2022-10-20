resource "aws_instance" "test_server" {
    
    ami           = "ami-0cd7837c4f521cd56" //windows 2016
    instance_type = "t2.micro"
   
    vpc_security_group_ids = ["${var.ec2_sg_id}"]
    subnet_id              = "${var.subnet_id1}"

    tags = {
      "Name" = "${var.server_name}"
    }
}

