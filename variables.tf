locals {
  features = [
    "CLOUD_NATIVE_ARCHIVAL",
    "CLOUD_NATIVE_PROTECTION",
    "CLOUD_NATIVE_S3_PROTECTION",
    "EXOCOMPUTE",
    "RDS_PROTECTION",
  ]

  cloud_native_archival = [
    "BASIC",
  ]

  cloud_native_protection = [
    "BASIC",
  ]

  cloud_native_s3_protection = [
    "BASIC",
  ]

  exocompute = [
    "BASIC",
    "RSC_MANAGED_CLUSTER"
  ]

  rds_protection = [
    "BASIC",
  ]
}

variable "account_id" {
  type        = string
  description = "AWS account ID."
}

variable "account_name" {
  type        = string
  description = "AWS account name."
}

variable "cloud_type" {
  type        = string
  default     = "STANDARD"
  description = "AWS cloud type. Possible values are: STANDARD, GOV. Defaults to STANDARD."

  validation {
    condition     = can(regex("STANDARD|GOV", var.cloud_type))
    error_message = "Invalid AWS cloud type. Allowed values are: STANDARD or GOV."
  }
}

variable "ec2_recovery_role_path" {
  type        = string
  default     = ""
  description = "AWS EC2 recovery role path."
}

variable "external_id" {
  type        = string
  default     = ""
  description = "AWS external ID. If empty, RSC will automatically generate an external ID."
}

variable "features" {
  type = map(object({
    permission_groups = set(string)
  }))
  description = "RSC features with permission groups. Possible features are: CLOUD_NATIVE_ARCHIVAL, CLOUD_NATIVE_PROTECTION, CLOUD_NATIVE_S3_PROTECTION, EXOCOMPUTE, RDS_PROTECTION."

  validation {
    condition     = length(setsubtract(keys(var.features), local.features)) == 0
    error_message = format("Invalid RSC feature. Allowed features are: %v.", local.features)
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_ARCHIVAL"].permission_groups, []), local.cloud_native_archival)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_archival))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_PROTECTION"].permission_groups, []), local.cloud_native_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_S3_PROTECTION"].permission_groups, []), local.cloud_native_s3_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_s3_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["EXOCOMPUTE"].permission_groups, []), local.exocompute)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.exocompute))
  }
  validation {
    condition     = length(setsubtract(try(var.features["RDS_PROTECTION"].permission_groups, []), local.rds_protection)) == 0
    error_message = format("Invalid permission groups for RSC feature. Allowed permission groups are: %v.", join(", ", local.rds_protection))
  }
}

variable "role_path" {
  type        = string
  default     = "/"
  description = "AWS role path. Defaults to '/'."

  validation {
    condition     = startswith(var.role_path, "/") && endswith(var.role_path, "/")
    error_message = "Invalid AWS role path. The role path must start and end with '/'."
  }
}

variable "regions" {
  type        = set(string)
  description = "AWS regions to onboard."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to AWS resources created."
}
