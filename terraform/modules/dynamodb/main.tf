resource "aws_dynamodb_table" "task_list_api_table" {
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


  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "task_type"
    type = "S"
  }

  attribute {
    name = "scheduled_for"
    type = "S"
  }


  global_secondary_index {
    name            = "GSI_Status"
    hash_key        = "status"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "GSI_TaskType"
    hash_key        = "task_type"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "GSI_ScheduledFor"
    hash_key        = "scheduled_for"
    projection_type = "ALL"
  }

  tags = var.tags
}
