resource "aws_s3_bucket" "s3_bucket_name" {
  bucket = "pii-detector-test-vig"
}

resource "aws_s3_bucket_object" "pii-data" {

  bucket = aws_s3_bucket.s3_bucket_name.id

  key = "pii-data"

  source = "C:/Users/ryans/Desktop/sample-pii-data.csv"

}

resource "aws_s3_bucket_object" "glue_job" {

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
    path = "aws_s3_bucket_object.object"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage   = 10
  db_name             = "piitestdatabase"
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  username            = "postgres"
  password            = "November72022"
  skip_final_snapshot = true
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

resource "aws_glue_connection" "example" {
  connection_properties = {
    JDBC_CONNECTION_URL = "${aws_db_instance.default.endpoint}"
    PASSWORD            = "November72022"
    USERNAME            = "postgres"
  }

  name = "glueconnectionpii"
}

#export AWS_ACCESS_KEY_ID=
#export AWS_SECRET_ACCESS_KEY=
