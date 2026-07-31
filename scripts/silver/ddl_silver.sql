-- Definición de Tablas (DDL) - Capa Silver
-- Proyecto: TechMart Capstone
USE TechMartDW;
GO

DROP TABLE IF EXISTS silver.oltp_order_items;
DROP TABLE IF EXISTS silver.oltp_orders;
DROP TABLE IF EXISTS silver.oltp_customers;
DROP TABLE IF EXISTS silver.api_products;
GO

-- Catálogo limpio. Conserva ambos snapshots.
CREATE TABLE silver.api_products (
    product_id       INT            NOT NULL,
    title            NVARCHAR(500)  NULL,
    price            DECIMAL(10, 2) NOT NULL,
    description      NVARCHAR(MAX)  NULL,
    category         NVARCHAR(100)  NOT NULL,
    image_url        NVARCHAR(1000) NULL,
    rating_rate      DECIMAL(4, 2)  NOT NULL,
    rating_count     INT            NOT NULL,
    extraction_date  DATE           NOT NULL
);
GO

-- Clientes internos limpios.
CREATE TABLE silver.oltp_customers (
    customer_id   INT           NOT NULL,
    customer_name NVARCHAR(150) NOT NULL,
    city          NVARCHAR(100) NOT NULL
);
GO

-- Pedidos internos limpios.
CREATE TABLE silver.oltp_orders (
    order_id      INT          NOT NULL,
    customer_id   INT          NOT NULL,
    order_date    DATE         NOT NULL,
    order_status  NVARCHAR(30) NOT NULL
);
GO

-- Ítems válidos: solo productos presentes en el catálogo.
CREATE TABLE silver.oltp_order_items (
    order_item_id  INT NOT NULL,
    order_id       INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL
);
GO