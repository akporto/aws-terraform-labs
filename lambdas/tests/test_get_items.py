import pytest
from unittest.mock import MagicMock, patch
import sys
import os
from datetime import datetime

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "../lambda_market_list/get_items/src")
    )
)

import get_items


@patch("get_items.boto3")
def test_lambda_handler_success(mock_boto3):
    mock_dynamodb = MagicMock()
    mock_table = MagicMock()
    mock_table.query.return_value = {
        "Items": [{"itemId": "123", "name": "banana", "status": "todo"}]
    }
    mock_dynamodb.resource.return_value.Table.return_value = mock_table
    mock_boto3.resource.return_value = mock_dynamodb.resource.return_value

    event = {"queryStringParameters": {"date": "20250526"}}
    response = get_items.lambda_handler(event, None)

    assert response["statusCode"] == 200
    assert "banana" in response["body"]
    assert '"success": true' in response["body"]


# Sem parametro de data
@patch("get_items.boto3")
def test_lambda_handler_no_date_parameter(mock_boto3):
    mock_dynamodb = MagicMock()
    mock_table = MagicMock()
    mock_table.query.return_value = {
        "Items": [{"itemId": "456", "name": "apple", "status": "todo"}]
    }
    mock_dynamodb.resource.return_value.Table.return_value = mock_table
    mock_boto3.resource.return_value = mock_dynamodb.resource.return_value

    event = {"queryStringParameters": None}
    response = get_items.lambda_handler(event, None)

    assert response["statusCode"] == 200
    assert "apple" in response["body"]
    assert '"success": true' in response["body"]

    # Confirma que o pk usada foi a data atual
    today = datetime.now().strftime("%Y%m%d")
    assert f"lista de {today}" in response["body"]


# Retorno vazio
@patch("get_items.boto3")
def test_lambda_handler_empty_items(mock_boto3):
    mock_dynamodb = MagicMock()
    mock_table = MagicMock()
    mock_table.query.return_value = {"Items": []}
    mock_dynamodb.resource.return_value.Table.return_value = mock_table
    mock_boto3.resource.return_value = mock_dynamodb.resource.return_value

    event = {"queryStringParameters": {"date": "20250526"}}
    response = get_items.lambda_handler(event, None)

    assert response["statusCode"] == 200
    assert '"items": []' in response["body"]
    assert '"success": true' in response["body"]


# Falha ao executar
@patch("get_items.boto3")
def test_lambda_handler_exception(mock_boto3):
    mock_dynamodb = MagicMock()
    mock_table = MagicMock()
    mock_table.query.side_effect = Exception("DynamoDB falhou")
    mock_dynamodb.resource.return_value.Table.return_value = mock_table
    mock_boto3.resource.return_value = mock_dynamodb.resource.return_value

    event = {"queryStringParameters": {"date": "20250526"}}
    response = get_items.lambda_handler(event, None)

    assert response["statusCode"] == 500
    assert "DynamoDB falhou" in response["body"]
    assert '"success": false' in response["body"]
