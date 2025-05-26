import json
import os
import uuid
from datetime import datetime

import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    print("Processando requisição para adicionar item à lista de mercado")

    try:

        item = json.loads(event["body"])

        if "name" not in item or not item["name"].strip():
            return create_error_response(400, "O nome do item é obrigatório")

        item_id = str(uuid.uuid4())
        pk = datetime.now().strftime("%Y%m%d")

        item_attributes = {
            "PK": f"LIST#{pk}",
            "SK": f"ITEM#{item_id}",
            "name": item["name"],
            "date": datetime.now().isoformat(),
            "status": "todo",
        }

        # Salva item
        print(f"Salvando item no DynamoDB: PK={pk}, SK=ITEM#{item_id}")
        table.put_item(Item=item_attributes)

        # Resposta atualizada
        response_body = {
            "success": True,
            "message": "Item adicionado com sucesso à lista de mercado",
            "item": {
                "pk": pk,
                "sk": f"ITEM#{item_id}",
                "name": item["name"],
                "date": datetime.now().isoformat(),
                "status": "todo",
            },
        }

        response = {
            "statusCode": 201,
            "body": json.dumps(response_body),
            "headers": {"Content-Type": "application/json"},
        }
        return response

    except Exception as e:
        print(f"Erro ao processar a solicitação: {str(e)}")
        return create_error_response(500, f"Erro ao processar a solicitação: {str(e)}")


def create_error_response(status_code, message):
    error_body = {"success": False, "message": message}
    response = {
        "statusCode": status_code,
        "body": json.dumps(error_body),
        "headers": {"Content-Type": "application/json"},
    }
    return response
