/*
===============================================================================
DATA WAREHOUSE GOLD LAYER - STAR SCHEMA IMPLEMENTATION
===============================================================================
Purpose: Creates business-ready dimension and fact tables for analytics
Architecture: Medallion Architecture (Bronze -> Silver -> Gold)
Target Layer: Gold (Business/Analytics Ready)
===============================================================================
*/

-- =============================================================================
-- CUSTOMER DIMENSION TABLE
-- =============================================================================
-- Combines customer info from CRM, ERP, and location tables into one clean view

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,

    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    ci.cst_marital_status              AS marital_status,
    
    la.cntry                           AS country,
    
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  -- CRM is primary source
        ELSE COALESCE(ca.gen, 'n/a')                -- ERP fallback if CRM unavailable
    END                                AS gender,
    
    ca.bdate                           AS birthdate,
    
    ci.cst_create_date                 AS create_date
    
FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid;

go
-- =============================================================================
-- PRODUCT DIMENSION TABLE
-- =============================================================================
-- Combines product info from CRM and ERP into one clean view (active products only)

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT

    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    
    pn.prd_id                          AS product_id,
    pn.prd_key                         AS product_number,
    pn.prd_nm                          AS product_name,
    
    pn.cat_id                          AS category_id,
    pc.cat                             AS category,
    pc.subcat                          AS subcategory,
    pc.maintenance                     AS maintenance,
    
    pn.prd_cost                        AS cost,
    
    pn.prd_line                        AS product_line,
    
    pn.prd_start_dt                    AS start_date
    
FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id
WHERE 
    pn.prd_end_dt IS NULL;  -- ACTIVE PRODUCTS ONLY: Exclude discontinued products

go
-- =============================================================================
-- SALES FACT TABLE
-- =============================================================================
-- Sales transactions with links to customer and product tables

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    -- Business key
    sd.sls_ord_num                     AS order_number,
    
    -- Foreign keys to dimension tables
    pr.product_key                     AS product_key,    -- Links to dim_products
    cu.customer_key                    AS customer_key,   -- Links to dim_customers
    
    -- Date attributes (consider creating separate date dimension)
    sd.sls_order_dt                    AS order_date,
    sd.sls_ship_dt                     AS shipping_date,
    sd.sls_due_dt                      AS due_date,
    
    -- Fact measures (numeric values for aggregation)
    sd.sls_sales                       AS sales_amount,   -- Revenue measure
    sd.sls_quantity                    AS quantity,       -- Volume measure
    sd.sls_price                       AS price           -- Unit price measure
    
FROM silver.crm_sales_details sd
    -- Join to product dimension for product_key lookup
    LEFT JOIN gold.dim_products pr
        ON sd.sls_prd_key = pr.product_number
    -- Join to customer dimension for customer_key lookup  
    LEFT JOIN gold.dim_customers cu
        ON sd.sls_cust_id = cu.customer_id;

go





