resource "aws_s3_bucket" "ryan-glue-aws" {
  bucket = "ryan-glue-aws"
}

resource "aws_s3_object" "temp-dir" {
  bucket = aws_s3_bucket.ryan-glue-aws.id
  key    = "temp-dir/"
}

resource "aws_s3_object" "scripts" {
  bucket = aws_s3_bucket.ryan-glue-aws.id
  key    = "scripts/"
}

resource "aws_s3_object" "data" {
  bucket = aws_s3_bucket.ryan-glue-aws.id
  key    = "data/"
}

resource "aws_s3_object" "customers_database" {
  bucket = aws_s3_bucket.ryan-glue-aws.id
  key    = "data/customers_database/"
}

resource "aws_s3_object" "customers_csv" {
  bucket = aws_s3_bucket.ryan-glue-aws.id
  key    = "data/customers_database/customers_csv/"
}

resource "aws_s3_object" "dataload-20221103" {
  bucket = aws_s3_bucket.ryan-glue-aws.id
  key    = "data/customers_database/customers_csv/dataload-20221103/"
}

resource "aws_s3_object" "athena_results" {
  bucket = aws_s3_bucket.ryan-glue-aws.id
  key    = "athena_results/"
}
