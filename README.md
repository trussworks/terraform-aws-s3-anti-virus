
# terraform-aws-s3-anti-virus

Creates an AWS Lambda function to do anti-virus scanning of objects in AWS S3
using [bucket-antivirus-function](https://github.com/upsidetravel/bucket-antivirus-function)

While waiting for updates on that repo you will need to use a special resitory:

```sh
git clone git@github.com:upsidetravel/bucket-antivirus-function.git
cd bucket-antivirus-function
```

With that repo checked out you must run the `make all` command and then copy the resulting zip file to AWS S3 with:

```sh
aws s3 cp bucket-antivirus-function/build/lambda.zip "s3://your-s3-bucket-for-lambda-dependencies/lambda.zip"
```

or use the [s3_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) resource in your Terraform code

```hcl
...

resource "aws_s3_bucket_object" "function_zip" {
  ## https://github.com/upsidetravel/bucket-antivirus-function
  bucket = module.s3_bucket_dependencies.bucket_id
  key    = "lambda.zip"
  source = "./bucket-antivirus-function/build/lambda.zip"
  etag   = filemd5("./bucket-antivirus-function/build/lambda.zip")
  ...
}

...
```

Creates the following resources for anti-virus updates:

* IAM role for Lambda function to update Anti-Virus databases in S3
* CloudWatch Event to trigger function on a schedule.
* AWS Lambda function to download Anti-Virus databases files to S3

Creates the following resources for anti-virus scanning:

* IAM role for Lambda function to scan files in S3
* S3 Event to trigger function on object creation
* AWS Lambda function to scan S3 object and send alert to slack if any objects are infected and quarantined.

## Terraform Versions

Terraform 0.13 and newer. Pin module version to `~> 3.X`. Submit pull-requests to `main` branch.

Terraform 0.12. Pin module version to `~> 2.X`. Submit pull-requests to `terraform012` branch.

## Usage

```hcl
module "s3_anti_virus" {
  source = "trussworks/s3-anti-virus/aws"
  version = "2.1.2"

  name_scan   = "s3-anti-virus-scan"
  name_update = "s3-anti-virus-updates"

  lambda_s3_bucket            = "lambda-builds-us-west-2"
  lambda_s3_object_key        = "lambda.zip"

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

## Example

```hcl
...

locals {
  dir_source_code_function = "temp/bucket-antivirus-function"
  dir_build                = "temp/build"
  s3_object_clamav_func    = "Lambda_Function/lambda.zip"
}

resource "null_resource" "build_function" {
  triggers = {
    md5file = try(filemd5("./${local.dir_build}/lambda.zip"), timestamp())
  }

  ## Docker is required on your local machine!
  ## https://www.docker.com/get-started
  ##
  provisioner "local-exec" {
    interpreter = ["docker"]
    command     = "-v"
  }

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ./${local.dir_source_code_function} ./${local.dir_build} &&
      git clone git@github.com:upsidetravel/bucket-antivirus-function.git ./${local.dir_source_code_function} &&
      docker build -t bucket-antivirus-function:latest $(pwd)/${local.dir_source_code_function} &&
      docker run -v $(pwd)/${local.dir_build}:/opt/mount --rm --entrypoint cp bucket-antivirus-function:latest /opt/app/build/lambda.zip /opt/mount/lambda.zip &&
      rm -rf ./${local.dir_source_code_function}
    EOT
  }
}

resource "aws_s3_bucket_object" "function_zip" {
  ## https://github.com/upsidetravel/bucket-antivirus-function
  ## Remote
  bucket = module.s3_bucket_dependencies.bucket_id
  key    = local.s3_object_clamav_func

  ## Local
  source = "./${local.dir_build}/lambda.zip"
  etag   = try(filemd5("./${local.dir_build}/lambda.zip"), null)
  tags   = module.naming.tags

  depends_on = [
    null_resource.build_function
  ]
}

