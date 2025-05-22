locals {
  py_path_lambda_hellow_terraform = "${path.module}/../lambda/lambda_hellow_terraform/src/hellow_terraform.py"
  py_path_add_item                = "${path.module}/../lambda/lambda_market_list/add_item/src/add_market_item.py"
  py_path_update_item             = "${path.module}/../lambda/lambda_market_list/update_item/src/update_market_item.py"
  py_path_delete_item             = "${path.module}/../lambda/lambda_market_list/delete_item/src/delete_market_item.py"
}

# Recurso Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "my-userpool"

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    mutable                  = true
    developer_only_attribute = false
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  username_attributes = ["email"]

  username_configuration {
    case_sensitive = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

# Recurso do Client
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                         = "my-client"
  user_pool_id                 = aws_cognito_user_pool.user_pool.id
  supported_identity_providers = ["COGNITO"]
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  generate_secret               = false
  prevent_user_existence_errors = "LEGACY"
  refresh_token_validity        = 1
  access_token_validity         = 1
  id_token_validity             = 1

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "hours"
  }
}

# Módulo Lambda Hello Terraform 
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

# Tabela DynamoDB
resource "aws_dynamodb_table" "market_list_table" {
  name         = "${var.project_name}-${var.environment}-market-list"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Política IAM para acesso DynamoDB
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-dynamodb-policy"
  description = "Permite que as funções Lambda acessem a tabela DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.market_list_table.arn
      }
    ]
  })
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
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.market_list_table.name
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_add_item_dynamodb" {
  role       = module.lambda_add_item.role_name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
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
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.market_list_table.name
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_update_item_dynamodb" {
  role       = module.lambda_update_item.role_name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
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
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.market_list_table.name
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_delete_item_dynamodb" {
  role       = module.lambda_delete_item.role_name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

# Módulo API Gateway - passa as ARNs das Lambdas
module "api_gateway" {
  source                     = "./modules/api_gateway"
  project_name               = var.project_name
  environment                = var.environment
  lambda_function_get_arn    = module.lambda_hellow_terraform.function_arn
  lambda_function_post_arn   = module.lambda_add_item.function_arn
  lambda_function_put_arn    = module.lambda_update_item.function_arn
  lambda_function_delete_arn = module.lambda_delete_item.function_arn
  aws_region                 = var.aws_region
  cognito_user_pool_arn      = aws_cognito_user_pool.user_pool.arn
}