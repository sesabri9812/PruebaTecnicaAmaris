SELECT tipo_transaccion, SUM(precio) AS total_precio
FROM processed_transacciones
GROUP BY tipo_transaccion;