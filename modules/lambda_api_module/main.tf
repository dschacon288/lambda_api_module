provider "aws" {
  region = var.aws_region
}

# Lambda Function
resource "aws_lambda_function" "lambda" {
  function_name    = var.lambda_name
  runtime          = "python3.9"
  handler          = "app.lambda_handler"
  role             = aws_iam_role.lambda_exec.arn
  filename         = "${path.module}/lambda_code/lambda_function.zip"  # TODO crear la lambda

  environment {
    variables = {
      ENV_VAR = var.lambda_env_var
    }
  }
}

# Lambda Execution Role
resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_name}_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.lambda_name}_policy"
  role   = aws_iam_role.lambda_exec.id
  policy = file("${path.module}/policies/lambda_policy.json") ## TODO Crear policy
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "test"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

# Cognito Authorizer
resource "aws_cognito_user_pool" "user_pool" {
  name = var.cognito_user_pool_name
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "CognitoAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.user_pool.arn]
}

# WAF
resource "aws_wafv2_web_acl" "waf" {
  name        = var.waf_name
  scope       = "REGIONAL"
  description = "Basic WAF configuration"
  default_action {
    allow {}
  }

  # Regla para bloquear IPs
  rule {
    name     = "block_specific_ips"
    priority = 1

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.block_ips.arn
      }
    }

    action {
      block {}
    }

    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "block_specific_ips"
    }
  }

  # Regla rate limit
  rule {
    name     = "rate_limit"
    priority = 2

    statement {
      rate_based_statement {
        limit              = 1000 # Número máximo de solicitudes por IP (en 5 minutos)
        aggregate_key_type = "IP"
      }
    }

    action {
      block {}
    }

    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "rate_limit"
    }
  }

  visibility_config {
    sampled_requests_enabled = true
    cloudwatch_metrics_enabled = true
    metric_name = var.waf_name
  }
}

# Conjunto de IPs bloqueadas
resource "aws_wafv2_ip_set" "block_ips" {
  name              = "block_ips"
  scope             = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = var.blocked_ips
}


resource "aws_wafv2_ip_set" "block_ips" {
  name        = "block_ips"
  scope       = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = var.blocked_ips
}