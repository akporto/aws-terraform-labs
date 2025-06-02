output "table_name" {
  description = "Nome da tabela DynamoDB criada"
  value       = aws_dynamodb_table.market_list_table.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB criada"
  value       = aws_dynamodb_table.market_list_table.arn
}

output "table_id" {
  description = "ID da tabela DynamoDB criada"
  value       = aws_dynamodb_table.market_list_table.id
}