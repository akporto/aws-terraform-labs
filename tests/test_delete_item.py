import json

import pytest
from delete_item import lambda_handler


def test_delete_item_success(mock_table):
    deleted_data = {
        "PK": "USER#123",
        "SK": "LIST#20250608#ITEM#abc",
        "name": "Item deletado",
    }

    mock_table.delete_item.return_value = {"Attributes": deleted_data}

    event = {"pathParameters": {"pk": "USER#123", "sk": "LIST#20250608#ITEM#abc"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["success"] is True
    assert body["message"] == "Item removido com sucesso"
    assert body["removedItem"] == deleted_data

    mock_table.delete_item.assert_called_once_with(
        Key={"PK": "USER#123", "SK": "LIST#20250608#ITEM#abc"}, ReturnValues="ALL_OLD"
    )


def test_delete_item_not_found(mock_table):
    mock_table.delete_item.return_value = {}

    event = {"pathParameters": {"pk": "USER#123", "sk": "LIST#20250608#ITEM#abc"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["success"] is True
    assert "não encontrado" in body["message"]

    mock_table.delete_item.assert_called_once()


def test_delete_item_missing_path_parameters(mock_table):
    event = {"pathParameters": None}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "PK e SK são obrigatórios" in body["message"]

    mock_table.delete_item.assert_not_called()


def test_delete_item_internal_error(mock_table):
    mock_table.delete_item.side_effect = Exception("Erro simulado")

    event = {"pathParameters": {"pk": "USER#123", "sk": "LIST#20250608#ITEM#abc"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 500
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "Erro interno" in body["message"]

    mock_table.delete_item.assert_called_once()
