import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

def sparkSqlQuery(glueContext, query, mapping, transformation_ctx) -> DynamicFrame:
    for alias, frame in mapping.items():
        frame.toDF().createOrReplaceTempView(alias)
    result = spark.sql(query)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)


args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node1668648689348 = glueContext.create_dynamic_frame.from_catalog(
    database="500_best_albums_database",
    table_name="best_albums_glue",
    transformation_ctx="AWSGlueDataCatalog_node1668648689348",
)

# Script generated for node Change Schema (Apply Mapping)
ChangeSchemaApplyMapping_node1668648717660 = ApplyMapping.apply(
    frame=AWSGlueDataCatalog_node1668648689348,
    mappings=[
        ("title", "string", "title", "string"),
        ("year", "long", "year", "int"),
        ("number:int", "long", "number", "int"),
    ],
    transformation_ctx="ChangeSchemaApplyMapping_node1668648717660",
)

# Script generated for node SQL Query
SqlQuery1 = """
SELECT * from CATALOG ORDER BY year ASC LIMIT 15;

"""
SQLQuery_node1668648753295 = sparkSqlQuery(
    glueContext,
    query=SqlQuery1,
    mapping={"catalog": ChangeSchemaApplyMapping_node1668648717660},
    transformation_ctx="SQLQuery_node1668648753295",
)

Datasink1 = glueContext.write_dynamic_frame_from_options(
    
    connection_type="dynamodb",
    frame=SQLQuery_node1668648753295,
    connection_options={
        "dynamodb.output.tableName": "best_albums_table",
        "dynamodb.throughput.write.percent": "1.0"
    }
)

job.commit()
