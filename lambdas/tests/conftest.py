import json
import pytest
from unittest.mock import MagicMock
import os
import sys
import importlib
 
os.environ["DYNAMODB_TABLE_NAME"] = "mock-table"
 
sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "../lambda_market_list/add_item/src")
    )
)
 
sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "../lambda_market_list/get_items/src")
    )
)
 
import get_items
 
from add_market_item import add_handler
 
 
@pytest.fixture
def mock_table():
    table = MagicMock()
    return table
 
@pytest.fixture(autouse=True)
def patch_boto3_mock_table(monkeypatch, mock_table):
    """
    Aplica patch em boto3.resource para retornar mock_table,
    e recarrega o módulo get_items para que a variável table seja atualizada.
    """
    mock_dynamodb = MagicMock()
    mock_dynamodb.resource.return_value.Table.return_value = mock_table
 
    # Patch boto3.resource para sempre retornar mock_dynamodb.resource()
    monkeypatch.setattr("get_items.boto3.resource", lambda service_name=None: mock_dynamodb.resource())
 
    # Recarrega o módulo get_items para aplicar o patch no objeto table
    importlib.reload(get_items)

    yield