variables {
  tags = {
    Environment = "test"
    Module      = "terraform-polaris-aws-account"
    TestSuite   = "with_ec2_recovery_role_path"
  }
}

run "aws_account_with_ec2_recovery_role_path" {
  variables {
    ec2_recovery_role_path = format("arn:aws:iam::%s:role/EC2-Recovery-Role", var.account_id)
  }

  # polaris_aws_cnp_permissions data source.
  assert {
    condition     = length(data.polaris_aws_cnp_permissions.permissions) == 1
    error_message = "The number of permissions instances does not match the expected value."
  }
  assert {
    condition     = data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].ec2_recovery_role_path == var.ec2_recovery_role_path
    error_message = "The ec2 recovery role path does not match the expected value."
  }
  assert {
    condition = length(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies) == 1
    error_message = "The number of customer managed policies does not match the expected value."
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

  # aws_iam_role resource.
  assert {
    condition     = length(aws_iam_role.role) == 1
    error_message = "The number of role instances does not match the expected value."
  }
  assert {
    condition = length(aws_iam_role.role["CROSSACCOUNT"].inline_policy) == 1
    error_message = "The number of inline policies does not match the expected value."
  }
  assert {
    condition = one(aws_iam_role.role["CROSSACCOUNT"].inline_policy[*].name) == "EC2ProtectionPolicy"
    error_message = "The inline policy name does not match the expected value."
  }
  assert {
    # Make sure the JSON documents are ordered and formatted the same way.
    condition = jsonencode(jsondecode(one(aws_iam_role.role["CROSSACCOUNT"].inline_policy[*].policy))) == jsonencode(jsondecode(data.polaris_aws_cnp_permissions.permissions["CROSSACCOUNT"].customer_managed_policies[0].policy))
    error_message = "The inline policy policy does not match the expected value."
  }
}
