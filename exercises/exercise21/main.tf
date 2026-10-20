terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Latest Amazon Linux 2023 image for ARM64/Graviton.
data "aws_ssm_parameter" "amazon_linux_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

# This example uses your account's default VPC and one of its subnets.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# No public inbound ports by default.
# Use AWS Systems Manager Session Manager to access the server, or add a
# narrowly restricted SSH rule only if you need it.
resource "aws_security_group" "ai_server" {
  name_prefix = "word-ai-"
  description = "Security group for local word AI server"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "Allow updates and initial model download"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name_prefix = "word-ai-ec2-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name_prefix = "word-ai-"
  role        = aws_iam_role.ec2_ssm.name
}

resource "aws_instance" "word_ai" {
  ami                    = data.aws_ssm_parameter.amazon_linux_arm64.value
  instance_type          = "t4g.medium"
  #instance_market_options {
  #  market_type = "spot"
  #  spot_options {
  #    instance_interruption_behavior = "terminate"
  #  }
  #}

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }

  subnet_id              = tolist(data.aws_subnets.default_vpc.ids)[0]
  vpc_security_group_ids = [aws_security_group.ai_server.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm.name

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y curl --skip-broken

    # Installs the ARM64-compatible Ollama server.
    curl -fsSL https://ollama.com/install.sh | sh

    systemctl enable ollama
    systemctl start ollama

    # Wait for the local API to become ready.
    until curl --fail --silent http://127.0.0.1:11434/api/tags; do
      sleep 2
    done

    # Small model appropriate for word meanings and example sentences.
    export HOME=/root
    /usr/local/bin/ollama pull qwen2.5:1.5b
  EOF

  tags = {
    Name = "word-ai-t4g-medium"
  }
}

output "instance_id" {
  value = aws_instance.word_ai.id
}