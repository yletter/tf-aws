terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main1" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "CloudAcademy1"
    Demo = "Terraform"
  }
}


resource "aws_vpc" "main2" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "CloudAcademy2"
    Demo = "Terraform"
  }
}

resource "aws_subnet" "subnet11" {
  vpc_id            = aws_vpc.main1.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Subnet1"
    Type = "Public"
  }
}

resource "aws_subnet" "subnet12" {
  vpc_id            = aws_vpc.main1.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Subnet2"
    Type = "Public"
  }
}

resource "aws_subnet" "subnet21" {
  vpc_id            = aws_vpc.main2.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Subnet1"
    Type = "Public"
  }
}

resource "aws_subnet" "subnet22" {
  vpc_id            = aws_vpc.main2.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Subnet2"
    Type = "Public"
  }
}

resource "aws_internet_gateway" "main1" {
  vpc_id = aws_vpc.main1.id

  tags = {
    "Name"  = "Main"
    "Owner" = "CloudAcademy"
  }
}

resource "aws_internet_gateway" "main2" {
  vpc_id = aws_vpc.main2.id

  tags = {
    "Name"  = "Main"
    "Owner" = "CloudAcademy"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main1.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.main2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main2.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table_association" "rta11" {
  subnet_id      = aws_subnet.subnet11.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta12" {
  subnet_id      = aws_subnet.subnet12.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta21" {
  subnet_id      = aws_subnet.subnet21.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "rta22" {
  subnet_id      = aws_subnet.subnet22.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_security_group" "webserver1" {
  name        = "Webserver1"
  description = "Webserver network traffic"
  vpc_id      = aws_vpc.main1.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.workstation_ip]
  }

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow traffic"
  }
}

resource "aws_security_group" "webserver2" {
  name        = "Webserver2"
  description = "Webserver network traffic"
  vpc_id      = aws_vpc.main2.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.workstation_ip]
  }

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow traffic"
  }
}

resource "aws_instance" "web1" {
  ami                    = data.aws_ami.amazon_linux_useast1.id # var.amis[var.region]
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet11.id
  vpc_security_group_ids = [aws_security_group.webserver1.id]

  associate_public_ip_address = true

  #userdata
  user_data = <<EOF
#!/bin/bash
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo yum install -y git

cd /usr/share/nginx/html

git clone https://github.com/cloudacademy/webgl-globe/ ./web
cp -a web/src/* .
rm -rf {.git,*.md,src,conf.d,docs,Dockerfile,index.nginx-debian.html}
systemctl start nginx
systemctl enable nginx

echo fin v1.00!
EOF

  tags = {
    Name = "CloudAcademy1"
  }
}

resource "aws_instance" "web2" {
  ami                    = data.aws_ami.amazon_linux_useast1.id # var.amis[var.region]
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet21.id
  vpc_security_group_ids = [aws_security_group.webserver2.id]

  associate_public_ip_address = true

  #userdata
  user_data = <<EOF
#!/bin/bash
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo yum install -y git

cd /usr/share/nginx/html

git clone https://github.com/cloudacademy/webgl-globe/ ./web
cp -a web/src/* .
rm -rf {.git,*.md,src,conf.d,docs,Dockerfile,index.nginx-debian.html}
systemctl start nginx
systemctl enable nginx

echo fin v1.00!
EOF

  tags = {
    Name = "CloudAcademy2"
  }
}

# 1. Create the VPC Peering Connection
resource "aws_vpc_peering_connection" "main1_to_main2" {
  vpc_id        = aws_vpc.main1.id
  peer_vpc_id   = aws_vpc.main2.id
  auto_accept   = true

  tags = {
    Name = "peer-main1-to-main2"
  }
}

# 2. Add Route in VPC main1's Route Table pointing to VPC main2
resource "aws_route" "main1_to_main2_route" {
  route_table_id            = aws_vpc.main1.main_route_table_id
  destination_cidr_block    = aws_vpc.main2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main1_to_main2.id
}

# 3. Add Route in VPC main2's Route Table pointing to VPC main1
resource "aws_route" "aws_route_main2_to_main1" {
  route_table_id            = aws_vpc.main2.main_route_table_id
  destination_cidr_block    = aws_vpc.main1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main1_to_main2.id
}
