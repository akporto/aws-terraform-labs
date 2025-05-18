# API Gateway REST API
resource "aws_api_gateway_rest_api" "market_list_api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API para gerenciar lista de mercado"
}

# Recurso de API para "items"
resource "aws_api_gateway_resource" "items_resource" {
  rest_api_id = aws_api_gateway_rest_api.market_list_api.id
  parent_id   = aws_api_gateway_rest_api.market_list_api.root_resource_id
  path_part   = "items"
}

# Método POST para adicionar item (integração com Lambda Add Item)
resource "aws_api_gateway_method" "add_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "add_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.market_list_api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.add_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_add_item.invoke_arn
}

# Método PUT para atualizar item (integração com Lambda Update Item)
resource "aws_api_gateway_method" "update_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.market_list_api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.update_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_update_item.invoke_arn
}

# Método DELETE para remover item (integração com Lambda Delete Item)
resource "aws_api_gateway_method" "delete_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.market_list_api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.delete_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_delete_item.invoke_arn
}

# Permissão para o API Gateway invocar a função Lambda Add Item
resource "aws_lambda_permission" "api_gateway_lambda_add_item" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_add_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Permissão para o API Gateway invocar a função Lambda Update Item
resource "aws_lambda_permission" "api_gateway_lambda_update_item" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_update_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Permissão para o API Gateway invocar a função Lambda Delete Item
resource "aws_lambda_permission" "api_gateway_lambda_delete_item" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_delete_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Deployment do API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.add_item_integration,
    aws_api_gateway_integration.update_item_integration,
    aws_api_gateway_integration.delete_item_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.market_list_api.id
}

# gerenciar estágio
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

# URL do API Gateway
output "api_url" {
  value = "${aws_api_gateway_stage.api_stage.invoke_url}/items"
}