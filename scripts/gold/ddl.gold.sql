-- =====================================================================
-- G O L D   L A Y E R   -   D A T A   M A R T   /   S T A R   S C H E M A
-- =====================================================================
-- Purpose:
--   This layer provides a clean, analytics-ready schema (Star Schema)
--   by joining and transforming data from the Silver Layer.
--   It includes:
--       - Dimension tables (Dim_Customers, Dim_Products)
--       - Fact table (Fact_Sales)
--
--   Each object uses surrogate keys, standardized attributes,
--   and handles missing or unknown references gracefully.
-- =====================================================================



-- ==========================================================
-- Dimension: Customers
-- Purpose:
--   Stores master customer data used for analytics.
--   Combines CRM and ERP customer info with location data.
--   Handles unknown customers using a default surrogate key (-1).
-- ==========================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,        -- Surrogate key
    ci.cst_id AS customer_id,                                  -- Business key (CRM)
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid

UNION ALL

-- Add default "Unknown Customer" record to handle missing joins
SELECT
    -1 AS customer_key,
    NULL AS customer_id,
    NULL AS customer_number,
    'Unknown' AS first_name,
    'Customer' AS last_name,
    'Unknown' AS country,
    'Unknown' AS marital_status,
    'Unknown' AS gender,
    NULL AS birthdate,
    NULL AS create_date;
GO



-- ==========================================================
-- Dimension: Products
-- Purpose:
--   Stores product master details used in sales analysis.
--   Combines product info from CRM and category hierarchy from ERP.
--   Filters out historical/inactive product records.
-- ==========================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,  -- Surrogate key
    pn.prd_id AS product_id,              -- Business key
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;  -- Keep only active records
GO



-- ==========================================================
-- Fact: Sales
-- Purpose:
--   Stores transactional sales data joined with dimension keys.
--   Includes sales metrics, quantity, price, and order dates.
--   Handles unknown customer references using default key (-1).
-- ==========================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num AS order_number,            -- Natural key from CRM
    pr.product_key,                            -- Foreign key to Dim_Product
    COALESCE(cu.customer_key, -1) AS customer_key,  -- Foreign key to Dim_Customer (defaults to -1 if missing)
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr 
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu 
    ON sd.sls_cust_id = cu.customer_id;
GO



-- ==========================================================
-- End of Gold Layer Views
-- Author: Madhuri Uppunuthula
-- Description: Finalized star-schema views for analytics and BI reporting.
-- ==========================================================
