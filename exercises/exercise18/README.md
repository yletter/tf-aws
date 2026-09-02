# Exercise 18: VPC with SSM Endpoint Access to Private EC2 Instance

This Terraform configuration creates a private VPC infrastructure with an EC2 instance accessible via AWS Systems Manager Session Manager (SSM) without requiring an internet gateway or bastion host.

## Overview

This exercise demonstrates how to access a private EC2 instance using AWS Systems Manager Session Manager through VPC endpoints. This is a secure, audit-able alternative to using internet gateways and bastion hosts.

## Architecture

```
VPC (10.0.0.0/16)
├── Private Subnet (10.0.1.0/24)
│   ├── EC2 Instance (Private IP)
│   ├── Network ACL
│   └── Security Groups
└── VPC Endpoints (Interface type)
    ├── SSM Endpoint
    ├── EC2 Messages Endpoint
    └── SSM Messages Endpoint
```

## Features

- **VPC**: Private VPC with CIDR block 10.0.0.0/16
- **Private Subnet**: Single private subnet in availability zone with no internet gateway
- **Route Table**: Private route table with local routes only
- **Security Groups**:
  - EC2 SG: Allows outbound traffic to VPC endpoints
  - VPC Endpoints SG: Allows inbound HTTPS (port 443) from EC2 instances
- **Network ACL**: Allows all traffic within VPC and all outbound traffic
- **IAM Role**: EC2 instance role with `AmazonSSMManagedInstanceCore` policy
- **VPC Endpoints**: Three Interface VPC endpoints for SSM connectivity:
  - `com.amazonaws.<region>.ssm` - Systems Manager Endpoint
  - `com.amazonaws.<region>.ec2messages` - EC2 Messages Endpoint
  - `com.amazonaws.<region>.ssmmessages` - SSM Messages Endpoint
- **EC2 Instance**: Amazon Linux 2 instance in private subnet with IAM role

## Files

| File | Purpose |
|------|---------|
| `main.tf` | VPC, subnets, security groups, NACL, IAM role, VPC endpoints, and EC2 instance |
| `variables.tf` | Input variables with defaults |
| `outputs.tf` | Output values (instance ID, VPC ID, SSM login command) |
| `backend.tf` | S3 remote state backend configuration |
| `README.md` | This file |

## Key Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region for resources |
| `project_name` | `ssm-vpc-lab` | Project name for resource naming |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `subnet_cidr` | `10.0.1.0/24` | Private subnet CIDR block |
| `instance_type` | `t2.micro` | EC2 instance type |

## Prerequisites

1. AWS Account with appropriate IAM permissions
2. Terraform >= 1.0
3. AWS CLI configured with credentials
4. Session Manager plugin for AWS CLI (optional, for terminal access)

## Deployment

### 1. Initialize Terraform

```bash
cd exercise18
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

Terraform will create all the resources and output the instance ID and SSM login command.

## Accessing the EC2 Instance via SSM

### Method 1: Using AWS Console

1. Go to AWS Systems Manager > Session Manager
2. Click "Start session"
3. Select the instance (ssm-vpc-lab-ec2-instance)
4. Click "Start session"

### Method 2: Using AWS CLI

After Terraform completes, retrieve the SSM login command from outputs:

```bash
terraform output ssm_login_command
```

Or manually run:

```bash
aws ssm start-session --target <instance-id> --region us-east-1
```

Replace `<instance-id>` with the instance ID from the outputs.

### Method 3: Using AWS CLI with Port Forwarding

For SSH-like access, you can use the session-manager-plugin:

```bash
aws ssm start-session --target <instance-id> --document-name AWS-StartInteractiveCommand --region us-east-1
```

## Important Notes

1. **No Internet Access**: The EC2 instance has no internet gateway and cannot access the internet directly. It only connects to AWS services through VPC endpoints.

2. **VPC Endpoint Costs**: Interface VPC endpoints incur hourly charges. For this exercise, be aware of potential costs.

3. **IAM Permissions**: The AWS user/role running Terraform must have permissions to:
   - Create VPC, subnets, security groups, NACLs
   - Create IAM roles and instance profiles
   - Create VPC endpoints
   - Create EC2 instances

4. **SSM Requirements**: 
   - The EC2 instance must have the `AmazonSSMManagedInstanceCore` policy attached
   - The security group must allow outbound HTTPS (port 443) traffic
   - VPC endpoints must be properly configured

5. **DNS Resolution**: Private DNS is enabled on the VPC endpoints, so instances can use DNS names to communicate with the endpoints.

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | The ID of the created VPC |
| `subnet_id` | The ID of the private subnet |
| `ec2_instance_id` | The ID of the EC2 instance |
| `ec2_private_ip` | The private IP address of the EC2 instance |
| `ec2_security_group_id` | The security group ID of the EC2 instance |
| `iam_role_name` | The IAM role name for EC2 SSM access |
| `ssm_endpoint_id` | The ID of the SSM VPC endpoint |
| `ec2_messages_endpoint_id` | The ID of the EC2 Messages VPC endpoint |
| `ssm_messages_endpoint_id` | The ID of the SSM Messages VPC endpoint |
| `ssm_login_command` | The command to login to EC2 instance via SSM |

## Cleanup

To avoid incurring ongoing charges for VPC endpoints, destroy the infrastructure when finished:

```bash
terraform destroy
```

## Troubleshooting

### EC2 instance not appearing in Session Manager

1. **Check IAM Role**: Ensure the EC2 instance has the `AmazonSSMManagedInstanceCore` policy
2. **Check Security Group**: Ensure the EC2 security group allows outbound HTTPS (port 443) traffic
3. **Check VPC Endpoints**: Verify that the three required VPC endpoints are in "Available" state
4. **Check Instance Connectivity**: Verify the instance can reach the VPC endpoints (they should be in the same VPC)
5. **Wait for SSM Agent**: Give the instance a few minutes to start and communicate with SSM service

### Permission Denied when connecting

1. Ensure your IAM user has `ssm:StartSession` permission
2. Check the Session Manager configuration in Systems Manager

### No route to endpoint

1. Verify the private route table doesn't have a default route
2. Ensure security group rules allow outbound HTTPS traffic
3. Check that VPC endpoints are in the correct subnet and VPC

## References

- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
- [SSM Agent](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html)
- [Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_ACLs.html)
