resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "maine_cities_db"
}

resource "aws_glue_crawler" "example" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  name          = "maine_crawler"
  role          = "arn:aws:iam::583715230104:role/glue-course-full-access"

  s3_target {
    path = "s3://ryan-aws-glue/data/customers_database/customers_csv/dataload-20221103/maine_cities.csv"
  }
}
