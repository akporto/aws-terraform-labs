import json

import pytest
from update_item import lambda_handler


def test_update_item_success(mock_table):
    mock_table.update_item.return_value = {
        "Attributes": {
            "PK": "USER#123",
            "SK": "LIST#20250608#ITEM#abc",
            "name": "Item atualizado",
            "status": "DONE",
            "updatedAt": "2025-06-08T12:00:00",
        }
    }

    event = {
        "pathParameters": {"pk": "USER#123", "sk": "LIST#20250608#ITEM#abc"},
        "body": json.dumps({"name": "Item atualizado", "status": "DONE"}),
    }
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["success"] is True
    assert body["message"] == "Item atualizado com sucesso"
    assert "item" in body
    assert body["item"]["name"] == "Item atualizado"
    assert body["item"]["status"] == "DONE"

    mock_table.update_item.assert_called_once()
    args, kwargs = mock_table.update_item.call_args
    assert kwargs["Key"] == {"PK": "USER#123", "SK": "LIST#20250608#ITEM#abc"}


def test_update_missing_path_parameters(mock_table):
    event = {"pathParameters": None, "body": json.dumps({"name": "Novo nome"})}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "PK e SK são obrigatórios" in body["message"]

    mock_table.update_item.assert_not_called()


def test_update_invalid_status_value(mock_table):
    event = {
        "pathParameters": {"pk": "USER#123", "sk": "LIST#20250608#ITEM#abc"},
        "body": json.dumps({"status": "IN_PROGRESS"}),
    }
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "Status deve ser TODO ou DONE" in body["message"]

    mock_table.update_item.assert_not_called()


def test_update_no_valid_fields(mock_table):
    event = {
        "pathParameters": {"pk": "USER#123", "sk": "LIST#20250608#ITEM#abc"},
        "body": json.dumps({"invalid_field": "foo"}),
    }
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "Nenhum campo válido para atualizar" in body["message"]

    mock_table.update_item.assert_not_called()


def test_update_internal_error(monkeypatch, mock_table):
    def raise_exception(*args, **kwargs):
        raise Exception("Simulated error")

    mock_table.update_item.side_effect = raise_exception

    event = {
        "pathParameters": {"pk": "USER#123", "sk": "LIST#20250608#ITEM#abc"},
        "body": json.dumps({"name": "Erro interno"}),
    }
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 500
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "Erro interno" in body["message"]

    mock_table.update_item.assert_called_once()
