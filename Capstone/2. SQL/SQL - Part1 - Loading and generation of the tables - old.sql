-- DataCo Supply Chain - SQL data model creation
-- This script creates the database, loads the cleaned dataset into a staging table,
-- and generates the dimension and fact tables used for Power BI reporting.

DROP DATABASE IF EXISTS dataco_supply_chain_v2;
CREATE DATABASE IF NOT EXISTS dataco_supply_chain_v2
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE dataco_supply_chain_v2; 

DROP TABLE IF EXISTS fact_order_items;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_delivery_location;
DROP TABLE IF EXISTS dim_order;

-- 1. CREATE STAGING TABLE
-- This table stores the cleaned CSV exported from Python before creating the final data model.

CREATE TABLE dataco_cleaned_final_2 (
    customer_id INT,
    customer_segment VARCHAR(50),
    customer_first_name VARCHAR(100),
    customer_last_name VARCHAR(100),

    order_id INT,
    order_customer_id INT,
    order_date DATETIME,
    transaction_type VARCHAR(50),
    order_status VARCHAR(50),

    delivery_city VARCHAR(100),
    delivery_state VARCHAR(100),
    delivery_region VARCHAR(100),
    delivery_country VARCHAR(100),
    delivery_market VARCHAR(100),

    store_department_id INT,
    store_department_name VARCHAR(100),
    store_zipcode VARCHAR(20),
    store_city VARCHAR(100),
    store_state VARCHAR(100),
    store_country VARCHAR(100),
    store_latitude DECIMAL(10,6),
    store_longitude DECIMAL(10,6),

    product_card_id INT,
    product_name VARCHAR(255),
    product_category_id INT,
    product_price DECIMAL(12,2),

    category_id INT,
    category_name VARCHAR(100),

    order_item_id INT,
    order_item_quantity INT,
    order_item_product_price DECIMAL(12,2),
    order_item_discount DECIMAL(12,2),
    order_item_discount_rate DECIMAL(10,4),
    order_item_total DECIMAL(12,2),
    order_item_profit_ratio DECIMAL(10,4),
    order_item_product_card_id INT,

    sales DECIMAL(12,2),
    sales_per_customer DECIMAL(12,2),
    profit_per_order DECIMAL(12,2),
    order_profit_per_order DECIMAL(12,2),

    shipping_date DATETIME,
    shipping_mode VARCHAR(100),
    scheduled_shipping_days INT,
    actual_shipping_days INT,
    delivery_status VARCHAR(100),
    late_delivery_risk INT
);

-- 2. LOAD CLEANED CSV DATA INTO THE STAGING TABLE
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dataco_cleaned_final.csv'
INTO TABLE dataco_cleaned_final_2
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. VALIDATE STAGING TABLE ROW COUNT
-- Check that the number of rows and unique order items matches the cleaned dataset.
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_item_id) AS unique_order_items
FROM dataco_cleaned_final_2;

-- Result: 180,519 rows and 180,519 unique order_item_id values.
-- This confirms that order_item_id is unique and the staging import is consistent.

-- 4. CREATE DIMENSION AND FACT TABLES
-- The original flat table is split into a star-schema model for Power BI.

-- Dimension table: product categories
CREATE TABLE dim_category (
	category_id INT NOT NULL PRIMARY KEY,
    category_name VARCHAR(100));

INSERT INTO dim_category (
	category_id,
    category_name
)
SELECT DISTINCT
	category_id,
    category_name
FROM dataco_cleaned_final_2;

-- Dimension table: products
CREATE TABLE dim_product (
	product_card_id INT NOT NULL PRIMARY KEY,
    product_name VARCHAR(255),
    product_category_id INT,
    product_price DECIMAL(12,2),
    CONSTRAINT FK_dimproduct_categoryID FOREIGN KEY(product_category_id) REFERENCES dim_category(category_id));
    
INSERT INTO dim_product (
	product_card_id,
    product_name,
    product_category_id,
    product_price
)
SELECT DISTINCT
	product_card_id,
	product_name,
    product_category_id,
	product_price
FROM dataco_cleaned_final_2;

-- Dimension table: customers
CREATE TABLE dim_customer (
customer_id INT NOT NULL PRIMARY KEY,
customer_first_name VARCHAR(100),
customer_last_name VARCHAR(100),
customer_segment VARCHAR(50));

INSERT INTO dim_customer (
customer_id,
customer_first_name,
customer_last_name,
customer_segment)
SELECT DISTINCT
customer_id,
customer_first_name,
customer_last_name,
customer_segment
FROM dataco_cleaned_final_2;

-- Dimension table: stores
CREATE TABLE dim_store (
store_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
store_department_id INT,
store_department_name VARCHAR(100),
store_zipcode VARCHAR(20),
store_city VARCHAR(100),
store_state VARCHAR(100),
store_country VARCHAR(100),
store_latitude DECIMAL(10,6),
store_longitude DECIMAL(10,6)
);

INSERT INTO dim_store (
store_department_id,
store_department_name,
store_zipcode,
store_city,
store_state,
store_country,
store_latitude,
store_longitude)
SELECT DISTINCT 
store_department_id,
store_department_name,
store_zipcode,
store_city,
store_state,
store_country,
store_latitude,
store_longitude
FROM dataco_cleaned_final_2;

-- Dimension table: delivery locations
CREATE TABLE dim_delivery_location (
delivery_location_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
delivery_city VARCHAR(100),
delivery_state VARCHAR(100),
delivery_region VARCHAR(100),
delivery_country VARCHAR(100),
delivery_market VARCHAR(20));

