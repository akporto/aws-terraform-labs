import json
import pytest
from unittest.mock import MagicMock
import os
import sys

os.environ["DYNAMODB_TABLE_NAME"] = "mock-table"

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "../lambda_market_list/add_item/src")
    )
)

from add_market_item import add_handler


@pytest.fixture
def mock_table():
    table = MagicMock()
    return table
