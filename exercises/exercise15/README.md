# AWS ECS Service Deployment

This Terraform configuration deploys a Docker container to an AWS Elastic Container Service (ECS) Fargate cluster. It sets up the necessary networking components, an Application Load Balancer (ALB), and the ECS Task Definition/Service required to run the container.

## Features

- **Networking:** Creates a new VPC, Internet Gateway, Route Tables, and two public subnets for High Availability.
- **ALB:** Configures an Application Load Balancer listening on port 80, routing traffic to port 8080 on the ECS containers.
- **ECS Cluster:** Creates a Fargate-compatible ECS cluster named `test-python`.
- **ECS Task & Service:** Runs the specified container image, exposes port 8080, injects the `PYTHON_ENV="PROD"` environment variable, and configures CloudWatch logging.

## Prerequisites

- Terraform CLI installed.
- AWS CLI installed and configured with credentials for `us-east-1` (or your desired region).

## Usage

1. Initialize the Terraform workspace:
   ```sh
   terraform init
   ```

2. Review the planned changes:
   ```sh
   terraform plan
   ```

3. Apply the configuration to create the resources:
   ```sh
   terraform apply
   ```

4. **Access the application:** Once the deployment finishes, Terraform will output the `alb_dns_name`. You can copy that DNS name and paste it into your browser to access the service.

## Cleanup

To avoid incurring ongoing charges, destroy the infrastructure when you are done:
```sh
terraform destroy
```
