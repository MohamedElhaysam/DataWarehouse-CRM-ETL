----------------------------------------------------------------
-- CRM_CUST_INFO (1st Table)
----------------------------------------------------------------

-- 1st preview raw data
SELECT * FROM bronze.crm_cust_info

-- Insert cleaned customer data into the Silver layer
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
    record_insert_dt
)

-- Select the cleaned data from the Bronze layer
SELECT 
    cst_id,
    cst_key,

    -- Clean first and last name
    -- 1) TRIM spaces 
    -- 2) Make first letter uppercase 
    -- 3) Make the rest lowercase
    UPPER(LEFT(TRIM(cst_firstname),1)) 
        + LOWER(SUBSTRING(TRIM(cst_firstname),2,LEN(TRIM(cst_firstname)))) AS cst_firstname,
    UPPER(LEFT(TRIM(cst_lastname),1)) 
        + LOWER(SUBSTRING(TRIM(cst_lastname),2,LEN(TRIM(cst_lastname)))) AS cst_lastname,

    -- Standardize marital status:
    -- S -> Single, M -> Married, else n/a
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,

    -- Standardize gender:
    -- F -> Female, M -> Male, else n/a
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,

    -- Keep the original create date
    cst_create_date,

    -- Add a new record insert date = current timestamp
    GETDATE()AS record_insert_dt

-- Deduplicate: keep only the latest record for each cst_id
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id 
               ORDER BY cst_create_date DESC
           ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL   
) t
WHERE flag_last = 1;  




----------------------------------------------------------------
-- CRM_PRD_INFO  (2nd Table)
----------------------------------------------------------------
-- 1st view raw data
select * from bronze.crm_prd_info
-- Find duplicate or NULL product IDs
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
-- Find product names with leading or trailing spaces
SELECT prd_nm 
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
-- Find products with zero or missing cost
SELECT prd_id, prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost = 0 OR prd_cost IS NULL;
-- Get unique product line values
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;
-- Find records where product end date is earlier than start date
SELECT * FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;



-- Insert cleaned product data into Silver layer
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt,
    record_insert_dt
)
SELECT
    prd_id,

    -- divides prd_key into 2 columns cat_id, prd_key
    replace(substring(prd_key,1,5),'-','_') as cat_id,
    substring(prd_key,7,len(prd_key)) as prd_key,

    prd_nm,

    -- Convert cost to INT convert it to 0 if null
    ISNULL(prd_cost, 0) AS prd_cost,

    -- Standardize product line codes
    CASE
        WHEN upper(trim(prd_line)) = 'R' THEN 'Road'
        WHEN upper(trim(prd_line)) = 'M' THEN 'Mountain'
        WHEN upper(trim(prd_line)) = 'T' THEN 'Touring'
        WHEN upper(trim(prd_line)) = 'S' THEN 'Sport'
        ELSE 'n/a'
    END AS prd_line,

    -- Keep start date as is
    cast(prd_start_dt as date) as prd_start_dt,

    cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt,

    -- Record insert timestamp
    cast(GETDATE() as date) AS record_insert_dt 

FROM bronze.crm_prd_info




----------------------------------------------------------------
-- CRM_SALES_DETAILS  (3rd Table)
----------------------------------------------------------------

--1st view the raw data
select * from bronze.crm_sales_details


select distinct sls_sales, sls_quantity, sls_price
from bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price    -- sales value doesn’t match quantity * price
   OR sls_sales IS NULL                        -- missing sales
   OR sls_quantity IS NULL                     -- missing quantity
   OR sls_price IS NULL                        -- missing price
   OR sls_sales <= 0                           -- sales should be positive
   OR sls_quantity <= 0                        -- quantity should be positive
   OR sls_price <= 0                           -- price should be positive
order by sls_sales, sls_quantity, sls_price;

select * from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt
   or sls_order_dt > sls_due_dt;


SELECT
  NULLIF(sls_order_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
  OR LEN(sls_order_dt) != 8
  OR sls_order_dt > 20500101
  OR sls_order_dt < 19000101;


INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price,
    record_insert_dt
)
SELECT 
    sls_ord_num, 
    sls_prd_key, 
    sls_cust_id,

    -- Clean and convert order date:
    -- If it's 0 or length != 8 return NULL.
    -- Otherwise, cast it into a proper DATE.
    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    -- Clean and convert ship date:
    -- Same logic as order date
    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    -- Clean and convert due date:
    -- Ensures only valid 8‑digit turned into DATEs.
    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    -- Validate and recalculate sales:
    -- If sales are NULL, <= 0, or don’t equal quantity * price,
    -- then recalculate as quantity * ABS(price).
    -- Otherwise, keep the original sales value.
    CASE
         WHEN sls_sales IS NULL 
              OR sls_sales <= 0 
              OR sls_sales != sls_quantity * ABS(sls_price)
             THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END AS sls_sales,

    -- Keep original quantity (no transformation).
    sls_quantity,

    -- Validate and correct price:
    -- If price is NULL or <= 0, then recalculate as sales ÷ quantity
    -- (using NULLIF to avoid division by zero).
    -- Otherwise, keep the original price.
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price,

    GETDATE() AS record_insert_dt 

FROM bronze.crm_sales_details;





----------------------------------------------------------------
-- ERP_CUST_AZ12  (4th Table)
----------------------------------------------------------------
-- VIEW RAW DATA
select * from bronze.erp_cust_az12

--CHECK GENDER Distribution
select gen , count(*) from bronze.erp_cust_az12 group by gen 

INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen,
            record_insert_dt
)
select
    case
        when cid like 'NAS%' then substring(cid,4,len(cid))
        else cid
    end as cid,
    case
        when bdate > getdate() then null
        else bdate
    end as bdate,
    case 
        when upper(trim(gen)) in ('F', 'FEMALE') THEN 'Female'
        when upper(trim(gen)) in ('M', 'MALE') THEN 'Male'
        else 'n/a'
    end as gen,
    GETDATE() AS record_insert_dt
from bronze.erp_cust_az12;


----------------------------------------------------------------
-- ERP_LOC_A101  (5th Table)
----------------------------------------------------------------
select * from bronze.erp_loc_a101

--Check country distribution
select cntry , count(*) from bronze.erp_loc_a101 group by cntry

INSERT INTO silver.erp_loc_a101(
     cid,
     cntry,
     record_insert_dt
)
select 
    replace(cid, '-', '') as cid,
    case
        when trim(cntry) IN ('DE','Germany') then 'Germany'
        when trim(cntry) IN ('US','USA','United States') THEN 'United States'
        WHEN cntry LIKE 'France' THEN 'France'
        WHEN cntry LIKE 'Canada' THEN 'Canada'
        WHEN cntry LIKE 'Australia' THEN 'Australia'
        WHEN cntry LIKE 'United Kingdom' THEN 'United Kingdom'
        else 'N/A'
    end,
    GETDATE() AS record_insert_dt
from bronze.erp_loc_a101



----------------------------------------------------------------
-- ERP_PX_CAT_G1V2  (5th Table)
----------------------------------------------------------------
-- VIEW RAW DATA
SELECT * FROM bronze.erp_px_cat_g1v2

-- this table doesn't need any cleaning

insert into silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance,
    record_insert_dt
)
select 
    id,
    cat,
    subcat,
    maintenance,
    GETDATE() AS record_insert_dt
from bronze.erp_px_cat_g1v2









