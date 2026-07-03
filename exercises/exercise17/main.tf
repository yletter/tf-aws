terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Cognito User Pool
resource "aws_cognito_user_pool" "mainpool" {
  name = "mainpool"

  # Password policy configuration
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Account recovery settings
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # MFA configuration
  mfa_configuration = "OFF"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cognito_user_pool_domain" "mainpool_domain" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.mainpool.id
}

# Cognito Identity Provider - SAML (Auth0)
resource "aws_cognito_identity_provider" "auth0_saml" {
  user_pool_id  = aws_cognito_user_pool.mainpool.id
  provider_name = "auth0"
  provider_type = "SAML"

  provider_details = {
    MetadataFile = file("${path.module}/${var.saml_metadata_file}")
  }

  attribute_mapping = {
    email       = "email"
    name        = "name"
    family_name = "name"
    given_name  = "name"
    username    = "username"
  }

  depends_on = [aws_cognito_user_pool.mainpool]
}

# Cognito User Pool Client - bridge-client
resource "aws_cognito_user_pool_client" "bridge_client" {
  name                = "bridge-client"
  user_pool_id        = aws_cognito_user_pool.mainpool.id
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]

  callback_urls = [
    "http://localhost:8080/login/oauth2/code/auth0",
    "https://d84l1y8p4kdic.cloudfront.net"
  ]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "phone"]

  # Supported identity providers
  supported_identity_providers = ["auth0"] # , "COGNITO"]

  # Token expiration times
  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  generate_secret = true

  depends_on = [aws_cognito_user_pool.mainpool, aws_cognito_identity_provider.auth0_saml]

}
