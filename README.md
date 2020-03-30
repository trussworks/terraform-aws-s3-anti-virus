
# terraform-aws-s3-anti-virus

Creates an AWS Lambda function to do anti-virus scanning of objects in AWS S3
using [bucket-antivirus-function](https://github.com/upsidetravel/bucket-antivirus-function)

While waiting for updates on that repo you will need to use a special fork and branch:

```sh
git clone git@github.com:upsidetravel/bucket-antivirus-function.git
cd bucket-antivirus-function
git checkout v2.0.0
```

With that repo checked out you must run the `make` command and then copy the resulting zip file
to AWS S3 with:

```sh
VERSION=2.0.0
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

## Terraform Versions

Terraform 0.12. Pin module version to ~> 2.0.0. Submit pull-requests to master branch.

Terraform 0.11. Pin module version to ~> 1.1.1. Submit pull-requests to terraform011 branch.

## Usage

```hcl
module "s3_anti_virus" {
  source = "trussworks/s3-anti-virus/aws"
  version = "2.1.2"

  name_scan   = "s3-anti-virus-scan"
  name_update = "s3-anti-virus-updates"

  lambda_s3_bucket = "lambda-builds-us-west-2"
  lambda_version   = "2.0.0"
  lambda_package   = "anti-virus"

  av_update_minutes = "180"
  av_scan_buckets   = ["bucket-name"]

  av_definition_s3_bucket   = "av-update-bucket-name"
  av_definition_s3_prefix   = "anti-virus"
  av_scan_start_sns_arn     = "sns-topic-name"
  av_status_sns_arn         = "sns-topic-name"

  tags = {
    "Environment" = "my-environment"
    "Purpose"     = "s3-anti-virus"
    "Terraform"   = "true"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| av\_definition\_s3\_bucket | Bucket containing antivirus database files. | `string` | n/a | yes |
| av\_definition\_s3\_prefix | Prefix for antivirus database files. | `string` | `"clamav_defs"` | no |
| av\_scan\_buckets | A list of S3 bucket names to scan for viruses. | `list(string)` | n/a | yes |
| av\_scan\_start\_sns\_arn | SNS topic ARN to publish notification about start of scan (optional). | `string` | `""` | no |
| av\_status\_sns\_arn | SNS topic ARN to publish scan results (optional). | `string` | `""` | no |
| av\_status\_sns\_publish\_clean | Publish AV\_STATUS\_CLEAN results to AV\_STATUS\_SNS\_ARN. | `string` | `"True"` | no |
| av\_status\_sns\_publish\_infected | Publish AV\_STATUS\_INFECTED results to AV\_STATUS\_SNS\_ARN. | `string` | `"True"` | no |
| av\_update\_minutes | How often to download updated Anti-Virus databases. | `string` | `180` | no |
| cloudwatch\_logs\_retention\_days | Number of days to keep logs in AWS CloudWatch. | `string` | `90` | no |
| lambda\_package | The name of the lambda package. Used for a directory tree and zip file. | `string` | `"anti-virus"` | no |
| lambda\_s3\_bucket | The name of the S3 bucket used to store the Lambda builds. | `string` | n/a | yes |
| lambda\_version | The version the Lambda function to deploy. | `string` | n/a | yes |
| name\_scan | Name for resources associated with anti-virus scanning | `string` | `"s3-anti-virus-scan"` | no |
| name\_update | Name for resources associated with anti-virus updating | `string` | `"s3-anti-virus-updates"` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| scan\_aws\_cloudwatch\_log\_group\_arn | ARN for the Anti-Virus Scanning Cloudwatch LogGroup. |
| scan\_aws\_cloudwatch\_log\_group\_name | The Anti-Virus Scanning Cloudwatch LogGroup name. |
| scan\_lambda\_function\_arn | ARN for the Anti-Virus Scanning lambda function. |
| scan\_lambda\_function\_iam\_role\_arn | Name of the Anti-Virus Scanning lambda role. |
| scan\_lambda\_function\_iam\_role\_name | Name of the Anti-Virus Scanning lambda role. |
| scan\_lambda\_function\_name | The Anti-Virus Scanning lambda function name. |
| scan\_lambda\_function\_version | Current version of the Anti-Virus Scanning lambda function. |
| update\_aws\_cloudwatch\_log\_group\_arn | ARN for the Anti-Virus Definitions Cloudwatch LogGroup. |
| update\_aws\_cloudwatch\_log\_group\_name | The Anti-Virus Definitions Cloudwatch LogGroup name. |
| update\_lambda\_function\_arn | ARN for the Anti-Virus Definitions lambda function. |
| update\_lambda\_function\_iam\_role\_arn | ARN of the Anti-Virus Definitions lambda role. |
| update\_lambda\_function\_iam\_role\_name | Name of the Anti-Virus Definitions lambda role. |
| update\_lambda\_function\_name | The Anti-Virus Definitions lambda function name. |
| update\_lambda\_function\_version | Current version of the Anti-Virus Definitions lambda function. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
