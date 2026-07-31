-- Definición de Tablas (DDL) - Capa Bronze
-- Proyecto: TechMart Capstone
USE TechMartDW;
GO

-- Eliminando primero las tablas en caso que existan

DROP TABLE IF EXISTS bronze.api_products;
DROP TABLE IF EXISTS bronze.oltp_order_items;
DROP TABLE IF EXISTS bronze.oltp_orders;
DROP TABLE IF EXISTS bronze.oltp_customers;
GO

-- Productos provenientes de Fake Store API.
-- Un mismo producto puede aparecer varias veces:
-- una fila por producto y por fecha de extracción.
CREATE TABLE bronze.api_products (
    product_id       INT            NOT NULL,
    title            NVARCHAR(500)  NULL,
    price            DECIMAL(10, 2) NULL,
    description      NVARCHAR(MAX)  NULL,
    category         NVARCHAR(100)  NULL,
    image_url        NVARCHAR(1000) NULL,
    rating_rate      DECIMAL(4, 2)  NULL,
    rating_count     INT            NULL,
    extraction_date  DATE           NOT NULL
);
GO

-- Clientes del sistema interno de TechMart.
CREATE TABLE bronze.oltp_customers (
    customer_id   INT           NOT NULL,
    customer_name NVARCHAR(150) NULL,
    city          NVARCHAR(100) NULL
);
GO

-- Pedidos del sistema interno de TechMart.
CREATE TABLE bronze.oltp_orders (
    order_id      INT          NOT NULL,
    customer_id   INT          NOT NULL,
    order_date    DATE         NOT NULL,
    order_status  NVARCHAR(30) NULL
);
GO

-- Detalle de productos vendidos en cada pedido.
CREATE TABLE bronze.oltp_order_items (
    order_item_id  INT NOT NULL,
    order_id       INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL
);
GO

-- Verificando tablas
SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables AS t
JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
WHERE s.name = 'bronze'
ORDER BY t.name;