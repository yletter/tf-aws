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

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CloudAcademy"
    Demo = "Terraform"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Public Subnet"
    Type = "Public"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Private Subnet"
    Type = "Private"
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Firewall Subnet"
    Type = "Public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name"  = "Main"
    "Owner" = "CloudAcademy"
  }
}

resource "aws_route_table" "igw_rt" {
  vpc_id = aws_vpc.main.id

  route {
    # Any traffic destined for the Private Subnet...
    cidr_block = aws_subnet.subnet2.cidr_block
    # ...must be sent to the Firewall Endpoint first!
    vpc_endpoint_id = local.vpc_endpoints[0].endpoint_id
  }

  tags = {
    Name = "IGW Route Table"
  }
}

resource "aws_route_table_association" "igw_rt_assoc" {
  gateway_id     = aws_internet_gateway.main.id
  route_table_id = aws_route_table.igw_rt.id
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id = aws_internet_gateway.main.id
    vpc_endpoint_id = local.vpc_endpoints[0].endpoint_id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table" "rt4" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Network Route Table"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.rt4.id
}

resource "aws_security_group" "webserver" {
  name        = "Webserver"
  description = "Webserver network traffic"
  vpc_id      = aws_vpc.main.id

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
    Name = "Webserver Security Group"
  }
}

resource "aws_security_group" "webserver2" {
  name        = "Webserver2"
  description = "Webserver2 network traffic"
  vpc_id      = aws_vpc.main.id

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

  ingress {
    description = "8080 from anywhere"
    from_port   = 8080
    to_port     = 8080
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
    Name = "Webserver Security Group 2"
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_useast1.id # var.amis[var.region]
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.webserver.id]

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
    Name = "Web Server Public"
  }
}

resource "aws_instance" "web2" {
  ami                    = data.aws_ami.amazon_linux_useast1.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.webserver2.id]

  associate_public_ip_address = true

  #userdata
  user_data = <<EOF
#!/bin/bash
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo yum install -y git

sudo sed -i 's/80;/8080;/g' /etc/nginx/nginx.conf

cd /usr/share/nginx/html

git clone https://github.com/cloudacademy/webgl-globe/ ./web
cp -a web/src/* .
rm -rf {.git,*.md,src,conf.d,docs,Dockerfile,index.nginx-debian.html}
systemctl start nginx
systemctl enable nginx

echo fin v1.00!
EOF

  tags = {
    Name = "Web Server Network Firewall"
  }
}
