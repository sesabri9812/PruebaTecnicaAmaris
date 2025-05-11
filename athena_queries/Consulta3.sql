SELECT tipo_energia, AVG(precio) AS precio_promedio
FROM processed_transacciones
GROUP BY tipo_energia
ORDER BY precio_promedio DESC;