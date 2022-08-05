output "cloudwatch_rule_arn" {
  value       = aws_cloudwatch_event_rule.organization_sync.arn
  description = "CloudWatch Event Rule ARN"
}

output "lambda_function_name" {
  value       = local.lambda_function_name
  description = "Lambda Function Name"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.organization_sync.arn
  description = "Lambda Function ARN"
}

output "lambda_role_name" {
  value       = local.lambda_role_name
  description = "Lambda IAM Role Name"
}

output "lambda_role_arn" {
  value       = aws_iam_role.organization_sync.arn
  description = "Lambda IAM Role ARN"
}
