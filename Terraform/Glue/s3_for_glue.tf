resource "aws_s3_bucket" "s3_bucket_name" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_object" "temp-dir" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "temp-dir/"
}

resource "aws_s3_object" "scripts" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "scripts/"
}

resource "aws_s3_object" "data" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "data/"
}

resource "aws_s3_object" "customers_database" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "data/customers_database/"
}

resource "aws_s3_object" "customers_csv" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "data/customers_database/customers_csv/"
}

resource "aws_s3_object" "dataload-20221103" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "data/customers_database/customers_csv/dataload-20221103/"
}

resource "aws_s3_object" "athena_results" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "athena_results/"
}
