variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB"
  type        = string
}

variable "tags" {
  description = "Tags para os recursos IAM"
  type        = map(string)
  default     = {}
}