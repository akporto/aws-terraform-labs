output "api_gateway_id" {
  description = "ID da API Gateway"
  value       = aws_api_gateway_rest_api.market_list_api.id
}

output "api_gateway_stage_name" {
  description = "Nome do stage da API Gateway"
  value       = var.environment
}

output "api_gateway_invoke_url" {
  description = "URL base para invocar a API Gateway com stage"
  value       = "https://${aws_api_gateway_rest_api.market_list_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.environment}"
}