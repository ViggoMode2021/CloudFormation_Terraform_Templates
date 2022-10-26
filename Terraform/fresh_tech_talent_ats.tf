provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "freshtechtalentatsbucket" {
  bucket = "freshtechtalentatsbucketunique"

  tags = {
    Name        = "Bucket for Fresh Tech Talent ATS"
    Environment = "Dev"
  }
}

variable "iam_role" {
  description = "Value of the Name tag for the Lambda function"
  type        = string
  default     = "arn:aws:iam::583715230104:role/service-role/textract-lambda-role-r2ws9akc"
}

#data "aws_s3_object" "freshtechtalentatslambdacode" {
#bucket = "freshtechtalentresources"
#key    = "freshtechtalentlambda.zip"
#}

resource "aws_lambda_function" "fresh_tech_talent_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  #s3_bucket     = data.aws_s3_object.freshtechtalentatslambdacode.bucket
  #s3_key        = data.aws_s3_object.freshtechtalentatslambdacode.key
  filename      = "freshtechtalentlambda.zip"
  function_name = "freshtechtalentatslambda"
  role          = var.iam_role
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.freshtechtalentatsbucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.fresh_tech_talent_lambda.arn
    events              = ["s3:ObjectCreated:*"]

  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fresh_tech_talent_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.freshtechtalentatsbucket.arn
}