module "s3_anti_virus" {
  ## https://github.com/trussworks/terraform-aws-s3-anti-virus
  ## https://registry.terraform.io/modules/trussworks/s3-anti-virus/aws/latest
  source  = "trussworks/s3-anti-virus/aws"
  version = "~> x.x.x"

  name_scan   = "${module.naming.id}-scan"
  name_update = "${module.naming.id}-updates"

  ## https://github.com/upsidetravel/bucket-antivirus-function
  lambda_s3_bucket     = module.s3_bucket_dependencies.bucket_id
  lambda_s3_object_key = aws_s3_bucket_object.function_zip.key

  av_update_schedule_expression = "rate(6 hours)"
  av_definition_s3_bucket       = module.s3_bucket_dependencies.bucket_id
  av_definition_s3_prefix       = "ClamAV_Virus_Database"

  av_scan_buckets = [
    module.s3_bucket_test_1.bucket_id,
    module.s3_bucket_test_2.bucket_id
  ]

  depends_on = [
    module.s3_bucket_dependencies,
    aws_s3_bucket_object.function_zip
  ]

  tags = module.naming.tags
}
...
```

## TODO

[ ] Add directory with examples
[ ] Add lambda function build to the module using local-exec.
[ ] ^ Don't forget to check the installed docker on the local machine
[ ] Fix permanent triggers and false positives with source_account `(known after apply) # forces replacement

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
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
| <a name="input_av_definition_path"></a> [av\_definition\_path](#input\_av\_definition\_path) | Path containing files at runtime | `string` | `"/tmp/clamav_defs"` | no |
| <a name="input_av_definition_s3_bucket"></a> [av\_definition\_s3\_bucket](#input\_av\_definition\_s3\_bucket) | Bucket containing antivirus database files. | `string` | n/a | yes |
| <a name="input_av_definition_s3_prefix"></a> [av\_definition\_s3\_prefix](#input\_av\_definition\_s3\_prefix) | Prefix for antivirus database files. | `string` | `"clamav_defs"` | no |
| <a name="input_av_delete_infected_files"></a> [av\_delete\_infected\_files](#input\_av\_delete\_infected\_files) | Set it True in order to delete infected values. | `bool` | `false` | no |
| <a name="input_av_process_original_version_only"></a> [av\_process\_original\_version\_only](#input\_av\_process\_original\_version\_only) | Controls that only original version of an S3 key is processed (if bucket versioning is enabled) | `bool` | `false` | no |
| <a name="input_av_scan_buckets"></a> [av\_scan\_buckets](#input\_av\_scan\_buckets) | A list of S3 bucket names to scan for viruses. | `list(string)` | n/a | yes |
| <a name="input_av_scan_start_metadata"></a> [av\_scan\_start\_metadata](#input\_av\_scan\_start\_metadata) | The tag/metadata indicating the start of the scan | `string` | `"av-scan-start"` | no |
| <a name="input_av_scan_start_sns_arn"></a> [av\_scan\_start\_sns\_arn](#input\_av\_scan\_start\_sns\_arn) | SNS topic ARN to publish notification about start of scan (optional). | `string` | `null` | no |
| <a name="input_av_signature_metadata"></a> [av\_signature\_metadata](#input\_av\_signature\_metadata) | The tag/metadata name representing file's AV type | `string` | `"av-signature"` | no |
| <a name="input_av_status_clean"></a> [av\_status\_clean](#input\_av\_status\_clean) | The value assigned to clean items inside of tags/metadata | `string` | `"CLEAN"` | no |
| <a name="input_av_status_infected"></a> [av\_status\_infected](#input\_av\_status\_infected) | The value assigned to clean items inside of tags/metadata | `string` | `"INFECTED"` | no |
| <a name="input_av_status_metadata"></a> [av\_status\_metadata](#input\_av\_status\_metadata) | The tag/metadata name representing file's AV status | `string` | `"av-status"` | no |
| <a name="input_av_status_sns_arn"></a> [av\_status\_sns\_arn](#input\_av\_status\_sns\_arn) | SNS topic ARN to publish scan results (optional). | `string` | `null` | no |
| <a name="input_av_status_sns_publish_clean"></a> [av\_status\_sns\_publish\_clean](#input\_av\_status\_sns\_publish\_clean) | Publish AV\_STATUS\_CLEAN results to AV\_STATUS\_SNS\_ARN. | `bool` | `true` | no |
| <a name="input_av_status_sns_publish_infected"></a> [av\_status\_sns\_publish\_infected](#input\_av\_status\_sns\_publish\_infected) | Publish AV\_STATUS\_INFECTED results to AV\_STATUS\_SNS\_ARN. | `bool` | `true` | no |
| <a name="input_av_timestamp_metadata"></a> [av\_timestamp\_metadata](#input\_av\_timestamp\_metadata) | The tag/metadata name representing file's scan time | `string` | `"av-timestamp"` | no |
| <a name="input_av_update_minutes"></a> [av\_update\_minutes](#input\_av\_update\_minutes) | How often to download updated Anti-Virus databases. | `number` | `null` | no |
| <a name="input_av_update_schedule_expression"></a> [av\_update\_schedule\_expression](#input\_av\_update\_schedule\_expression) | A new, more flexible option for the scheduler. Not working if `av_update_minutes` variable is set. The scheduling expression how often to download updated Anti-Virus databases. [For example, cron(0 20 * * ? *) or rate(180 minutes)](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html) | `string` | `"rate(180 minutes)"` | no |
| <a name="input_clamavlib_path"></a> [clamavlib\_path](#input\_clamavlib\_path) | Path to ClamAV library files | `string` | `"./bin"` | no |
| <a name="input_cloudwatch_logs_retention_days"></a> [cloudwatch\_logs\_retention\_days](#input\_cloudwatch\_logs\_retention\_days) | Number of days to keep logs in AWS CloudWatch. | `number` | `90` | no |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | API Key for pushing metrics to DataDog (optional) | `string` | `null` | no |
| <a name="input_event_source"></a> [event\_source](#input\_event\_source) | The source of antivirus scan event "S3" or "SNS" (optional) | `string` | `"S3"` | no |
| <a name="input_lambda_package"></a> [lambda\_package](#input\_lambda\_package) | Deprecated. The name of the lambda package. Used for a directory tree and zip file. | `string` | `"anti-virus"` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Identifier of the function's runtime. | `string` | `"python3.7"` | no |
| <a name="input_lambda_s3_bucket"></a> [lambda\_s3\_bucket](#input\_lambda\_s3\_bucket) | The name of the S3 bucket used to store the Lambda builds. | `string` | n/a | yes |
| <a name="input_lambda_s3_object_key"></a> [lambda\_s3\_object\_key](#input\_lambda\_s3\_object\_key) | The object key for the lambda distribution. If given, the value is used as the key in lieu of the value constructed using `lambda_package` and `lambda_version`. | `string` | `null` | no |
| <a name="input_lambda_version"></a> [lambda\_version](#input\_lambda\_version) | Deprecated. The version the Lambda function to deploy. | `string` | `"2.0.0"` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda memory allocation, in MB | `number` | `2048` | no |
| <a name="input_name_scan"></a> [name\_scan](#input\_name\_scan) | Name for resources associated with anti-virus scanning | `string` | `"s3-anti-virus-scan"` | no |
| <a name="input_name_update"></a> [name\_update](#input\_name\_update) | Name for resources associated with anti-virus updating | `string` | `"s3-anti-virus-updates"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | ARN of the boundary policy to attach to IAM roles. | `string` | `null` | no |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | The Endpoint to use when interacting wth S3 | `string` | `null` | no |
| <a name="input_sns_endpoint"></a> [sns\_endpoint](#input\_sns\_endpoint) | The Endpoint to use when interacting wth SNS | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_timeout_seconds"></a> [timeout\_seconds](#input\_timeout\_seconds) | Lambda timeout, in seconds | `number` | `300` | no |

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
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
