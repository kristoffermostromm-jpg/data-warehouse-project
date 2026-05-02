/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates the simplified, user-friendly views for the Gold layer.
    These views represent the 'Star Schema' used for analysis and AI tools.
===============================================================================
*/

-- 1. Create Dimension: Products
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    product_id,
    product_key,
    product_name,
    category_id,
    category,
    subcategory,
    maintenance,
    cost,
    product_line,
    start_date
FROM (
    SELECT
        p.prd_id       AS product_id,
        p.prd_key      AS product_key,
        p.prd_nm       AS product_name,
        p.cat_id       AS category_id,
        pc.cat         AS category,
        pc.subcat      AS subcategory,
        pc.maintenance AS maintenance,
        p.prd_cost     AS cost,
        p.prd_line     AS product_line,
        p.prd_start_dt AS start_date,
        ROW_NUMBER() OVER (PARTITION BY p.prd_key ORDER BY p.prd_start_dt DESC) AS flag_last
    FROM silver.crm_prd_info p
    LEFT JOIN silver.erp_px_cat_g1v2 pc ON p.cat_id = pc.id
) t
WHERE flag_last = 1;
GO

-- 2. Create Dimension: Customers
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_key,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    la.cntry                           AS country,
    ci.cst_marital_status              AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
        ELSE COALESCE(ca.gen, 'n/a') 
    END                                AS gender,
    ca.bdate                           AS birthdate,
    ci.cst_create_date                 AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;
GO

-- 3. Create Fact: Sales
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_id   AS product_id,
    cu.customer_id  AS customer_id,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_key
LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
GO
