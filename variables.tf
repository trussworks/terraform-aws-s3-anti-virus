variable "name_scan" {
  default     = "s3-anti-virus-scan"
  description = "Name for resources associated with anti-virus scanning"
  type        = string
}

variable "name_update" {
  default     = "s3-anti-virus-updates"
  description = "Name for resources associated with anti-virus updating"
  type        = string
}

variable "cloudwatch_logs_retention_days" {
  default     = 90
  description = "Number of days to keep logs in AWS CloudWatch."
  type        = number
}

variable "lambda_s3_bucket" {
  description = "The name of the S3 bucket used to store the Lambda builds."
  type        = string
}

variable "lambda_version" {
  description = "Deprecated. The version the Lambda function to deploy."
  type        = string
  default     = "2.0.0"
}

variable "lambda_package" {
  description = "Deprecated. The name of the lambda package. Used for a directory tree and zip file."
  type        = string
  default     = "anti-virus"
}

variable "lambda_s3_object_key" {
  description = "The object key for the lambda distribution. If given, the value is used as the key in lieu of the value constructed using `lambda_package` and `lambda_version`."
  type        = string
  default     = null
}

variable "lambda_runtime" {
  type        = string
  default     = "python3.7"
  description = "Identifier of the function's runtime."
}

variable "memory_size" {
  description = "Lambda memory allocation, in MB"
  type        = number
  default     = 2048
}

variable "av_update_minutes" {
  default     = null
  description = "How often to download updated Anti-Virus databases."
  type        = number
}

variable "av_update_schedule_expression" {
  default     = "rate(180 minutes)"
  description = "A new, more flexible option for the scheduler. Not working if `av_update_minutes` variable is set. The scheduling expression how often to download updated Anti-Virus databases. [For example, cron(0 20 * * ? *) or rate(180 minutes)](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html)"
  type        = string
}

variable "av_scan_buckets" {
  description = "A list of S3 bucket names to scan for viruses."
  type        = list(string)
}

variable "permissions_boundary" {
  description = "ARN of the boundary policy to attach to IAM roles."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "timeout_seconds" {
  description = "Lambda timeout, in seconds"
  type        = number
  default     = 300
}

#
# The variables below correspond to https://github.com/upsidetravel/bucket-antivirus-function/tree/master#configuration
# https://github.com/upsidetravel/bucket-antivirus-function/blob/master/common.py
#
variable "av_definition_s3_bucket" {
  description = "Bucket containing antivirus database files."
  type        = string
}

variable "av_definition_s3_prefix" {
  description = "Prefix for antivirus database files."
  type        = string
  default     = "clamav_defs"
}

variable "av_scan_start_sns_arn" {
  description = "SNS topic ARN to publish notification about start of scan (optional)."
  type        = string
  default     = null
}

variable "av_status_sns_arn" {
  description = "SNS topic ARN to publish scan results (optional)."
  type        = string
  default     = null
}

variable "av_status_sns_publish_clean" {
  description = "Publish AV_STATUS_CLEAN results to AV_STATUS_SNS_ARN."
  type        = bool
  default     = true
}

variable "av_status_sns_publish_infected" {
  description = "Publish AV_STATUS_INFECTED results to AV_STATUS_SNS_ARN."
  type        = bool
  default     = true
}

variable "av_delete_infected_files" {
  description = "Set it True in order to delete infected values."
  type        = bool
  default     = false
}

variable "av_process_original_version_only" {
  description = "Controls that only original version of an S3 key is processed (if bucket versioning is enabled)"
  type        = bool
  default     = true
}

variable "av_scan_start_metadata" {
  description = "The tag/metadata indicating the start of the scan"
  type        = string
  default     = "av-scan-start"
}

variable "av_signature_metadata" {
  description = "The tag/metadata name representing file's AV type"
  type        = string
  default     = "av-signature"
}

variable "av_status_clean" {
  description = "The value assigned to clean items inside of tags/metadata"
  type        = string
  default     = "CLEAN"
}

variable "av_status_infected" {
  description = "The value assigned to clean items inside of tags/metadata"
  type        = string
  default     = "INFECTED"
}

variable "av_status_metadata" {
  description = "The tag/metadata name representing file's AV status"
  type        = string
  default     = "av-status"
}

variable "av_timestamp_metadata" {
  description = "The tag/metadata name representing file's scan time"
  type        = string
  default     = "av-timestamp"
}

variable "event_source" {
  description = "The source of antivirus scan event \"S3\" or \"SNS\" (optional)"
  type        = string
  default     = "S3"
}

variable "s3_endpoint" {
  description = "The Endpoint to use when interacting wth S3"
  type        = string
  default     = null
}

variable "sns_endpoint" {
  description = "The Endpoint to use when interacting wth SNS"
  type        = string
  default     = null
}

variable "datadog_api_key" {
  description = "API Key for pushing metrics to DataDog (optional)"
  type        = string
  default     = null
}

variable "av_definition_path" {
  description = "Path containing files at runtime"
  type        = string
  default     = "/tmp/clamav_defs"
}

variable "clamavlib_path" {
  description = "Path to ClamAV library files"
  type        = string
  default     = "./bin"
}
