variable "aws_region" {
  description = "AWS region for the ECS resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used for IAM resource names"
  type        = string
  default     = "simple-ecs-task"
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "simple-ecs-cluster"
}

variable "task_family" {
  description = "ECS task definition family"
  type        = string
  default     = "simple-ecs-task"
}

variable "container_name" {
  description = "Name of the container in the task definition"
  type        = string
  default     = "hello"
}

variable "container_port" {
  description = "Port of the container in the task definition"
  type        = number
  default     = 80
}

variable "container_image" {
  description = "Container image to run"
  type        = string
  default     = "public.ecr.aws/docker/library/alpine:3.20"
}

variable "task_cpu" {
  description = "Fargate task CPU units"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = string
  default     = "512"
}
