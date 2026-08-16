/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/
--===============================================================================
--Create Dimension: gold.dim_customers
--===============================================================================

IF OBJECT_ID ('gold.dim_customers','v') IS NOT NULL
  DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (Order BY cst_id) AS customer_key, --Creating surrogate key
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the master for gender information
		ELSE COALESCE(ca.gender,'n/a')
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_CUST_AZ12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_LOC_A101 AS la
ON ci.cst_key = la.cid;

GO
  
--===============================================================================
--Create Dimension: gold.dim_products
--===============================================================================

IF OBJECT_ID ('gold.dim_products','v') IS NOT NULL
  DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,--Create surrogate key
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	CASE WHEN cat IS NULL THEN 'n/a'
		ELSE pc.cat
	END AS category,
	CASE WHEN subcat IS NULL THEN 'n/a'
		ELSE pc.subcat
	END AS subcategory,
	CASE WHEN maintenance IS NULL THEN 'n/a'
		ELSE pc.maintenance
	END AS maintenance,
	pn.prd_cost AS product_cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_PX_CAT_G1V2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL; --Filter out historical data

GO

--===============================================================================
--Create Fact Table: gold.fact_sales
--===============================================================================

IF OBJECT_ID ('gold.fact_sales','v') IS NOT NULL
  DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cst_id = cu.customer_id;

GO
