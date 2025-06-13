import json
import os

import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    print("Processando requisição para deletar item")

    try:
        path = event.get("pathParameters") or {}
        pk = path.get("pk")  # Ex: USER#<user_id>
        sk = path.get("sk")  # Ex: LIST#<date>#ITEM#<uuid>

        if not pk or not sk:
            return create_error_response(400, "PK e SK são obrigatórios no path")

        response = table.delete_item(Key={"PK": pk, "SK": sk}, ReturnValues="ALL_OLD")

        deleted_item = response.get("Attributes")
        if not deleted_item:
            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps(
                    {
                        "success": True,
                        "message": "Item não encontrado ou já removido anteriormente",
                    },
                    ensure_ascii=False,
                ),
            }

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(
                {
                    "success": True,
                    "message": "Item removido com sucesso",
                    "removedItem": deleted_item,
                },
                ensure_ascii=False,
            ),
        }

    except Exception as e:
        print(f"Erro: {e}")
        return create_error_response(500, f"Erro interno: {str(e)}")


def create_error_response(status_code, message):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"success": False, "message": message}),
    }
