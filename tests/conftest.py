import importlib
import os
import sys
from unittest.mock import MagicMock

import pytest

os.environ["DYNAMODB_TABLE_NAME"] = "mock-table"

BASE_DIR = os.path.dirname(__file__)
SRC_DIR = os.path.abspath(os.path.join(BASE_DIR, "../src/lambdas/lambda_task_list"))

sys.path.append(os.path.join(SRC_DIR, "add_item"))
sys.path.append(os.path.join(SRC_DIR, "get_item"))
sys.path.append(os.path.join(SRC_DIR, "update_item"))
sys.path.append(os.path.join(SRC_DIR, "delete_item"))

import add_item
import delete_item
import get_item
import update_item


@pytest.fixture(scope="function")
def mock_table():
    return MagicMock()


@pytest.fixture(autouse=True)
def patch_boto3_mock_table(monkeypatch, mock_table):
    """
    Aplica patch em boto3.resource para retornar mock_table,
    e recarrega os módulos para atualizar os objetos internos.
    """
    mock_dynamodb = MagicMock()
    mock_dynamodb.resource.return_value.Table.return_value = mock_table

    monkeypatch.setattr(
        "boto3.resource", lambda service_name=None: mock_dynamodb.resource()
    )

    importlib.reload(get_item)
    importlib.reload(update_item)
    importlib.reload(add_item)
    importlib.reload(delete_item)

    yield
