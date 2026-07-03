output "cognito_user_pool_id" {
  value       = aws_cognito_user_pool.mainpool.id
  description = "The ID of the Cognito User Pool (mainpool)"
}

output "cognito_user_pool_arn" {
  value       = aws_cognito_user_pool.mainpool.arn
  description = "The ARN of the Cognito User Pool"
}

output "cognito_user_pool_name" {
  value       = aws_cognito_user_pool.mainpool.name
  description = "The name of the Cognito User Pool"
}

output "cognito_client_id" {
  value       = aws_cognito_user_pool_client.bridge_client.id
  description = "The ID of the Cognito User Pool Client (bridge-client)"
}

output "cognito_client_secret" {
  value       = aws_cognito_user_pool_client.bridge_client.client_secret
  sensitive   = true
  description = "The secret of the Cognito User Pool Client (bridge-client)"
}

output "identity_provider_name" {
  value       = aws_cognito_identity_provider.auth0_saml.provider_name
  description = "The name of the SAML Identity Provider (auth0)"
}

output "identity_provider_type" {
  value       = aws_cognito_identity_provider.auth0_saml.provider_type
  description = "The type of the Identity Provider (SAML)"
}
