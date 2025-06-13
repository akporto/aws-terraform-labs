import json
import os
from datetime import datetime

import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    print("Processando requisição de update")

    try:
        path = event.get("pathParameters") or {}
        pk = path.get("pk")  # USER#<user_id>
        sk = path.get("sk")  # LIST#<date>#ITEM#<uuid>

        if not pk or not sk:
            return create_error_response(400, "PK e SK são obrigatórios no path")

        body = json.loads(event["body"])

        allowed_fields = [
            "name",
            "status",
            "scheduled_for",
            "completed_at",
            "task_type",
        ]
        expr_values = {}
        expr_names = {}
        update_expr = []

        for field in allowed_fields:
            if field in body:
                value = body[field]

                if field == "status" and value.upper() not in ["TODO", "DONE"]:
                    return create_error_response(400, "Status deve ser TODO ou DONE")

                update_expr.append(f"#{field} = :{field}")
                expr_values[f":{field}"] = value
                expr_names[f"#{field}"] = field

        if not update_expr:
            return create_error_response(400, "Nenhum campo válido para atualizar")

        # Marca data da última atualização
        update_expr.append("#updatedAt = :updatedAt")
        expr_values[":updatedAt"] = datetime.now().isoformat()
        expr_names["#updatedAt"] = "updatedAt"

        # Executa a atualização
        result = table.update_item(
            Key={"PK": pk, "SK": sk},
            UpdateExpression="SET " + ", ".join(update_expr),
            ExpressionAttributeNames=expr_names,
            ExpressionAttributeValues=expr_values,
            ReturnValues="ALL_NEW",
        )

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(
                {
                    "success": True,
                    "message": "Item atualizado com sucesso",
                    "item": result["Attributes"],
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
