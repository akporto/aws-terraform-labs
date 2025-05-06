locals {
  jar_path = "${path.module}/../lambda/funcao-um/target/funcao-um-1.0.0.jar"

}

module "lambda_funcao_um" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-${var.environment}-funcao-um"
  description   = "Função Lambda que retorna 'Hello Terraform'"
  handler       = "com.example.FuncaoUmHandler::handleRequest"
  runtime       = "java11"

  artifact_path = local.jar_path

  environment_variables = {
    ENVIRONMENT = var.environment
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
