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

module "lacework_organization_sync_module" {
  source = "github.com/alannix-lw/terraform-aws-organization-sync"

  # API Credentials
  lacework_account    = "<Lacework Account>"
  lacework_api_key    = "<Lacework API Key>"
  lacework_api_secret = "<Lacework API Secret>"

  # Integration Configuration
  lacework_integration_guid = "<Lacework CloudTrail Integration GUID>"
  lacework_default_account  = "<Lacework Account>"
  lacework_org_map = {
    "<Lacework Sub-Account 1>" = ["<AWS Organization OU 1>", "<AWS Organization OU 2>"],
    "<Lacework Sub-Account 2>" = ["<AWS Organization OU 3>"]
  }
}
```
