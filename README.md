# DataWarehouse-CRM-ETL

A data warehouse ETL pipeline built in **SQL Server (T-SQL)** with a **medallion architecture** (Bronze, Silver, Gold). It loads raw **CRM** and **ERP** CSV files, cleans them, and models them as a star schema for reporting.

## Project Overview

- **2 source systems:** CRM and ERP, delivered as CSV files.
- **3 layers:** Bronze (raw), Silver (cleaned), Gold (business-ready).
- **Gold model:** a star schema with 2 dimension tables (`dim_customers`, `dim_products`) and 1 fact table (`fact_sales`).

## Architecture

| Layer  | What it holds | What happens |
|--------|---------------|--------------|
| Bronze | Raw copy of the CRM and ERP CSV files | Loaded with `BULK INSERT`. Minimal transformation. Truncate-and-reload, so runs are repeatable. |
| Silver | Cleaned and standardised data | Deduplication, standardisation, date fixes, and sales validation (see "Cleaning rules"). |
| Gold   | Business-ready star schema | Dimension and fact tables built from the Silver layer. |

## Setup

The four scripts are in the `Data Warehouse PROJECT` folder. Run them in this order in SQL Server Management Studio.

1. `01- Create tables and Schemas.sql`: creates the `data_warehouse` database, the `bronze`, `silver`, and `gold` schemas, and the Bronze and Silver tables.
2. `02-Load raw data (bronze).sql`: loads the CSV files into the Bronze tables with `BULK INSERT`.
3. `03- TRANSFORM TO SILVER.sql`: cleans the Bronze data and inserts it into the Silver tables.
4. `04- Gold_Layer.sql`: creates the Gold tables:
   - `dim_customers`: customer dimension combining CRM, ERP, and location data.
   - `dim_products`: product dimension with category hierarchy (active products only).
   - `fact_sales`: sales fact table with foreign keys to both dimensions.

> Update the script paths and the CSV file paths in step 2 to match your machine.

## Cleaning rules (Silver layer)

- Remove duplicate records, keeping only the latest record per customer ID (`cst_id`).
- Trim and capitalise customer names: `"  jon"` becomes `"Jon"`.
- Standardise gender: `M` and `F` become `Male` and `Female`, anything else becomes `NULL`.
- Standardise marital status: `S` and `M` become `Single` and `Married`, anything else becomes `NULL`.
- Standardise product lines: `S` becomes `Sport`.
- Standardise countries: `DE` becomes `Germany`, and `US` and `USA` become `United States`.
- Replace invalid (`NULL`) product costs with `0` and fix the data type.
- Split the product key: `AC-BC-BC-M005` becomes `cat_id` = `AC_BC` and `prd_key` = `BC-M005`.
- Convert integer dates to valid dates: `20111229` becomes `2011-12-29`.
- Fix missing or inconsistent product end dates so product timelines are clean.
- Validate and recalculate sales values.

## Tech Stack

- **Database:** Microsoft SQL Server
- **Language:** T-SQL
- **Data architecture:** Medallion architecture and star schema
- **Data source:** CRM and ERP CSV datasets

## Author

**Mohamed Elhaysam Omar Selim**: Data Engineering, Data Warehousing, ETL, SQL
[LinkedIn](https://www.linkedin.com/in/mohamed-elhaysam-omar-selim/)
