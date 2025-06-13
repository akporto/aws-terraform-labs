data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "task_list_api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API para gerenciar lista de tarefas"
}

# /lista-tarefa
resource "aws_api_gateway_resource" "lista_tarefa_resource" {
  rest_api_id = aws_api_gateway_rest_api.task_list_api.id
  parent_id   = aws_api_gateway_rest_api.task_list_api.root_resource_id
  path_part   = "lista-tarefa"
}

# /lista-tarefa/{pk}
resource "aws_api_gateway_resource" "lista_tarefa_pk" {
  rest_api_id = aws_api_gateway_rest_api.task_list_api.id
  parent_id   = aws_api_gateway_resource.lista_tarefa_resource.id
  path_part   = "{pk}"
}

# /lista-tarefa/{pk}/{sk}
resource "aws_api_gateway_resource" "lista_tarefa_sk" {
  rest_api_id = aws_api_gateway_rest_api.task_list_api.id
  parent_id   = aws_api_gateway_resource.lista_tarefa_pk.id
  path_part   = "{sk}"
}

# /hello
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.task_list_api.id
  parent_id   = aws_api_gateway_rest_api.task_list_api.root_resource_id
  path_part   = "hello"
}


# GET /hello → hellow_terraform.py
resource "aws_api_gateway_method" "get_hello_method" {
  depends_on    = [aws_api_gateway_authorizer.cognito_authorizer]
  rest_api_id   = aws_api_gateway_rest_api.task_list_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# GET /lista-tarefa  get_item.py
resource "aws_api_gateway_method" "get_item_method" {
  depends_on    = [aws_api_gateway_authorizer.cognito_authorizer]
  rest_api_id   = aws_api_gateway_rest_api.task_list_api.id
  resource_id   = aws_api_gateway_resource.lista_tarefa_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# POST /lista-tarefa
resource "aws_api_gateway_method" "add_item_method" {
  depends_on    = [aws_api_gateway_authorizer.cognito_authorizer]
  rest_api_id   = aws_api_gateway_rest_api.task_list_api.id
  resource_id   = aws_api_gateway_resource.lista_tarefa_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# PUT /lista-tarefa/{pk}/{sk}
resource "aws_api_gateway_method" "update_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.task_list_api.id
  resource_id   = aws_api_gateway_resource.lista_tarefa_sk.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.pk" = true
    "method.request.path.sk" = true
  }
}

# DELETE /lista-tarefa/{pk}/{sk}
resource "aws_api_gateway_method" "delete_item_method" {
  rest_api_id   = aws_api_gateway_rest_api.task_list_api.id
  resource_id   = aws_api_gateway_resource.lista_tarefa_sk.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.pk" = true
    "method.request.path.sk" = true
  }
}

# Integrações

resource "aws_api_gateway_integration" "get_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.task_list_api.id
  resource_id             = aws_api_gateway_resource.lista_tarefa_resource.id
  http_method             = aws_api_gateway_method.get_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_get_item_arn}/invocations"
}

resource "aws_api_gateway_integration" "get_hello_integration" {
  rest_api_id             = aws_api_gateway_rest_api.task_list_api.id
  resource_id             = aws_api_gateway_resource.hello_resource.id
  http_method             = aws_api_gateway_method.get_hello_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_hello_arn}/invocations"
}

resource "aws_api_gateway_integration" "add_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.task_list_api.id
  resource_id             = aws_api_gateway_resource.lista_tarefa_resource.id
  http_method             = aws_api_gateway_method.add_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_post_arn}/invocations"
}

resource "aws_api_gateway_integration" "update_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.task_list_api.id
  resource_id             = aws_api_gateway_resource.lista_tarefa_sk.id
  http_method             = aws_api_gateway_method.update_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_put_arn}/invocations"
}

resource "aws_api_gateway_integration" "delete_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.task_list_api.id
  resource_id             = aws_api_gateway_resource.lista_tarefa_sk.id
  http_method             = aws_api_gateway_method.delete_item_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_delete_arn}/invocations"
}

# Permissões

resource "aws_lambda_permission" "api_gateway_lambda_get_item" {
  statement_id  = "AllowAPIGatewayInvokeGetItem"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_get_item_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.task_list_api.execution_arn}/*/GET/lista-tarefa"
}

resource "aws_lambda_permission" "api_gateway_lambda_get_hello" {
  statement_id  = "AllowAPIGatewayInvokeGetHello"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_hello_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.task_list_api.execution_arn}/*/GET/hello"
}

resource "aws_lambda_permission" "api_gateway_lambda_add_item" {
  statement_id  = "AllowAPIGatewayInvokeAdd"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_post_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.task_list_api.execution_arn}/*/POST/lista-tarefa"
}

resource "aws_lambda_permission" "api_gateway_lambda_update_item" {
  statement_id  = "AllowAPIGatewayInvokeUpdate"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_put_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.task_list_api.execution_arn}/*/PUT/lista-tarefa/*/*"
}

resource "aws_lambda_permission" "api_gateway_lambda_delete_item" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_delete_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.task_list_api.execution_arn}/*/DELETE/lista-tarefa/*/*"
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "${var.project_name}-${var.environment}-cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.task_list_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.cognito_user_pool_arn]
}

# Deployment & Stage
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.get_item_integration,
    aws_api_gateway_integration.get_hello_integration,
    aws_api_gateway_integration.add_item_integration,
    aws_api_gateway_integration.update_item_integration,
    aws_api_gateway_integration.delete_item_integration,
  ]
  rest_api_id = aws_api_gateway_rest_api.task_list_api.id
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.task_list_api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.environment
}
