resource "aws_instance" "test_server" {
    
    ami           = "ami-02a9c04e461574620" //windows 2016
    instance_type = "t2.micro"
    key_name      = aws_key_pair._.key_name
    get_password_data = true

    user_data = <<EOF
      <powershell>
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
      $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
      (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
      powershell.exe -ExecutionPolicy ByPass -File $file
      </powershell>
      EOF
   
    vpc_security_group_ids = ["${var.ec2_sg_id}"]
    subnet_id              = "${var.subnet_id1}"

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