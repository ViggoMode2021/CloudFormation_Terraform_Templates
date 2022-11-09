resource "aws_s3_bucket" "s3_bucket_name" {
  bucket = "pii-detector-test-vig"
} # S3 bucket to store CSV data

resource "aws_s3_bucket" "s3_bucket_name_2" {
  bucket = "pii-glue-job-code"
} # S3 bucket to store glue job Python code

resource "aws_s3_object" "pii-data" {

  bucket = aws_s3_bucket.s3_bucket_name.id

  key = "pii-data.csv"

  source = "C:/Users/ryans/Desktop/sample-pii-data.csv"

} # S3 object for CSV data

resource "aws_s3_object" "glue_job" {

  bucket = aws_s3_bucket.s3_bucket_name_2.id

  key = "glue_job.py"

  source = "C:/Users/ryans/Desktop/ecuador_glue/glue_job.py"

} # S3 object for Python file 

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "pii_test_db"
} # Glue catalog database 

resource "aws_glue_crawler" "pii_crawler_glue_db" {
  database_name = "sample-pii-data"
  name          = "pii_crawler_test"
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
    path = "s3://pii-detector-test-vig/"
  }
} # Glue crawler that will extract data from CSV and put it into a table in the Glue catalog database. 

resource "aws_glue_job" "pii-job" {
  name     = "pii-job-terraform"
  role_arn = "arn:aws:iam::583715230104:role/glue-course-full-access"

  command {
    script_location = "s3://pii-glue-job-code/glue_job.py"
  }
} # Reference to code for Glue job that is stored in S3 bucket.

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
} # Create RDS Postgres instance to be accessed via PgAdmin

output "rds_endpoint" {
  value = aws_db_instance.pii-test-postgres.endpoint
} # Output endpoint for RDS endpoint to both create the Glue JDMC connection and connect to db via PgAdmin

resource "aws_glue_connection" "rds_glue_connection" {
  connection_properties = {
    JDBC_CONNECTION_URL = aws_db_instance.pii-test-postgres.endpoint
    PASSWORD            = "November72022"
    USERNAME            = "postgres"
  }

  name = "glueconnectionpii"

  physical_connection_requirements {
    availability_zone      = "us-east-1a"
    security_group_id_list = ["sg-0ed5d6ef0aa040a40"]
    subnet_id              = "subnet-0e29231d3158e0d30"
  }
} # Create connection for RDS instance to connect to Glue. NOTE: Manually append #jdbc:postgresql:// to Glue connection endpoint via the console. Need to find out how
# to do this programmatically with Terraform.  

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "vpc-00eb03f199d096b0c"
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    "rtb-046c4ceba38e2c488",
  ]
}

resource "aws_glue_crawler" "rds_crawler" {
  database_name = aws_db_instance.pii-test-postgres.db_name
  name          = "rds_crawler"
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

  jdbc_target {
    connection_name = aws_glue_connection.rds_glue_connection.name
    path            = "piitestdatabase/%"
  }
} # Glue crawler that will crawl table in RDS after crawling CSV data and prior to running the Glue job.  

# Create Gateway VPC endpoint to faciliate connection between RDS instance and Glue 

#export AWS_ACCESS_KEY_ID=""
#export AWS_SECRET_ACCESS_KEY=""
