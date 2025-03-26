variables {
  tags = {
    Environment = "test"
    Module      = "terraform-polaris-aws-account"
    TestSuite   = "basic"
  }
}

run "aws_account" {
  # polaris_aws_cnp_artifacts data source.
  assert {
    condition     = data.polaris_aws_cnp_artifacts.artifacts.cloud == var.cloud_type
    error_message = "The cloud type does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(data.polaris_aws_cnp_artifacts.artifacts.feature.*.name, ["CLOUD_NATIVE_PROTECTION"])) == 0
    error_message = "The feature names does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(data.polaris_aws_cnp_artifacts.artifacts.role_keys, ["CROSSACCOUNT"])) == 0
    error_message = "The role keys does not match the expected value."
  }
  assert {
    condition     = length(data.polaris_aws_cnp_artifacts.artifacts.instance_profile_keys) == 0
    error_message = "The instance profiles does not match the expected value."
  }

  # polaris_aws_cnp_permissions data source.
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions) == 1
    error_message = "The number of permissions instances does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].cloud == var.cloud_type
    error_message = "The cloud type does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].ec2_recovery_role_path == null
    error_message = "The ec2 recovery role path does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].role_key == "CROSSACCOUNT"
    error_message = "The role keys does not match the expected value."
  }
  assert {
    condition = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[0].feature == "CLOUD_NATIVE_PROTECTION"
    error_message = "The customer managed policies feature does not match the expected value."
  }
  assert {
    condition = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[0].name == "EC2ProtectionPolicy"
    error_message = "The customer managed policies name does not match the expected value."
  }
  assert {
    condition = can(regex(var.ec2_recovery_role_path, data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[0].policy))
    error_message = "The customer managed policies policy does not match the expected value."
  }

  # polaris_aws_cnp_account resource.
  assert {
    condition     = length(polaris_aws_cnp_account.account.id) == 36 && polaris_aws_cnp_account.account.id != "00000000-0000-0000-0000-000000000000"
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.cloud == var.cloud_type
    error_message = "The cloud type does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.name == var.account_name
    error_message = "The name does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.native_id == var.account_id
    error_message = "The account ID does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account.account.feature) == 1
    error_message = "The number of features does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account.account.feature.*.name, ["CLOUD_NATIVE_PROTECTION"])) == 0
    error_message = "The feature does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.external_id == var.external_id
    error_message = "The external ID does not match the expected value."
  }
  assert {
    condition = length(polaris_aws_cnp_account.account.regions) == length(var.regions)
    error_message = "The number of regions does not match the expected value."
  }
  assert {
    condition = length(setsubtract(polaris_aws_cnp_account.account.regions, var.regions)) == 0
    error_message = "The regions does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.id == output.cloud_account_id
    error_message = "The cloud account ID output does not match the expected value."
  }

  # polaris_aws_cnp_account_attachments resource.
  assert {
    condition     = polaris_aws_cnp_account_attachments.attachments.id == polaris_aws_cnp_account.account.id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account_attachments.attachments.account_id == polaris_aws_cnp_account.account.id
    error_message = "The account ID does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.features) == 1
    error_message = "The number of features does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account_attachments.attachments.features, ["CLOUD_NATIVE_PROTECTION"])) == 0
    error_message = "The features does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.instance_profile) == 0
    error_message = "The instance profile does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.role) == 1
    error_message = "The role does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account_attachments.attachments.role.*.key) == "CROSSACCOUNT"
    error_message = "The role key does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account_attachments.attachments.role.*.arn) == aws_iam_role.role["CROSSACCOUNT"].arn
    error_message = "The role ARN does not match the expected value."
  }
  assert {
    condition     = length(one(polaris_aws_cnp_account_attachments.attachments.role.*.permissions)) == 64
    error_message = "The role permissions does not match the expected value."
  }
}

run "update_features" {
  variables {
    features = {
      CLOUD_NATIVE_PROTECTION = {
        permission_groups = ["BASIC"]
      },
      EXOCOMPUTE = {
        permission_groups = ["BASIC", "RSC_MANAGED_CLUSTER"]
      }
    }
  }

  # polaris_aws_cnp_artifacts data source.
  assert {
    condition     = length(setsubtract(data.polaris_aws_cnp_artifacts.artifacts.role_keys, ["CROSSACCOUNT", "EXOCOMPUTE_EKS_MASTERNODE", "EXOCOMPUTE_EKS_WORKERNODE"])) == 0
    error_message = "The role keys does not match the expected value."
  }

  # polaris_aws_cnp_account resource.
  assert {
    # Make sure the account resource isn't recreated.
    condition     = polaris_aws_cnp_account.account.id == run.aws_account.cloud_account_id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account.account.feature.*.name, ["CLOUD_NATIVE_PROTECTION", "EXOCOMPUTE"])) == 0
    error_message = "The feature names does not match the expected value."
  }

  # polaris_aws_cnp_account_attachments resource.
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.instance_profile) == 1
    error_message = "The instance profile does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account_attachments.attachments.instance_profile.*.key) == "EXOCOMPUTE_EKS_WORKERNODE"
    error_message = "The role key does not match the expected value."
  }
  assert {
    condition     = one(polaris_aws_cnp_account_attachments.attachments.instance_profile.*.name) == aws_iam_instance_profile.profile["EXOCOMPUTE_EKS_WORKERNODE"].arn
    error_message = "The role ARN does not match the expected value."
  }
  assert {
    condition     = length(polaris_aws_cnp_account_attachments.attachments.role) == 3
    error_message = "The role does not match the expected value."
  }
  assert {
    condition     = length(setsubtract(polaris_aws_cnp_account_attachments.attachments.role.*.key, ["CROSSACCOUNT", "EXOCOMPUTE_EKS_MASTERNODE", "EXOCOMPUTE_EKS_WORKERNODE"])) == 0
    error_message = "The role key does not match the expected value."
  }
}

run "update_name" {
  variables {
    account_name = "Updated Name"
  }

  # polaris_aws_cnp_account resource.
  assert {
    # Make sure the account resource isn't recreated.
    condition     = polaris_aws_cnp_account.account.id == run.aws_account.cloud_account_id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account.account.name == var.account_name
    error_message = "The name does not match the expected value."
  }
}

run "update_regions" {
  variables {
    regions = concat(var.regions, ["eu-north-1"])
  }

  # polaris_aws_cnp_account resource.
  assert {
    # Make sure the account resource isn't recreated.
    condition     = polaris_aws_cnp_account.account.id == run.aws_account.cloud_account_id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition = length(polaris_aws_cnp_account.account.regions) == length(var.regions)
    error_message = "The number of regions does not match the expected value."
  }
  assert {
    condition = length(setsubtract(polaris_aws_cnp_account.account.regions, var.regions)) == 0
    error_message = "The regions does not match the expected value."
  }
}
