

-----------------------------------------------
-- BRONZE LAYER   ---->   Loading the Raw Data
-----------------------------------------------

Create procedure bronze.load_bronze as
Begin
		
		Truncate Table bronze.crm_cust_info
		Bulk Insert bronze.crm_cust_info
		from 'C:\Users\HP\Downloads\devops\week 12\Session 34 Material-20250917\Data Warehouse PROJECT\datasets\source_crm\cust_info.csv'
		with (
		Firstrow=2,
		FIELDTERMINATOR =',',
		Tablock
		);


        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\HP\Downloads\devops\week 12\Session 34 Material-20250917\Data Warehouse PROJECT\datasets\source_crm\prd_info.csv'
        WITH (
	    FIRSTROW = 2,
	    FIELDTERMINATOR = ',',
	    TABLOCK
        );

		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\HP\Downloads\devops\week 12\Session 34 Material-20250917\Data Warehouse PROJECT\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\HP\Downloads\devops\week 12\Session 34 Material-20250917\Data Warehouse PROJECT\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\HP\Downloads\devops\week 12\Session 34 Material-20250917\Data Warehouse PROJECT\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);


		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\HP\Downloads\devops\week 12\Session 34 Material-20250917\Data Warehouse PROJECT\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
END