INSERT INTO dim_delivery_location (
delivery_city,
delivery_state,
delivery_region,
delivery_country,
delivery_market
)
SELECT DISTINCT 
delivery_city,
delivery_state,
delivery_region,
delivery_country,
delivery_market
FROM dataco_cleaned_final_2;

-- Dimension table: orders
CREATE TABLE dim_order (
order_id INT NOT NULL PRIMARY KEY,
order_date DATETIME,
transaction_type VARCHAR(20),
order_status VARCHAR(20));

INSERT INTO dim_order (
order_id,
order_date,
transaction_type,
order_status
)
SELECT DISTINCT 
order_id,
order_date,
transaction_type,
order_status
FROM dataco_cleaned_final_2;

-- Fact table: order items
-- The fact table keeps the original order item level granularity.
CREATE TABLE fact_order_items (
order_item_id INT NOT NULL PRIMARY KEY,
order_id INT NOT NULL,
order_customer_id INT NOT NULL,
store_id INT NOT NULL,
delivery_location_id INT NOT NULL,
order_item_product_card_id INT NOT NULL,
order_item_quantity INT,
order_item_product_price DECIMAL(12,2),
order_item_discount DECIMAL(12,2),
order_item_discount_rate DECIMAL(10,4),
order_item_total DECIMAL(12,2),
order_item_profit_ratio DECIMAL(10,4),
sales DECIMAL(12,2),
sales_per_customer DECIMAL(12,2),
order_profit_per_order DECIMAL(12,2),
shipping_date DATETIME,
shipping_mode VARCHAR(100),
scheduled_shipping_days INT,
actual_shipping_days INT,
delivery_status VARCHAR(100),
late_delivery_risk INT,

CONSTRAINT fk_fact_order
        FOREIGN KEY (order_id) REFERENCES dim_order(order_id),

    CONSTRAINT fk_fact_customer
        FOREIGN KEY (order_customer_id) REFERENCES dim_customer(customer_id),

    CONSTRAINT fk_fact_store
        FOREIGN KEY (store_id) REFERENCES dim_store(store_id),

    CONSTRAINT fk_fact_delivery
        FOREIGN KEY (delivery_location_id) REFERENCES dim_delivery_location(delivery_location_id),

    CONSTRAINT fk_fact_product
        FOREIGN KEY (order_item_product_card_id) REFERENCES dim_product(product_card_id)
);

-- Populate the fact table by joining the staging table with store and delivery dimensions
-- in order to retrieve the generated surrogate keys.
INSERT INTO fact_order_items (
order_item_id,
order_id,
order_customer_id,
store_id,
delivery_location_id,
order_item_product_card_id,
order_item_quantity,
order_item_product_price,
order_item_discount,
order_item_discount_rate,
order_item_total,
order_item_profit_ratio,
sales,
sales_per_customer,
order_profit_per_order,
shipping_date,
shipping_mode,
scheduled_shipping_days,
actual_shipping_days,
delivery_status,
late_delivery_risk)
SELECT 
d.order_item_id,
d.order_id,
d.order_customer_id,
ds.store_id,
dl.delivery_location_id,
d.order_item_product_card_id,
d.order_item_quantity,
d.order_item_product_price,
d.order_item_discount,
d.order_item_discount_rate,
d.order_item_total,
d.order_item_profit_ratio,
d.sales,
d.sales_per_customer,
d.order_profit_per_order,
d.shipping_date,
d.shipping_mode,
d.scheduled_shipping_days,
d.actual_shipping_days,
d.delivery_status,
d.late_delivery_risk
FROM dataco_cleaned_final_2 AS d
JOIN dim_store AS ds ON d.store_department_id = ds.store_department_id
	AND d.store_department_name = ds.store_department_name
	AND d.store_zipcode = ds.store_zipcode
	AND d.store_city = ds.store_city
	AND d.store_state = ds.store_state
	AND d.store_country = ds.store_country
	AND d.store_latitude = ds.store_latitude
	AND d.store_longitude = ds.store_longitude
JOIN dim_delivery_location dl
    ON d.delivery_city = dl.delivery_city
    AND d.delivery_state = dl.delivery_state
    AND d.delivery_region = dl.delivery_region
    AND d.delivery_country = dl.delivery_country
    AND d.delivery_market = dl.delivery_market;

-- 5. FINAL VALIDATION CHECKS
-- Check row counts for all final tables and validate the fact table granularity.
SELECT 
    'dim_product' AS table_name, COUNT(*) AS total_rows
FROM dim_product 
UNION ALL 
SELECT 
    'dim_category', COUNT(*)
FROM dim_category 
UNION ALL 
SELECT 
    'dim_customer', COUNT(*)
FROM dim_customer 
UNION ALL 
SELECT 
    'dim_store', COUNT(*)
FROM dim_store 
UNION ALL 
SELECT 
    'dim_delivery_location', COUNT(*)
FROM dim_delivery_location
UNION ALL
SELECT 
    'dim_order', COUNT(*)
FROM dim_order
UNION ALL 
SELECT 
    'fact_order_items', COUNT(*) 
FROM fact_order_items;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_item_id) AS unique_order_items
FROM fact_order_items;

-- The fact table should return 180,519 rows and 180,519 unique order_item_id values.
-- This confirms that no rows were lost during the dimensional modeling process.