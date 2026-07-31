-- Procedimientos Almacenados de Carga - Capa Silver
-- Proyecto: TechMart Capstone
USE TechMartDW;
GO

CREATE OR ALTER PROCEDURE silver.sp_load_silver
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Vaciar las tablas Silver.
    TRUNCATE TABLE silver.oltp_order_items;
    TRUNCATE TABLE silver.oltp_orders;
    TRUNCATE TABLE silver.oltp_customers;
    TRUNCATE TABLE silver.api_products;

    -- 2. Insertar productos limpios.
        INSERT INTO silver.api_products (
        product_id,
        title,
        price,
        description,
        category,
        image_url,
        rating_rate,
        rating_count,
        extraction_date
    )
    SELECT
        product_id,
        NULLIF(LTRIM(RTRIM(title)), ''),
        price,
        NULLIF(LTRIM(RTRIM(description)), ''),
        UPPER(LTRIM(RTRIM(category))),
        image_url,
        COALESCE(rating_rate, 0.00),
        COALESCE(rating_count, 0),
        extraction_date
    FROM bronze.api_products
    WHERE price IS NOT NULL
      AND price >= 0
      AND NULLIF(LTRIM(RTRIM(category)), '') IS NOT NULL;
    -- 3. Insertar clientes limpios.
        INSERT INTO silver.oltp_customers (
        customer_id,
        customer_name,
        city
    )
    SELECT
        customer_id,
        NULLIF(LTRIM(RTRIM(customer_name)), ''),
        UPPER(NULLIF(LTRIM(RTRIM(city)), ''))
    FROM bronze.oltp_customers
    WHERE customer_id IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(customer_name)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(city)), '') IS NOT NULL;
    -- 4. Insertar pedidos limpios.
        INSERT INTO silver.oltp_orders (
        order_id,
        customer_id,
        order_date,
        order_status
    )
    SELECT
        order_id,
        customer_id,
        order_date,
        UPPER(NULLIF(LTRIM(RTRIM(order_status)), ''))
    FROM bronze.oltp_orders
    WHERE order_id IS NOT NULL
      AND customer_id IS NOT NULL
      AND order_date IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(order_status)), '') IS NOT NULL;
    -- 5. Insertar ítems válidos.
    INSERT INTO silver.oltp_order_items (
        order_item_id,
        order_id,
        product_id,
        quantity
    )
    SELECT
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        oi.quantity
    FROM bronze.oltp_order_items AS oi
    INNER JOIN (
        SELECT DISTINCT product_id
        FROM bronze.api_products
    ) AS p
        ON oi.product_id = p.product_id
    WHERE oi.order_item_id IS NOT NULL
      AND oi.order_id IS NOT NULL
      AND oi.product_id IS NOT NULL
      AND oi.quantity > 0;

    -- 6. Control del proceso
    PRINT 'Tablas de Silver cargadas exitosamente.';

    -- 7. Contar registros cargados.
    PRINT '--- Cantidad de registros cargados por tabla ---';
    SELECT 'api_products' AS nombre_tabla, COUNT(*) AS row_count FROM silver.api_products
    UNION ALL
    SELECT 'oltp_customers', COUNT(*) FROM silver.oltp_customers
    UNION ALL
    SELECT 'oltp_orders', COUNT(*) FROM silver.oltp_orders
    UNION ALL
    SELECT 'oltp_order_items', COUNT(*) FROM silver.oltp_order_items;
END;
GO
EXEC silver.sp_load_silver;
GO