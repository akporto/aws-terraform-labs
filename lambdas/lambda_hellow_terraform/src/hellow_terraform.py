import json


def lambda_handler(event, context):
    # Log
    print("Lambda function is running!")

    # resposta
    response = {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps("Hellow Terraform"),
    }

    return response
