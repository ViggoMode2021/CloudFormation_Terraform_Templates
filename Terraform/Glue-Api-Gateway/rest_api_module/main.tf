provider "aws" {
  region = "us-east-1"
}

data "aws_s3_object" "lambda" {
  bucket = "api-gateway-lambda-zip-files"
  key    = "best_albums_rest_api_lambda.zip"
}

resource "aws_lambda_function" "Best_Albums_API_Gateway" {
  s3_bucket     = data.aws_s3_object.lambda.bucket
  s3_key        = data.aws_s3_object.lambda.key
  function_name = "best_albums_rest_api_lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  role          = "arn:aws:iam::583715230104:role/serverless-api-role"
  memory_size   = 128
  timeout       = 10
}

resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Best_Albums_API_Gateway.function_name
  principal     = "apigateway.amazonaws.com"
}

################ API GATEWAY ################

resource "aws_api_gateway_rest_api" "best_albums_API" {
  name = "best_albums_API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "album" {
  rest_api_id = aws_api_gateway_rest_api.best_albums_API.id
  parent_id   = aws_api_gateway_rest_api.best_albums_API.root_resource_id
  path_part   = "album"
}

// POST
resource "aws_api_gateway_method" "POST" {
  rest_api_id      = aws_api_gateway_rest_api.best_albums_API.id
  resource_id      = aws_api_gateway_resource.album.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.best_albums_API.id
  resource_id             = aws_api_gateway_resource.album.id
  http_method             = aws_api_gateway_method.POST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Best_Albums_API_Gateway.invoke_arn
}

// GET
resource "aws_api_gateway_method" "GET" {
  rest_api_id      = aws_api_gateway_rest_api.best_albums_API.id
  resource_id      = aws_api_gateway_resource.album.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration-get" {
  rest_api_id             = aws_api_gateway_rest_api.best_albums_API.id
  resource_id             = aws_api_gateway_resource.album.id
  http_method             = aws_api_gateway_method.GET.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Best_Albums_API_Gateway.invoke_arn
}

// PATCH
resource "aws_api_gateway_method" "PATCH" {
  rest_api_id      = aws_api_gateway_rest_api.best_albums_API.id
  resource_id      = aws_api_gateway_resource.album.id
  http_method      = "PATCH"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration-patch" {
  rest_api_id             = aws_api_gateway_rest_api.best_albums_API.id
  resource_id             = aws_api_gateway_resource.album.id
  http_method             = aws_api_gateway_method.PATCH.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Best_Albums_API_Gateway.invoke_arn
}

// DELETE
resource "aws_api_gateway_method" "DELETE" {
  rest_api_id      = aws_api_gateway_rest_api.best_albums_API.id
  resource_id      = aws_api_gateway_resource.album.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration-delete" {
  rest_api_id             = aws_api_gateway_rest_api.best_albums_API.id
  resource_id             = aws_api_gateway_resource.album.id
  http_method             = aws_api_gateway_method.DELETE.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Best_Albums_API_Gateway.invoke_arn
}

################ Deployment of API gateway ################

resource "aws_api_gateway_deployment" "deployment1" {
  rest_api_id = aws_api_gateway_rest_api.best_albums_API.id

  depends_on = [aws_api_gateway_integration.integration]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.deployment1.id
  rest_api_id   = aws_api_gateway_rest_api.best_albums_API.id
  stage_name    = "test"
}

output "complete_invoke_url" { value = "${aws_api_gateway_deployment.deployment1.invoke_url}${aws_api_gateway_stage.example.stage_name}/${aws_api_gateway_resource.album.path_part}"}
