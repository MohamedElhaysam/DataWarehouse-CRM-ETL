# DataWarehouse-CRM-ETL

## 📌 Project Overview
This project is a **Data Warehouse ETL pipeline** built using **SQL Server**.  
It demonstrates the full workflow of loading raw CRM & ERP data (CSV files) into a Data Warehouse using a **multi-layered architecture**:

- **Bronze Layer** → Raw data ingestion (directly from CSVs).  
- **Silver Layer** → Cleaned, standardized, and validated data ready for analysis.  
- **Gold Layer** → Business-level data marts for reporting and analytics.  

The dataset simulates CRM & ERP sources, and the ETL scripts ensure data quality, consistency, and usability.

---

## 🏗️ Architecture
The project follows a **Medallion Architecture** style:

- **Bronze Layer**: Exact copy of the source system (CRM, ERP). Minimal transformations.  
- **Silver Layer**: Data is cleaned (e.g., trimming names, standardizing gender, fixing invalid dates, handling nulls).  
- **Gold Layer**: Planned for aggregations & reporting.

---

## ⚙️ Setup Instructions

### 1. Create the Database and Schemas
Run:
```sql
sql/01- Create tables and Schemas.sql
```
This will:
- Create `data_warehouse` database
- Create schemas: `bronze`, `silver`, `gold`
- Create all bronze & silver tables

---

### 2. Load Raw Data into Bronze
Execute:
```sql
sql/02-Load raw data (bronze).sql
```
This script:
- Uses `BULK INSERT` to load CSV files into bronze tables
- Handles truncation & reload for repeatable runs

---

### 3. Transform and Clean Data into Silver
Run:
```sql
sql/03- TRANSFORM TO SILVER.sql
```
This script performs:
- **Deduplication**
-  Keep only the latest record per cast_id based on date
- **Data Cleaning**:
  - Trim and capitalize customer names
  - Standardize gender: M/F → Male/Female, else NULL
  - Standardize marital status: S/M → Single/Married, else NULL
  - Fix data type and invalid from `prd_cost`
  - Extract `cat_id` and `prd_key` from product key
  - Convert integer-based dates (YYYYMMDD) to valid DATE
  - Fill in missing or inconsistent product end dates to ensure clean timelines.
  - Validate and recalculate sales
- Inserts the cleaned data into the **silver tables**

---

### 4. 
Run:
```sql
sql/04- Gold_Layer.sql
```
This creates
- **business-ready analytics tables**:
  - dim_customers: Customer dimension combining `CRM`, `ERP`, and `location data`
  - dim_products: Product dimension with category hierarchies (active products only)
  - fact_sales: Sales fact table with foreign keys to dimension tables


## 📊 Example Cleaning Rules

- `cst_firstname = "  jon"` → `"Jon"`
- `cst_gndr = "M"` → `"Male"`
- `prd_line = "S"` → `"Sport"`
- Invalid INT (`NULL`) to `0`
- `prd_key = "AC-BC-BC-M005"` → Extracts TO
  - `cat_id` `AC_BC`
  - `prd_key` `BC-M005`
- Convert integer-based date (`20111229`) to valid DATE (`2011-12-29`)
- Standarize countries ex:- `DE` ---> `Germany`, `US,USA` ---> `United States`

---

## 📚 Tech Stack
- **Database**: Microsoft SQL Server
- **Language**: T-SQL
- **Data Architecture**: Medallion Architecture + Star Schema
- **Data Source**: CRM & ERP CSV datasets

---

## 📚 Key Takeaways
- Designed **Data Warehouse** following the **Medallion Architecture** (Bronze → Silver → Gold layers).  
- Built a full **ETL pipeline**.  
- Applied advanced **data cleaning & transformation techniques**:
  - Handling missing values and duplicates  
  - Standardizing inconsistent string formats  
  - Validating and correcting invalid dates    
- Built **business-ready dimension and fact tables** optimized for BI tools and reporting.

---

## 👨‍💻 Author
**Mohamed Elhaysam Omar**  
Data Engineering | Data Warehousing | ETL | SQL | Star Schema

🔗 [LinkedIn](https://www.linkedin.com/in/mohamed-elhaysam-omar-selim/) |



















