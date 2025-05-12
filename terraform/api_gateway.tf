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

# Método POST para adicionar item (integração com Lambda Dois)
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
  uri                     = module.lambda_funcao_dois.invoke_arn
}

# Método PUT para atualizar item (integração com Lambda Três)
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
  uri                     = aws_lambda_function.lambda_funcao_tres.invoke_arn
}

# Método DELETE para remover item (integração com Lambda Quatro)
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
  uri                     = aws_lambda_function.lambda_funcao_quatro.invoke_arn
}


# Permissão para o API Gateway invocar a função Lambda Dois
resource "aws_lambda_permission" "api_gateway_lambda_dois" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_funcao_dois.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Permissão para o API Gateway invocar a função Lambda Três
resource "aws_lambda_permission" "api_gateway_lambda_tres" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_funcao_tres.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Permissão para o API Gateway invocar a função Lambda Quatro
resource "aws_lambda_permission" "api_gateway_lambda_quatro" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_funcao_quatro.function_name
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

# Novo recurso para gerenciar o estágio
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}


# URL do API Gateway
output "api_url" {
  value = "${aws_api_gateway_stage.api_stage.invoke_url}/items"
}