# Obtendo a região atual da AWS
data "aws_region" "current" {}

# Definição da API Gateway REST API
resource "aws_api_gateway_rest_api" "market_list_api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API para gerenciar lista de mercado"
}

# Recurso para o caminho /items
resource "aws_api_gateway_resource" "items_resource" {
  rest_api_id = aws_api_gateway_rest_api.market_list_api.id
  parent_id   = aws_api_gateway_rest_api.market_list_api.root_resource_id
  path_part   = "items"
}

# Método GET para retornar na tela: "Lambda function is running!"
resource "aws_api_gateway_method" "get_hellow_method" {
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Método POST para adicionar itens
resource "aws_api_gateway_method" "add_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integração do método GET com Lambda
resource "aws_api_gateway_integration" "get_hellow_terraform" {
  rest_api_id             = aws_api_gateway_rest_api.market_list_api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.get_hellow_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_get_arn}/invocations"
}

# Integração do método POST com Lambda
resource "aws_api_gateway_integration" "add_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.market_list_api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.add_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_post_arn}/invocations"
}

# Método PUT para atualizar itens
resource "aws_api_gateway_method" "update_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

# Integração do método PUT com Lambda
resource "aws_api_gateway_integration" "update_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.market_list_api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.update_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_put_arn}/invocations"
}

# Método DELETE para remover itens
resource "aws_api_gateway_method" "delete_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# Integração do método DELETE com Lambda
resource "aws_api_gateway_integration" "delete_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.market_list_api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.delete_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_delete_arn}/invocations"
}

# Permissão para o API Gateway invocar a função Lambda (GET)
resource "aws_lambda_permission" "api_gateway_lambda_get_lambda" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_get_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Permissão para o API Gateway invocar a função Lambda (POST)
resource "aws_lambda_permission" "api_gateway_lambda_add_item" {
  statement_id  = "AllowAPIGatewayInvokeAdd"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_post_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Permissão para o API Gateway invocar a função Lambda (PUT)
resource "aws_lambda_permission" "api_gateway_lambda_update_item" {
  statement_id  = "AllowAPIGatewayInvokeUpdate"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_put_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Permissão para o API Gateway invocar a função Lambda (DELETE)
resource "aws_lambda_permission" "api_gateway_lambda_delete_item" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_delete_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.market_list_api.execution_arn}/*/*"
}

# Deployment da API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.add_item_integration,
    aws_api_gateway_integration.update_item_integration,
    aws_api_gateway_integration.delete_item_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.market_list_api.id
}

# Stage da API Gateway
resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.market_list_api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.environment
}