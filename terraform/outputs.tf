output "lambda_function_name" {
  description = "Nome da função Lambda criada"
  value       = module.lambda_funcao_um.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda criada"
  value       = module.lambda_funcao_um.function_arn
}

output "lambda_role_arn" {
  description = "ARN da role IAM criada para a função Lambda"
  value       = module.lambda_funcao_um.role_arn
}