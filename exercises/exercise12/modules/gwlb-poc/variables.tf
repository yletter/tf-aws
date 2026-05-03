variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the POC VPC"
  default     = "10.0.0.0/16"
}

variable "security_vpc_cidr" {
  type        = string
  description = "CIDR block for the Security VPC"
  default     = "10.1.0.0/16"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "gwlb-poc"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance type"
  default     = "t3.micro"
}
