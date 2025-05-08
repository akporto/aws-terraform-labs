# Nome da função Lambda criada
output "function_name" {
  description = "Nome da função Lambda criada"
  value       = aws_lambda_function.function.function_name
}

# ARN (Amazon Resource Name) completo da função Lambda
output "function_arn" {
  description = "ARN da função Lambda criada"
  value       = aws_lambda_function.function.arn
}

# ARN da role IAM associada à função Lambda
output "role_arn" {
  description = "ARN da role IAM criada para a função Lambda"
  value       = aws_iam_role.lambda_role.arn
}

# Nome da role IAM (necessário para anexar políticas adicionais)
output "role_name" {
  description = "Nome da role IAM criada para a função Lambda"
  value       = aws_iam_role.lambda_role.name
}

# ARN de invocação que permite chamar a função Lambda
output "invoke_arn" {
  description = "ARN de invocação da função Lambda"
  value       = aws_lambda_function.function.invoke_arn
}