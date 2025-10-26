-- ===============================================
-- Silver Layer Tables for CRM and ERP Data
-- Purpose: Store cleaned, standardized, and transformed data derived from the Bronze layer.
-- This layer ensures high-quality data ready for reporting, analytics, and downstream consumption.
-- Each table includes a data lineage column (dwh_create_date) to track load timestamps.
-- ===============================================

-- ==============================
-- CRM Customer Info Table
-- Purpose: Stores cleaned and standardized customer information from CRM system.
-- Fields include transformed marital status, gender, and trimming of names.
-- ==============================
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- ==============================
-- CRM Product Info Table
-- Purpose: Stores cleaned and standardized product information from CRM system.
-- Includes product line transformations and product key/category parsing.
-- ==============================
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- ==============================
-- CRM Sales Details Table
-- Purpose: Stores cleaned sales transaction details from CRM system.
-- Includes price/sales validation and date transformations.
-- ==============================
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- ==============================
-- ERP Location Table
-- Purpose: Stores cleaned location information for customers from ERP system.
-- Country codes are standardized to full names and missing values set as 'n/a'.
-- ==============================
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- ==============================
-- ERP Customer Table
-- Purpose: Stores cleaned customer information from ERP system.
-- Birthdates in the future are replaced with NULL, gender is standardized.
-- ==============================
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- ==============================
-- ERP Product Category Table
-- Purpose: Stores cleaned product category details from ERP system.
-- Includes category, subcategory, and maintenance information.
-- ==============================
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
