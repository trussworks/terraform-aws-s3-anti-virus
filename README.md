
# terraform-aws-s3-anti-virus

Creates an AWS Lambda function to do anti-virus scanning of objects in AWS S3
using [bucket-antivirus-function](https://github.com/trussworks/bucket-antivirus-function)

The source repository hasn't been updated in a long time, so we've forked the repo to our account and made changes.

```sh
git clone git@github.com:trussworks/bucket-antivirus-function.git
cd bucket-antivirus-function
git checkout v2.2.0
```

With that repo checked out you must run the `make` command and then copy the resulting zip file
to AWS S3 with:

```sh
VERSION=2.2.0
aws s3 cp bucket-antivirus-function/build/lambda.zip "s3://lambda-builds-us-west-2/anti-virus/${VERSION}/anti-virus.zip"
```

NOTE: It is a good idea to make `VERSION` match the git tag you are deploying.

Creates the following resources for anti-virus updates:

* IAM role for Lambda function to update Anti-Virus databases in S3
* CloudWatch Event to trigger function on a schedule.
* AWS Lambda function to download Anti-Virus databases files to S3

Creates the following resources for anti-virus scanning:

* IAM role for Lambda function to scan files in S3
* S3 Event to trigger function on object creation
* AWS Lambda function to scan S3 object and send alert to slack if any objects are infected and quarantined.


## Usage

```hcl
module "s3_anti_virus" {
  source = "trussworks/s3-anti-virus/aws"
  version = "2.1.2"

  name_scan   = "s3-anti-virus-scan"
  name_update = "s3-anti-virus-updates"

  lambda_s3_bucket = "lambda-builds-us-west-2"
  lambda_package_key   = "lambda.zip"

  av_update_minutes = "180"
  av_scan_buckets   = ["bucket-name"]

  av_definition_s3_bucket   = "av-update-bucket-name"
  av_definition_s3_prefix   = "anti-virus"

  tags = {
    "Environment" = "my-environment"
    "Purpose"     = "s3-anti-virus"
    "Terraform"   = "true"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.main_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.main_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.main_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.main_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.main_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.main_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.main_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.main_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.main_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.main_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.main_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.main_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.main_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.main_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.main_scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_av_definition_s3_bucket"></a> [av\_definition\_s3\_bucket](#input\_av\_definition\_s3\_bucket) | Bucket containing antivirus database files. | `string` | n/a | yes |
| <a name="input_av_definition_s3_prefix"></a> [av\_definition\_s3\_prefix](#input\_av\_definition\_s3\_prefix) | Prefix for antivirus database files. | `string` | `"clamav_defs"` | no |
| <a name="input_av_delete_infected_files"></a> [av\_delete\_infected\_files](#input\_av\_delete\_infected\_files) | Set it True in order to delete infected values. | `string` | `"False"` | no |
| <a name="input_av_scan_buckets"></a> [av\_scan\_buckets](#input\_av\_scan\_buckets) | A list of S3 bucket names to scan for viruses. | `list(string)` | n/a | yes |
| <a name="input_av_scan_start_sns_arn"></a> [av\_scan\_start\_sns\_arn](#input\_av\_scan\_start\_sns\_arn) | SNS topic ARN to publish notification about start of scan (optional). | `string` | `""` | no |
| <a name="input_av_status_sns_arn"></a> [av\_status\_sns\_arn](#input\_av\_status\_sns\_arn) | SNS topic ARN to publish scan results (optional). | `string` | `""` | no |
| <a name="input_av_status_sns_publish_clean"></a> [av\_status\_sns\_publish\_clean](#input\_av\_status\_sns\_publish\_clean) | Publish AV\_STATUS\_CLEAN results to AV\_STATUS\_SNS\_ARN. | `string` | `"True"` | no |
| <a name="input_av_status_sns_publish_infected"></a> [av\_status\_sns\_publish\_infected](#input\_av\_status\_sns\_publish\_infected) | Publish AV\_STATUS\_INFECTED results to AV\_STATUS\_SNS\_ARN. | `string` | `"True"` | no |
| <a name="input_av_update_minutes"></a> [av\_update\_minutes](#input\_av\_update\_minutes) | How often to download updated Anti-Virus databases. | `string` | `180` | no |
| <a name="input_cloudwatch_kms_arn"></a> [cloudwatch\_kms\_arn](#input\_cloudwatch\_kms\_arn) | The arn of the kms key used for encrypting the cloudwatch log groups created by this module. | `string` | `""` | no |
| <a name="input_cloudwatch_logs_retention_days"></a> [cloudwatch\_logs\_retention\_days](#input\_cloudwatch\_logs\_retention\_days) | Number of days to keep logs in AWS CloudWatch. | `string` | `90` | no |
| <a name="input_kms_key_sns_arn"></a> [kms\_key\_sns\_arn](#input\_kms\_key\_sns\_arn) | ARN of the KMS Key to use for SNS Encryption | `string` | `""` | no |
| <a name="input_lambda_package"></a> [lambda\_package](#input\_lambda\_package) | The name of the lambda package. Used for a directory tree and zip file. | `string` | `"anti-virus"` | no |
| <a name="input_lambda_package_key"></a> [lambda\_package\_key](#input\_lambda\_package\_key) | The object key for the lambda distribution. If given, the value is used as the key in lieu of the value constructed using `lambda_package` and `lambda_version`. | `string` | `null` | no |
| <a name="input_lambda_s3_bucket"></a> [lambda\_s3\_bucket](#input\_lambda\_s3\_bucket) | The name of the S3 bucket used to store the Lambda builds. | `string` | n/a | yes |
| <a name="input_lambda_version"></a> [lambda\_version](#input\_lambda\_version) | The version the Lambda function to deploy. | `any` | n/a | yes |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda memory allocation, in MB | `string` | `2048` | no |
| <a name="input_name_scan"></a> [name\_scan](#input\_name\_scan) | Name for resources associated with anti-virus scanning | `string` | `"s3-anti-virus-scan"` | no |
| <a name="input_name_update"></a> [name\_update](#input\_name\_update) | Name for resources associated with anti-virus updating | `string` | `"s3-anti-virus-updates"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | ARN of the boundary policy to attach to IAM roles. | `string` | `null` | no |
| <a name="input_skip_s3_notification"></a> [skip\_s3\_notification](#input\_skip\_s3\_notification) | Boolean indicating if the bucket notification should not be added. This module implementation will not operate without a bucket notification. However, since bucket notifications can only be managed once, if an implementer wants additional notifications on the bucket, they must be managed outside this module. If you give this variable as `true`, you *must* add a bucket notification to the lambda given in outputs as `scan_lambda_function_arn`. See [this issue (#510) on the provider](https://github.com/hashicorp/terraform-provider-aws/issues/501#issuecomment-445106037) for more details on the topic. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_timeout_seconds"></a> [timeout\_seconds](#input\_timeout\_seconds) | Lambda timeout, in seconds | `string` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scan_aws_cloudwatch_log_group_arn"></a> [scan\_aws\_cloudwatch\_log\_group\_arn](#output\_scan\_aws\_cloudwatch\_log\_group\_arn) | ARN for the Anti-Virus Scanning Cloudwatch LogGroup. |
| <a name="output_scan_aws_cloudwatch_log_group_name"></a> [scan\_aws\_cloudwatch\_log\_group\_name](#output\_scan\_aws\_cloudwatch\_log\_group\_name) | The Anti-Virus Scanning Cloudwatch LogGroup name. |
| <a name="output_scan_lambda_function_arn"></a> [scan\_lambda\_function\_arn](#output\_scan\_lambda\_function\_arn) | ARN for the Anti-Virus Scanning lambda function. |
| <a name="output_scan_lambda_function_iam_role_arn"></a> [scan\_lambda\_function\_iam\_role\_arn](#output\_scan\_lambda\_function\_iam\_role\_arn) | Name of the Anti-Virus Scanning lambda role. |
| <a name="output_scan_lambda_function_iam_role_name"></a> [scan\_lambda\_function\_iam\_role\_name](#output\_scan\_lambda\_function\_iam\_role\_name) | Name of the Anti-Virus Scanning lambda role. |
| <a name="output_scan_lambda_function_name"></a> [scan\_lambda\_function\_name](#output\_scan\_lambda\_function\_name) | The Anti-Virus Scanning lambda function name. |
| <a name="output_scan_lambda_function_version"></a> [scan\_lambda\_function\_version](#output\_scan\_lambda\_function\_version) | Current version of the Anti-Virus Scanning lambda function. |
| <a name="output_update_aws_cloudwatch_log_group_arn"></a> [update\_aws\_cloudwatch\_log\_group\_arn](#output\_update\_aws\_cloudwatch\_log\_group\_arn) | ARN for the Anti-Virus Definitions Cloudwatch LogGroup. |
| <a name="output_update_aws_cloudwatch_log_group_name"></a> [update\_aws\_cloudwatch\_log\_group\_name](#output\_update\_aws\_cloudwatch\_log\_group\_name) | The Anti-Virus Definitions Cloudwatch LogGroup name. |
| <a name="output_update_lambda_function_arn"></a> [update\_lambda\_function\_arn](#output\_update\_lambda\_function\_arn) | ARN for the Anti-Virus Definitions lambda function. |
| <a name="output_update_lambda_function_iam_role_arn"></a> [update\_lambda\_function\_iam\_role\_arn](#output\_update\_lambda\_function\_iam\_role\_arn) | ARN of the Anti-Virus Definitions lambda role. |
| <a name="output_update_lambda_function_iam_role_name"></a> [update\_lambda\_function\_iam\_role\_name](#output\_update\_lambda\_function\_iam\_role\_name) | Name of the Anti-Virus Definitions lambda role. |
| <a name="output_update_lambda_function_name"></a> [update\_lambda\_function\_name](#output\_update\_lambda\_function\_name) | The Anti-Virus Definitions lambda function name. |
| <a name="output_update_lambda_function_version"></a> [update\_lambda\_function\_version](#output\_update\_lambda\_function\_version) | Current version of the Anti-Virus Definitions lambda function. |
<!-- END_TF_DOCS -->