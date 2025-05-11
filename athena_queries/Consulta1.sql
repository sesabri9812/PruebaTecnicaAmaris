SELECT tipo_transaccion, COUNT(*) AS total
FROM processed_transacciones
GROUP BY tipo_transaccion;