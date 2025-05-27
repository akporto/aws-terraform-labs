
# Papel IAM para execução da função Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

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

# Política de logging para a função Lambda
resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.function_name}-logging-policy"
  description = "Política para permitir logs da função Lambda ${var.function_name}"

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

# Vinculação da política ao papel
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Cria diretório para pacotes Lambda
resource "null_resource" "create_pkg_dir" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/lambda_pkg"
  }
}

# Configuração para empacotar o código Python
data "archive_file" "lambda_zip" {
  depends_on = [null_resource.create_pkg_dir]

  type        = "zip"
  source_dir  = dirname(var.artifact_path) # Pega todo o diretório onde está o arquivo
  output_path = "${path.module}/lambda_pkg/${var.function_name}.zip"

  # Exclui arquivos desnecessários
  excludes = [
    "__pycache__",
    "*.pyc",
    "*.zip"
  ]
}

# Configuração da função Lambda
resource "aws_lambda_function" "function" {
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    data.archive_file.lambda_zip
  ]

  function_name = var.function_name
  description   = var.description
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}

# Grupo de logs CloudWatch
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}