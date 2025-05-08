# Função Lambda Um
output "lambda_funcao_um_name" {
  description = "Nome da função Lambda Um criada"
  value       = module.lambda_funcao_um.function_name
}

output "lambda_funcao_um_arn" {
  description = "ARN da função Lambda Um criada"
  value       = module.lambda_funcao_um.function_arn
}

output "lambda_funcao_um_role_arn" {
  description = "ARN da role IAM criada para a função Lambda Um"
  value       = module.lambda_funcao_um.role_arn
}

output "lambda_funcao_um_invoke_arn" {
  description = "ARN de invocação da função Lambda Um"
  value       = module.lambda_funcao_um.invoke_arn
}

# Função Lambda Dois
output "lambda_funcao_dois_name" {
  description = "Nome da função Lambda Dois criada"
  value       = module.lambda_funcao_dois.function_name
}

output "lambda_funcao_dois_arn" {
  description = "ARN da função Lambda Dois criada"
  value       = module.lambda_funcao_dois.function_arn
}

output "lambda_funcao_dois_role_arn" {
  description = "ARN da role IAM criada para a função Lambda Dois"
  value       = module.lambda_funcao_dois.role_arn
}

output "lambda_funcao_dois_invoke_arn" {
  description = "ARN de invocação da função Lambda Dois"
  value       = module.lambda_funcao_dois.invoke_arn
}

# Tabela DynamoDB
output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB criada"
  value       = aws_dynamodb_table.market_list_table.name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB criada"
  value       = aws_dynamodb_table.market_list_table.arn
}