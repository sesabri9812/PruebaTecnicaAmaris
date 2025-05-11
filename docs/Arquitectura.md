# Data Pipeline - Prueba Técnica Ingeniero de Datos (AWS) para Amaris

Este proyecto implementa un pipeline de datos serverless utilizando servicios de AWS para simular el procesamiento de datos de una comercializadora de energía. Se construyó una arquitectura de Data Lake en S3, procesos de transformación con AWS Glue, catalogación con Glue Crawlers y consultas con Amazon Athena.

---

## Arquitectura General

- **Amazon S3**: Almacenamiento del datalake en tres capas: `raw`, `processed` y `curated`.
- **AWS Glue**: 
  - Crawlers para detección automática de esquemas.
  - Jobs para transformación de datos (CSV → Parquet).
- **Amazon Athena**: Consulta de datos transformados directamente en S3.
- **GitHub**: Control de versiones del código fuente y documentación del proyecto.

---

## Estructura del Datalake (S3)

```text
s3://datalake-demo-pruebatecnica/
│
├── raw/
│   ├── clientes/year=2025/month=05/day=10/
│   ├── proveedores/year=2025/month=05/day=10/
│   └── transacciones/year=2025/month=05/day=10/
│
├── processed/
│   ├── clientes/year=2025/month=05/day=10/
│   ├── proveedores/year=2025/month=05/day=10/
│   └── transacciones/year=2025/month=05/day=10/
