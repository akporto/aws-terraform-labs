# Hello Terraform

Este projeto é um estudo prático utilizando o Terraform para provisionamento de infraestrutura na AWS, incluindo o deploy de funções Lambda escritas em Java. O repositório está organizado por ambientes, facilitando a reutilização de módulos e a separação de contextos.


## 🚀 Pré-requisitos

Antes de iniciar, você precisa ter instalado:
- Terraform v1.x
- AWS CLI configurado com credenciais
- Java JDK 11 ou superior
- Maven (ou Gradle)
- Git

## ⚙️ Configuração e Deploy

### 1. Clone o repositório
```bash
git clone https://github.com/akporto/terraform-estudo01.git
cd terraform-estudo01
```

### 2. Compile a função Lambda
```bash
cd lambda/funcao-um
mvn clean package
```

Isso gerará um arquivo .jar dentro de target/, usado pelo Terraform para criar a função Lambda.


### 3. Configure as variáveis do ambiente
```bash
cd environments/dev
cp backend.tf terraform.tfvars
```
## 📁 Explicação dos Arquivos de Configuração Terraform

### 🔙 `backend.tf`

O arquivo `backend.tf` define o backend remoto onde o Terraform armazenará o estado da infraestrutura. Usar um backend remoto como o S3 permite que múltiplos desenvolvedores compartilhem o mesmo estado de forma segura.

```hcl
terraform {
  backend "s3" {
    bucket         = "nome-do-seu-bucket"
    key            = "caminho/do/arquivo/terraform.tfstate"
    region         = "regiao-aws"
    dynamodb_table = "nome-da-tabela-dynamodb"
    encrypt        = true
  }
}
```

## 🔧 terraform.tfvars

O arquivo `terraform.tfvars` armazena os valores das variáveis usadas no projeto, separando as configurações do código principal. Ele facilita a reutilização do código com diferentes ambientes.

```hcl
aws_region   = "regiao-aws"
project_name = "nome-do-projeto"
environment  = "nome-do-ambiente"
```

## 4. Inicialize e aplique a infraestrutura
```bash
cd terraform
terraform init
terraform plan -var-file=../environments/dev/terraform.tfvars
terraform apply -var-file=../environments/dev/terraform.tfvars
```

## 5. Teste a função Lambda
Após o deploy, você pode testar a Lambda pela AWS CLI:

```bash
aws lambda invoke --function-name NOME_DA_FUNCAO out.json
cat out.json
```

## 🧹 Limpeza dos Recursos
Para destruir toda a infraestrutura criada:

```bash
terraform destroy -var-file=../environments/dev/terraform.tfvars
```


