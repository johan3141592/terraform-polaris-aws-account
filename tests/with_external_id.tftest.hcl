variables {
  tags = {
    Environment = "test"
    Module      = "terraform-polaris-aws-account"
    TestSuite   = "with_external_id"
  }
}

run "aws_account_with_external_id" {
  variables {
    external_id = "Unique-External-ID"
  }

  # polaris_aws_cnp_account resource.
  assert {
    condition     = polaris_aws_cnp_account.account.external_id == var.external_id
    error_message = "The external ID does not match the expected value."
  }

  # polaris_aws_cnp_account_trust_policy resource.
  assert {
    condition     = length(polaris_aws_cnp_account_trust_policy.trust_policy) == 1
    error_message = "The number of trust policy instances does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account_trust_policy.trust_policy["CROSSACCOUNT"].id == polaris_aws_cnp_account.account.id
    error_message = "The resource ID does not match the expected value."
  }
  assert {
    condition     = polaris_aws_cnp_account_trust_policy.trust_policy["CROSSACCOUNT"].external_id == var.external_id
    error_message = "The external ID does not match the expected value."
  }
  assert {
    condition     = can(regex(var.external_id, polaris_aws_cnp_account_trust_policy.trust_policy["CROSSACCOUNT"].policy))
    error_message = "The policy does not match the expected value."
  }

  # aws_iam_role resource.
  assert {
    condition     = length(aws_iam_role.role) == 1
    error_message = "The number of role instances does not match the expected value."
  }
  assert {
    # Make sure the JSON documents are ordered and formatted the same way.
    condition     = jsonencode(jsondecode(aws_iam_role.role["CROSSACCOUNT"].assume_role_policy)) == jsonencode(jsondecode(polaris_aws_cnp_account_trust_policy.trust_policy["CROSSACCOUNT"].policy))
    error_message = "The assume role policy does not match the expected value."
  }
}
