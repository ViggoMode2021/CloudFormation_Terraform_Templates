terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.74"
    }
  }
}

resource "aws_dynamodb_table" "best_albums_table" {
  name           = "best_albums_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "title"

  attribute {
    name = "title"
    type = "S"
  }
}
