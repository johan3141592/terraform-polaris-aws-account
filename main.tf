data "polaris_account" "account" {
  lifecycle {
    postcondition {
      condition     = length(setsubtract(keys(var.features), self.features)) == 0
      error_message = "RSC account does not support all features specified."
    }
  }
}

# Lookup the instance profiles and roles needed for the RSC features.
data "polaris_aws_cnp_artifacts" "artifacts" {
  cloud = var.cloud_type

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value["permission_groups"]
    }
  }
}

# Lookup the permission set, customer managed policies and managed policies,
# for each role given the current feature set.
data "polaris_aws_cnp_permissions" "permissions" {
  for_each               = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  cloud                  = var.cloud_type
  ec2_recovery_role_path = var.ec2_recovery_role_path
  role_key               = each.key

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value["permission_groups"]
    }
  }
}

# Create an AWS cloud account resource in RSC.
resource "polaris_aws_cnp_account" "account" {
  cloud       = var.cloud_type
  external_id = var.external_id
  name        = var.account_name
  native_id   = var.account_id
  regions     = var.regions

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value["permission_groups"]
    }
  }
}

resource "polaris_aws_cnp_account_trust_policy" "trust_policy" {
  for_each    = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  account_id  = polaris_aws_cnp_account.account.id
  features    = keys(var.features)
  external_id = var.external_id
  role_key    = each.key
}

resource "aws_iam_role" "role" {
  for_each            = data.polaris_aws_cnp_artifacts.artifacts.role_keys
  assume_role_policy  = polaris_aws_cnp_account_trust_policy.trust_policy[each.key].policy
  managed_policy_arns = data.polaris_aws_cnp_permissions.permissions[each.key].managed_policies
  name_prefix         = "rubrik-${lower(each.key)}-"
  path                = var.role_path
  tags                = var.tags

  dynamic "inline_policy" {
    for_each = data.polaris_aws_cnp_permissions.permissions[each.key].customer_managed_policies
    content {
      name   = inline_policy.value["name"]
      policy = inline_policy.value["policy"]
    }
  }
}

resource "aws_iam_instance_profile" "profile" {
  for_each    = data.polaris_aws_cnp_artifacts.artifacts.instance_profile_keys
  name_prefix = "rubrik-${lower(each.key)}-"
  role        = aws_iam_role.role[each.value].name
  tags        = var.tags
}

# Attach the instance profiles and the roles to the RSC cloud account.
resource "polaris_aws_cnp_account_attachments" "attachments" {
  account_id = polaris_aws_cnp_account.account.id
  features   = keys(var.features)

  dynamic "instance_profile" {
    for_each = aws_iam_instance_profile.profile
    content {
      key  = instance_profile.key
      name = instance_profile.value["arn"]
    }
  }

  dynamic "role" {
    for_each = aws_iam_role.role
    content {
      key         = role.key
      arn         = role.value["arn"]
      permissions = data.polaris_aws_cnp_permissions.permissions[role.key].id
    }
  }
}
