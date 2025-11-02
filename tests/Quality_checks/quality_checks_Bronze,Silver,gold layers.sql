-- ===============================================
-- DATA QUALITY CHECKS – BRONZE, SILVER & GOLD LAYERS
-- ===============================================
-- Purpose:
--   This script performs key data validation and quality checks 
--   across all three layers (Bronze, Silver, and Gold).
--   These checks ensure:
--     - Data completeness
--     - Referential integrity
--     - Duplicates detection
--     - Null / Missing values identification
--     - Schema and transformation consistency
--
-- Usage:
--   Execute section by section for each layer after data load.
--   Review results and take corrective actions if issues are found.
-- ===============================================



-- ==========================================================
--  BRONZE LAYER – RAW DATA VALIDATION
-- Purpose:
--   Validate completeness and structure of raw ingested data.
--   Detect duplicates, nulls, and anomalies from source systems.
-- ==========================================================

-- 1️ Record Count by Table
SELECT 'bronze.crm_cust_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL
SELECT 'bronze.crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL
SELECT 'bronze.crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL
SELECT 'bronze.erp_cust_az12', COUNT(*) FROM bronze.erp_cust_az12
UNION ALL
SELECT 'bronze.erp_loc_a101', COUNT(*) FROM bronze.erp_loc_a101
UNION ALL
SELECT 'bronze.erp_px_cat_g1v2', COUNT(*) FROM bronze.erp_px_cat_g1v2;


-- 2️ Duplicate Primary Key / Business Key Check
SELECT cst_id, COUNT(*) AS cnt 
FROM bronze.crm_cust_info 
GROUP BY cst_id 
HAVING COUNT(*) > 1;  -- Should return zero rows

SELECT prd_key, COUNT(*) 
FROM bronze.crm_prd_info 
GROUP BY prd_key 
HAVING COUNT(*) > 1;

SELECT sls_ord_num, COUNT(*) 
FROM bronze.crm_sales_details 
GROUP BY sls_ord_num 
HAVING COUNT(*) > 1;


-- 3️ Null Value Checks for Key Columns
SELECT * FROM bronze.crm_cust_info WHERE cst_id IS NULL OR cst_key IS NULL;
SELECT * FROM bronze.crm_prd_info WHERE prd_key IS NULL OR prd_id IS NULL;
SELECT * FROM bronze.crm_sales_details WHERE sls_ord_num IS NULL OR sls_cust_id IS NULL OR sls_prd_key IS NULL;


-- 4️ Invalid or Outlier Data Check
SELECT * FROM bronze.erp_cust_az12 WHERE bdate > GETDATE();  -- Invalid future birthdates
SELECT * FROM bronze.crm_prd_info WHERE prd_cost < 0;       -- Negative costs not allowed



-- ==========================================================
--  SILVER LAYER – TRANSFORMED DATA VALIDATION
-- Purpose:
--   Validate cleaning, standardization, and transformation logic.
--   Ensure lineage columns and transformations are correct.
-- ==========================================================

-- 1️ Record Count Comparison (Bronze vs Silver)
SELECT 
    'crm_cust_info' AS table_name,
    (SELECT COUNT(*) FROM bronze.crm_cust_info) AS bronze_count,
    (SELECT COUNT(*) FROM silver.crm_cust_info) AS silver_count;

SELECT 
    'crm_prd_info' AS table_name,
    (SELECT COUNT(*) FROM bronze.crm_prd_info),
    (SELECT COUNT(*) FROM silver.crm_prd_info);

SELECT 
    'crm_sales_details' AS table_name,
    (SELECT COUNT(*) FROM bronze.crm_sales_details),
    (SELECT COUNT(*) FROM silver.crm_sales_details);


-- 2️ Check for NULLs in Mandatory Fields
SELECT * FROM silver.crm_cust_info WHERE cst_id IS NULL OR cst_key IS NULL;
SELECT * FROM silver.crm_prd_info WHERE prd_id IS NULL OR prd_key IS NULL;
SELECT * FROM silver.crm_sales_details WHERE sls_ord_num IS NULL;


-- 3 Validate Data Type Transformations
SELECT TOP 10 sls_order_dt, TRY_CONVERT(DATE, sls_order_dt) AS validated_date
FROM silver.crm_sales_details
WHERE TRY_CONVERT(DATE, sls_order_dt) IS NULL;  -- Should return 0 rows


-- 4️ dwh_create_date Validation (Lineage Check)
SELECT * FROM silver.crm_cust_info WHERE dwh_create_date IS NULL;
SELECT * FROM silver.crm_prd_info WHERE dwh_create_date IS NULL;
SELECT * FROM silver.crm_sales_details WHERE dwh_create_date IS NULL;



-- ==========================================================
--  GOLD LAYER – STAR SCHEMA VALIDATION
-- Purpose:
--   Validate dimensional model integrity and data consistency.
--   Ensure referential integrity and no broken joins between fact/dim.
-- ==========================================================

-- 1️ Record Count Summary
SELECT 'gold.dim_customers' AS table_name, COUNT(*) AS row_count FROM gold.dim_customers
UNION ALL
SELECT 'gold.dim_products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'gold.fact_sales', COUNT(*) FROM gold.fact_sales;


-- 2️ Fact to Dimension Integrity Checks
-- Customers
SELECT DISTINCT f.customer_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Products
SELECT DISTINCT f.product_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


-- 3️ Null / Missing Attribute Checks
SELECT * FROM gold.dim_customers WHERE first_name IS NULL OR last_name IS NULL;
SELECT * FROM gold.dim_products WHERE product_name IS NULL;
SELECT * FROM gold.fact_sales WHERE order_number IS NULL;


-- 4️ Duplicate Surrogate Key Checks
SELECT customer_key, COUNT(*) 
FROM gold.dim_customers 
GROUP BY customer_key 
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) 
FROM gold.dim_products 
GROUP BY product_key 
HAVING COUNT(*) > 1;


-- 5️ Sales Metric Validation
SELECT * 
FROM gold.fact_sales 
WHERE sales_amount < 0 OR quantity <= 0 OR price < 0;  -- Invalid metrics


-- 6️ Date Consistency Check
SELECT * 
FROM gold.fact_sales 
WHERE shipping_date < order_date 
   OR due_date < order_date;  -- Invalid order timelines



-- ===============================================
-- END OF DATA QUALITY CHECKS
-- Author: Madhuri Uppunuthula
-- Description:
--   Comprehensive data validation script for Bronze, Silver,
--   and Gold layers in Customer 360 data warehouse project.
-- ===============================================
