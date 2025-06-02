# Variáveis de configuração
variable "aws_region" {
  description = "Região da AWS para criar os recursos"
  type        = string
  default     = "sa-east-1"
}

variable "environment" {
  description = "Ambiente (dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "O ambiente deve ser 'dev' ou 'prod'."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "hello-terraform"
}


