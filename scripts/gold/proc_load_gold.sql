USE TechMartDW;
GO

--Creando proc almacenado de transformacion a GOLD

CREATE OR ALTER PROCEDURE gold.sp_load_gold
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE gold.dim_product;

    WITH productos_base AS (
        SELECT
            product_id,
            title,
            category,
            price,
            rating_rate,
            rating_count,
            extraction_date,
            LAG(price) OVER (
                PARTITION BY product_id
                ORDER BY extraction_date
            ) AS precio_anterior,
            LEAD(extraction_date) OVER (
                PARTITION BY product_id
                ORDER BY extraction_date
            ) AS siguiente_fecha
        FROM silver.api_products
    )
    INSERT INTO gold.dim_product (
        product_id,
        product_title,
        category,
        price,
        rating_rate,
        rating_count,
        valid_from,
        valid_to,
        is_current
    )
    SELECT
        product_id,
        title,
        category,
        price,
        rating_rate,
        rating_count,
        extraction_date AS valid_from,
        COALESCE(siguiente_fecha, '9999-12-31') AS valid_to,
        CASE
            WHEN siguiente_fecha IS NULL THEN 1
            ELSE 0
        END AS is_current
    FROM productos_base
    WHERE precio_anterior IS NULL
       OR price <> precio_anterior;

    PRINT 'gold.dim_product cargada correctamente.';
END;
GO

--Ejecutando proc

EXEC gold.sp_load_gold;

go
-- Validando registros de dim_product

SELECT COUNT(*) AS filas_dim_product
FROM gold.dim_product;
go

SELECT
    product_id,
    COUNT(*) AS versiones
FROM gold.dim_product
GROUP BY product_id
ORDER BY product_id;
go

SELECT *
FROM gold.dim_product
WHERE is_current = 1
ORDER BY product_id;