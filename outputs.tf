#
# Lambda Function: Anti-Virus Scanning `var.name_scan`
#
output "scan_aws_cloudwatch_log_group_arn" {
  description = "ARN for the Anti-Virus Scanning Cloudwatch LogGroup."
  value       = aws_cloudwatch_log_group.main_scan.arn
}

output "scan_aws_cloudwatch_log_group_name" {
  description = "The Anti-Virus Scanning Cloudwatch LogGroup name."
  value       = "/aws/lambda/${var.name_scan}"
}

output "scan_lambda_function_iam_role_arn" {
  description = "Name of the Anti-Virus Scanning lambda role"
  value       = aws_iam_role.main_scan.arn
}

output "scan_lambda_function_iam_role_name" {
  description = "Name of the Anti-Virus Scanning lambda role"
  value       = aws_iam_role.main_scan.name
}

output "scan_lambda_function_arn" {
  description = "ARN for the Anti-Virus Scanning lambda function"
  value       = aws_lambda_function.main_scan.arn
}

output "scan_lambda_function_name" {
  description = "The Anti-Virus Scanning lambda function name"
  value       = var.name_scan
}

output "scan_lambda_function_version" {
  description = "Current version of the Anti-Virus Scanning lambda function"
  value       = aws_lambda_function.main_scan.version
}

#
# Lambda Function: Anti-Virus Definitions `var.name_update`
#
output "update_aws_cloudwatch_log_group_arn" {
  description = "ARN for the Anti-Virus Definitions Cloudwatch LogGroup."
  value       = aws_cloudwatch_log_group.main_update.arn
}

output "update_aws_cloudwatch_log_group_name" {
  description = "The Anti-Virus Definitions Cloudwatch LogGroup name."
  value       = "/aws/lambda/${var.name_update}"
}

output "update_lambda_function_iam_role_arn" {
  description = "Name of the Anti-Virus Definitions lambda role"
  value       = aws_iam_role.main_update.arn
}

output "update_lambda_function_iam_role_name" {
  description = "Name of the Anti-Virus Definitions lambda role"
  value       = aws_iam_role.main_update.name
}

output "update_lambda_function_arn" {
  description = "ARN for the Anti-Virus Definitions lambda function"
  value       = aws_lambda_function.main_update.arn
}

output "update_lambda_function_name" {
  description = "The Anti-Virus Definitions lambda function name"
  value       = var.name_update
}

output "update_lambda_function_version" {
  description = "Current version of the Anti-Virus Definitions lambda function"
  value       = aws_lambda_function.main_update.version
}
