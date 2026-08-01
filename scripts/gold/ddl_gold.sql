-- Definición de Tablas (DDL) - Capa Gold
-- Proyecto: TechMart Capstone
USE TechMartDW;
GO

--1) Tabla física: gold.dim_product
DROP TABLE IF EXISTS gold.dim_product;
GO

CREATE TABLE gold.dim_product (
    product_key   INT IDENTITY(1,1) NOT NULL,
    product_id    INT               NOT NULL,
    product_title NVARCHAR(500)     NOT NULL,
    category      NVARCHAR(100)     NOT NULL,
    price         DECIMAL(10,2)     NOT NULL,
    rating_rate   DECIMAL(4,2)      NOT NULL,
    rating_count  INT               NOT NULL,
    valid_from    DATE              NOT NULL,
    valid_to      DATE              NOT NULL,
    is_current    BIT               NOT NULL,

    CONSTRAINT pk_gold_dim_product
        PRIMARY KEY (product_key)
);
GO

--  2) Vista: gold.dim_customer

CREATE OR ALTER VIEW gold.dim_customer AS
SELECT
    ROW_NUMBER() OVER (ORDER BY c.customer_id) AS customer_key,
    c.customer_id,
    c.customer_name,
    c.city
FROM silver.oltp_customers c;

GO


--  3) Vista: gold.dim_date

CREATE OR ALTER VIEW gold.dim_date AS
SELECT DISTINCT
    CONVERT(INT, CONVERT(CHAR(8), o.order_date, 112)) AS date_key,
    o.order_date AS full_date,
    YEAR(o.order_date) AS year_number,
    MONTH(o.order_date) AS month_number,
    DATENAME(MONTH, o.order_date) AS month_name,
    DAY(o.order_date) AS day_number,
    DATEPART(QUARTER, o.order_date) AS quarter_number
FROM silver.oltp_orders o;
GO


--  4) Vista: gold.fact_sales

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
    oi.order_item_id,
    o.order_id,
    dc.customer_key,
    dd.date_key,
    dp.product_key,
    oi.product_id,
    oi.quantity,
    oi.quantity * dp.price AS gross_amount
FROM silver.oltp_order_items oi
INNER JOIN silver.oltp_orders o
    ON oi.order_id = o.order_id
INNER JOIN gold.dim_customer dc
    ON o.customer_id = dc.customer_id
INNER JOIN gold.dim_date dd
    ON o.order_date = dd.full_date
INNER JOIN gold.dim_product dp
    ON oi.product_id = dp.product_id
   AND o.order_date >= dp.valid_from
   AND o.order_date <  dp.valid_to;
GO