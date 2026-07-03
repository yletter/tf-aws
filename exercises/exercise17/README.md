# Exercise 16: Terraform Cognito User Pool with Auth0 SAML Integration

This Terraform configuration creates an AWS Cognito User Pool named "mainpool" with Auth0 SAML identity provider integration and a client named "bridge-client".

## Architecture Overview

- **Cognito User Pool**: `mainpool` - Main user authentication pool
- **Identity Provider**: Auth0 SAML provider with configured attributes
- **User Pool Client**: `bridge-client` - Application client for accessing the user pool
- **Supported Attributes**: name, family_name, given_name, username, email

## Files

- `main.tf` - Primary Terraform configuration with Cognito resources
- `variables.tf` - Input variables for the configuration
- `outputs.tf` - Output values from the Terraform state
- `saml-metadata.xml` - Dummy SAML metadata file for Auth0 (replace with actual metadata)
- `terraform.tfvars.example` - Example variables file

## Prerequisites

1. AWS Account with appropriate IAM permissions
2. Terraform >= 1.0
3. AWS CLI configured with credentials
4. Auth0 tenant with SAML metadata (for production use)

## Setup Instructions

### 1. Clone or Create the Configuration

```bash
mkdir terraform-cognito-setup
cd terraform-cognito-setup
