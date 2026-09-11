# Exercise 19: Simple ECS Fargate Task

This exercise creates the smallest useful ECS Fargate example: an ECS cluster, a task execution role, a CloudWatch log group, and an Alpine-based task definition.

The task uses the first subnet and the default security group in the account's default VPC. No VPC, subnet, service, load balancer, or container registry is created.

## Files

| File | Purpose |
|------|---------|
| `main.tf` | ECS cluster, IAM execution role, log group, and Fargate task definition |
| `variables.tf` | Configurable names, image, CPU, and memory |
| `outputs.tf` | Task identifiers and a command to run one task |
| `backend.tf` | S3 remote state backend |
| `README.md` | Exercise instructions |

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- An AWS account with permissions to create ECS, IAM, and CloudWatch Logs resources
- A default VPC with at least one subnet
- Internet access from the selected subnet when `assignPublicIp=ENABLED` is used

## Deploy

```bash
cd exercise19
terraform init
terraform plan
terraform apply
```

Terraform outputs a `run_task_command`. Run that command to start one Fargate task:

```bash
terraform output -raw run_task_command
```

The container prints `ECS task started` and then stays alive for about one hour. View its logs in the `/ecs/simple-ecs-task` CloudWatch log group.

## Cleanup

```bash
terraform destroy
```

The command removes the ECS cluster, task definition, execution role, and log group. Stop any task started manually before cleanup if it is still running.
