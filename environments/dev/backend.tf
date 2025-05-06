terraform {
  backend "s3" {
    bucket         = "akporto-projetolambda-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "akporto-projetoteste-terraform-locks"
    encrypt        = true
  }
}