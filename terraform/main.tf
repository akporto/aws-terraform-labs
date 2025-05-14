locals {
  jar_path_um    = "${path.module}/../lambda/funcao-um/target/funcao-um-1.0.0.jar"
  jar_path_dois  = "${path.module}/../lambda/funcao-dois/target/funcao-dois-1.0.0.jar"
  py_path_tres   = "${path.module}/../lambda/funcao-tres/src/FuncaoTresHandler.py"
  py_path_quatro = "${path.module}/../lambda/funcao-quatro/src/FuncaoQuatroHandler.py"
}

# Função Lambda Um
module "lambda_funcao_um" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-${var.environment}-funcao-um"
  description   = "Função Lambda que retorna 'Hello Terraform'"
  handler       = "com.example.FuncaoUmHandler::handleRequest"
  runtime       = "java11"
  timeout       = 30
  memory_size   = 512

  artifact_path = local.jar_path_um

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

# Função Lambda Dois
module "lambda_funcao_dois" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-${var.environment}-funcao-dois"
  description   = "Função Lambda para adicionar itens à lista de mercado"
  handler       = "com.example.FuncaoDoisHandler::handleRequest"
  runtime       = "java11"
  timeout       = 30
  memory_size   = 512

  artifact_path = local.jar_path_dois

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

# Política adicional para a função Lambda Dois acessar o DynamoDB
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

resource "aws_iam_role_policy_attachment" "lambda_dois_dynamodb" {
  role       = module.lambda_funcao_dois.role_name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

# Função Lambda Três (Python)
resource "aws_lambda_function" "lambda_funcao_tres" {
  function_name = "${var.project_name}-${var.environment}-funcao-tres"
  description   = "Função Lambda para atualizar itens na lista de mercado"
  role          = aws_iam_role.lambda_funcao_tres_role.arn
  handler       = "FuncaoTresHandler.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512

  filename         = "${path.module}/lambda_funcao_tres.zip"
  source_code_hash = data.archive_file.lambda_funcao_tres_code.output_base64sha256

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

data "archive_file" "lambda_funcao_tres_code" {
  type        = "zip"
  source_file = local.py_path_tres
  output_path = "${path.module}/lambda_funcao_tres.zip"
}

resource "aws_iam_role" "lambda_funcao_tres_role" {
  name = "${var.project_name}-${var.environment}-funcao-tres-role"

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

resource "aws_iam_policy" "lambda_funcao_tres_logging" {
  name        = "${var.project_name}-${var.environment}-funcao-tres-logging-policy"
  description = "Permite que a função Lambda Três crie logs"

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

resource "aws_iam_role_policy_attachment" "lambda_funcao_tres_logs" {
  role       = aws_iam_role.lambda_funcao_tres_role.name
  policy_arn = aws_iam_policy.lambda_funcao_tres_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda_funcao_tres_dynamodb" {
  role       = aws_iam_role.lambda_funcao_tres_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_funcao_tres_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_funcao_tres.function_name}"
  retention_in_days = 14
}

# Função Lambda Quatro (Python) - Para remover itens
resource "aws_lambda_function" "lambda_funcao_quatro" {
  function_name = "${var.project_name}-${var.environment}-funcao-quatro"
  description   = "Função Lambda para remover itens da lista de mercado"
  role          = aws_iam_role.lambda_funcao_quatro_role.arn
  handler       = "FuncaoQuatroHandler.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 512

  filename         = "${path.module}/lambda_funcao_quatro.zip"
  source_code_hash = data.archive_file.lambda_funcao_quatro_code.output_base64sha256

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

data "archive_file" "lambda_funcao_quatro_code" {
  type        = "zip"
  source_file = local.py_path_quatro
  output_path = "${path.module}/lambda_funcao_quatro.zip"
}

resource "aws_iam_role" "lambda_funcao_quatro_role" {
  name = "${var.project_name}-${var.environment}-funcao-quatro-role"

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

resource "aws_iam_policy" "lambda_funcao_quatro_logging" {
  name        = "${var.project_name}-${var.environment}-funcao-quatro-logging-policy"
  description = "Permite que a função Lambda Quatro crie logs"

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

resource "aws_iam_role_policy_attachment" "lambda_funcao_quatro_logs" {
  role       = aws_iam_role.lambda_funcao_quatro_role.name
  policy_arn = aws_iam_policy.lambda_funcao_quatro_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda_funcao_quatro_dynamodb" {
  role       = aws_iam_role.lambda_funcao_quatro_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_funcao_quatro_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_funcao_quatro.function_name}"
  retention_in_days = 14
}