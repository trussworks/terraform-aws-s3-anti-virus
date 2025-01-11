
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
| terraform | >= 1.0 |
| aws | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

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
| av_definition_s3_bucket | Bucket containing antivirus database files. | `string` | n/a | yes |
| av_definition_s3_prefix | Prefix for antivirus database files. | `string` | `"clamav_defs"` | no |
| av_delete_infected_files | Set it True in order to delete infected values. | `string` | `"False"` | no |
| av_scan_buckets | A list of S3 bucket names to scan for viruses. | `list(string)` | n/a | yes |
| av_scan_start_sns_arn | SNS topic ARN to publish notification about start of scan (optional). | `string` | `""` | no |
| av_status_sns_arn | SNS topic ARN to publish scan results (optional). | `string` | `""` | no |
| av_status_sns_publish_clean | Publish AV_STATUS_CLEAN results to AV_STATUS_SNS_ARN. | `string` | `"True"` | no |
| av_status_sns_publish_infected | Publish AV_STATUS_INFECTED results to AV_STATUS_SNS_ARN. | `string` | `"True"` | no |
| av_update_minutes | How often to download updated Anti-Virus databases. | `string` | `180` | no |
| cloudwatch_kms_arn | The arn of the kms key used for encrypting the cloudwatch log groups created by this module. | `string` | `""` | no |
| cloudwatch_logs_retention_days | Number of days to keep logs in AWS CloudWatch. | `string` | `90` | no |
| kms_key_sns_arn | ARN of the KMS Key to use for SNS Encryption | `string` | `""` | no |
| lambda_package | The name of the lambda package. Used for a directory tree and zip file. | `string` | `"anti-virus"` | no |
| lambda_package_key | The object key for the lambda distribution. If given, the value is used as the key in lieu of the value constructed using `lambda_package` and `lambda_version`. | `string` | `null` | no |
| lambda_s3_bucket | The name of the S3 bucket used to store the Lambda builds. | `string` | n/a | yes |
| lambda_version | The version the Lambda function to deploy. | `any` | n/a | yes |
| memory_size | Lambda memory allocation, in MB | `string` | `2048` | no |
| name_scan | Name for resources associated with anti-virus scanning | `string` | `"s3-anti-virus-scan"` | no |
| name_update | Name for resources associated with anti-virus updating | `string` | `"s3-anti-virus-updates"` | no |
| permissions_boundary | ARN of the boundary policy to attach to IAM roles. | `string` | `null` | no |
| skip_s3_notification | Boolean indicating if the bucket notification should not be added. This module implementation will not operate without a bucket notification. However, since bucket notifications can only be managed once, if an implementer wants additional notifications on the bucket, they must be managed outside this module. If you give this variable as `true`, you *must* add a bucket notification to the lambda given in outputs as `scan_lambda_function_arn`. See [this issue (#510) on the provider](https://github.com/hashicorp/terraform-provider-aws/issues/501#issuecomment-445106037) for more details on the topic. | `bool` | `false` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| timeout_seconds | Lambda timeout, in seconds | `string` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| scan_aws_cloudwatch_log_group_arn | ARN for the Anti-Virus Scanning Cloudwatch LogGroup. |
| scan_aws_cloudwatch_log_group_name | The Anti-Virus Scanning Cloudwatch LogGroup name. |
| scan_lambda_function_arn | ARN for the Anti-Virus Scanning lambda function. |
| scan_lambda_function_iam_role_arn | Name of the Anti-Virus Scanning lambda role. |
| scan_lambda_function_iam_role_name | Name of the Anti-Virus Scanning lambda role. |
| scan_lambda_function_name | The Anti-Virus Scanning lambda function name. |
| scan_lambda_function_version | Current version of the Anti-Virus Scanning lambda function. |
| update_aws_cloudwatch_log_group_arn | ARN for the Anti-Virus Definitions Cloudwatch LogGroup. |
| update_aws_cloudwatch_log_group_name | The Anti-Virus Definitions Cloudwatch LogGroup name. |
| update_lambda_function_arn | ARN for the Anti-Virus Definitions lambda function. |
| update_lambda_function_iam_role_arn | ARN of the Anti-Virus Definitions lambda role. |
| update_lambda_function_iam_role_name | Name of the Anti-Virus Definitions lambda role. |
| update_lambda_function_name | The Anti-Virus Definitions lambda function name. |
| update_lambda_function_version | Current version of the Anti-Virus Definitions lambda function. |
<!-- END_TF_DOCS -->