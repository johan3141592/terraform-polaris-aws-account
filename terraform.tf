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

# These locals are used both in the module and in the tests.
locals {
  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^(?i)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}
