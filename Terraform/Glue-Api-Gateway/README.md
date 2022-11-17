Provider: Amazon Web Services

Premise: This Terraform project will create a "500 Best Music Albums" CRUD Rest API with AWS API Gateway, Lambda, DynamoDB, and Glue.
The API will be served in API Gateway from a Lambda function written in Python 3.9. The Lambda function will be retreived from a zip file in an S3 bucket that has already been created. This Lambda function will contain a Lambda handler, which will interpret the if the incoming request method from API Gateway is POST, GET, UPDATE, or DELETE and then run the corresponding Python function in the code. The functions are named: post_album, get_album, update_album, and delete_album. The will each then execute the respective corresponding CRUD invocation on the DynamoDB table. There will be Lambda Proxy Integration incorporated and the API will not have an API key, although one can be added either via Terraform, AWS console, CLI, SDK etc. The function will be deployed with the stage 'test'. The Terraform file will deploy an S3 bucket and an S3 object, a csv file titled "500 best albums". This csv file contains 5 columns (~id, ~label, title, year, and number:int) and a total of 
501 rows (including 1 row that contains the column fields). This csv data will be populated into a Glue database table that was created after the Glue crawler has been ran (also created with TF). Glue will then run an Extract, Transform, and Load (ETL) job on the csv data. The Glue job will also be created via Terraform by reference to a zip file of the code in an S3 bucket (written in PySpark). Said Glue job will run a "Change Schema (Apply Mapping)" on the data to rename the columns to (album_id, label, title, year, and number_sold). Then, the job will assure that the album_id, year, and number_sold columns are of data type INT, while the label and title columns are of data type VARCHAR. Lastly, the job will dump the results into a DynamoDB table titled "500 best albums" that contains a Hash key (Primary key) of 'album_id'. 

The user can then access the API via the base url and what every payload or query string parameters they need. 

This Terraform project will deploy three modules:

1. Glue module 

2. API Gateway module

3. DynamoDB module
