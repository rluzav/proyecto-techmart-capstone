-- Procedimientos Almacenados de Carga - Capa Bronze
-- Proyecto: TechMart Capstone
USE TechMartDW;
GO

CREATE OR ALTER PROCEDURE bronze.sp_load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Vaciar tablas Bronze.
    TRUNCATE TABLE bronze.api_products;
    TRUNCATE TABLE bronze.oltp_order_items;
    TRUNCATE TABLE bronze.oltp_orders;
    TRUNCATE TABLE bronze.oltp_customers;

    -- 2. BULK INSERT customers.csv.
    BULK INSERT bronze.oltp_customers
    FROM 'D:\CURSO JHON\SQL DATA ENGINIEER\PROYECTO\proyecto-techmart-capstone\datasets\oltp\customers.csv'
    WITH (
			FORMAT = 'CSV',
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001'
    );

    -- 3. BULK INSERT orders.csv.
    BULK INSERT bronze.oltp_orders
    FROM 'D:\CURSO JHON\SQL DATA ENGINIEER\PROYECTO\proyecto-techmart-capstone\datasets\oltp\orders.csv'
    WITH (
			FORMAT = 'CSV',
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001'
    );

    -- 4. BULK INSERT order_items.csv.
    BULK INSERT bronze.oltp_order_items
    FROM 'D:\CURSO JHON\SQL DATA ENGINIEER\PROYECTO\proyecto-techmart-capstone\datasets\oltp\order_items.csv'
    WITH (
			FORMAT = 'CSV',
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001'
    );

    -- 5. OPENJSON snapshot del Día 1. 
DECLARE @json NVARCHAR(MAX);

SELECT @json = BulkColumn
FROM OPENROWSET(
    BULK 'D:\CURSO JHON\SQL DATA ENGINIEER\PROYECTO\proyecto-techmart-capstone\datasets\api_snapshots\products_2026-07-30.json',
    SINGLE_CLOB
) AS j;

INSERT INTO bronze.api_products (
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
    title,
    price,
    description,
    category,
    image_url,
    rating_rate,
    rating_count,
    extraction_date
FROM OPENJSON(@json)
WITH (
    product_id      INT            '$.id',
    title           NVARCHAR(500)  '$.title',
    price           DECIMAL(10, 2) '$.price',
    description     NVARCHAR(MAX)  '$.description',
    category        NVARCHAR(100)  '$.category',
    image_url       NVARCHAR(1000) '$.image',
    rating_rate     DECIMAL(4, 2)  '$.rating.rate',
    rating_count    INT            '$.rating.count',
    extraction_date DATE           '$.extraction_date'
);
     
    -- 6. OPENJSON snapshot del Día 2.
  DECLARE @json_dia2 NVARCHAR(MAX);

SELECT @json_dia2 = BulkColumn
FROM OPENROWSET(
    BULK 'D:\CURSO JHON\SQL DATA ENGINIEER\PROYECTO\proyecto-techmart-capstone\datasets\api_snapshots\products_2026-08-06.json',
    SINGLE_CLOB
) AS j;

INSERT INTO bronze.api_products (
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
    title,
    price,
    description,
    category,
    image_url,
    rating_rate,
    rating_count,
    extraction_date
FROM OPENJSON(@json_dia2)
WITH (
    product_id      INT            '$.id',
    title           NVARCHAR(500)  '$.title',
    price           DECIMAL(10, 2) '$.price',
    description     NVARCHAR(MAX)  '$.description',
    category        NVARCHAR(100)  '$.category',
    image_url       NVARCHAR(1000) '$.image',
    rating_rate     DECIMAL(4, 2)  '$.rating.rate',
    rating_count    INT            '$.rating.count',
    extraction_date DATE           '$.extraction_date'
);

    -- Imprimir confirmación
    PRINT 'Tablas de Bronze cargadas exitosamente.';

    -- Contar registros cargados
    PRINT '--- Cantidad de registros cargados por tabla ---';
    SELECT 'api_products' AS nombre_tabla, COUNT(*) AS row_count FROM bronze.api_products
    UNION ALL
    SELECT 'oltp_customers', COUNT(*) FROM bronze.oltp_customers
    UNION ALL
    SELECT 'oltp_orders', COUNT(*) FROM bronze.oltp_orders
    UNION ALL
    SELECT 'oltp_order_items', COUNT(*) FROM bronze.oltp_order_items;
END;
GO

EXEC bronze.sp_load_bronze;
GO

SELECT * FROM [bronze].[api_products];
GO
SELECT * FROM [bronze].[oltp_customers];
GO
SELECT * FROM [bronze].[oltp_order_items];
GO
SELECT * FROM [bronze].[oltp_orders];