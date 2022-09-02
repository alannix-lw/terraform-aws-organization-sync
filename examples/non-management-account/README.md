# Non Management Account Deployment Example

Example configuration for setting up hourly AWS OU sync for Lacework Organizational CloudTrail using an Assumed Role

```hcl
terraform {
  required_providers {
    aws = "~> 4.0"
  }
}

# AWS Management Account
provider "aws" {
  alias   = "management"
  profile = "management"
}

# AWS Non-Management Account
provider "aws" {
  alias   = "non-management"
  profile = "non-management"
}

provider "lacework" {
  organization = true
}

resource "aws_iam_role" "organization_sync" {
  providers = {
    aws = aws.management
  }

  name = "lacework-organization-sync-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "${module.lacework_org_sync.lambda_role_arn}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "organization_sync_organization_policy" {
  providers = {
    aws = aws.management
  }

  name = "lacework-organization-sync-access"
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

  providers = {
    aws = aws.non-management
  }

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

  use_assumed_role        = true
  management_account_role = aws_iam_role.organization_sync.arn
}
```
