IF DB_ID('data_warehouse') IS NULL
    create DATABASE data_warehouse;

GO
use data_warehouse;
GO

-------------------------------
--Creating  Schemas
-------------------------------
create schema bronze;
create schema silver;
create schema gold;


-------------------------------
-- DDL for Bronze Layer
-------------------------------

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);



-------------------------------
-- DDL for Silver Layer
-------------------------------
CREATE TABLE silver.crm_cust_info
(
    cst_id          INT,
    cst_key         NVARCHAR(50),
    cst_firstname   NVARCHAR(50),
    cst_lastname    NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr        NVARCHAR(50),
    cst_create_date DATE,
    record_insert_dt DATETIME DEFAULT GETDATE()
);



CREATE TABLE silver.crm_prd_info (
    prd_id          INT,
    cat_id          NVARCHAR(50),
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    record_insert_dt DATETIME DEFAULT GETDATE()
);



CREATE TABLE silver.crm_sales_details (
    sls_ord_num      NVARCHAR(50),
    sls_prd_key      NVARCHAR(50),
    sls_cust_id      INT,
    sls_order_dt     DATE,
    sls_ship_dt      DATE,
    sls_due_dt       DATE,
    sls_sales        INT,
    sls_quantity     INT,
    sls_price        INT,
    record_insert_dt DATETIME DEFAULT GETDATE()
);



create table silver.erp_cust_az12(
     cid            NVARCHAR(50),
     bdate          DATE,
     gen            NVARCHAR(50),
     record_insert_dt DATETIME DEFAULT GETDATE()
);





CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),
    cntry           NVARCHAR(50),
    record_insert_dt DATETIME DEFAULT GETDATE()
);



create table silver.erp_px_cat_g1v2(
   id   NVARCHAR(50),
   cat  NVARCHAR(50),
   subcat   NVARCHAR(50),
   maintenance NVARCHAR(50),
   record_insert_dt DATETIME DEFAULT GETDATE()
)


select * from silver.crm_cust_info
select * from silver.crm_prd_info
SELECT * FROM silver.crm_sales_details
SELECT * FROM silver.erp_cust_az12
select * from silver.erp_loc_a101
select * from silver.erp_px_cat_g1v2
