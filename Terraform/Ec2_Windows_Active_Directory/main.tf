#export AWS_ACCESS_KEY_ID=""
#export AWS_SECRET_ACCESS_KEY=""

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "windows_ec2_instance" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = "Active Directory"
  get_password_data      = true
  vpc_security_group_ids = ["sg-0f93f04b65d001ce2"]

  tags = {
    Name = "Active Directory Windows EC2 instance"
  }
}
