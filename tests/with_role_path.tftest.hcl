variables {
  tags = {
    Environment = "test"
    Module      = "terraform-polaris-aws-account"
    TestSuite   = "with_role_path"
  }
}

run "aws_account_with_role_path" {
  variables {
    role_path = "/application/component/"
  }

  # aws_iam_role resource.
  assert {
    condition     = length(aws_iam_role.role) == 1
    error_message = "The number of role instances does not match the expected value."
  }
  assert {
    condition     = aws_iam_role.role["CROSSACCOUNT"].path == var.role_path
    error_message = "The path does not match the expected value."
  }
}
