variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "tags" {
  description = "Tags padrão para os recursos"
  type        = map(string)
}
