# Exercise 15: ECS Fargate Deployment with ALB

Deploy a containerized application to AWS ECS Fargate with complete networking infrastructure and Application Load Balancer.

## Overview

This Terraform configuration provisions:
- VPC with Internet Gateway and public subnets across 2 availability zones
- Application Load Balancer (ALB) listening on port 80
- Security groups for ALB and ECS tasks
- ECS Fargate cluster and task definition
- CloudWatch Log Group for application logs
- Remote state management via S3 backend

## Architecture

```
Internet
   ↓
ALB (Port 80)
   ↓
Security Group (ALB)
   ↓
ECS Service (Port 3000)
   ↓
ECS Task Definition (Container)
   ↓
CloudWatch Logs
```

## Configuration Files

| File | Purpose |
|------|---------|
| `main.tf` | VPC, networking, ALB, ECS cluster, task definition, and service |
| `variables.tf` | Input variables with defaults |
| `outputs.tf` | Output values (ALB DNS name) |
| `backend.tf` | S3 remote state backend configuration |

## Key Variables

- `aws_region`: AWS region (default: `us-east-1`)
- `cluster_name`: ECS cluster name (default: `auth0-webapp`)
- `image_uri`: Docker image URI for the container
- `container_port`: Container application port (default: `3000`)
- `host_port`: ALB listener port (default: `80`)
- `vpc_cidr`: VPC CIDR block (default: `10.0.0.0/16`)
- `subnet_cidrs`: Public subnet CIDR blocks (default: `10.0.1.0/24`, `10.0.2.0/24`)

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Application

After deployment, retrieve the ALB DNS name:

```bash
terraform output alb_dns_name
```

Open the DNS name in a browser to access the application.

## Cleanup

```bash
terraform destroy
```
