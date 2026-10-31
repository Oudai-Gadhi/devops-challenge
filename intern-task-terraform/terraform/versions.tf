terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # no real aws account here, these let plan work with fake credentials
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}
