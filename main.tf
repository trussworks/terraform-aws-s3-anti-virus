# The AWS region currently being used.
data "aws_region" "current" {}

# The AWS account id
data "aws_caller_identity" "current" {}

# The AWS partition (commercial or govcloud)
data "aws_partition" "current" {}

locals {
  aws_account_id         = data.aws_caller_identity.current.account_id
  aws_partition          = data.aws_partition.current.partition
  aws_region_name        = data.aws_region.current.name
  cw_schedule_expression = var.av_update_minutes != null ? "rate(${var.av_update_minutes} minutes)" : var.av_update_schedule_expression
  lambda_s3_object_key   = var.lambda_s3_object_key != null ? var.lambda_s3_object_key : "${var.lambda_package}/${var.lambda_version}/${var.lambda_package}.zip"
}
