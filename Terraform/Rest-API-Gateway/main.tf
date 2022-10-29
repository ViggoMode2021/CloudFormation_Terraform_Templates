#export AWS_ACCESS_KEY_ID=""
#export AWS_SECRET_ACCESS_KEY=""

provider "aws" {
  region = "us-east-1"
}

module "rest_api_module" {
  source = "C:/Users/ryans/Desktop/Terraform Practice/rest_api_module"
}

module "dynamo_db_module" {
  source = "C:/Users/ryans/Desktop/Terraform Practice/dynamo_db_module"
}
