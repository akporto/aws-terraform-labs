import json
import os
import boto3


dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ['DYNAMODB_TABLE_NAME']
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    print("Processando requisição para remover item")


    try:
        # Verifica se o corpo da requisição existe
        if not event.get('body'):
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'success': False, 'message': 'O corpo da requisição não pode estar vazio'})
            }

        body = json.loads(event['body'])

        # Valida campos obrigatórios
        if not all(key in body for key in ['pk', 'itemId']):
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'success': False, 'message': 'pk e itemId são obrigatórios'})
            }


        formatted_pk = f"LIST#{body['pk']}"
        formatted_sk = f"ITEM#{body['itemId']}"

        
        existing_item = table.get_item(Key={'PK': formatted_pk, 'SK': formatted_sk}).get('Item')

        # Remove o item
        response = table.delete_item(
            Key={
                'PK': formatted_pk,
                'SK': formatted_sk
            },
            ReturnValues='ALL_OLD'  
        )

        # Verifica se o item foi encontrado e excluído
        deleted_item = response.get('Attributes')
        if not deleted_item:
            return {
                'statusCode': 200,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({
                    'success': True,
                    'message': 'Item não encontrado ou já removido anteriormente'
                })
            }

        # Retorna confirmação de sucesso com o item excluído
        response={
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'success': True,
                'message': 'Item removido com sucesso',
                'removedItem': deleted_item
            }, ensure_ascii=False)
        }
        return response


    except Exception as e:
        print(f"Erro: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'success': False, 'message': f'Erro interno: {str(e)}'})
        }