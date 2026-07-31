-- Controles de Calidad de Datos - Capa Silver
-- Proyecto: TechMart Capstone
USE TechMartDW;
GO



-- 1. Verificar cantidades cargadas
SELECT
    'silver.api_products' AS table_name,
    COUNT(*) AS row_count
FROM silver.api_products

UNION ALL

SELECT
    'silver.oltp_customers',
    COUNT(*)
FROM silver.oltp_customers

UNION ALL

SELECT
    'silver.oltp_orders',
    COUNT(*)
FROM silver.oltp_orders

UNION ALL

SELECT
    'silver.oltp_order_items',
    COUNT(*)
FROM silver.oltp_order_items;
GO


-- 2. Verificar que las categorías estén estandarizadas
SELECT DISTINCT
    category
FROM silver.api_products
ORDER BY category;
GO


-- 3. Verificar nulos en los ratings

SELECT
    COUNT(*) AS ratings_nulos
FROM silver.api_products
WHERE rating_rate IS NULL
   OR rating_count IS NULL;
GO


-- 4. Verificar productos con precio inválido

SELECT
    COUNT(*) AS productos_precio_invalido
FROM silver.api_products
WHERE price IS NULL
   OR price < 0;
GO


-- 5. Verificar ítems de pedido huérfanos
-- Un huérfano tiene product_id que no existe en el catálogo.

SELECT
    COUNT(*) AS order_items_huerfanos
FROM silver.oltp_order_items AS oi
LEFT JOIN (
    SELECT DISTINCT product_id
    FROM silver.api_products
) AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
GO


-- 6. Verificar duplicados en clientes

SELECT
    customer_id,
    COUNT(*) AS cantidad
FROM silver.oltp_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
GO


-- 7. Verificar duplicados en pedidos

SELECT
    order_id,
    COUNT(*) AS cantidad
FROM silver.oltp_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
GO


-- 8. Verificar duplicados en ítems de pedido

SELECT
    order_item_id,
    COUNT(*) AS cantidad
FROM silver.oltp_order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;
GO


-- 9. Verificar datos obligatorios de clientes

SELECT
    COUNT(*) AS clientes_incompletos
FROM silver.oltp_customers
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR city IS NULL;
GO


-- 10. Verificar fechas de pedido

SELECT
    COUNT(*) AS pedidos_sin_fecha
FROM silver.oltp_orders
WHERE order_date IS NULL;
GO