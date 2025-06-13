import json
import os
import uuid
from datetime import datetime

import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    print("Processando requisição para adicionar item à lista de tarefas")

    try:
        item = json.loads(event["body"])
        response = create_item(item, table)
        return response

    except Exception as e:
        print(f"Erro ao processar a solicitação: {str(e)}")
        return create_error_response(500, f"Erro ao processar a solicitação: {str(e)}")


def create_item(item, table):
    required_fields = ["name", "user_id", "created_at"]

    for field in required_fields:
        if field not in item or not str(item[field]).strip():
            return create_error_response(400, f"O campo '{field}' é obrigatório")

    user_id = item["user_id"]
    created_at = item["created_at"]
    scheduled_for = item.get("scheduled_for")
    task_type = item.get("task_type", "Tarefa")
    status = item.get("status", "TODO").upper()
    completed_at = item.get("completed_at")
    item_id = str(uuid.uuid4())

    # SK com base na data de criação
    date_str = created_at[:10].replace("-", "") 
    sk = f"LIST#{date_str}#ITEM#{item_id}"

    item_attributes = {
        "PK": f"USER#{user_id}",
        "SK": sk,
        "name": item["name"],
        "task_type": task_type,
        "status": status,
        "created_at": created_at,
        "completed_at": completed_at,
        "scheduled_for": scheduled_for,
        "item_id": item_id,
    }

    # Remove atributos com valor None
    item_attributes = {k: v for k, v in item_attributes.items() if v is not None}

    table.put_item(Item=item_attributes)

    response_body = {
        "success": True,
        "message": "Item adicionado com sucesso à lista de tarefas",
        "item": item_attributes,
    }

    return {
        "statusCode": 201,
        "body": json.dumps(response_body),
        "headers": {"Content-Type": "application/json"},
    }


def create_error_response(status_code, message):
    return {
        "statusCode": status_code,
        "body": json.dumps({"success": False, "message": message}),
        "headers": {"Content-Type": "application/json"},
    }
