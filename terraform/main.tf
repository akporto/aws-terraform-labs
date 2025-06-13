locals {
  default_lambda_runtime     = "python3.12"
  default_lambda_timeout     = 30
  default_lambda_memory_size = 512

  py_path_lambda_hellow_terraform = "${path.module}/../src/lambdas/lambda_hello_terraform/hellow_terraform.py"
  py_path_add_item                = "${path.module}/../src/lambdas/lambda_task_list/add_item/add_item.py"
  py_path_update_item             = "${path.module}/../src/lambdas/lambda_task_list/update_item/update_item.py"
  py_path_delete_item             = "${path.module}/../src/lambdas/lambda_task_list/delete_item/delete_item.py"
  py_path_get_item                = "${path.module}/../src/lambdas/lambda_task_list/get_item/get_item.py"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Cognito
module "cognito" {
  source       = "./modules/cognito"
  project_name = var.project_name
  environment  = var.environment

  refresh_token_validity = 1
  access_token_validity  = 1
  id_token_validity      = 1

  tags = local.common_tags
}

# DynamoDB
module "dynamodb" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment

  tags = local.common_tags
}

# IAM
module "iam" {
  source             = "./modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  dynamodb_table_arn = module.dynamodb.table_arn

  tags = local.common_tags
}

# Lambda Hello Terraform
module "lambda_hellow_terraform" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-lambda-hellow-terraform"
  description   = "Função Lambda que retorna 'Hello Terraform'"
  handler       = "hellow_terraform.lambda_handler"
  runtime       = local.default_lambda_runtime
  timeout       = local.default_lambda_timeout
  memory_size   = local.default_lambda_memory_size
  artifact_path = local.py_path_lambda_hellow_terraform

  environment_variables = {
    ENVIRONMENT = var.environment
  }

  tags = local.common_tags
}

# Lambda Add Item
module "lambda_add_item" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-lambda-add-item"
  description   = "Função Lambda para adicionar itens à lista de tarefas"
  handler       = "add_item.lambda_handler"
  runtime       = local.default_lambda_runtime
  timeout       = local.default_lambda_timeout
  memory_size   = local.default_lambda_memory_size
  artifact_path = local.py_path_add_item

  environment_variables = {
    ENVIRONMENT         = var.environment
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_add_item_dynamodb" {
  role       = module.lambda_add_item.role_name
  policy_arn = module.iam.dynamodb_access_policy_arn
}

# Lambda Update Item
module "lambda_update_item" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-lambda-update-item"
  description   = "Função Lambda para atualizar itens da lista de tarefas"
  handler       = "update_item.lambda_handler"
  runtime       = local.default_lambda_runtime
  timeout       = local.default_lambda_timeout
  memory_size   = local.default_lambda_memory_size
  artifact_path = local.py_path_update_item

  environment_variables = {
    ENVIRONMENT         = var.environment
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_update_item_dynamodb" {
  role       = module.lambda_update_item.role_name
  policy_arn = module.iam.dynamodb_access_policy_arn
}

# Lambda Delete Item
module "lambda_delete_item" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-lambda-delete-item"
  description   = "Função Lambda para deletar itens da lista de tarefas"
  handler       = "delete_item.lambda_handler"
  runtime       = local.default_lambda_runtime
  timeout       = local.default_lambda_timeout
  memory_size   = local.default_lambda_memory_size
  artifact_path = local.py_path_delete_item

  environment_variables = {
    ENVIRONMENT         = var.environment
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_delete_item_dynamodb" {
  role       = module.lambda_delete_item.role_name
  policy_arn = module.iam.dynamodb_access_policy_arn
}

# Lambda Get Item
module "lambda_get_item" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-get-item"
  description   = "Função para obter itens da lista de tarefas"
  handler       = "get_item.lambda_handler"
  runtime       = local.default_lambda_runtime
  timeout       = 10
  memory_size   = 128
  artifact_path = local.py_path_get_item

  environment_variables = {
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_get_item_dynamodb" {
  role       = module.lambda_get_item.role_name
  policy_arn = module.iam.dynamodb_access_policy_arn
}

# API Gateway
module "api_gateway" {
  source       = "./modules/api_gateway"
  project_name = var.project_name
  environment  = var.environment

  lambda_function_hello_arn    = module.lambda_hellow_terraform.function_arn
  lambda_function_get_item_arn = module.lambda_get_item.function_arn
  lambda_function_post_arn     = module.lambda_add_item.function_arn
  lambda_function_put_arn      = module.lambda_update_item.function_arn
  lambda_function_delete_arn   = module.lambda_delete_item.function_arn

  cognito_user_pool_arn = module.cognito.user_pool_arn
  aws_region            = var.aws_region
}
