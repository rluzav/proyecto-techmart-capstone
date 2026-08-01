USE TechMartDW;
GO

-- 1) Ranking de productos más vendidos por categoría


WITH ventas_por_producto AS (
    SELECT
        dp.category,
        dp.product_title,
        SUM(fs.quantity) AS total_unidades_vendidas
    FROM gold.fact_sales fs
    INNER JOIN gold.dim_product dp
        ON fs.product_key = dp.product_key
    GROUP BY
        dp.category,
        dp.product_title
)
SELECT
    category,
    product_title,
    total_unidades_vendidas,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY total_unidades_vendidas DESC
    ) AS ranking_categoria
FROM ventas_por_producto
ORDER BY
    category,
    ranking_categoria,
    product_title;
GO
-- 2) Ticket promedio mensual con tendencia

WITH pedidos AS (
    SELECT
        fs.order_id,
        dd.year_number,
        dd.month_number,
        dd.month_name,
        SUM(fs.gross_amount) AS total_pedido
    FROM gold.fact_sales fs
    INNER JOIN gold.dim_date dd
        ON fs.date_key = dd.date_key
    GROUP BY
        fs.order_id,
        dd.year_number,
        dd.month_number,
        dd.month_name
),
ticket_mensual AS (
    SELECT
        year_number,
        month_number,
        month_name,
        AVG(total_pedido) AS ticket_promedio_mensual
    FROM pedidos
    GROUP BY
        year_number,
        month_number,
        month_name
)
SELECT
    year_number,
    month_number,
    month_name,
    ticket_promedio_mensual,
    LAG(ticket_promedio_mensual) OVER (
        ORDER BY year_number, month_number
    ) AS ticket_mes_anterior,
    ticket_promedio_mensual
      - LAG(ticket_promedio_mensual) OVER (
            ORDER BY year_number, month_number
        ) AS variacion_vs_mes_anterior
FROM ticket_mensual
ORDER BY
    year_number,
    month_number;
GO

-- 3) Segmentación de clientes
-- Bajo valor  : total gastado < 500
-- Medio valor : total gastado entre 500 y 999.99
-- Alto valor  : total gastado >= 1000

WITH gasto_por_cliente AS (
    SELECT
        dc.customer_id,
        dc.customer_name,
        dc.city,
        SUM(fs.gross_amount) AS total_gastado
    FROM gold.fact_sales fs
    INNER JOIN gold.dim_customer dc
        ON fs.customer_key = dc.customer_key
    GROUP BY
        dc.customer_id,
        dc.customer_name,
        dc.city
)
SELECT
    customer_id,
    customer_name,
    city,
    total_gastado,
    CASE
        WHEN total_gastado >= 1000 THEN 'Alto valor'
        WHEN total_gastado >= 500 THEN 'Medio valor'
        ELSE 'Bajo valor'
    END AS segmento_cliente
FROM gasto_por_cliente
ORDER BY
    total_gastado DESC;
GO

-- 4) Impacto del cambio de precio en las ventas
-- Se comparan ventas antes y después del cambio de precio
-- solo para los productos que tuvieron más de una versión en dim_product.

WITH productos_con_cambio AS (
    SELECT
        product_id
    FROM gold.dim_product
    GROUP BY product_id
    HAVING COUNT(*) > 1
),
ventas_por_version AS (
    SELECT
        dp.product_id,
        dp.product_title,
        dp.price,
        dp.valid_from,
        dp.valid_to,
        dp.is_current,
        SUM(fs.quantity) AS unidades_vendidas,
        SUM(fs.gross_amount) AS importe_vendido
    FROM gold.fact_sales fs
    INNER JOIN gold.dim_product dp
        ON fs.product_key = dp.product_key
    INNER JOIN productos_con_cambio pc
        ON dp.product_id = pc.product_id
    GROUP BY
        dp.product_id,
        dp.product_title,
        dp.price,
        dp.valid_from,
        dp.valid_to,
        dp.is_current
)
SELECT
    product_id,
    product_title,
    price,
    valid_from,
    valid_to,
    is_current,
    unidades_vendidas,
    importe_vendido,
    LAG(unidades_vendidas) OVER (
        PARTITION BY product_id
        ORDER BY valid_from
    ) AS unidades_version_anterior,
    unidades_vendidas
      - LAG(unidades_vendidas) OVER (
            PARTITION BY product_id
            ORDER BY valid_from
        ) AS diferencia_unidades
FROM ventas_por_version
ORDER BY
    product_id,
    valid_from;
GO