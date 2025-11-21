terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
}

provider "aws" {
  profile             = local.env.account_name
  region              = local.env.region
  allowed_account_ids = [local.env.account_id]

  default_tags {
    tags = var.default_tags
  }
}
