output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "waf_arn" {
  description = "ARN of the WAF ACL"
  value       = aws_wafv2_web_acl.waf.arn
}