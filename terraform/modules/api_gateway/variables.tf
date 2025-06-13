variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod, staging)"
  type        = string
}

variable "aws_region" {
  description = "Região da AWS (ex: sa-east-1)"
  type        = string
}

variable "lambda_function_hello_arn" {
  description = "ARN da Lambda para GET /hello"
  type        = string
}

variable "lambda_function_get_item_arn" {
  description = "ARN da Lambda para GET /lista-tarefa (get_item)"
  type        = string
}

variable "lambda_function_post_arn" {
  description = "ARN da Lambda para POST /lista-tarefa"
  type        = string
}

variable "lambda_function_put_arn" {
  description = "ARN da Lambda para PUT /lista-tarefa/{pk}/{sk}"
  type        = string
}

variable "lambda_function_delete_arn" {
  description = "ARN da Lambda para DELETE /lista-tarefa/{pk}/{sk}"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN do Cognito User Pool"
  type        = string
}
