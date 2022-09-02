# Default Example

Example configuration for setting up hourly AWS OU sync for Lacework Organizational CloudTrail

```hcl
terraform {
  required_providers {
    aws = "~> 4.0"
  }
}

# AWS Management Account
provider "aws" {}

provider "lacework" {
  organization = true
}

module "aws_org_cloudtrail" {
  source  = "lacework/cloudtrail/aws"
  version = "~> 2.0"

  bucket_logs_enabled   = false
  consolidated_trail    = true
  is_organization_trail = true

  create_lacework_integration = false
}

module "lacework_organization_sync_module" {
  source = "github.com/alannix-lw/terraform-aws-organization-sync"

  # API Credentials
  lacework_account    = "<Lacework Account>"
  lacework_api_key    = "<Lacework API Key>"
  lacework_api_secret = "<Lacework API Secret>"

  # Integration Configuration
  lacework_iam_role_arn         = module.aws_org_cloudtrail.iam_role_arn
  lacework_iam_role_external_id = module.aws_org_cloudtrail.external_id
  lacework_sqs_queue_url        = module.aws_org_cloudtrail.sqs_url

  lacework_default_account  = "<Lacework Account>"
  lacework_org_map = {
    "<Lacework Sub-Account 1>" = ["<AWS Organization OU 1>", "<AWS Organization OU 2>"],
    "<Lacework Sub-Account 2>" = ["<AWS Organization OU 3>"]
  }
}
```
