# Hello Terraform - Lista de Mercado

Este projeto é um estudo prático utilizando o Terraform para provisionamento de infraestrutura na AWS, implementando uma API para gerenciar listas de compras de mercado. A infraestrutura inclui funções Lambda (em Java e Python), API Gateway e DynamoDB.

## 🌿 Fluxo de Trabalho Git

### Padrões de Branch
* `main`: Branch de produção (protegida)
* `dev`: Branch de desenvolvimento (protegida)
* `feature/nome-da-feature`: Novas funcionalidades
* `bugfix/nome-do-bug`: Correções de bugs
* `hotfix/nome-do-hotfix`: Correções urgentes em produção
* `release/x.y.z`: Preparação para lançamento de versão


### Processo de Contribuição
1. Crie uma branch a partir de dev:

```bash
git checkout dev
git pull origin dev
git checkout -b feature/minha-feature
```

Envie suas alterações:

```bash
git add .
git commit -m "Descrição clara das mudanças"
git push origin feature/minha-feature
```

Abra um Pull Request no GitHub:

Target branch: dev
Adicione revisores quando aplicável
Aguarde aprovações



🚀## Pré-requisitos
Antes de iniciar, você precisa ter instalado:

Terraform v1.0.0 ou superior
AWS CLI configurado com credenciais
Java JDK 11 (para funções Lambda em Java)
Python 3.9 (para funções Lambda em Python)
Maven (para compilação dos projetos Java)
Git

## Estrutura do Projeto
O projeto está dividido em várias partes

.
├── lambda/
│   ├── funcao-um/     # Lambda Java - Hello Terraform
│   ├── funcao-dois/   # Lambda Java - Adicionar item à lista
│   ├── funcao-tres/   # Lambda Python - Atualizar item na lista
│   └── funcao-quatro/ # Lambda Python - Remover item da lista
└── terraform/
├── modules/       # Módulos reutilizáveis do Terraform
│   └── lambda/    # Módulo para criar funções Lambda
├── environments/  # Configurações específicas de ambiente
│   ├── dev/       # Ambiente de desenvolvimento
│   └── prod/      # Ambiente de produção
├── main.tf        # Definição principal de recursos
├── variables.tf   # Variáveis do projeto
└── outputs.tf     # Saídas após aplicação do Terraform

## Componentes do Sistema
1. Funções Lambda
   O projeto contém quatro funções Lambda:

Função Um (Java): Função básica que retorna "Hello Terraform"
Função Dois (Java): Adiciona novos itens à lista de mercado
Função Três (Python): Atualiza itens existentes na lista de mercado
Função Quatro (Python): Remove itens da lista de mercado

2. API Gateway
   Uma API REST que expõe endpoints para gerenciar a lista de mercado:

POST /items: Adiciona um novo item (integrado com Função Dois)
PUT /items: Atualiza um item existente (integrado com Função Três)
DELETE /items: Remove um item (integrado com Função Quatro)

3. DynamoDB
   Armazena todos os itens da lista de mercado em uma tabela com:

Chave primária composta: PK (partition key) e SK (sort key)
Formato de chaves: PK = "LIST#[data]" e SK = "ITEM#[id]"

## Configuração e Deploy
1. Clone o repositório

```bash
git clone https://github.com/akporto/terraform-estudo01.git
cd terraform-estudo01
```

2. Compile as funções Lambda Java
   ```bash
   cd lambda/funcao-um
   mvn clean package
   cd ../funcao-dois
   mvn clean package
   cd ../../
   ```
   
   Isso gerará os arquivos .jar dentro de target/, que serão usados pelo Terraform para criar as funções Lambda.

3. Configure as variáveis do ambiente
   ```bash
   cd terraform/environments/dev
   cp terraform.tfvars.example terraform.tfvars
   ```
# Edite o arquivo terraform.tfvars com seus próprios valores

4. Configure o backend remoto 
  ``` bash
   cp backend.tf.example backend.tf
   ```

# Edite o arquivo backend.tf com as configurações do seu bucket S3
5. Inicialize e aplique a infraestrutura
   ```bash
   cd ../../
   terraform init
   terraform plan -var-file=environments/dev/terraform.tfvars
   terraform apply -var-file=environments/dev/terraform.tfvars
   ```

📁## Explicação dos Arquivos de Configuração Terraform

Módulos
O projeto utiliza um módulo reutilizável para criar funções Lambda, localizado em modules/lambda/. Esse módulo encapsula toda a configuração necessária para criar uma função Lambda padrão, incluindo:

A função Lambda em si
Papel IAM e políticas de permissão
Configuração de logs

### Arquivos Principais
🔙 backend.tf
O arquivo backend.tf define o backend remoto onde o Terraform armazenará o estado da infraestrutura. Usar um backend remoto como o S3 permite que múltiplos desenvolvedores compartilhem o mesmo estado de forma segura.

```
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

terraform.tfvars

O arquivo terraform.tfvars armazena os valores das variáveis usadas no projeto, separando as configurações do código principal. Ele facilita a reutilização do código com diferentes ambientes.

```hcl
aws_region   = "sa-east-1"
project_name = "hello-terraform"
environment  = "dev"
```

📝 main.tf
Define todos os recursos principais, incluindo:

Funções Lambda (usando módulos para Java e recursos diretos para Python)
Tabela DynamoDB
Políticas IAM para acesso ao DynamoDB

🌐 api_gateway.tf
Define o API Gateway REST com endpoints para operações CRUD na lista de mercado, integrando-os com as funções Lambda.
🧪 Testando a API
Após o deploy, você pode testar a API usando curl ou ferramentas como Postman:

## Adicionar um item (Função Dois)
```bash
curl -X POST \
https://seu-api-gateway-url/dev/items \
-H 'Content-Type: application/json' \
-d '{"name": "Leite"}'
```

## Atualizar um item (Função Três)
```bash
curl -X PUT \
https://seu-api-gateway-url/dev/items \
-H 'Content-Type: application/json' \
-d '{"pk": "20250514", "itemId": "abc123", "name": "Leite Integral", "status": "DONE"}'
```

## Remover um item (Função Quatro)
```bash
curl -X DELETE \
https://seu-api-gateway-url/dev/items \
-H 'Content-Type: application/json' \
-d '{"pk": "20250514", "itemId": "abc123"}'
```
🧹 
## Limpeza dos Recursos

Para destruir toda a infraestrutura criada:

```bash
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## Arquitetura

O sistema segue uma arquitetura serverless:

O cliente envia requisições REST para o API Gateway
O API Gateway encaminha as requisições para as funções Lambda correspondentes
As funções Lambda processam as operações (CRUD) na tabela DynamoDB
Os resultados são retornados ao cliente através do API Gateway

## Segurança

Todas as permissões seguem o princípio do menor privilégio
As variáveis de ambiente sensíveis são gerenciadas pelo Terraform
Os recursos têm tags para fácil identificação e gerenciamento

📜