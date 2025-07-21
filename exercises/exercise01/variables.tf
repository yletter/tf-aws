variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "workstation_ip" {
  type = string
}

data "aws_ami" "amazon_linux_useast1" {
  most_recent = true
  owners      = ["amazon"] # Amazon's official AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  region = "us-east-1" # Optional; usually set in provider block
}

data "aws_ami" "amazon_linux_useast2" {
  most_recent = true
  owners      = ["amazon"] # Amazon's official AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  region = "us-east-2" # Optional; usually set in provider block
}

# variable "amis" {
#   type = map(any)
#   default = {
#     "us-east-1" : data.aws_ami.amazon_linux_useast1.id
#     "us-east-2" : data.aws_ami.amazon_linux_useast2.id
#   }
# }
