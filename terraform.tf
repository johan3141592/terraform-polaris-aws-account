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
  required_version = ">= 1.7.0"
}
