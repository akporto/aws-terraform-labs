locals {
  jar_path_um = "${path.module}/../lambda/funcao-um/target/funcao-um-1.0.0.jar"
  jar_path_dois = "${path.module}/../lambda/funcao-dois/target/funcao-dois-1.0.0.jar"
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
  name           = "${var.project_name}-${var.environment}-market-list"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "itemId"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "itemId"
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
    ENVIRONMENT = var.environment
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
  name        = "${var.project_name}-${var.environment}-funcao-dois-dynamodb-policy"
  description = "Permite que a função Lambda Dois acesse a tabela DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.market_list_table.arn
      }
    ]
  })
}

# Anexa a política DynamoDB à função Lambda Dois
resource "aws_iam_role_policy_attachment" "lambda_dois_dynamodb" {
  role       = module.lambda_funcao_dois.role_name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}