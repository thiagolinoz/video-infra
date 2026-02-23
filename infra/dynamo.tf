resource "aws_dynamodb_table" "pessoas_table" {
  name           = "Persons"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "nmEmail"

  attribute {
    name = "nmEmail"
    type = "S"
  }
}

resource "aws_dynamodb_table" "videos_table" {
  name           = "Videos"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "nmPessoaEmail"
  range_key      = "idVideoSend"

  attribute {
    name = "nmPessoaEmail"
    type = "S"
  }

  attribute {
    name = "idVideoSend"
    type = "S"
  }

  attribute {
    name = "cdVideoStatus"
    type = "S"
  }

  local_secondary_index {
    name               = "cdVideoStatusIndex"
    range_key          = "cdVideoStatus"
    projection_type    = "ALL"
  }
}