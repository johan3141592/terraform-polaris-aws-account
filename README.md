# Polaris AWS Account Terraform Module
Terraform module which creates AWS account resources in RSC.

## Usage

```hcl
module "aws_account" {
  source = "terraform-polaris-aws-account"

  account_id   = "123456789012"
  account_name = "my-aws-account"

  features = {
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
    },
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
        "RSC_MANAGED_CLUSTER",
      ]
    }
  }

  regions = [
    "us-east-1",
  ]

  tags = {
    Environment = "dev"
  }
}
```

## Examples

- [Basic AWS Account](https://github.com/johan3141592/terraform-polaris-aws-account/tree/main/examples/basic)

## Requirements

| Name      | Version |
|-----------|---------|
| terraform | >= 1.7  |
| aws       | ~= 5.50 |
| polaris   | >= 1.0  |

## Providers

| Name     | Version |
|----------|---------|
| aws      | ~= 5.50 |
| polaris  | >= 1.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                 | Type        |
|------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/5.55.0/docs/resources/iam_instance_profile)                         | resource    |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/5.55.0/docs/resources/iam_role)                                                 | resource    |
| [polaris_aws_cnp_account](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_cnp_account)                           | resource    |
| [polaris_aws_cnp_account_attachments](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_cnp_account_attachments)   | resource    |
| [polaris_aws_cnp_account_trust_policy](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_cnp_account_trust_policy) | resource    |
| [polaris_account](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/account)                                        | data source |
| [polaris_aws_cnp_artifacts](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/aws_cnp_artifacts)                    | data source |
| [polaris_aws_cnp_permissions](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/aws_cnp_permissions)                | data source |

## Inputs

| Name                   | Description                            | Type          | Default      | Required |
|------------------------|----------------------------------------|---------------|--------------|:--------:|
| account_id             | AWS account ID                         | `string`      |              |   yes    |
| account_name           | AWS account name                       | `string`      |              |   yes    |
| cloud_type             | AWS cloud type                         | `string`      | `"STANDARD"` |    no    |
| ec2_recovery_role_path | AWS EC2 recovery role path             | `string`      | `""`         |    no    |
| external_id            | AWS external ID                        | `string`      | `""`         |    no    |
| features               | RSC features with permission groups    | `map(object)` |              |   yes    |
| role_path              | AWS role path.                         | `string`      | `"/"`        |    no    |
| regions                | AWS regions to onboard                 | `set(string)` |              |   yes    |
| tags                   | Tags to apply to AWS resources created | `map(string)` | `{}`         |    no    |

## Outputs

| Name             | Description               |
|------------------|---------------------------|
| cloud_account_id | The RSC cloud account ID  |
