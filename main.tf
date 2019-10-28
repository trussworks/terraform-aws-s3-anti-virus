/**
 *
 * # terraform-aws-s3-anti-virus
 *
 * Creates an AWS Lambda function to do anti-virus scanning of objects in AWS S3
 * using [bucket-antivirus-function](https://github.com/upsidetravel/bucket-antivirus-function)
 *
 * While waiting for updates on that repo you will need to use a special fork and branch:
 *
 * ```sh
 * git clone git@github.com:upsidetravel/bucket-antivirus-function.git
 * cd bucket-antivirus-function
 * git checkout master
 * ```
 *
 * With that repo checked out you must run the `make` command and then copy the resulting zip file
 * to AWS S3 with:
 *
 * ```sh
 * aws s3 cp bucket-antivirus-function/build/lambda.zip s3://lambda-builds-us-west-2/anti-virus/VERSION/anti-virus.zip
 * ```
 *
 * Creates the following resources for anti-virus updates:
 *
 * * IAM role for Lambda function to update Anti-Virus databases in S3
 * * CloudWatch Event to trigger function on a schedule.
 * * AWS Lambda function to download Anti-Virus databases files to S3
 *
 * Creates the following resources for anti-virus scanning:
 *
 * * IAM role for Lambda function to scan files in S3
 * * S3 Event to trigger function on object creation
 * * AWS Lambda function to scan S3 object and send alert to slack if any objects are infected and quarantined.
 *
 * ## Usage
 *
 * ```hcl
 * module "s3_anti_virus" {
 *   source = "trussworks/s3-anti-virus/aws"
 *   version = "1.0.0"
 *
 *   lambda_s3_bucket = "lambda-builds-us-west-2"
 *   lambda_version   = "1.0"
 *   lambda_package   = "anti-virus"
 *
 *   av_update_minutes = "180"
 *   av_scan_buckets   = ["bucket-name"]
 *
 *   av_definition_s3_bucket   = "av-update-bucket-name"
 *   av_definition_s3_prefix   = "anti-virus"
 *   av_scan_start_sns_arn = "sns-topic-name"
 *   av_status_sns_arn     = "sns-topic-name"
 * }
 * ```
 */

locals {
  name_scan   = "s3-anti-virus-scan"
  name_update = "s3-anti-virus-updates"
}

data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

