output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.my_lambda.function_name
}
