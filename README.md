# PruebaTecnicaAmaris
Elaboracion de prueba tecnica para la empresa amaris usando herramientas de AWS.

Ejercicio 1 
Una compañía comercializadora de energía compra la electricidad a los generadores en el mercado 
mayoritario, donde después de una serie de contratos y control riesgos de precios esta se vende a los 
usuarios finales que pueden ser clientes residenciales, comerciales o industriales. 
El sistema de la compañía que administra este producto tiene la capacidad de exportar la información 
de proveedores, clientes y transacciones en archivos CSV. 
Requisitos técnicos: 
1. Crear una estrategia de datalake en s3 con las capas que usted considere necesario tener y cargue esta 
información de manera automática y periódica. Los archivos deben particionarse por fecha de carga. 
2. Realice 3 transformaciones básicas de datos utilizando AWS Glue y transforme la información para que 
esta sea almacenada en formato parquet en una zona procesada. 
3. Utilizando AWS Glue, crea un proceso que detecte y catalogue automáticamente los esquemas de los 
datos almacenados en el datalake. 
4. Utilizando Amazon Athena desde Python, realiza consultas SQL básicas sobre los datos que han sido 
transformados.