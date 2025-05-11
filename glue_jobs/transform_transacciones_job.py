import sys
import unicodedata
from pyspark.sql.functions import udf, lower, col, round
from pyspark.sql.types import StringType, DoubleType
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

dyf = glueContext.create_dynamic_frame.from_catalog(
    database="energy_raw_db",
    table_name="raw_transacciones"
)

df = dyf.toDF()

def remove_accents(input_str):
    if input_str is None:
        return None
    return ''.join(c for c in unicodedata.normalize('NFD', input_str) if unicodedata.category(c) != 'Mn')

remove_accents_udf = udf(remove_accents, StringType())

# Transformaciones
df = df.withColumn("tipo_transaccion", lower(remove_accents_udf(col("tipo_transaccion"))))
df = df.withColumn("total", round(col("cantidad_comprada") * col("precio"), 2))

transformed_dyf = DynamicFrame.fromDF(df, glueContext, "transformed_dyf")

glueContext.write_dynamic_frame.from_options(
    frame=transformed_dyf,
    connection_type="s3",
    connection_options={
        "path": "s3://datalake-demo-pruebatecnica/processed/transacciones/",
        "partitionKeys": ["year", "month", "day"]
    },
    format="parquet"
)

job.commit()