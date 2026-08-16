/*
================================================================================
Quality Checks
================================================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
================================================================================
*/
--================================================================================================
--Check for the table bronze.crm_cust_info
--================================================================================================
--Check for nulls and duplicate values in crm_cust_info table cst_id columns
SELECT
cst_id,
COUNT (*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT (*) >1 OR cst_id IS NULL ;

--Check For unwanted spaces in string values
SELECT
cst_firstname,
cst_lastname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) OR cst_lastname != TRIM(cst_lastname);

--Check the consistency of values in low cardinality columns
SELECT DISTINCT cst_gndr , cst_marital_status
FROM bronze.crm_cust_info;

--================================================================================================
--Check for the table bronze.crm_prd_info
--================================================================================================
--Check for nulls and duplicate values in crm_cust_info table cst_id columns
SELECT
prd_id,
COUNT (*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT (*) >1 OR prd_id IS NULL ;
--Check For unwanted spaces in string values
SELECT
prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
--Check for Nulls and negative numbers
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
--Check for data consistancy and standardization
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;
--Check for invalid date orders
SELECT 
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
--================================================================================================
--Check for the table bronze.crm_sales_details
--================================================================================================
--Check for unwanted spaces in crm_sales_details table ord_num columns
SELECT
sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);
--Check for invalid dates
SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101;
--Check data consistancy between sales, quantity, price
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_price <= 0;
--================================================================================================
--Check for the table bronze.erp_CUST_AZ12
--================================================================================================
--Check the cid for usebality
SELECT
cid
FROM bronze.erp_CUST_AZ12
WHERE cid LIKE '%% AW00019902'
--Check for out of range dates
SELECT DISTINCT
bdate
FROM bronze.erp_CUST_AZ12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
--Check for data consistancy and standardization
SELECT DISTINCT gender
FROM bronze.erp_CUST_AZ12;
--================================================================================================
--Check for the table bronze.erp_LOC_A101
--================================================================================================
--Check for data consistancy and standardization
SELECT DISTINCT cntry
FROM bronze.erp_LOC_A101;
--================================================================================================
--Check for the table bronze.erp_LOC_A101
--================================================================================================
--Check For unwanted spaces in string values
SELECT
cat,
subcat,
maintenance
FROM bronze.erp_PX_CAT_G1V2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);
