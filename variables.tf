variable "lacework_account" {
  type        = string
  description = "Lacework Account (without `.lacework.net`)"
}

variable "lacework_api_key" {
  type        = string
  description = "Lacework API Access Key"
}

variable "lacework_api_secret" {
  type        = string
  description = "Lacework API Secret"
}

variable "lacework_default_account" {
  type        = string
  description = "The catch-all 'default' Lacework Account name to use for CloudTrail data."
}

variable "lacework_integration_name" {
  type        = string
  default     = ""
  description = "The name of the Lacework org-level CloudTrail integration."
}

variable "lacework_iam_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the Lacework org-level CloudTrail integration."
}

variable "lacework_iam_role_external_id" {
  type        = string
  description = "The External ID of the IAM role to use for the Lacework org-level CloudTrail integration."
}

variable "lacework_sqs_queue_url" {
  type        = string
  description = "The URL of the SQS queue to use for the Lacework org-level CloudTrail integration."
}

variable "lacework_org_map" {
  type        = map(any)
  description = "A key/value map of Lacework Account names to AWS Organization OU IDs."
}

variable "lambda_function_name" {
  type        = string
  default     = ""
  description = "The desired name of the lambda function."
}

variable "lambda_log_retention" {
  type        = number
  default     = 30
  description = "The number of days in which to retain logs for the lambda function."
}

variable "lambda_role_name" {
  type        = string
  default     = ""
  description = "The desired IAM role name for the Lacework remediation lambda function."
}

variable "lambda_timeout" {
  type        = number
  default     = 15
  description = "The execution timeout for the Lambda function, in seconds."
}

variable "lambda_triger_interval" {
  type        = number
  default     = 1
  description = "The frequency at which the lambda function should trigger, in hours."
}

variable "management_account_role" {
  type        = string
  default     = ""
  description = "The role ARN with `organizations:ListAccountsForParent` permissions in the AWS Organization management account."
}

variable "resource_prefix" {
  type        = string
  default     = "lacework-organization-sync"
  description = "The name prefix to use for resources provisioned by the module."
}

variable "use_assumed_role" {
  type        = bool
  default     = false
  description = "Set to `true` to use an assumed role to access the AWS Organizations API in the management account."
}
