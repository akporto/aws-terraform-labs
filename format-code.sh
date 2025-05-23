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

PYTHON_DIRS="lambda/lambda_hellow_terraform lambda/lambda_market_list"
TERRAFORM_DIRS="terraform terraform/modules/api_gateway terraform/modules/lambda"
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
      find "$dir" -type d -name ".terraform" -exec rm -rf {} +
      find "$dir" -type f -name "*.tfstate" -delete
      find "$dir" -type f -name "*.tfstate.*" -delete
      find "$dir" -type f -name ".terraform.lock.hcl" -delete
      find "$dir" -type f -name "*.tfplan" -delete
      find "$dir" -type f -name "crash.log" -delete
      if [ $? -eq 0 ]; then
        echo "Arquivos Terraform excluídos com sucesso em $dir."
      else
        echo "Erro ao excluir arquivos Terraform em $dir."
        exit 1
      fi
    fi
  done

  if git diff --quiet; then
    echo "Nenhum arquivo Terraform foi excluído (nenhum encontrado)."
  else
    echo "Arquivos Terraform foram excluídos."
    CHANGES=1
  fi
}

destroy_terraform_local() {
  echo "Destruindo infraestrutura local com Terraform na raiz do projeto..."

  TF_DIR="terraform"
  TF_VAR_FILE="terraform.auto.tfvars"

  if [ -d "$TF_DIR" ]; then
    cd "$TF_DIR" || exit 1

    terraform init
    if [ $? -ne 0 ]; then
      echo "Erro ao executar terraform init em $TF_DIR."
      exit 1
    fi

    if [ ! -f "$TF_VAR_FILE" ]; then
      echo "Arquivo de variáveis $TF_VAR_FILE não encontrado."
      exit 1
    fi

    terraform destroy -auto-approve -var-file="$TF_VAR_FILE"
    if [ $? -ne 0 ]; then
      echo "Erro ao executar terraform destroy em $TF_DIR."
      exit 1
    fi

    cd - > /dev/null || exit 1
    echo "Infraestrutura local destruída com sucesso."
  else
    echo "Diretório $TF_DIR não encontrado."
    exit 1
  fi
}

format_black() {
  echo "Executando black para formatar arquivos Python..."
  for dir in $PYTHON_DIRS; do
    if [ -d "$dir" ]; then
      black "$dir" --line-length 88
      if [ $? -eq 0 ]; then
        echo "Formatação com black concluída em $dir."
      else
        echo "Erro ao executar black em $dir."
        exit 1
      fi
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
      if [ $? -eq 0 ]; then
        echo "Organização de imports com isort concluída em $dir."
      else
        echo "Erro ao executar isort em $dir."
        exit 1
      fi
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
      if [ $? -eq 0 ]; then
        echo "Formatação com terraform fmt concluída em $dir."
      else
        echo "Erro ao executar terraform fmt em $dir."
        exit 1
      fi
    fi
  done

  if git diff --quiet; then
    echo "Nenhuma mudança feita pelo terraform fmt."
  else
    echo "Arquivos Terraform foram formatados pelo terraform fmt."
    CHANGES=1
  fi
}

# Executar as funções na ordem
delete_zip_files
delete_terraform_files
destroy_terraform_local
format_black
format_isort
format_terraform

# Sugerir commit se necessário
if [ $CHANGES -eq 1 ]; then
  echo "Mudanças foram feitas nos arquivos. Considere fazer commit das alterações:"
  echo "  git add ."
  echo "  git commit -m 'Excluir .zip, arquivos Terraform, destruir Terraform local e aplicar formatação com black, isort e terraform fmt'"
else
  echo "Nenhuma mudança foi necessária. O código já está formatado corretamente e sem arquivos .zip, Terraform ou infraestrutura local."
fi

exit 0
