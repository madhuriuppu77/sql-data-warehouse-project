-- =====================================================================
-- 🗂️  ENTERPRISE DATA WAREHOUSE (EDW) - DATA CATALOG
-- =====================================================================
-- Author: Madhuri Uppunuthula
-- Version: 1.0
-- Last Updated: October 2025
-- 
-- Purpose:
--     This document defines the complete data catalog for the Data Warehouse
--     architecture — including the Bronze (Raw), Silver (Cleaned),
--     and Gold (Analytics) layers.
--
--     Each section contains the purpose, structure, and relationship details
--     of all tables/views within its layer.
--
--     Layers:
--       🥉 Bronze  - Raw ingestion from CRM & ERP
--       🥈 Silver  - Cleaned & standardized data
--       🥇 Gold    - Analytics-ready star schema
-- =====================================================================



-- =====================================================================
-- 🥉  B R O N Z E   L A Y E R  -  R A W   D A T A
-- =====================================================================
-- Purpose:
--     The Bronze Layer stores unprocessed, raw data from CRM and ERP systems.
--     It serves as a staging zone for data lineage, auditing, and reprocessing.
-- =====================================================================

-- ==========================================================
-- Table: bronze.crm_cust_info
-- Purpose: Holds raw customer data from CRM before standardization.
-- ==========================================================
-- Columns:
--   cst_id               INT              - Unique customer identifier
--   cst_key              NVARCHAR(50)     - Customer key from CRM
--   cst_firstname        NVARCHAR(50)     - First name
--   cst_lastname         NVARCHAR(50)     - Last name
--   cst_marital_status   NVARCHAR(50)     - Marital status as captured
--   cst_gndr             NVARCHAR(50)     - Gender
--   cst_create_date      DATE             - Customer creation date


-- ==========================================================
-- Table: bronze.crm_prd_info
-- Purpose: Stores raw product details from CRM system.
-- ==========================================================
-- Columns:
--   prd_id        INT              - Product ID
--   prd_key       NVARCHAR(50)     - Product key
--   prd_nm        NVARCHAR(50)     - Product name
--   prd_cost      INT              - Product cost
--   prd_line      NVARCHAR(50)     - Product line
--   prd_start_dt  DATETIME         - Product start date
--   prd_end_dt    DATETIME         - Product end date


-- ==========================================================
-- Table: bronze.crm_sales_details
-- Purpose: Stores raw sales transactions from CRM.
-- ==========================================================
-- Columns:
--   sls_ord_num    NVARCHAR(50)     - Sales order number
--   sls_prd_key    NVARCHAR(50)     - Product reference
--   sls_cust_id    INT              - Customer reference
--   sls_order_dt   INT              - Order date (raw)
--   sls_ship_dt    INT              - Shipping date (raw)
--   sls_due_dt     INT              - Due date (raw)
--   sls_sales      INT              - Sales amount
--   sls_quantity   INT              - Quantity sold
--   sls_price      INT              - Price per unit


-- ==========================================================
-- Table: bronze.erp_loc_a101
-- Purpose: Stores location information from ERP.
-- ==========================================================
-- Columns:
--   cid       NVARCHAR(50)     - Customer ID reference
--   cntry     NVARCHAR(50)     - Country name or code


-- ==========================================================
-- Table: bronze.erp_cust_az12
-- Purpose: Holds ERP customer details such as birthdate and gender.
-- ==========================================================
-- Columns:
--   cid       NVARCHAR(50)     - Customer ID
--   bdate     DATE             - Birthdate
--   gen       NVARCHAR(50)     - Gender


-- ==========================================================
-- Table: bronze.erp_px_cat_g1v2
-- Purpose: Stores product category and subcategory details from ERP.
-- ==========================================================
-- Columns:
--   id           NVARCHAR(50)     - Category ID
--   cat          NVARCHAR(50)     - Category
--   subcat       NVARCHAR(50)     - Subcategory
--   maintenance  NVARCHAR(50)     - Maintenance level




-- =====================================================================
-- 🥈  S I L V E R   L A Y E R  -  C L E A N E D   D A T A
-- =====================================================================
-- Purpose:
--     The Silver Layer contains cleaned, standardized, and conformed data.
--     It ensures data quality and consistency for downstream usage.
--     Each table includes a load timestamp for lineage tracking.
-- =====================================================================

-- ==========================================================
-- Table: silver.crm_cust_info
-- Purpose: Cleaned CRM customer data with standardized gender & marital status.
-- ==========================================================
-- Columns:
--   cst_id              INT              - Customer ID
--   cst_key             NVARCHAR(50)     - CRM Customer Key
--   cst_firstname       NVARCHAR(50)     - First name (cleaned)
--   cst_lastname        NVARCHAR(50)     - Last name (cleaned)
--   cst_marital_status  NVARCHAR(50)     - Standardized marital status
--   cst_gndr            NVARCHAR(50)     - Standardized gender
--   cst_create_date     DATE             - Creation date
--   dwh_create_date     DATETIME2        - Data load timestamp


