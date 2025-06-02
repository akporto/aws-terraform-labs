# IAM Policy para acesso ao DynamoDB
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
        Effect = "Allow",
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      }
    ]
  })

  tags = var.tags
}