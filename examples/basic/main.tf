terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">= 1.0.0"
    }
  }
  required_version = ">= 1.9.0"
}

locals {
  regions = [
    "us-east-2",
    "us-west-2",
  ]
}

provider "aws" {
  region = coalesce(local.regions...)
}

variable "example_account_id" {
  type = string
}

variable "example_account_name" {
  type = string
}

module "aws_account" {
  source = "../../"

  account_id   = var.example_account_id
  account_name = var.example_account_name

  features = {
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
    },
  }

  regions = local.regions

  tags = {
    Environment = "test"
    Example     = "basic"
    Module      = "terraform-polaris-aws-account"
  }
}
