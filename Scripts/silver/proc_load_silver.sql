/*
================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
================================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
================================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY

		SET @batch_start_time = GETDATE();
		PRINT '= = = = = = = = = = = = = = = = = = = = = = = = = = = = ='
		PRINT '= = = = = = = = = = = = = = = = = = = = = = = = = = = = ='
		PRINT 'Load Silver Layer'
		PRINT '= = = = = = = = = = = = = = = = = = = = = = = = = = = = ='
		PRINT '- - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
		PRINT 'Loading CRM tables';
		PRINT '- - - - - - - - - - - - - - - - - - - - - - - - - - - - -'

		SET @start_time = GETDATE();

		PRINT '>> Truncating table silver.crm_cust_info';

		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			cst_gndr,
			cst_create_date
		)
			SELECT
				COALESCE(cst_id, 0) AS cst_id, --Replacing NULL values in cst_id with 0
				cst_key,
				TRIM (cst_firstname) AS cst_firstname, --Removing the leading and trailing spaces from the cst_firstname column
				TRIM (cst_lastname) AS cst_lastname, --Removing the leading and trailing spaces from the cst_lastname column
				CASE WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married' --Standardizing the material status
					 WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
					 ELSE 'n/a'
				END AS cst_material_status,
				CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' --Standardizing the gender
					WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
					ELSE 'n/a'
				END AS cst_gndr,
				cst_create_date
				FROM (
					SELECT
						*,
						ROW_NUMBER () OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
					FROM bronze.crm_cust_info)t 
			WHERE flag_last = 1; --Unique values based on cst_id and the latest cst_create_date
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';

		SET @start_time = GETDATE();

		PRINT '>>Trancating table silver.crm_prd_info';

		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>>Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
			SELECT
				prd_id,
				REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, --Break the prd_key column and replace '-' with '_'
				SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
				prd_nm,
				COALESCE(prd_cost,0) AS prd_cost, --Replace null values in prd_cost with 0
				CASE UPPER(TRIM(prd_line)) --Standardize the prd_line values
					WHEN 'M' THEN 'Mountain'
					WHEN 'R' THEN 'Road'
					WHEN 'T' THEN 'Touring'
					WHEN 'S' THEN 'Other Sales'
					ELSE 'n/a'
				END AS prd_line,
				CAST(prd_start_dt AS DATE) AS prd_start_dt, --Convert prd_start_dt to date format
				CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt --Calculate prd_end_dt as the day before the next prd_start_dt for the same prd_key
			FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';

		SET @start_time = GETDATE();

		PRINT '>> Truncating table:silver.crm_sales_details';

		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Insert Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cst_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
			SELECT
				sls_ord_num,
				sls_prd_key,
				sls_cst_id,
				CASE WHEN sls_order_dt = 0 OR LEN (sls_order_dt) != 8 THEN NULL --Change the datatype and clean the data
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
				END AS sls_order_dt,
				CASE WHEN sls_ship_dt = 0 OR LEN (sls_ship_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
				END AS sls_ship_dt,
				CASE WHEN sls_due_dt = 0 OR LEN (sls_due_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
				END AS sls_due_dt,
				CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) --Re calculating the values and cleaning the data
					THEN sls_quantity * ABS(sls_price)
					ELSE sls_sales
				END AS sls_sales,
				sls_quantity,
				CASE WHEN sls_price IS NULL OR sls_price <= 0
					THEN sls_sales / NULLIF(sls_quantity,0)
					ELSE sls_price
				END AS sls_price
			FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';

		PRINT '- - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
		PRINT 'Loading ERP tables';
		PRINT '- - - - - - - - - - - - - - - - - - - - - - - - - - - - -'

		SET @start_time = GETDATE();

		PRINT '>>Truncating table silver.erp_CUST_AZ12';

		TRUNCATE TABLE silver.erp_CUST_AZ12;
		PRINT '>>Insert Data Into: silver.erp_CUST_AZ12';
		INSERT INTO silver.erp_CUST_AZ12 (
			cid,
			bdate,
			gender
		)
			SELECT
				CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING (cid,4,LEN(cid)) --Remove the NAS pefix if present
					ELSE cid
				END AS cid,
				CASE WHEN bdate > GETDATE() THEN NULL --Set future Dates to NULL
					ELSE bdate
				END AS bdate,
				CASE WHEN UPPER(TRIM(gender)) IN ('F','FEMALE') THEN 'Female' --Normalize the gender value and handle the unknown value
					WHEN UPPER(TRIM(gender)) IN ('M','MALE') THEN 'Male'
					ELSE 'n/a'
				END AS gender
			FROM bronze.erp_CUST_AZ12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';

		SET @start_time = GETDATE();

		PRINT '>>Truncating table silver.erp_LOC_A101';

		TRUNCATE TABLE silver.erp_LOC_A101;
		PRINT '>>Inserting Data Into:silver.erp_LOC_A101'
		INSERT INTO silver.erp_LOC_A101 (
			cid,
			cntry
		)
			SELECT
				REPLACE (cid, '-','') AS cid, --Replacing the '-' for better readability
				CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany' --Normalize and Handle the missing or blank
					WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
					WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
					ELSE TRIM(cntry)
				END cntry
			FROM bronze.erp_LOC_A101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';

		SET @start_time = GETDATE();

		PRINT '>>Truncating table silver.erp_PX_CAT_G1V2';

		TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
		PRINT '>>Inserting Data Into: silver.erp_PX_CAT_G1V2';
		INSERT INTO silver.erp_PX_CAT_G1V2 (
			id,
			cat,
			subcat,
			maintenance
		)
			SELECT
				id,
				cat,
				subcat,
				maintenance
			FROM bronze.erp_PX_CAT_G1V2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';

		SET @batch_end_time = GETDATE();
		
		PRINT '= = = = = = = = = = = = = = = = = = = = = = = = = = = = ='
		PRINT 'Loading Silver Layer is complete'
		PRINT '>> Batch Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10)) + ' seconds';
		PRINT '= = = = = = = = = = = = = = = = = = = = = = = = = = = = ='
	
	END TRY
	BEGIN CATCH
		PRINT '= = = = = = = = = = = = = = = = = = = = = = = = = = = = ='
		PRINT 'Error occurred while loading Bronze Layer'
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
		PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(10));
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(10));
		PRINT'= = = = = = = = = = = = = = = = = = = = = = = = = = = = ='
	END CATCH
END
