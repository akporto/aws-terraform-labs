#!/bin/bash

# Script para limpar arquivos .zip, arquivos gerados pelo Terraform,
# destruir infraestrutura local e formatar código com black, isort e terraform fmt

check_tool() {
  if ! command -v "$1" &> /dev/null; then
    echo "Erro: $1 não está instalado. Por favor, instale-o antes de continuar."
    exit 1
  fi
}

check_tool python3
check_tool black
check_tool isort
check_tool terraform


PYTHON_DIRS="src/lambdas/lambda_hello_terraform src/lambdas/lambda_task_list tests"
TERRAFORM_DIRS="terraform terraform/modules/api_gateway terraform/modules/lambda terraform/modules/cognito terraform/modules/dynamodb terraform/modules/iam environments/dev"
CHANGES=0

delete_zip_files() {
  echo "Excluindo arquivos .zip no projeto..."
  find . -type f -name "*.zip" -delete
  if [ $? -eq 0 ]; then
    echo "Arquivos .zip excluídos com sucesso."
  else
    echo "Erro ao excluir arquivos .zip."
    exit 1
  fi

  if git diff --quiet; then
    echo "Nenhum arquivo .zip foi excluído (nenhum encontrado)."
  else
    echo "Arquivos .zip foram excluídos."
    CHANGES=1
  fi
}

delete_terraform_files() {
  echo "Excluindo arquivos gerados pelo Terraform..."
  for dir in $TERRAFORM_DIRS; do
    if [ -d "$dir" ]; then
      find "$dir" -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null
      find "$dir" -type f -name "*.tfstate" -delete 2>/dev/null
      find "$dir" -type f -name "*.tfstate.*" -delete 2>/dev/null
      find "$dir" -type f -name ".terraform.lock.hcl" -delete 2>/dev/null
      find "$dir" -type f -name "*.tfplan" -delete 2>/dev/null
      find "$dir" -type f -name "crash.log" -delete 2>/dev/null
      echo "Arquivos Terraform processados em $dir."
    fi
  done

  if git diff --quiet; then
    echo "Nenhum arquivo Terraform foi excluído (nenhum encontrado)."
  else
    echo "Arquivos Terraform foram excluídos."
    CHANGES=1
  fi
}

delete_pycache_files() {
  echo "Excluindo arquivos __pycache__ no projeto..."
  find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
  find . -type f -name "*.pyc" -delete 2>/dev/null
  find . -type f -name "*.pyo" -delete 2>/dev/null

  if git diff --quiet; then
    echo "Nenhum arquivo __pycache__ foi excluído (nenhum encontrado)."
  else
    echo "Arquivos __pycache__ foram excluídos."
    CHANGES=1
  fi
}

destroy_terraform_local() {
  echo "Destruindo infraestrutura local com Terraform..."

  TF_ROOT="terraform"
  TF_VAR_FILE="../environments/dev/terraform.tfvars"

  if [ -d "$TF_ROOT" ]; then
    terraform -chdir=$TF_ROOT init
    if [ $? -ne 0 ]; then
      echo "Erro ao executar terraform init no diretório $TF_ROOT."
      exit 1
    fi

    if [ -f "$TF_VAR_FILE" ]; then
      terraform -chdir=$TF_ROOT destroy -auto-approve -var-file="$TF_VAR_FILE"
    else
      echo "Arquivo $TF_VAR_FILE não encontrado. Executando destroy sem var-file..."
      terraform -chdir=$TF_ROOT destroy -auto-approve
    fi

    if [ $? -ne 0 ]; then
      echo "Erro ao executar terraform destroy."
      exit 1
    fi

    echo "Infraestrutura local destruída com sucesso."
  else
    echo "Diretório $TF_ROOT não encontrado."
    exit 1
  fi
}

format_black() {
  echo "Executando black para formatar arquivos Python..."
  for dir in $PYTHON_DIRS; do
    if [ -d "$dir" ]; then
      black "$dir" --line-length 88
      echo "Formatação com black concluída em $dir."
    else
      echo "Diretório $dir não encontrado, ignorando..."
    fi
  done

  if git diff --quiet; then
    echo "Nenhuma mudança feita pelo black."
  else
    echo "Arquivos Python foram formatados pelo black."
    CHANGES=1
  fi
}

format_isort() {
  echo "Executando isort para organizar imports em arquivos Python..."
  for dir in $PYTHON_DIRS; do
    if [ -d "$dir" ]; then
      isort "$dir" --profile black
      echo "Organização de imports com isort concluída em $dir."
    else
      echo "Diretório $dir não encontrado, ignorando..."
    fi
  done

  if git diff --quiet; then
    echo "Nenhuma mudança feita pelo isort."
  else
    echo "Imports foram organizados pelo isort."
    CHANGES=1
  fi
}

format_terraform() {
  echo "Executando terraform fmt para formatar arquivos Terraform..."
  for dir in $TERRAFORM_DIRS; do
    if [ -d "$dir" ]; then
      terraform fmt -recursive "$dir"
      echo "Formatação com terraform fmt concluída em $dir."
    else
      echo "Diretório $dir não encontrado, ignorando..."
    fi
  done

  if git diff --quiet; then
    echo "Nenhuma mudança feita pelo terraform fmt."
  else
    echo "Arquivos Terraform foram formatados pelo terraform fmt."
    CHANGES=1
  fi
}


delete_zip_files
delete_terraform_files
delete_pycache_files
destroy_terraform_local
format_black
format_isort
format_terraform


if [ $CHANGES -eq 1 ]; then
  echo "Mudanças foram feitas nos arquivos. Considere fazer commit das alterações:"
  echo "  git add ."
  echo "  git commit -m 'Limpeza: excluir .zip, __pycache__, arquivos Terraform, destruir infra local e aplicar formatação'"
else
  echo "Nenhuma mudança foi necessária. O código já está formatado corretamente e sem arquivos temporários."
fi

exit 0
