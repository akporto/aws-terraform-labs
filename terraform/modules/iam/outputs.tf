output "dynamodb_access_policy_arn" {
  description = "ARN da política de acesso ao DynamoDB"
  value       = aws_iam_policy.dynamodb_access_policy.arn
}