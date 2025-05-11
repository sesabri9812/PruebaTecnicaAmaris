import sys
import unicodedata
from pyspark.sql.functions import udf, upper, col
from pyspark.sql.types import StringType
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
    table_name="raw_clientes"
)
df = dyf.toDF()

# Función para eliminar tildes
def remove_accents(input_str):
    if input_str is None:
        return None
    return ''.join(c for c in unicodedata.normalize('NFD', input_str) if unicodedata.category(c) != 'Mn')

remove_accents_udf = udf(remove_accents, StringType())

df = df.withColumn("nombre_cliente_proveedor", upper(remove_accents_udf(col("nombre_cliente_proveedor"))))
df = df.withColumn("tipo_energia", remove_accents_udf(col("tipo_energia")))

transformed_dyf = DynamicFrame.fromDF(df, glueContext, "transformed_dyf")

glueContext.write_dynamic_frame.from_options(
    frame=transformed_dyf,
    connection_type="s3",
    connection_options={
        "path": "s3://datalake-demo-pruebatecnica/processed/clientes/year=2025/month=05/day=10/",
        "partitionKeys": []
    },
    format="parquet"
)

job.commit()
