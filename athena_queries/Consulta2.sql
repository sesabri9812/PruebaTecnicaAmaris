SELECT nombre_cliente_proveedor, SUM(cantidad_comprada) AS total_cantidad
FROM processed_transacciones
GROUP BY nombre_cliente_proveedor
ORDER BY total_cantidad DESC;