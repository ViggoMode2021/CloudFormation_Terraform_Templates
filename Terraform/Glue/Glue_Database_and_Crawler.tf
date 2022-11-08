resource "aws_s3_bucket" "s3_bucket_name" {
  bucket = "pii-detector-test-vig"
}

resource "aws_s3_object" "pii-data" {

  bucket = aws_s3_bucket.s3_bucket_name.id

  key = "pii-data"

  source = "C:/Users/ryans/Desktop/sample-pii-data.csv"

}

resource "aws_s3_object" "glue_job" {

  bucket = aws_s3_bucket.s3_bucket_name.id

  key = "glue_job.py"

  source = "C:/Users/ryans/Desktop/ecuador_glue/glue_job.py"

}

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "pii_test_db"
}

resource "aws_glue_crawler" "example" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  name          = "pii_crawler_test"
  role          = "arn:aws:iam::583715230104:role/glue-course-full-access"

  s3_target {
    path = "s3://pii-detector-test-vig"
  }
}

resource "aws_glue_job" "pii-job" {
  name     = "pii-job-terraform"
  role_arn = "arn:aws:iam::583715230104:role/glue-course-full-access"

  command {
    script_location = "s3://pii-detector-test-vig/glue_job.py"
  }
}

resource "aws_db_instance" "pii-test-postgres" {
  allocated_storage   = 10
  identifier          = "piitestdatabase"
  db_name             = "piitestdatabase"
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  username            = "postgres"
  password            = "November72022"
  skip_final_snapshot = true
  publicly_accessible = true
}

output "rds_endpoint" {
  value = aws_db_instance.pii-test-postgres.endpoint
}

resource "aws_glue_connection" "example" {
  connection_properties = {
    JDBC_CONNECTION_URL = aws_db_instance.pii-test-postgres.endpoint #jdbc:postgresql://
    PASSWORD            = "November72022"
    USERNAME            = "postgres"
  }

  name = "glueconnectionpii"

  physical_connection_requirements {
    availability_zone      = "us-east-1a"
    security_group_id_list = ["sg-0ed5d6ef0aa040a40"]
    subnet_id              = "subnet-0e29231d3158e0d30"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "vpc-00eb03f199d096b0c"
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    "rtb-046c4ceba38e2c488",
  ]
}

#export AWS_ACCESS_KEY_ID=""
#export AWS_SECRET_ACCESS_KEY=""
