resource "aws_s3_bucket" "s3_bucket_name" {
  bucket = "best-albums-glue"
} # S3 bucket to store CSV data

resource "aws_s3_bucket" "s3_bucket_name_2" {
  bucket = "best-albums-glue-job-code"
} # S3 bucket to store glue job Python code

resource "aws_s3_object" "best-albums-data" {

  bucket = aws_s3_bucket.s3_bucket_name.id

  key = "500_best_albums.csv"

  source = "C:/Users/ryans/Desktop/500_best_albums.csv"

} # S3 object for CSV data

resource "aws_s3_object" "glue_job" { # CHANGE THIS 

  bucket = aws_s3_bucket.s3_bucket_name_2.id

  key = "glue_job_dynamo_db.py"

  source = "C:/Users/ryans/Desktop/glue_job_dynamo_db.py"

} # S3 object for Python file 

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "500_best_albums_database"
} # Glue catalog database 

resource "aws_glue_crawler" "pii_crawler_glue_db" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  name          = "500_albums_crawler"
  role          = "arn:aws:iam::583715230104:role/glue-course-full-access"

  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      CrawlerOutput = {
        Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      }
      Version = 1
    }
  )

  s3_target {
    path = "s3://best-albums-glue"
  }
} # Glue crawler that will extract data from CSV and put it into a table in the Glue catalog database. 

resource "aws_glue_job" "albums-job" {
  name     = "albums-job-terraform"
  role_arn = "arn:aws:iam::583715230104:role/glue-course-full-access"

  command {
    script_location = "s3://pii-glue-job-code/glue_job.py"
  }
} # Reference to code for Glue job that is stored in S3 bucket.
