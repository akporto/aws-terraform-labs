import json

import pytest
from get_item import lambda_handler


def mock_dynamo_response(items):
    return {"Items": items}


def test_get_item_by_user_id_success(mock_table):
    mock_items = [{"PK": "USER#123", "SK": "LIST#20250608#ITEM#abc", "name": "Item 1"}]
    mock_table.query.return_value = mock_dynamo_response(mock_items)

    event = {"queryStringParameters": {"user_id": "123"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["success"] is True
    assert body["message"] == "1 item(s) encontrado(s)"
    assert body["items"] == mock_items

    mock_table.query.assert_called_once()


def test_get_item_by_scheduled_for_success(mock_table):
    mock_items = [{"scheduled_for": "2025-06-08", "name": "Item 2"}]
    mock_table.query.return_value = mock_dynamo_response(mock_items)

    event = {"queryStringParameters": {"scheduled_for": "2025-06-08"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["success"] is True
    assert body["items"] == mock_items

    mock_table.query.assert_called_once()
    args, kwargs = mock_table.query.call_args
    assert kwargs["IndexName"] == "GSI_ScheduledFor"


def test_get_item_by_task_type_success(mock_table):
    mock_items = [{"task_type": "Compra", "name": "Item 3"}]
    mock_table.query.return_value = mock_dynamo_response(mock_items)

    event = {"queryStringParameters": {"task_type": "Compra"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["success"] is True
    assert body["items"] == mock_items

    mock_table.query.assert_called_once()
    args, kwargs = mock_table.query.call_args
    assert kwargs["IndexName"] == "GSI_TaskType"


def test_get_item_by_status_success(mock_table):
    mock_items = [{"status": "TODO", "name": "Item 4"}]
    mock_table.query.return_value = mock_dynamo_response(mock_items)

    event = {"queryStringParameters": {"status": "todo"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["success"] is True
    assert body["items"] == mock_items

    mock_table.query.assert_called_once()
    args, kwargs = mock_table.query.call_args
    assert kwargs["IndexName"] == "GSI_Status"


def test_get_item_by_invalid_status(mock_table):
    event = {"queryStringParameters": {"status": "INVALID"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "Status deve ser TODO ou DONE" in body["message"]

    mock_table.query.assert_not_called()


def test_get_item_with_no_query_params(mock_table):
    event = {"queryStringParameters": None}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "fornecer pelo menos um parâmetro de filtro" in body["message"]

    mock_table.query.assert_not_called()


def test_get_item_with_unhandled_filter(mock_table):
    event = {"queryStringParameters": {"foo": "bar"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "combinação não suportada" in body["message"]

    mock_table.query.assert_not_called()


def test_get_item_internal_error(monkeypatch, mock_table):
    def raise_exception(*args, **kwargs):
        raise Exception("Erro simulado")

    monkeypatch.setattr("get_item.table", mock_table)
    mock_table.query.side_effect = raise_exception

    event = {"queryStringParameters": {"user_id": "123"}}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 500
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "Erro ao obter itens" in body["message"]

    mock_table.query.assert_called_once()
