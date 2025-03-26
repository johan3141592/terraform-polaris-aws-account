# Basic AWS Account
The configuration in this directory creates an RSC AWS account resource and the required AWS roles.

## Usage
To run this example you need to execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these
resources.

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

| Name        | Source | Version |
|-------------|--------|---------|
| aws_account | ../../ | n/a     |

## Inputs

| Name                 | Description          |
|----------------------|----------------------|
| example_account_id   | The AWS account ID   |
| example_account_name | The AWS account name |

## Outputs

| Name             | Description              |
|------------------|--------------------------|
| cloud_account_id | The RSC cloud account ID |
