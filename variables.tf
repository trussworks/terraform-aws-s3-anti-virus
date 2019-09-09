variable "cloudwatch_logs_retention_days" {
  default     = 90
  description = "Number of days to keep logs in AWS CloudWatch."
  type        = "string"
}

variable "lambda_s3_bucket" {
  description = "The name of the S3 bucket used to store the Lambda builds."
  type        = "string"
}

variable "lambda_version" {
  description = "The version the Lambda function to deploy."
  type        = "string"
}

variable "lambda_package" {
  description = "The name of the lambda package. Used for a directory tree and zip file."
  type        = "string"
  default     = "anti-virus"
}

variable "av_update_minutes" {
  default     = 180
  description = "How often to download updated Anti-Virus databases."
  type        = "string"
}

variable "av_scan_buckets" {
  description = "A list of S3 bucket names to scan for viruses."
  type        = "list"
}

#
# The variables below correspond to https://github.com/upsidetravel/bucket-antivirus-function/tree/master#configuration
#
variable "av_definition_s3_bucket" {
  description = "Bucket containing antivirus databse files."
  type        = "string"
}

variable "av_definition_s3_prefix" {
  description = "Prefix for antivirus databse files."
  type        = "string"
  default     = "clamav_defs"
}

variable "av_scan_start_sns_arn" {
  description = "SNS topic ARN to publish notification about start of scan (optional)."
  type        = "string"
  default     = ""
}

variable "av_status_sns_arn" {
  description = "SNS topic ARN to publish scan results (optional)."
  type        = "string"
  default     = ""
}

variable "av_status_sns_publish_clean" {
  description = "Publish AV_STATUS_CLEAN results to AV_STATUS_SNS_ARN."
  type        = "string"
  default     = "True"
}

variable "av_status_sns_publish_infected" {
  description = "Publish AV_STATUS_INFECTED results to AV_STATUS_SNS_ARN."
  type        = "string"
  default     = "True"
}
