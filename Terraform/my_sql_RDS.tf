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

variable "master_username" {
  description = "DB master username"
  #default
  type = string
}

variable "master_password" {
  description = "DB master username"
  #default
  type = string
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-mysql"
  engine_mode             = "serverless"
  database_name           = "myauroradb"
  enable_http_endpoint    = true
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = 1

  skip_final_snapshot = true

  scaling_configuration {
    auto_pause               = true
    min_capacity             = 1
    max_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}
