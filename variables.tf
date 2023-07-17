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
  type        = string
}

variable "lambda_s3_bucket" {
  description = "The name of the S3 bucket used to store the Lambda builds."
  type        = string
}

variable "lambda_version" {
  description = "The version the Lambda function to deploy."
}

variable "lambda_package" {
  description = "The name of the lambda package. Used for a directory tree and zip file."
  type        = string
  default     = "anti-virus"
}

variable "lambda_package_key" {
  description = "The object key for the lambda distribution. If given, the value is used as the key in lieu of the value constructed using `lambda_package` and `lambda_version`."
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Lambda memory allocation, in MB"
  type        = string
  default     = 2048
}

variable "kms_key_sns_arn" {
  description = "ARN of the KMS Key to use for SNS Encryption"
  type        = string
  default     = ""
}

variable "av_update_minutes" {
  default     = 180
  description = "How often to download updated Anti-Virus databases."
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
  type        = string
  default     = 300
}

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
  default     = ""
}

variable "av_status_sns_arn" {
  description = "SNS topic ARN to publish scan results (optional)."
  type        = string
  default     = ""
}

variable "av_status_sns_publish_clean" {
  description = "Publish AV_STATUS_CLEAN results to AV_STATUS_SNS_ARN."
  type        = string
  default     = "True"
}

variable "av_status_sns_publish_infected" {
  description = "Publish AV_STATUS_INFECTED results to AV_STATUS_SNS_ARN."
  type        = string
  default     = "True"
}

variable "av_delete_infected_files" {
  description = "Set it True in order to delete infected values."
  type        = string
  default     = "False"
}

variable "cloudwatch_kms_arn" {
  description = "The arn of the kms key used for encrypting the cloudwatch log groups created by this module."
  type        = string
  default     = ""
}

variable "platform" {
  description = "Instruction set architecture for your Lambda function. Valid values are 'x86_64' and 'arm64'"
  type        = string
  default     = "arm64"
}

variable "activate_s3_event_notification" {
  description = "true activates the s3 event notification to clamav. default is false"
  type        = bool
  default     = false
}

variable "s3_event_notification_name" {
  description = "s3 event notification name"
  type        = string
  default     = null
}
