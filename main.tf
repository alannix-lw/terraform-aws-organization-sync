locals {
  lambda_function_name = length(var.lambda_function_name) > 0 ? var.lambda_function_name : "${var.resource_prefix}-function-${random_id.uniq.hex}"
  lambda_role_name     = length(var.lambda_role_name) > 0 ? var.lambda_role_name : "${var.resource_prefix}-role-${random_id.uniq.hex}"
}

resource "random_id" "uniq" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "organization_sync_secret" {
  name = "${var.resource_prefix}-secret-${random_id.uniq.hex}"
}

resource "aws_secretsmanager_secret_version" "organization_sync_secret_version" {
  secret_id     = aws_secretsmanager_secret.organization_sync_secret.id
  secret_string = <<EOF
   {
    "account": "${var.lacework_account}",
    "api_key": "${var.lacework_api_key}",
    "api_secret": "${var.lacework_api_secret}",
    "default_account": "${var.lacework_default_account}",
    "intg_guid": "${var.lacework_integration_guid}",
    "org_map": ${jsonencode(var.lacework_org_map)}
   }
EOF
}

# Create a CloudWatch periodic event rule
resource "aws_cloudwatch_event_rule" "organization_sync" {
  name                = "${var.resource_prefix}-periodic-trigger-${random_id.uniq.hex}"
  schedule_expression = "rate(${var.lambda_triger_interval} hour)"
  event_bus_name      = "default"
}

# Set the CloudWatch event target as the Lambda function
resource "aws_cloudwatch_event_target" "organization_sync" {
  target_id = "organization_sync"
  rule      = aws_cloudwatch_event_rule.organization_sync.name
  arn       = aws_lambda_function.organization_sync.arn
}

# Set Log retention period
resource "aws_cloudwatch_log_group" "organization_sync" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.lambda_log_retention
}

# Create the Lambda function
resource "aws_lambda_function" "organization_sync" {
  function_name    = local.lambda_function_name
  filename         = "${path.module}/functions/dist/organization-sync/LaceworkOrganizationSync.zip"
  source_code_hash = filebase64sha256("${path.module}/functions/dist/organization-sync/LaceworkOrganizationSync.zip")
  handler          = "main.handler"
  runtime          = "python3.9"
  role             = aws_iam_role.organization_sync.arn
  timeout          = var.lambda_timeout

  environment {
    variables = {
      LACEWORK_SECRET_ARN = aws_secretsmanager_secret.organization_sync_secret.arn
    }
  }
}

# Allow CloudWatch to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch_invocation" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.organization_sync.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.organization_sync.arn
}

# IAM role which dictates what other AWS services the Lambda function may access.
resource "aws_iam_role" "organization_sync" {
  name = local.lambda_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Allow the Lambda function to write logs
resource "aws_iam_role_policy" "organization_sync_log_policy" {
  name = "${var.resource_prefix}-log-access"
  role = aws_iam_role.organization_sync.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "LambdaAccessLogs"
    }
  ]
}
EOF
}

# Allow the Lambda function to query Organization resources
resource "aws_iam_role_policy" "organization_sync_organization_policy" {
  name = "${var.resource_prefix}-organization-access"
  role = aws_iam_role.organization_sync.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "organizations:ListAccountsForParent"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "LambdaAccessOrganizations"
    }
  ]
}
EOF
}

# Allow the Lambda function to read the secret
resource "aws_iam_role_policy" "organization_sync_secret_policy" {
  name = "${var.resource_prefix}-secret-access"
  role = aws_iam_role.organization_sync.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:GetSecretValue",
        "secretsmanager:GetResourcePolicy"
      ],
      "Effect": "Allow",
      "Resource": "${aws_secretsmanager_secret.organization_sync_secret.arn}",
      "Sid": "LambdaAccessSecrets"
    }
  ]
}
EOF
}
