variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "refresh_token_validity" {
  description = "Validade do refresh token em horas"
  type        = number
  default     = 1
}

variable "access_token_validity" {
  description = "Validade do access token em horas"
  type        = number
  default     = 1
}

variable "id_token_validity" {
  description = "Validade do id token em horas"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags para os recursos do Cognito"
  type        = map(string)
  default     = {}
}