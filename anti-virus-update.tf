#
# Lambda Function: Anti-Virus Definitions
#

#
# IAM
#

data "aws_iam_policy_document" "assume_role_update" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "main_update" {
  # Allow creating and writing CloudWatch logs for Lambda function.
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_update}:*"]
  }

  statement {
    sid = "s3GetAndPutWithTagging"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
    ]

    resources = ["arn:aws:s3:::${var.av_definition_s3_bucket}/${var.av_definition_s3_prefix}/*"]
  }

  statement {
    sid = "s3HeadObject"

    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.av_definition_s3_bucket}",
      "arn:aws:s3:::${var.av_definition_s3_bucket}/*",
    ]
  }
}

resource "aws_iam_role" "main_update" {
  name               = "lambda-${local.name_update}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_update.json
}

resource "aws_iam_role_policy" "main_update" {
  name = "lambda-${local.name_update}"
  role = aws_iam_role.main_update.id

  policy = data.aws_iam_policy_document.main_update.json
}

#
# CloudWatch Scheduled Event
#

resource "aws_cloudwatch_event_rule" "main_update" {
  name                = local.name_update
  description         = "scheduled trigger for ${local.name_update}"
  schedule_expression = "rate(${var.av_update_minutes} minutes)"
}

resource "aws_cloudwatch_event_target" "main_update" {
  rule = aws_cloudwatch_event_rule.main_update.name
  arn  = aws_lambda_function.main_update.arn
}

#
# CloudWatch Logs
#

resource "aws_cloudwatch_log_group" "main_update" {
  # This name must match the lambda function name and should not be changed
  name              = "/aws/lambda/${local.name_update}"
  retention_in_days = var.cloudwatch_logs_retention_days

  tags = {
    Name = local.name_update
  }
}

#
# Lambda Function
#

resource "aws_lambda_function" "main_update" {
  depends_on = [aws_cloudwatch_log_group.main_update]

  s3_bucket = var.lambda_s3_bucket
  s3_key    = "${var.lambda_package}/${var.lambda_version}/${var.lambda_package}.zip"

  function_name = local.name_update
  role          = aws_iam_role.main_update.arn
  handler       = "update.lambda_handler"
  runtime       = "python2.7"
  memory_size   = "512"
  timeout       = "300"

  environment {
    variables = {
      AV_DEFINITION_S3_BUCKET = var.av_definition_s3_bucket
      AV_DEFINITION_S3_PREFIX = var.av_definition_s3_prefix
    }
  }

  tags = {
    Name = local.name_update
  }
}

resource "aws_lambda_permission" "main_update" {
  statement_id = local.name_update

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_update.function_name

  principal  = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.main_update.arn
}

