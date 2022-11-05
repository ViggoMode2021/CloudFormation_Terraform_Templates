resource "aws_s3_bucket" "s3_bucket_name" {
  bucket = "ecuador-food-bucket"
}

resource "aws_s3_object" "data-outputs" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "data-outputs/"
}

resource "aws_s3_object" "scripts" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "scripts/"
}

resource "aws_s3_object" "data" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "data/"
}

resource "aws_s3_object" "ecuador_food_database" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "data/ecuador_food_database/"
}

resource "aws_s3_object" "ecuador_food_prices_csv" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  key    = "data/ecuador_food_database/ecuador_food_prices_csv/"
}
