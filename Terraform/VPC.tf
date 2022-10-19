provider "aws" {
  region     = "us-east-1"
  access_key = "#AccessKeyHere"
  secret_key = "#SecretAccessKeyHere"
}

resource "aws_vpc" "fenugreekVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "fenugreekVPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.fenugreekVPC.id

  tags = {
    Name = "fenugreekVPC"
  }
}

resource "aws_route_table" "FenugreekRouteTable" {
  vpc_id = aws_vpc.fenugreekVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "FenuGreekRouteTable"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.fenugreekVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.FenugreekRouteTable.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_trafic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.fenugreekVPC.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_network_interface" "fenugreek" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

  attachment {
    instance     = aws_instance.my_server.id
    device_index = 0
  }
}

resource "aws_eip" "lb" {
  vpc                       = true
  network_interface         = aws_network_interface.fenugreek.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_instance" "my_server" {
  ami               = "ami-08c40ec9ead489470"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "terraform"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.fenugreek.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo the best webserver > /var/www/html/index.html'
              EOF

  tags = { Name = "web-server"
  }
}
