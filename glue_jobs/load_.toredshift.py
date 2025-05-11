import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import col

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Inicializar GlueContext y Spark
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Leer datos desde S3 en la zona procesada
df_clientes = spark.read.parquet("s3://datalake-demo-pruebatecnica/processed/clientes/")

# Realizar cualquier transformación si es necesario
df_clientes_transformed = df_clientes.withColumn("year", col("year").cast("int")) \
                                     .withColumn("month", col("month").cast("int")) \
                                     .withColumn("day", col("day").cast("int"))

# Conectar a Redshift
redshift_url = "jdbc:redshift://<redshift-cluster-endpoint>:5439/datalake_db"
redshift_properties = {
    "user" : "awsuser",
    "password" : "_____",
    "driver" : "com.amazon.redshift.jdbc42.Driver"
}

# Guardar los datos en Redshift
df_clientes_transformed.write \
    .format("jdbc") \
    .option("url", redshift_url) \
    .option("dbtable", "clientes") \
    .option("user", "awsuser") \
    .option("password", "your-password") \
    .mode("overwrite") \
    .save()
