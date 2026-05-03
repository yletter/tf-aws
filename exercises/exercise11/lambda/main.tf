locals {
  # Define the single AZ to be used for the POC
  az = data.aws_availability_zones.available.names[0]
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# --- VPC & Subnets ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.prefix}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.prefix}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 0)
  availability_zone = local.az
  tags              = { Name = "${var.prefix}-public-subnet" }
}

resource "aws_subnet" "app" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 1)
  availability_zone       = local.az
  map_public_ip_on_launch = true # EC2 will get a public IP to use IGW
  tags                    = { Name = "${var.prefix}-app-subnet" }
}

resource "aws_subnet" "gwlbe" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 2)
  availability_zone = local.az
  tags              = { Name = "${var.prefix}-gwlbe-subnet" }
}

resource "aws_subnet" "security" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 3)
  availability_zone = local.az
  tags              = { Name = "${var.prefix}-security-subnet" }
}

# --- Step 1 & 2: Gateway Load Balancer and Service ---
resource "aws_lb" "gwlb" {
  name               = "${var.prefix}-gwlb"
  load_balancer_type = "gateway"
  subnets            = [aws_subnet.security.id]
}

resource "aws_lb_target_group" "gwlb_tg" {
  name     = "${var.prefix}-gwlb-tg"
  port     = 6081
  protocol = "GENEVE"
  vpc_id   = aws_vpc.main.id

  health_check {
    port     = 80
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "gwlb_listener" {
  load_balancer_arn = aws_lb.gwlb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gwlb_tg.arn
  }
}

resource "aws_vpc_endpoint_service" "gwlb_service" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]
}

# --- Step 3: GWLB Endpoint ---
resource "aws_vpc_endpoint" "gwlb_endpoint" {
  service_name      = aws_vpc_endpoint_service.gwlb_service.service_name
  subnet_ids        = [aws_subnet.gwlbe.id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = aws_vpc.main.id
}

# --- Step 4: Routing ---
# Ingress routing from IGW -> GWLB Endpoint for App Subnet
resource "aws_route_table" "edge" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = aws_subnet.app.cidr_block
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint.id
  }

  tags = { Name = "${var.prefix}-edge-rt" }
}

resource "aws_route_table_association" "edge_assoc" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.edge.id
}

# App Subnet Route -> sends internet bound traffic to GWLB Endpoint
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint.id
  }

  tags = { Name = "${var.prefix}-app-rt" }
}

resource "aws_route_table_association" "app_assoc" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.app.id
}

# GWLB Endpoint Subnet Route -> sends everything to IGW so returned traffic escapes
resource "aws_route_table" "gwlbe" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.prefix}-gwlbe-rt" }
}

resource "aws_route_table_association" "gwlbe_assoc" {
  subnet_id      = aws_subnet.gwlbe.id
  route_table_id = aws_route_table.gwlbe.id
}

# Security Subnet Route -> Needs internet access to download tools for validation
resource "aws_route_table" "security" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.prefix}-security-rt" }
}

resource "aws_route_table_association" "security_assoc" {
  subnet_id      = aws_subnet.security.id
  route_table_id = aws_route_table.security.id
}

# --- Step 5: EC2 Instances ---

# Security EC2
resource "aws_security_group" "sec_sg" {
  vpc_id = aws_vpc.main.id
  name   = "${var.prefix}-sec-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "security" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.security.id
  vpc_security_group_ids      = [aws_security_group.sec_sg.id]
  associate_public_ip_address = true # To allow SSH & SSM

  user_data = <<-EOF
#!/bin/bash
# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

yum install -y tcpdump python3 iptables-services

# A fake health check responder on port 80 since GWLB needs to perform a health check
cat << 'HC' > /tmp/hc.py
from http.server import BaseHTTPRequestHandler, HTTPServer
class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')
httpd = HTTPServer(('0.0.0.0', 80), SimpleHTTPRequestHandler)
httpd.serve_forever()
HC

nohup python3 /tmp/hc.py >/dev/null 2>&1 &

# We don't reflect the traffic in this simple POC to keep it foolproof and simple.
# The user will validate GWLB works by observing incoming encapsulated packets on udp port 6081 using tcpdump.
EOF

  tags = { Name = "${var.prefix}-security-ec2" }
}

resource "aws_lb_target_group_attachment" "gwlb_attach" {
  target_group_arn = aws_lb_target_group.gwlb_tg.arn
  target_id        = aws_instance.security.id
}

# App EC2
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id
  name   = "${var.prefix}-app-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.app.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = "KeyPair2025ppk"
  user_data              = <<-EOF
#!/bin/bash
yum install -y httpd
echo "Successful request! This traffic reached the App Server behind the AWS Gateway Load Balancer." > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
EOF

  tags = { Name = "${var.prefix}-app-ec2" }
}
