# Função Lambda Hello Terraform
output "lambda_hellow_terraform_name" {
  description = "Nome da função Lambda Hello Terraform criada"
  value       = module.lambda_hellow_terraform.function_name
}

output "lambda_hellow_terraform_arn" {
  description = "ARN da função Lambda Hello Terraform criada"
  value       = module.lambda_hellow_terraform.function_arn
}

output "lambda_hellow_terraform_role_arn" {
  description = "ARN da role IAM criada para a função Lambda Hello Terraform"
  value       = module.lambda_hellow_terraform.role_arn
}

output "lambda_hellow_terraform_invoke_arn" {
  description = "ARN de invocação da função Lambda Hello Terraform"
  value       = module.lambda_hellow_terraform.invoke_arn
}

# Função Lambda Add Item
output "lambda_add_item_name" {
  description = "Nome da função Lambda Add Item criada"
  value       = module.lambda_add_item.function_name
}

output "lambda_add_item_arn" {
  description = "ARN da função Lambda Add Item criada"
  value       = module.lambda_add_item.function_arn
}

output "lambda_add_item_role_arn" {
  description = "ARN da role IAM criada para a função Lambda Add Item"
  value       = module.lambda_add_item.role_arn
}

output "lambda_add_item_invoke_arn" {
  description = "ARN de invocação da função Lambda Add Item"
  value       = module.lambda_add_item.invoke_arn
}

# Função Lambda Update Item
output "lambda_update_item_name" {
  description = "Nome da função Lambda Update Item criada"
  value       = module.lambda_update_item.function_name
}

output "lambda_update_item_arn" {
  description = "ARN da função Lambda Update Item criada"
  value       = module.lambda_update_item.function_arn
}

output "lambda_update_item_role_arn" {
  description = "ARN da role IAM criada para a função Lambda Update Item"
  value       = module.lambda_update_item.role_arn
}

output "lambda_update_item_invoke_arn" {
  description = "ARN de invocação da função Lambda Update Item"
  value       = module.lambda_update_item.invoke_arn
}

# Função Lambda Delete Item
output "lambda_delete_item_name" {
  description = "Nome da função Lambda Delete Item criada"
  value       = module.lambda_delete_item.function_name
}

output "lambda_delete_item_arn" {
  description = "ARN da função Lambda Delete Item criada"
  value       = module.lambda_delete_item.function_arn
}

output "lambda_delete_item_role_arn" {
  description = "ARN da role IAM criada para a função Lambda Delete Item"
  value       = module.lambda_delete_item.role_arn
}

output "lambda_delete_item_invoke_arn" {
  description = "ARN de invocação da função Lambda Delete Item"
  value       = module.lambda_delete_item.invoke_arn
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

# API Gateway URL
output "api_url" {
  description = "URL for invoking the API Gateway"
  value       = "${module.api_gateway.api_gateway_invoke_url}/items"
}

# Lambda get items
output "lambda_get_items_name" {
  description = "Nome da função Lambda Get Items criada"
  value       = module.lambda_get_items.function_name
}

output "lambda_get_items_arn" {
  description = "ARN da função Lambda Get Items criada"
  value       = module.lambda_get_items.function_arn
}

output "lambda_get_items_role_arn" {
  description = "ARN da role IAM criada para a função Lambda Get Items"
  value       = module.lambda_get_items.role_arn
}

output "lambda_get_items_invoke_arn" {
  description = "ARN de invocação da função Lambda Get Items"
  value       = module.lambda_get_items.invoke_arn
}