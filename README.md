# PruebaTecnicaAmaris


- Elaboracion de prueba tecnica para la empresa amaris usando herramientas de AWS.

## Punto 1 
### Arquitectura Implementada

- **Amazon S3**: Almacenamiento central del datalake con separación en zonas *raw* y *processed*.
- **AWS Glue**: 
  - Crawlers para catalogar los datos.
  - Jobs ETL que transforman y mueven los datos desde raw a processed.
- **AWS Lake Formation**: Administración de seguridad centralizada y permisos finos sobre datos.
- **Amazon Redshift**: Carga final de los datos procesados para análisis.
- **Terraform**: Infraestructura como código (IaC) para desplegar toda la arquitectura.

### Estructura del Repositorio

La organización del proyecto sigue una estructura clara para facilitar la navegación:

#### Infraestructura
 **iac/** → Contiene los archivos Terraform que definen la infraestructura en AWS.  
 `main.tf` → Configuración completa de los recursos en la nube.

#### Procesos ETL
 **scripts/** → Incluye los Glue Jobs para el procesamiento de datos.  
 `clientes_etl.py` → ETL para la información de clientes.  
 `proveedores_etl.py` → ETL para datos de proveedores.  
 `transacciones_etl.py` → ETL para registros de transacciones.

#### Evidencias
 **evidencias/** → Almacena capturas de ejecuciones y resultados (opcional).

#### Datos de prueba
 **data/** → Contiene los datos ficticios cargados a S3 para pruebas.

#### Documentación
 `README.md` → Archivo principal con la documentación del proyecto.

#### Proceso de Ingesta y Transformación

1. **Carga inicial a S3**:  
   Los datos CSV se almacenan en rutas como:
   - `s3://datalake-demo-pruebatecnica/raw/clientes/`
   - `s3://datalake-demo-pruebatecnica/raw/proveedores/`
   - `s3://datalake-demo-pruebatecnica/raw/transacciones/`

2. **Catalogación con Glue Crawlers**:  
   Los crawlers detectan el esquema y crean tablas en el Glue Data Catalog (`energy_raw_db` y `energy_processed_db`).

3. **Transformación con Glue Jobs**:  
   Los jobs procesan los datos (limpieza, transformación de columnas, formatos) y los cargan en `s3://.../processed/`.

4. **Carga final a Redshift**:  
   Los datos procesados se cargan al DWH en Redshift para habilitar consultas analíticas.

5. **Gobierno de datos con Lake Formation**:  
   Se definen permisos finos a través de Lake Formation, permitiendo control detallado por base de datos y tabla.

### Herramientas y Tecnologías

- Terraform
- AWS S3, Glue, Redshift, IAM
- AWS Lake Formation
- Python (para scripts de ETL)
- GitHub Desktop (para versionamiento)

### Consideraciones de Seguridad

- Uso de IAM roles con permisos mínimos necesarios.
- Cifrado en S3 habilitado (server-side encryption).
- Lake Formation como capa de gobernanza centralizada.

### Evidencias

Puedes incluir capturas de pantalla de:
- Bucket S3 con datos.
- Glue Crawlers y Jobs ejecutados.
- Glue Data Catalog con tablas creadas.
- Redshift con datos cargados.
- Consola de Lake Formation con permisos asignados.

### Autor

Este proyecto fue desarrollado como parte de una prueba técnica para el rol de Ingeniero de Datos por Johan Sebastian Sanabria Simbaqueva.

---


## Punto 2 – Arquitectura propuesta

Para conocer el diseño completo de la arquitectura, accede al siguiente enlace:

🔗 [Diseño en Figma – Arquitectura Venta de Dólares](https://www.figma.com/design/xrmoUCSBPbUnjoTTopgG0L/Arquitectura-Venta-dolares?node-id=0-1&t=h6twOG2eX2H2WWel-1)

### Componentes clave

| Servicio | Función |
|----------|---------|
| **Amazon Kinesis** | Captura en tiempo real de transacciones de usuarios. |
| **AWS Lambda** | Procesamiento ligero e integración con otros servicios. |
| **Amazon S3 (Datalake)** | Almacenamiento centralizado de eventos y datos históricos. |
| **AWS Glue / Step Functions** | ETL batch para enriquecer datos e integrarlos al modelo. |
| **Amazon SageMaker** | Entrenamiento e inferencia del modelo de recomendación. |
| **Amazon DynamoDB** | Portafolio en tiempo real de cada usuario. |
| **Amazon Redshift** | Almacenamiento analítico de transacciones históricas. |
| **Amazon QuickSight** | Visualización de KPIs para analistas y stakeholders. |
| **Amazon SNS / Firebase** | Notificaciones personalizadas al usuario final. |

La arquitectura fue diseñada para ser **escalable**, **segura** y capaz de soportar picos de tráfico altos sin comprometer la latencia del sistema.

---

## Punto 3 – Preguntas Técnicas

### 1. Experiencia como ingeniero de datos en AWS

Mi trayectoria se ha centrado en el sector bancario, desarrollando pipelines para ingestar, transformar y automatizar datos provenientes de servidores globales. Uno de los mayores retos fue manejar 25 ingestas con múltiples formatos, algunas con tablas de hasta 800 columnas, integraciones paramétricas complejas y garantizar la automatización, encriptación y validación de datos sensibles.

### 2️. Estrategias para mantener la arquitectura y pipelines de datos

- **Infraestructura como Código (IaC)** con Terraform para reproducibilidad y control de versiones.
- **Zonificación de datos** (raw y processed) para trazabilidad y calidad.
- **Glue Crawlers + Jobs** para automatizar transformaciones de datos.
- **Lake Formation** para administración de accesos a nivel de columna y tabla.
- **Redshift + QuickSight + SageMaker** para analítica y personalización.
- **Servicios serverless y gestionados**, como S3, Glue, Kinesis y Athena, para escalabilidad sin fricción.

### 3️. Consideraciones al decidir entre S3, RDS o Redshift

| Servicio | Uso recomendado |
|----------|----------------|
| **Amazon S3** | Almacenamiento flexible, económico y escalable para datos semiestructurados o sin procesar. |
| **Amazon RDS** | Ideal para consistencia ACID y relaciones fuertes en aplicaciones OLTP. |
| **Amazon Redshift** | Análisis avanzado sobre grandes volúmenes de datos estructurados con consultas rápidas. |

### 4️. AWS Glue vs. Lambda vs. Step Functions para ETL

- **AWS Glue** → Ideal para grandes volúmenes, manejo de metadatos y flujos complejos, pero con tiempos de arranque mayores.
- **AWS Lambda** → Mejor para tareas pequeñas y eventos rápidos con ejecución corta.
- **AWS Step Functions** → Destaca en orquestaciones con lógica condicional y flujos más personalizados.

### 5️. Garantizar la seguridad de los datos en un datalake en S3

- **IAM + Lake Formation** → Control detallado de accesos.
- **Encriptación en reposo y en tránsito** → Uso de SSE y TLS.
- **Versionado y políticas de retención** → Restauración de datos si es necesario.
- **Auditoría con CloudTrail + CloudWatch** → Monitoreo proactivo de eventos.
- **Validación de integridad** → Checksums y verificaciones en procesos ETL.
- **Bloqueo de accesos no autorizados** → Políticas de restricción por IP y permisos estrictos.

-----