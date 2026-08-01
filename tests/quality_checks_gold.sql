-- Controles de Calidad de Datos - Capa Gold
-- Proyecto: TechMart Capstone
USE TechMartDW;
GO
-- 1) Cuenta cuántas filas totales tiene la dimensión de productos.
SELECT COUNT(*) AS filas_dim_product
FROM gold.dim_product;
GO
-- 2) Muestra qué productos tienen más de una versión.
SELECT
    product_id,
    COUNT(*) AS versiones
FROM gold.dim_product
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY product_id;
GO
-- 3) Muestra solo la versión vigente de cada producto.
SELECT *
FROM gold.dim_product
WHERE is_current = 1
ORDER BY product_id;
GO
-- 4) Cuenta cuántas filas tiene la tabla de hechos.
SELECT COUNT(*) AS filas_fact_sales
FROM gold.fact_sales;
GO
-- 5) Busca claves nulas en fact_sales.
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR date_key IS NULL
   OR product_key IS NULL;
GO
-- 6) Revisa una muestra de fact_sales junto con sus dimensiones.
SELECT TOP 20
    fs.order_id,
    fs.product_id,
    fs.quantity,
    fs.gross_amount,
    dp.product_title,
    dd.full_date,
    dc.customer_name
FROM gold.fact_sales fs
INNER JOIN gold.dim_product dp
    ON fs.product_key = dp.product_key
INNER JOIN gold.dim_date dd
    ON fs.date_key = dd.date_key
INNER JOIN gold.dim_customer dc
    ON fs.customer_key = dc.customer_key
ORDER BY fs.order_id;
GO