# Hello Terraform

Este projeto é um estudo prático utilizando o Terraform para provisionamento de infraestrutura na AWS, implementando uma API para gerenciar listas de compras de mercado. A infraestrutura inclui funções Lambda (Python), API Gateway, DynamoDB e Cognito.


## 🔄 Fluxo de Trabalho Git

### Padrões de Branch

- **`main`**: Branch de produção (protegida)
- **`dev`**: Branch de desenvolvimento (protegida)
- **`feature/nome-da-feature`**: Novas funcionalidades
- **`bugfix/nome-do-bug`**: Correções de bugs
- **`hotfix/nome-do-hotfix`**: Correções urgentes em produção
- **`release/x.y.z`**: Preparação para lançamento de versão

### Processo de Contribuição

1. **Crie uma branch a partir de dev:**
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/minha-feature
   ```

2. **Envie suas alterações:**
   ```bash
   git add .
   git commit -m "Descrição clara das mudanças"
   git push origin feature/minha-feature
   ```

3. **Abra um Pull Request no GitHub:**
   - Target branch: `dev`
   - Adicione revisores quando aplicável
   - Aguarde aprovações

## 📋 Pré-requisitos

Antes de iniciar, você precisa ter instalado:

- **Terraform** v1.0.0 ou superior
- **AWS CLI** configurado com credenciais
- **Python 3.9+** (para funções Lambda)
- **Git**

### Dependências Python

```bash
pip install -r requirements.txt
```

## Configuração do VSCode
**Para executar os testes corretamente no VSCode, crie o arquivo .vscode/settings.json na raiz do projeto:**

```bash
json{
  "python.analysis.extraPaths": [
    "src/lambdas/lambda_task_list_api/add_item",
    "src/lambdas/lambda_task_list_api/get_item",
    "src/lambdas/lambda_task_list_api/update_item"
  ]
}
```

**Este arquivo configura o analisador Python do VSCode para reconhecer os caminhos das funções Lambda, permitindo que os testes sejam executados corretamente.**


## 🚀 Componentes do Sistema

### 1. Funções Lambda (Python)

O projeto contém cinco funções Lambda:

- **Hello Terraform**: Função básica que retorna "Hello Terraform"
- **Add Item**: Adiciona novos itens à lista de mercado
- **Get Items**: Lista todos os itens da lista de mercado
- **Update Item**: Atualiza itens existentes na lista de mercado
- **Delete Item**: Remove itens da lista de mercado

### 2. API Gateway

Uma API REST que expõe endpoints para gerenciar a lista de mercado:

- `GET /items`: Lista todos os itens
- `POST /items`: Adiciona um novo item
- `PUT /items`: Atualiza um item existente


### 3. DynamoDB

Armazena todos os itens da lista de mercado em uma tabela com:

- Chave primária composta: PK (partition key) e SK (sort key)
- Formato de chaves: PK = "LIST#[data]" e SK = "ITEM#[id]"

### 4. Cognito

Gerencia autenticação e autorização de usuários.

## ⚙️ Configuração e Deploy

### 1. Clone o repositório

```bash
git clone https://github.com/akporto/aws-terraform-labs.git
cd aws-terraform-labs
```

### 2. Instale as dependências Python

```bash
pip install -r requirements.txt
```

### 3. Configure as variáveis do ambiente

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Edite o arquivo `terraform.tfvars` com seus próprios valores:

```hcl
aws_region   = "sa-east-1"
project_name = "hello-terraform"
environment  = "dev"
```

### 4. Configure o backend remoto

```bash
cp backend.tf.example backend.tf
```

Edite o arquivo `backend.tf` com as configurações do seu bucket S3:

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

### 5. Inicialize e aplique a infraestrutura

```bash
cd ../../terraform
terraform init
terraform plan -var-file=../environments/dev/terraform.tfvars
terraform apply -var-file=../environments/dev/terraform.tfvars
```

## 🧪 Testando a API

Após o deploy, você pode testar a API usando curl ou ferramentas como Postman:

### Listar itens

```bash
curl -X GET \
  https://seu-api-gateway-url/dev/lista-tarefa \
  -H 'Authorization: Bearer seu-token'
```

### Adicionar um item

```bash
curl -X POST \
  https://seu-api-gateway-url/dev/lista-tarefa \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer seu-token' \
  -d '{"name": "Leite"}'
