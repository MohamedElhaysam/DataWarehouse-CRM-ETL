Project Overview
This project is a Data Warehouse ETL pipeline built using SQL Server.
It demonstrates the full workflow of loading raw CRM & ERP data (CSV files) into a Data Warehouse using a multi-layered architecture:

Bronze Layer → Raw data ingestion (directly from CSVs).
Silver Layer → Cleaned, standardized, and validated data ready for analysis.
(Future: Gold Layer) → Business-level data marts for reporting and analytics.
The dataset simulates CRM & ERP sources and the ETL scripts ensure data quality, consistency, and usability.

🏗️ Architecture
The project follows a Medallion Architecture style:

Datasets (CSV) → Bronze Layer → Silver Layer → (Gold Layer)
Bronze Layer: Exact copy of the source system (CRM, ERP). Minimal transformations.
Silver Layer: Data is cleaned (e.g., trimming names, standardizing gender, fixing invalid dates, handling nulls).
Gold Layer: Not yet implemented, but planned for aggregations & reporting.
📂 Repository Structure
DataWarehouse-CRM-ETL/
│
├── datasets/                  # Raw CSV files (bronze input)
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── sql/                       # SQL Scripts
│   ├── 01_create_schemas_and_tables.sql   # Create DB + bronze & silver schemas and tables
│   ├── 02_load_bronze.sql                 # Stored procedure to bulk insert CSV data into bronze
│   ├── 03_transform_to_silver.sql         # Data cleaning & transformations into silver
│
└── README.md
⚙️ Setup Instructions
1. Create the Database and Schemas
Run the script:

sql/01_create_schemas_and_tables.sql
This will:

Create datawarehouse database
Create schemas: bronze, silver, gold
Create all bronze & silver tables
2. Load Raw Data into Bronze
Execute:

sql/02_load_bronze.sql
This script:

Uses BULK INSERT to load CSV files into bronze tables
Handles truncation & reload for repeatable runs
3. Transform and Clean Data into Silver
Run:

sql/03_transform_to_silver.sql
This script performs:

Deduplication (e.g., keep latest cst_id record by date)
Data Cleaning:
Trim and capitalize customer names
Standardize gender (M/F → Male/Female, else Unknown)
Standardize marital status (S/M → Single/Married)
Fix invalid product end_date
Extract Color, Size, and Product Level from product names
Convert integer-based dates (YYYYMMDD) to valid DATE
Standardize countries (e.g., US/USA → United States)
Inserts the cleaned data into silver tables
📊 Example Cleaning Rules
cst_firstname = "  john" → "John"
cst_gndr = "M" → "Male"
prd_line = "R" → "Road"
prd_nm = "HL-U509-XL Black" → Extracts:
Color: "Black"
Size: "XL"
Product Level: "High-Level"
Invalid dates (0 or wrong format) → NULL in silver
Countries:
"US", "USA", "United States" → "United States"
🚀 Future Improvements
Implement Gold Layer for reporting (aggregated KPIs, dashboards).
Add Data Quality Reports (invalid records count, missing values).
Build a simple Power BI / Tableau dashboard on top of the silver layer.
Automate the pipeline using SQL Server Agent or Airflow.
📚 Tech Stack
Database: SQL Server
Language: T-SQL (Stored Procedures, DDL, DML)
Data Source: Simulated CRM & ERP CSV datasets
✨ Key Learnings
How to design a Data Warehouse with Medallion Architecture
Applying ETL best practices (Bronze → Silver → Gold)
Handling dirty data (invalid dates, inconsistent strings, duplicates)
Using SQL Server bulk insert for efficient ingestion
👨‍💻 Author
Yossef Abdelkarem
Data Engineering Enthusiast | SQL | Python | ETL | Data Warehousing
