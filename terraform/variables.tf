variable "aws_region" {
  description = "Região da AWS para criar os recursos"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "hello-terraform"
}