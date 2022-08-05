<a href="https://lacework.com"><img src="https://techally-content.s3-us-west-1.amazonaws.com/public-content/lacework_logo_full.png" width="600"></a>

# terraform-aws-organization-sync

A Terraform Module to periodically syncronize AWS Organizational Units with Lacework Organizational CloudTrail monitoring.

## Requirements

| Name                                                                     | Version    |
| ------------------------------------------------------------------------ | ---------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.12.31 |
| <a name="requirement_lacework"></a> [lacework](#requirement_lacework)    | ~> 0.3     |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | 4.25.0  |
| <a name="provider_random"></a> [random](#provider_random) | 3.3.2   |

## Resources

| Name                                                                                                                                                                            | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_event_rule.organization_sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                                | resource |
| [aws_cloudwatch_event_target.organization_sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)                            | resource |
| [aws_cloudwatch_log_group.organization_sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                  | resource |
| [aws_iam_role.organization_sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                          | resource |
| [aws_iam_role_policy.organization_sync_log_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                 | resource |
| [aws_iam_role_policy.organization_sync_organization_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                        | resource |
| [aws_iam_role_policy.organization_sync_secret_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                              | resource |
| [aws_lambda_function.organization_sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                            | resource |
| [aws_lambda_permission.allow_cloudwatch_invocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                              | resource |
| [aws_secretsmanager_secret.organization_sync_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                         | resource |
| [aws_secretsmanager_secret_version.organization_sync_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_id.uniq](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                             | resource |

## Inputs

| Name                                                                                                         | Description                                                               | Type       | Default                        | Required |
| ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------- | ---------- | ------------------------------ | :------: |
| <a name="input_lacework_account"></a> [lacework_account](#input_lacework_account)                            | Lacework Account (without `.lacework.net`)                                | `string`   | n/a                            |   yes    |
| <a name="input_lacework_api_key"></a> [lacework_api_key](#input_lacework_api_key)                            | Lacework API Access Key                                                   | `string`   | n/a                            |   yes    |
| <a name="input_lacework_api_secret"></a> [lacework_api_secret](#input_lacework_api_secret)                   | Lacework API Secret                                                       | `string`   | n/a                            |   yes    |
| <a name="input_lacework_default_account"></a> [lacework_default_account](#input_lacework_default_account)    | The catch-all 'default' Lacework Account name to use for CloudTrail data. | `string`   | n/a                            |   yes    |
| <a name="input_lacework_integration_guid"></a> [lacework_integration_guid](#input_lacework_integration_guid) | The GUID for the Org-level Cloudtrail integration to synchronize.         | `string`   | n/a                            |   yes    |
| <a name="input_lacework_org_map"></a> [lacework_org_map](#input_lacework_org_map)                            | A key/value map of Lacework Account names to AWS Organization OU IDs.     | `map(any)` | n/a                            |   yes    |
| <a name="input_lambda_function_name"></a> [lambda_function_name](#input_lambda_function_name)                | The desired name of the lambda function.                                  | `string`   | `""`                           |    no    |
| <a name="input_lambda_log_retention"></a> [lambda_log_retention](#input_lambda_log_retention)                | The number of days in which to retain logs for the lambda function.       | `number`   | `30`                           |    no    |
| <a name="input_lambda_role_name"></a> [lambda_role_name](#input_lambda_role_name)                            | The desired IAM role name for the Lacework remediation lambda function.   | `string`   | `""`                           |    no    |
| <a name="input_lambda_timeout"></a> [lambda_timeout](#input_lambda_timeout)                                  | The execution timeout for the Lambda function, in seconds.                | `number`   | `15`                           |    no    |
| <a name="input_lambda_triger_interval"></a> [lambda_triger_interval](#input_lambda_triger_interval)          | The frequency at which the lambda function should trigger, in hours.      | `number`   | `1`                            |    no    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                               | The name prefix to use for resources provisioned by the module.           | `string`   | `"lacework-organization-sync"` |    no    |

## Outputs

| Name                                                                                            | Description               |
| ----------------------------------------------------------------------------------------------- | ------------------------- |
| <a name="output_cloudwatch_rule_arn"></a> [cloudwatch_rule_arn](#output_cloudwatch_rule_arn)    | CloudWatch Event Rule ARN |
| <a name="output_lambda_function_arn"></a> [lambda_function_arn](#output_lambda_function_arn)    | Lambda Function ARN       |
| <a name="output_lambda_function_name"></a> [lambda_function_name](#output_lambda_function_name) | Lambda Function Name      |
| <a name="output_lambda_role_arn"></a> [lambda_role_arn](#output_lambda_role_arn)                | Lambda IAM Role ARN       |
| <a name="output_lambda_role_name"></a> [lambda_role_name](#output_lambda_role_name)             | Lambda IAM Role Name      |
