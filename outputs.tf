output "cloud_account_id" {
  value       = polaris_aws_cnp_account.account.id
  description = "RSC cloud account ID."

  precondition {
    condition     = can(regex(local.uuid_regex, polaris_aws_cnp_account.account.id)) && polaris_aws_cnp_account.account.id != local.uuid_null
    error_message = "The RSC cloud account ID must be a valid UUID."
  }
}
