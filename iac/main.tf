# Infraestructura como Código - Terraform

provider "aws" {
  region = "us-east-2"
}

########################
# 1. S3 Bucket
########################
resource "aws_s3_bucket" "datalake" {
  bucket = "datalake-demo-pruebatecnica"
  force_destroy = true

  tags = {
    Name        = "datalake-demo-pruebatecnica"
    Environment = "dev"
  }
}

########################
# 2. Glue Databases
########################
resource "aws_glue_catalog_database" "raw" {
  name = "energy_raw_db"
}

resource "aws_glue_catalog_database" "processed" {
  name = "energy_processed_db"
}

########################
# IAM Role for Glue
########################
resource "aws_iam_role" "glue_role" {
  name = "AWSGlueServiceRole-PruebaTecnica"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

########################
# IAM Role for Lake Formation
########################
resource "aws_iam_role" "lake_formation_role" {
  name = "LakeFormationAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lakeformation_s3_access" {
  role       = aws_iam_role.lake_formation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

########################
# Lake Formation Data Lake
########################
resource "aws_lakeformation_data_lake" "datalake" {
  database_name = aws_glue_catalog_database.raw.name
  location      = "s3://${aws_s3_bucket.datalake.bucket}/"
}

########################
# Lake Formation Permissions
########################
resource "aws_lakeformation_permissions" "access_raw_data" {
  principal       = aws_iam_role.lake_formation_role.arn
  database_name   = aws_glue_catalog_database.raw.name
  table_name      = "raw_clientes"
  permissions     = ["SELECT"]
  permissions_with_grant_option = ["SELECT"]
}

########################
# Athena Permissions
########################
resource "aws_iam_role_policy_attachment" "athena_access" {
  role       = aws_iam_role.lake_formation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}


########################
# 4. Glue Crawlers
########################
resource "aws_glue_crawler" "clientes_raw" {
  name         = "crawler_raw_clientes"
  database_name = aws_glue_catalog_database.raw.name
  role         = aws_iam_role.lake_formation_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/raw/clientes/"
  }

  configuration = jsonencode({
    Version = 1.0,
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })

  table_prefix = "raw_"
  schedule     = null
}

resource "aws_glue_crawler" "proveedores_raw" {
  name         = "crawler_raw_proveedores"
  database_name = aws_glue_catalog_database.raw.name
  role         = aws_iam_role.lake_formation_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/raw/proveedores/"
  }

  table_prefix = "raw_"
  schedule     = null
}

resource "aws_glue_crawler" "transacciones_raw" {
  name         = "crawler_raw_transacciones"
  database_name = aws_glue_catalog_database.raw.name
  role         = aws_iam_role.lake_formation_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/raw/transacciones/"
  }

  table_prefix = "raw_"
  schedule     = null
}

resource "aws_glue_crawler" "clientes_processed" {
  name         = "crawler_processed_clientes"
  database_name = aws_glue_catalog_database.processed.name
  role         = aws_iam_role.lake_formation_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/processed/clientes/"
  }

  table_prefix = "processed_"
  schedule     = null
}

resource "aws_glue_crawler" "proveedores_processed" {
  name         = "crawler_processed_proveedores"
  database_name = aws_glue_catalog_database.processed.name
  role         = aws_iam_role.lake_formation_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/processed/proveedores/"
  }

  table_prefix = "processed_"
  schedule     = null
}

resource "aws_glue_crawler" "transacciones_processed" {
  name         = "crawler_processed_transacciones"
  database_name = aws_glue_catalog_database.processed.name
  role         = aws_iam_role.lake_formation_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/processed/transacciones/"
  }

  table_prefix = "processed_"
  schedule     = null
}

########################
# 5. Glue Jobs
########################
resource "aws_glue_job" "clientes" {
  name     = "glue-job-clientes"
  role_arn = aws_iam_role.lake_formation_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.datalake.bucket}/scripts/transform_clientes_job.py"
    python_version  = "3"
  }

  glue_version = "3.0"
  number_of_workers = 2
  worker_type       = "G.1X"
}

resource "aws_glue_job" "proveedores" {
  name     = "glue-job-proveedores"
  role_arn = aws_iam_role.lake_formation_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.datalake.bucket}/scripts/transform_proveedores_job.py"
    python_version  = "3"
  }

  glue_version = "3.0"
  number_of_workers = 2
  worker_type       = "G.1X"
}

resource "aws_glue_job" "transacciones" {
  name     = "glue-job-transacciones"
  role_arn = aws_iam_role.lake_formation_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.datalake.bucket}/scripts/transform_transacciones_job.py"
    python_version  = "3"
  }

  glue_version = "3.0"
  number_of_workers = 2
  worker_type       = "G.1X"
}

########################
# 6. Outputs
########################
output "s3_bucket_name" {
  value = aws_s3_bucket.datalake.bucket
}

output "lake_formation_role_arn" {
  value = aws_iam_role.lake_formation_role.arn
}

output "raw_database_name" {
  value = aws_glue_catalog_database.raw.name
}

output "processed_database_name" {
  value = aws_glue_catalog_database.processed.name
}

########################
# 7. Redshift 
########################

resource "aws_redshift_cluster" "datalake_to_redshift" {
  cluster_identifier = "datalake-cluster"
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  master_username    = "awsuser"
  master_password    = "your-password"
  database_name      = "datalake_db"
  skip_final_snapshot = true
  port               = 5439

  # Redshift Security Group
  vpc_security_group_ids = [aws_security_group.redshift_sg.id]

  tags = {
    Name = "Redshift Cluster for Datalake"
  }
}

resource "aws_security_group" "redshift_sg" {
  name        = "redshift-sg"
  description = "Allow access to Redshift from Glue"

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_redshift_table" "clientes_table" {
  cluster_identifier = aws_redshift_cluster.datalake_to_redshift.id
  database_name      = "datalake_db"
  table_name         = "clientes"

  column {
    name = "tipo_transaccion"
    type = "VARCHAR"
  }

  column {
    name = "nombre_cliente_proveedor"
    type = "VARCHAR"
  }

  column {
    name = "cantidad_comprada"
    type = "INT"
  }

  column {
    name = "precio"
    type = "INT"
  }

  column {
    name = "tipo_energia"
    type = "VARCHAR"
  }

  column {
    name = "year"
    type = "INT"
  }

  column {
    name = "month"
    type = "INT"
  }

  column {
    name = "day"
    type = "INT"
  }
}

resource "aws_glue_connection" "redshift_connection" {
  name = "redshift-connection"
  connection_properties = {
    USERNAME = "awsuser"
    PASSWORD = "your-password"
    JDBC_CONNECTION_URL = "jdbc:redshift://<redshift-cluster-endpoint>:5439/datalake_db"
  }

  physical_connection_requirements {
    availability_zone = "us-east-2a"
    security_group_id_list = [aws_security_group.redshift_sg.id]
    subnet_id          = aws_subnet.glue_subnet.id
  }
}

resource "aws_glue_job" "load_to_redshift" {
  name     = "load-to-redshift"
  role_arn = aws_iam_role.lake_formation_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.datalake.bucket}/scripts/load_to_redshift.py"
    python_version  = "3"
  }

  glue_version    = "3.0"
  number_of_workers = 2
  worker_type       = "G.1X"
}