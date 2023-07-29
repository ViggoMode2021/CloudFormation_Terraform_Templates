provider "aws" {
  region = "us-east-1"
}

#export AWS_ACCESS_KEY_ID=""
#export AWS_SECRET_ACCESS_KEY=""

data "aws_s3_bucket_object" "lambda" {
  bucket = "api-gateway-lambda-zip-files"
  key    = "rest_api_lambda.zip"
}

resource "aws_lambda_function" "Ryan_API_Gateway" {
  s3_bucket     = data.aws_s3_bucket_object.lambda.bucket
  s3_key        = data.aws_s3_bucket_object.lambda.key
  function_name = "rest_api_lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  role          = "arn:aws:iam::583715230104:role/serverless-api-role" // TODO put your ARN role in here
  #filename      = data.aws_s3_bucket_object.lambda.key
  memory_size = 128
  timeout     = 10
}

resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Ryan_API_Gateway.function_name
  principal     = "apigateway.amazonaws.com"
}

################ API GATEWAY ################

resource "aws_api_gateway_rest_api" "test-Ryan-api-gateway" {
  name = "test-Ryan-api-gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  parent_id   = aws_api_gateway_rest_api.test-Ryan-api-gateway.root_resource_id
  path_part   = "product"
}

// POST
resource "aws_api_gateway_method" "POST" {
  rest_api_id      = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  resource_id      = aws_api_gateway_resource.product.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.POST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Ryan_API_Gateway.invoke_arn
}

// GET
resource "aws_api_gateway_method" "GET" {
  rest_api_id      = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  resource_id      = aws_api_gateway_resource.product.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration-get" {
  rest_api_id             = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.GET.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Ryan_API_Gateway.invoke_arn
}

// PATCH
resource "aws_api_gateway_method" "PATCH" {
  rest_api_id      = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  resource_id      = aws_api_gateway_resource.product.id
  http_method      = "PATCH"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration-patch" {
  rest_api_id             = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.PATCH.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Ryan_API_Gateway.invoke_arn
}

// DELETE
resource "aws_api_gateway_method" "DELETE" {
  rest_api_id      = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  resource_id      = aws_api_gateway_resource.product.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration-delete" {
  rest_api_id             = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.DELETE.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Ryan_API_Gateway.invoke_arn
}

## DynamoDB

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

################ Deployment of API gateway ################

resource "aws_api_gateway_deployment" "deployment1" {
  rest_api_id = aws_api_gateway_rest_api.test-Ryan-api-gateway.id

  depends_on = [aws_api_gateway_integration.integration]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.deployment1.id
  rest_api_id   = aws_api_gateway_rest_api.test-Ryan-api-gateway.id
  stage_name    = "test"
}

output "complete_unvoke_url" { value = "${aws_api_gateway_deployment.deployment1.invoke_url}${aws_api_gateway_stage.example.stage_name}/${aws_api_gateway_resource.product.path_part}" }
