import json
import os
import boto3
from datetime import datetime
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])

def lambda_handler(event, context):
    print("Recebida requisição para obter itens da lista")

    try:
        # Pega a data da query string, ou usa a data atual
        query_params = event.get('queryStringParameters') or {}
        date_str = query_params.get('date') if query_params.get('date') else datetime.now().strftime("%Y%m%d")
        pk = f"LIST#{date_str}"

        print(f"Consultando itens com PK: {pk}")

        # Query no DynamoDB
        response = table.query(
            KeyConditionExpression=Key('PK').eq(pk)
        )

        items = response.get('Items', [])

        return {
            'statusCode': 200,
            'body': json.dumps({
                'success': True,
                'message': f'{len(items)} item(s) encontrado(s) na lista de {date_str}',
                'items': items
            }),
            'headers': {'Content-Type': 'application/json'}
        }

    except Exception as e:
        print(f"Erro ao obter itens: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'success': False,
                'message': f"Erro ao obter itens: {str(e)}"
            }),
            'headers': {'Content-Type': 'application/json'}
        }
