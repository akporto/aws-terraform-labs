import importlib
import os
import sys
from unittest.mock import MagicMock

import pytest

# Configura variável de ambiente
os.environ["DYNAMODB_TABLE_NAME"] = "mock-table"

# Diretório base deste arquivo
BASE_DIR = os.path.dirname(__file__)

# Adiciona caminhos corretos para os módulos
sys.path.append(
    os.path.abspath(os.path.join(BASE_DIR, "../lambda_market_list/add_item"))
)
sys.path.append(
    os.path.abspath(os.path.join(BASE_DIR, "../lambda_market_list/get_items"))
)
sys.path.append(
    os.path.abspath(os.path.join(BASE_DIR, "../lambda_market_list/update_item"))
)

# Agora os imports devem funcionar
import get_items
import update_market_item
from add_market_item import lambda_handler


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

    # Recarrega os módulos para aplicar o patch nos objetos `table` internos
    importlib.reload(get_items)
    importlib.reload(update_market_item)

    yield
