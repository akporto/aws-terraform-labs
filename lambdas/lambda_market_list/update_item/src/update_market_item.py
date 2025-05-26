import json
import os
from datetime import datetime

import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    print("Processando requisição para atualizar item")

    try:
        body = json.loads(event["body"])

        if "status" in body and body["status"] not in ["TODO", "DONE"]:
            response = {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps(
                    {"success": False, "message": "Status deve ser TODO ou DONE"}
                ),
            }
            return response

        # campos obrigatórios
        if not all(key in body for key in ["pk", "itemId"]):
            response = {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps(
                    {"success": False, "message": "pk e itemId são obrigatórios"}
                ),
            }
            return response

        formatted_pk = f"LIST#{body['pk']}"
        formatted_sk = f"ITEM#{body['itemId']}"

        # Verifica existência do item
        existing_item = table.get_item(
            Key={"PK": formatted_pk, "SK": formatted_sk}
        ).get("Item")
        if not existing_item:
            response = {
                "statusCode": 404,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps(
                    {"success": False, "message": "Item não encontrado"}
                ),
            }
            return response

        update_expr = []
        expr_values = {}
        expr_names = {}

        if "name" in body:
            update_expr.append("#nm = :name")
            expr_values[":name"] = body["name"]
            expr_names["#nm"] = "name"

        if "date" in body:
            update_expr.append("#dt = :date")
            expr_values[":date"] = body["date"]
            expr_names["#dt"] = "date"

        if "status" in body:
            update_expr.append("#st = :status")
            expr_values[":status"] = body["status"]
            expr_names["#st"] = "status"

        if not update_expr:
            response = {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps(
                    {
                        "success": False,
                        "message": "Nenhum campo válido para atualização",
                    }
                ),
            }
            return response

        # rastreia a ultima atualização
        update_expr.append("#updatedAt = :updatedAt")
        expr_values[":updatedAt"] = datetime.now().isoformat()
        expr_names["#updatedAt"] = "updatedAt"

        # atualização
        update_result = table.update_item(
            Key={"PK": formatted_pk, "SK": formatted_sk},
            UpdateExpression="SET " + ", ".join(update_expr),
            ExpressionAttributeValues=expr_values,
            ExpressionAttributeNames=expr_names,
            ReturnValues="ALL_NEW",
        )

        # Retorna o item completo atualizado
        updated_item = update_result["Attributes"]
        response = {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(
                {
                    "success": True,
                    "message": "Item atualizado com sucesso",
                    "item": updated_item,
                },
                ensure_ascii=False,
            ),
        }
        return response

    except Exception as e:
        print(f"Erro: {str(e)}")
        response = {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(
                {"success": False, "message": f"Erro interno: {str(e)}"}
            ),
        }
        return response
