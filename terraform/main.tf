locals {
  py_path_lambda_hellow_terraform = "${path.module}/../lambdas/lambda_hellow_terraform/src/hellow_terraform.py"
  py_path_add_item                = "${path.module}/../lambdas/lambda_market_list/add_item/src/add_market_item.py"
  py_path_update_item             = "${path.module}/../lambdas/lambda_market_list/update_item/src/update_market_item.py"
  py_path_delete_item             = "${path.module}/../lambdas/lambda_market_list/delete_item/src/delete_market_item.py"
  py_path_get_item                = "${path.module}/../lambdas/lambda_market_list/get_items/src/get_items.py"
}

# Cognito
module "cognito" {
  source       = "./modules/cognito"
  project_name = var.project_name
  environment  = var.environment

  refresh_token_validity = 1
  access_token_validity  = 1
  id_token_validity      = 1

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Lambda Hello Terraform
module "lambda_hellow_terraform" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-lambda-hellow-terraform"
  description   = "Função Lambda que retorna 'Hello Terraform'"
  handler       = "hellow_terraform.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512
  artifact_path = local.py_path_lambda_hellow_terraform
  environment_variables = {
    ENVIRONMENT = var.environment
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# DynamoDB
module "dynamodb" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Módulo IAM
module "iam" {
  source             = "./modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  dynamodb_table_arn = module.dynamodb.table_arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Lambda Add Item
module "lambda_add_item" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-lambda-add-item"
  description   = "Função Lambda para adicionar itens à lista de mercado"
  handler       = "add_market_item.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512
  artifact_path = local.py_path_add_item
  environment_variables = {
    ENVIRONMENT         = var.environment
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_add_item_dynamodb" {
  role       = module.lambda_add_item.role_name
  policy_arn = module.iam.dynamodb_access_policy_arn
}

# Lambda Update Item
module "lambda_update_item" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-lambda-update-item"
  description   = "Função Lambda para atualizar itens da lista de mercado"
  handler       = "update_market_item.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512
  artifact_path = local.py_path_update_item
  environment_variables = {
    ENVIRONMENT         = var.environment
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_update_item_dynamodb" {
  role       = module.lambda_update_item.role_name
  policy_arn = module.iam.dynamodb_access_policy_arn
}

# Lambda Delete Item
module "lambda_delete_item" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-lambda-delete-item"
  description   = "Função Lambda para deletar itens da lista de mercado"
  handler       = "delete_market_item.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512
  artifact_path = local.py_path_delete_item
  environment_variables = {
    ENVIRONMENT         = var.environment
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_delete_item_dynamodb" {
  role       = module.lambda_delete_item.role_name
  policy_arn = module.iam.dynamodb_access_policy_arn
}

# Lambda Get Items
module "lambda_get_items" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-${var.environment}-get-items"
  description   = "Função para obter itens da lista de mercado"
  handler       = "get_items.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10
  memory_size   = 128
  artifact_path = local.py_path_get_item
  environment_variables = {
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }
  tags = {
    Projeto  = var.project_name
    Ambiente = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_get_items_dynamodb" {
  role       = module.lambda_get_items.role_name
  policy_arn = module.iam.dynamodb_access_policy_arn
}

# API Gateway
module "api_gateway" {
  source                        = "./modules/api_gateway"
  project_name                  = var.project_name
  environment                   = var.environment
  lambda_function_hello_get_arn = module.lambda_hellow_terraform.function_arn
  lambda_function_post_arn      = module.lambda_add_item.function_arn
  lambda_function_put_arn       = module.lambda_update_item.function_arn
  lambda_function_delete_arn    = module.lambda_delete_item.function_arn
  lambda_function_get_arn       = module.lambda_get_items.function_arn
  cognito_user_pool_arn         = module.cognito.user_pool_arn
  aws_region                    = var.aws_region
}