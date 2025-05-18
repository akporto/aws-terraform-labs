locals {
  py_path_lambda_hellow_terraform = "${path.module}/../lambda/lambda_hellow_terraform/src/hellow_terraform.py"
  py_path_add_item               = "${path.module}/../lambda/lambda_market_list/add_item/src/add_market_item.py"
  py_path_update_item            = "${path.module}/../lambda/lambda_market_list/update_item/src/update_market_item.py"
  py_path_delete_item            = "${path.module}/../lambda/lambda_market_list/delete_item/src/delete_market_item.py"
}

# Função Lambda Hellow Terraform
module "lambda_hellow_terraform" {
  source = "./modules/lambda"

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

# Tabela DynamoDB para a lista de mercado
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

# Função Lambda Add Item
module "lambda_add_item" {
  source = "./modules/lambda"

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

# Política adicional para a função Lambda Add Item acessar o DynamoDB
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-dynamodb-policy"
  description = "Permite que as funções Lambda acessem a tabela DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.market_list_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_add_item_dynamodb" {
  role       = module.lambda_add_item.role_name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

# Função Lambda update Item
resource "aws_lambda_function" "lambda_update_item" {
  function_name = "${var.project_name}-${var.environment}-lambda-update-item"
  description   = "Função Lambda para atualizar itens na lista de mercado"
  role          = aws_iam_role.lambda_update_item_role.arn
  handler       = "update_market_item.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512

  filename         = "${path.module}/lambda_update_item.zip"
  source_code_hash = data.archive_file.lambda_update_item_code.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT         = var.environment
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.market_list_table.name
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

data "archive_file" "lambda_update_item_code" {
  type        = "zip"
  source_file = local.py_path_update_item
  output_path = "${path.module}/lambda_update_item.zip"
}

resource "aws_iam_role" "lambda_update_item_role" {
  name = "${var.project_name}-${var.environment}-lambda-update-item-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_update_item_logging" {
  name        = "${var.project_name}-${var.environment}-lambda-update-item-logging-policy"
  description = "Permite que a função Lambda Update crie logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_update_item_logs" {
  role       = aws_iam_role.lambda_update_item_role.name
  policy_arn = aws_iam_policy.lambda_update_item_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda_update_item_dynamodb" {
  role       = aws_iam_role.lambda_update_item_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_update_item_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_update_item.function_name}"
  retention_in_days = 14
}

# Função Lambda Delete Item - Para remover itens
resource "aws_lambda_function" "lambda_delete_item" {
  function_name = "${var.project_name}-${var.environment}-lambda-delete-item"
  description   = "Função Lambda para remover itens da lista de mercado"
  role          = aws_iam_role.lambda_delete_item_role.arn
  handler       = "delete_market_item.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512

  filename         = "${path.module}/lambda_delete_item.zip"
  source_code_hash = data.archive_file.lambda_delete_item_code.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT         = var.environment
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.market_list_table.name
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

data "archive_file" "lambda_delete_item_code" {
  type        = "zip"
  source_file = local.py_path_delete_item
  output_path = "${path.module}/lambda_delete_item.zip"
}

resource "aws_iam_role" "lambda_delete_item_role" {
  name = "${var.project_name}-${var.environment}-lambda-delete-item-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_delete_item_logging" {
  name        = "${var.project_name}-${var.environment}-lambda-delete-item-logging-policy"
  description = "Permite que a função Lambda Delete Item crie logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_delete_item_logs" {
  role       = aws_iam_role.lambda_delete_item_role.name
  policy_arn = aws_iam_policy.lambda_delete_item_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda_delete_item_dynamodb" {
  role       = aws_iam_role.lambda_delete_item_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_delete_item_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_delete_item.function_name}"
  retention_in_days = 14
}