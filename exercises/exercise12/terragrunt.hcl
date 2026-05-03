terraform {
  source = "./modules/gwlb-poc"
}

inputs = {
  prefix        = "exercise12-gwlb"
  vpc_cidr      = "10.12.0.0/16"
  instance_type = "t3.micro"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}
