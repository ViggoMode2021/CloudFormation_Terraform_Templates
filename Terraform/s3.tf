variable "access_key" {
  description = "AWS Access Key"
  #default
  type = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  #default
  type = string
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "b" {
  bucket = "wonderfultestbucket"

  tags = {
    Name        = "wonderfultestbucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
