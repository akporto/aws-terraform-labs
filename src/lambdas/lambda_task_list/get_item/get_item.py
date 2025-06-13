import json
import os
from datetime import datetime

import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE_NAME"])


def lambda_handler(event, context):
    print("Recebida requisição para obter itens com filtros opcionais")

    try:
        query_params = event.get("queryStringParameters") or {}

        if not query_params:
            return create_error_response(
                400,
                "É necessário fornecer pelo menos um parâmetro de filtro: user_id, scheduled_for, task_type ou status",
            )

        user_id = query_params.get("user_id")
        scheduled_for = query_params.get("scheduled_for")
        task_type = query_params.get("task_type")
        status = query_params.get("status")

        items = []

        #  Filtro por user_id busca todos os itens do usuário
        if user_id and not (scheduled_for or task_type or status):
            pk = f"USER#{user_id}"
            print(f"Consultando por PK: {pk}")
            response = table.query(KeyConditionExpression=Key("PK").eq(pk))
            items = response.get("Items", [])

        #  Filtro por scheduled_for
        elif scheduled_for:
            print(f"Consultando GSI por scheduled_for = {scheduled_for}")
            response = table.query(
                IndexName="GSI_ScheduledFor",
                KeyConditionExpression=Key("scheduled_for").eq(scheduled_for),
            )
            items = response.get("Items", [])

        #  Filtro por task_type
        elif task_type:
            print(f"Consultando GSI por task_type = {task_type}")
            response = table.query(
                IndexName="GSI_TaskType",
                KeyConditionExpression=Key("task_type").eq(task_type),
            )
            items = response.get("Items", [])

        # 4 Filtro por status
        elif status:
            if status.upper() not in ["TODO", "DONE"]:
                return create_error_response(400, "Status deve ser TODO ou DONE")
            print(f"Consultando GSI por status = {status}")
            response = table.query(
                IndexName="GSI_Status",
                KeyConditionExpression=Key("status").eq(status.upper()),
            )
            items = response.get("Items", [])

        else:
            return create_error_response(
                400, "Parâmetro de filtro inválido ou combinação não suportada"
            )

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "success": True,
                    "message": f"{len(items)} item(s) encontrado(s)",
                    "items": items,
                }
            ),
            "headers": {"Content-Type": "application/json"},
        }

    except Exception as e:
        print(f"Erro ao obter itens: {str(e)}")
        return create_error_response(500, f"Erro ao obter itens: {str(e)}")


def create_error_response(status_code, message):
    return {
        "statusCode": status_code,
        "body": json.dumps({"success": False, "message": message}),
        "headers": {"Content-Type": "application/json"},
    }
