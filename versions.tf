terraform {
  required_version = ">= 0.12.31"

  required_providers {
    aws    = "~> 4.0"
    random = ">= 2.1"
    lacework = {
      source  = "lacework/lacework"
      version = "~> 1.0"
    }
  }
}