```

### Atualizar um item

```bash
curl -X PUT \
  https://seu-api-gateway-url/dev/lista-tarefa \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer seu-token' \
  -d '{"pk": "20250514", "itemId": "abc123", "name": "Leite Integral", "status": "DONE"}'
```


## 🛠️ Desenvolvimento

### Script de Limpeza e Formatação

O projeto inclui um script automatizado para limpeza e formatação:

```bash
# Dar permissão de execução
chmod +x format-code.sh

# Executar o script
./format-code.sh
```

O script realiza:

- Remove arquivos `.zip` e `__pycache__`
- Limpa arquivos temporários do Terraform
- Destrói infraestrutura local se necessário
- Formata código Python com `black` e `isort`
- Formata arquivos Terraform com `terraform fmt`

### Testes

Execute os testes das funções Lambda:

```bash
# Instalar dependências de teste
pip install -r requirements.txt

# Executar testes
python -m pytest src/lambdas/tests/ -v
```

## 📁 Explicação dos Arquivos de Configuração

### Módulos Terraform

O projeto utiliza módulos reutilizáveis localizados em `terraform/modules/`:

- **api_gateway/**: Configuração do API Gateway
- **cognito/**: Configuração do Cognito User Pool
- **dynamodb/**: Configuração da tabela DynamoDB
- **iam/**: Roles e políticas IAM
- **lambda/**: Configuração das funções Lambda

### Arquivos Principais

#### `environments/dev/backend.tf`

Define o backend remoto onde o Terraform armazenará o estado da infraestrutura.

#### `environments/dev/terraform.tfvars`

Armazena os valores das variáveis específicas do ambiente de desenvolvimento.

#### `terraform/main.tf`

Define todos os recursos principais, integrando os módulos.


## 🔒 Segurança

- Todas as permissões seguem o princípio do menor privilégio
- Autenticação gerenciada pelo Cognito
- Variáveis de ambiente sensíveis gerenciadas pelo Terraform
- Recursos têm tags para fácil identificação e gerenciamento

## 🧹 Limpeza dos Recursos

Para destruir toda a infraestrutura criada:

```bash
cd terraform
terraform destroy -var-file=../environments/dev/terraform.tfvars
```

Ou use o script de limpeza:

```bash
./format-code.sh
```

## 🧠 Integração com PySpark ETL

Este projeto é compatível com o repositório [akporto/pyspark-etl-scripts](https://github.com/akporto/pyspark-etl-scripts), que contém três scripts desenvolvidos em PySpark para realizar operações de leitura, análise e exclusão de dados na tabela DynamoDB provisionada por este projeto.

> A infraestrutura criada aqui — incluindo DynamoDB, permissões IAM e variáveis de ambiente — fornece a base ideal para executar scripts PySpark que interajam com o DynamoDB, seja localmente ou em ambientes como Colab, EMR ou Databricks (com configuração adicional).

### 🔗 Scripts disponíveis no repositório de ETL

- `envio_dynamodb.py`: Lê dados de um arquivo CSV, transforma e envia para uma tabela DynamoDB com chaves compostas (`PK` e `SK`).
- `analise_abandono.py`: Identifica tarefas ou itens abandonados com base em regras de tempo e status, e exporta relatório `.csv`.
- `deletar_usuario.py`: Remove todos os registros associados a um `user_id` específico no DynamoDB.

### 💡 Como usar os dois projetos em conjunto

1. **Provisionamento**: Use este projeto (`aws-terraform-labs`) para criar:
   - Tabela DynamoDB com chave composta (`PK`, `SK`)
   - Roles IAM com permissões de leitura/escrita/exclusão
   - Variáveis reutilizáveis (região, nome da tabela, etc.)

2. **Execução do ETL**:
   - Clone o projeto [pyspark-etl-scripts](https://github.com/akporto/pyspark-etl-scripts)
   - Configure as variáveis de ambiente:
     ```python
     os.environ["AWS_ACCESS_KEY_ID"] = "sua_access_key"
     os.environ["AWS_SECRET_ACCESS_KEY"] = "sua_secret_key"
     os.environ["AWS_DEFAULT_REGION"] = "sa-east-1"
     os.environ["USER_ID"] = "uuid-do-usuario"
     os.environ["DYNAMODB_TABLE_NAME"] = "nome-da-tabela"
     ```
   - Execute os scripts PySpark no ambiente de sua escolha

> Essa integração une o provisionamento automatizado via Terraform com a flexibilidade de análise e manipulação de dados com PySpark, formando um pipeline completo e escalável.


## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request
