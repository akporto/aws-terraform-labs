# DynamoDB Table
resource "aws_dynamodb_table" "market_list_table" {
  name         = "${var.project_name}-${var.environment}-market-list"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  global_secondary_index {
    name            = "item_id"
    hash_key        = "SK"
    projection_type = "ALL"
  }

  tags = var.tags
}