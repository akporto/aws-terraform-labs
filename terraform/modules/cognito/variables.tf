variable "user_pool_name" {
  description = "Nome do Cognito User Pool"
  type        = string
  default     = "my-userpool"
}

variable "user_pool_client_name" {
  description = "Nome do Cognito User Pool Client"
  type        = string
  default     = "my-client"
}

variable "tags" {
  description = "Tags para os recursos do Cognito"
  type        = map(string)
  default     = {}
}