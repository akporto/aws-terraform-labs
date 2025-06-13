output "table_name" {
  description = "Nome da tabela DynamoDB criada"
  value       = aws_dynamodb_table.task_list_api_table.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = aws_dynamodb_table.task_list_api_table.arn
}
