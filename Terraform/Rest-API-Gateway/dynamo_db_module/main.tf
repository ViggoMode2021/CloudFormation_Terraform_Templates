terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.74"
    }
  }
}

resource "aws_dynamodb_table" "rest_api_table" {
  name           = "rest_api_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "productId"

  attribute {
    name = "productId"
    type = "S"
  }
}
