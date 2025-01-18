variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_env_var" {
  description = "Environment variable for the Lambda function"
  type        = string
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "cognito_user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "waf_name" {
  description = "Name of the WAF ACL"
  type        = string
}

variable "blocked_ips" {
  description = "List of IPs to block in WAF"
  type        = list(string)
  default     = []
}