-- ==========================================================
-- Table: silver.crm_prd_info
-- Purpose: Standardized product information from CRM.
-- ==========================================================
-- Columns:
--   prd_id         INT              - Product ID
--   cat_id         NVARCHAR(50)     - Category reference
--   prd_key        NVARCHAR(50)     - Product key
--   prd_nm         NVARCHAR(50)     - Product name
--   prd_cost       INT              - Cost
--   prd_line       NVARCHAR(50)     - Product line
--   prd_start_dt   DATE             - Start date
--   prd_end_dt     DATE             - End date
--   dwh_create_date DATETIME2       - Load timestamp


-- ==========================================================
-- Table: silver.crm_sales_details
-- Purpose: Cleaned sales transactions with validated metrics and dates.
-- ==========================================================
-- Columns:
--   sls_ord_num    NVARCHAR(50)     - Sales order number
--   sls_prd_key    NVARCHAR(50)     - Product key
--   sls_cust_id    INT              - Customer ID
--   sls_order_dt   DATE             - Order date
--   sls_ship_dt    DATE             - Shipping date
--   sls_due_dt     DATE             - Due date
--   sls_sales      INT              - Sales amount
--   sls_quantity   INT              - Quantity
--   sls_price      INT              - Price per unit
--   dwh_create_date DATETIME2       - Load timestamp


-- ==========================================================
-- Table: silver.erp_loc_a101
-- Purpose: Cleaned ERP customer location data.
-- ==========================================================
-- Columns:
--   cid              NVARCHAR(50)     - Customer ID reference
--   cntry            NVARCHAR(50)     - Standardized country name
--   dwh_create_date  DATETIME2        - Load timestamp


-- ==========================================================
-- Table: silver.erp_cust_az12
-- Purpose: Cleaned ERP customer data (birthdate & gender).
-- ==========================================================
-- Columns:
--   cid              NVARCHAR(50)     - Customer ID
--   bdate            DATE             - Validated birthdate
--   gen              NVARCHAR(50)     - Standardized gender
--   dwh_create_date  DATETIME2        - Load timestamp


-- ==========================================================
-- Table: silver.erp_px_cat_g1v2
-- Purpose: Standardized ERP product category mapping.
-- ==========================================================
-- Columns:
--   id               NVARCHAR(50)     - Category ID
--   cat              NVARCHAR(50)     - Category name
--   subcat           NVARCHAR(50)     - Subcategory name
--   maintenance      NVARCHAR(50)     - Maintenance level
--   dwh_create_date  DATETIME2        - Load timestamp




-- =====================================================================
-- 🥇  G O L D   L A Y E R  -  A N A L Y T I C S   /   D A T A   M A R T
-- =====================================================================
-- Purpose:
--     The Gold Layer contains the final star-schema structures:
--     - Dimension Tables (Dim_Customers, Dim_Products)
--     - Fact Table (Fact_Sales)
--
--     These objects are optimized for reporting, dashboards, and BI tools.
--     Surrogate keys and “Unknown” default records ensure referential integrity.
-- =====================================================================

-- ==========================================================
-- View: gold.dim_customers
-- Purpose: Master Customer Dimension combining CRM & ERP data.
-- ==========================================================
-- Columns:
--   customer_key     INT              - Surrogate key
--   customer_id      INT              - Business key (CRM)
--   customer_number  NVARCHAR(50)     - CRM customer key
--   first_name       NVARCHAR(50)     - Customer first name
--   last_name        NVARCHAR(50)     - Customer last name
--   country          NVARCHAR(50)     - Country name
--   marital_status   NVARCHAR(50)     - Marital status
--   gender           NVARCHAR(50)     - Gender
--   birthdate        DATE             - Birthdate
--   create_date      DATE             - Creation date


-- ==========================================================
-- View: gold.dim_products
-- Purpose: Product Dimension combining CRM & ERP category data.
-- ==========================================================
-- Columns:
--   product_key     INT              - Surrogate key
--   product_id      INT              - Product ID
--   product_number  NVARCHAR(50)     - Product key
--   product_name    NVARCHAR(50)     - Product name
--   category_id     NVARCHAR(50)     - Category reference
--   category        NVARCHAR(50)     - Category
--   subcategory     NVARCHAR(50)     - Subcategory
--   maintenance     NVARCHAR(50)     - Maintenance info
--   cost            INT              - Product cost
--   product_line    NVARCHAR(50)     - Product line
--   start_date      DATE             - Product start date


-- ==========================================================
-- View: gold.fact_sales
-- Purpose: Sales Fact table linking Customers and Products.
-- ==========================================================
-- Columns:
--   order_number   NVARCHAR(50)     - Sales order number
--   product_key    INT              - FK to Dim_Product
--   customer_key   INT              - FK to Dim_Customer
--   order_date     DATE             - Order date
--   shipping_date  DATE             - Shipping date
--   due_date       DATE             - Due date
--   sales_amount   INT              - Total sales
--   quantity       INT              - Quantity sold
--   price          INT              - Unit price



-- =====================================================================
-- 📘  END OF DATA CATALOG
-- Author: Madhuri Uppunuthula
-- Description: Unified documentation for Bronze, Silver, and Gold layers.
-- =====================================================================

  
