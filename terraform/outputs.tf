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
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB criada"
  value       = module.dynamodb.table_arn
}

# API Gateway URL
output "api_url" {
  description = "URL for invoking the API Gateway"
  value       = "${module.api_gateway.api_gateway_invoke_url}/items"
}

# Lambda get items
output "lambda_get_item_name" {
  description = "Nome da função Lambda Get Items criada"
  value       = module.lambda_get_item.function_name
}

output "lambda_get_item_arn" {
  description = "ARN da função Lambda Get Items criada"
  value       = module.lambda_get_item.function_arn
}

output "lambda_get_item_role_arn" {
  description = "ARN da role IAM criada para a função Lambda Get Items"
  value       = module.lambda_get_item.role_arn
}

output "lambda_get_item_invoke_arn" {
  description = "ARN de invocação da função Lambda Get Items"
  value       = module.lambda_get_item.invoke_arn
}

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "ID do Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN do Cognito User Pool"
  value       = module.cognito.user_pool_arn
}

output "cognito_user_pool_client_id" {
  description = "ID do Cognito User Pool Client"
  value       = module.cognito.user_pool_client_id
}

output "cognito_user_pool_endpoint" {
  description = "Endpoint do Cognito User Pool"
  value       = module.cognito.user_pool_endpoint
}

# IAM Outputs
output "dynamodb_access_policy_arn" {
  description = "ARN da política de acesso ao DynamoDB"
  value       = module.iam.dynamodb_access_policy_arn
}