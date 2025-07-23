variable "lambda_function_name" {
  description = "The name of the AWS Lambda function"
  type        = string
  default     = "my_lambda_function"
}

variable "lambda_handler" {
  description = "The handler for the Lambda function"
  type        = string
  default     = "handler.lambda_handler"
}

variable "lambda_runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
  default     = "python3.8"
}

variable "lambda_memory_size" {
  description = "The amount of memory available to the function"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "The function execution time in seconds"
  type        = number
  default     = 3
}

variable "aws_region" {
  description = "The AWS region to deploy the Lambda function"
  type        = string
  default     = "us-east-1"
}
