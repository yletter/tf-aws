variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = "test-python"
}

variable "image_uri" {
  description = "The Docker image URI to run in the ECS task"
  type        = string
  default     = "050451371849.dkr.ecr.us-east-1.amazonaws.com/test-python:latest"
}

variable "container_port" {
  description = "The port the container exposes"
  type        = number
  default     = 8080
}

variable "host_port" {
  description = "The port the ALB listens on"
  type        = number
  default     = 80
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
