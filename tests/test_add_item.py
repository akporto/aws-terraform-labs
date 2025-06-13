import json

import pytest
from add_item import lambda_handler


def test_lambda_handler_success(mock_table):
    event = {
        "body": json.dumps(
            {
                "name": "Comprar pão",
                "user_id": "user123",
                "created_at": "2025-06-04T12:00:00",
                "scheduled_for": "2025-06-05T08:00:00",
                "task_type": "Compra",
                "status": "todo",
            }
        )
    }
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 201
    body = json.loads(response["body"])
    assert body["success"] is True
    assert "item" in body
    assert body["item"]["name"] == "Comprar pão"
    assert body["item"]["task_type"] == "Compra"
    assert body["item"]["status"] == "TODO"
    assert body["item"]["PK"] == "USER#user123"
    assert "SK" in body["item"]
    assert "item_id" in body["item"]

    # Verifica se put_item foi chamado com os dados corretos
    mock_table.put_item.assert_called_once()
    args, kwargs = mock_table.put_item.call_args
    assert "Item" in kwargs
    assert kwargs["Item"]["name"] == "Comprar pão"


@pytest.mark.parametrize("missing_field", ["name", "user_id", "created_at"])
def test_lambda_handler_missing_required_fields(mock_table, missing_field):
    body = {
        "name": "Comprar pão",
        "user_id": "user123",
        "created_at": "2025-06-04T12:00:00",
    }
    del body[missing_field]

    event = {"body": json.dumps(body)}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert body["success"] is False
    assert f"O campo '{missing_field}' é obrigatório" in body["message"]

    # put_item não deve ser chamado
    mock_table.put_item.assert_not_called()


def test_lambda_handler_invalid_json(mock_table):
    event = {"body": "{invalid-json}"}
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 500
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "Erro ao processar a solicitação" in body["message"]

    # put_item não deve ser chamado
    mock_table.put_item.assert_not_called()


def test_lambda_handler_unexpected_exception(monkeypatch, mock_table):
    def raise_exception(*args, **kwargs):
        raise Exception("Erro inesperado")

    monkeypatch.setattr("add_item.create_item", raise_exception)

    event = {
        "body": json.dumps(
            {
                "name": "Comprar pão",
                "user_id": "user123",
                "created_at": "2025-06-04T12:00:00",
            }
        )
    }
    context = {}

    response = lambda_handler(event, context)

    assert response["statusCode"] == 500
    body = json.loads(response["body"])
    assert body["success"] is False
    assert "Erro ao processar a solicitação" in body["message"]

    # put_item não deve ser chamado pois erro ocorreu antes
    mock_table.put_item.assert_not_called()
