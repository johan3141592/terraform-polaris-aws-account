variables {
  tags = {
    Environment = "test"
    Module      = "terraform-polaris-aws-account"
    TestSuite   = "validation"
  }
}

run "cloud_type_invalid_type" {
  command = plan

  variables {
    cloud_type = "CLOUD"
  }
  expect_failures = [
      var.cloud_type
  ]
}

run "features_invalid_feature_name" {
  command = plan

  variables {
    features = {
      CLOWN_NATIVE_PROTECTION = {
        permission_groups = ["BASIC"]
      }
    }
  }
  expect_failures = [
      var.features
  ]
}

run "features_invalid_permission_group" {
  command = plan

  variables {
    features = {
      CLOUD_NATIVE_PROTECTION = {
        permission_groups = ["ADVANCED"]
      }
    }
  }
  expect_failures = [
    var.features
  ]
}

run "role_path_no_slash_at_the_beginning" {
  command = plan

  variables {
    role_path = "application/component/"
  }
  expect_failures = [
    var.role_path
  ]
}

run "role_path_no_slash_at_the_end" {
  command = plan

  variables {
    role_path = "/application/component"
  }
  expect_failures = [
    var.role_path
  ]
}
