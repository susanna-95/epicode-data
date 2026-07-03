-- DataCo Supply Chain - Views for Power BI
-- This script creates reporting views used as the final Power BI data source.

USE dataco_supply_chain_v2; 

-- Fact view: order item level
-- This view enriches the fact table with order date and order status information
-- and creates calculated delivery fields for reporting.

CREATE OR REPLACE VIEW vw_fact_order_items AS
SELECT 
    f.order_item_id,

    f.order_id,
    f.order_customer_id AS customer_id,
    f.store_id,
    f.delivery_location_id,
    f.order_item_product_card_id AS product_card_id,

    o.order_date,
    DATE(o.order_date) AS order_date_only,
    o.transaction_type,
    o.order_status,

    f.order_item_quantity,
    f.order_item_product_price,
    f.order_item_discount,
    f.order_item_discount_rate,
    f.order_item_total,
    f.order_item_profit_ratio,

    f.sales,
    f.sales_per_customer,
    f.order_profit_per_order,

    f.shipping_date,
    f.shipping_mode,
    f.scheduled_shipping_days,
    f.actual_shipping_days,
    f.actual_shipping_days - f.scheduled_shipping_days AS shipping_delay_days,

    f.delivery_status,
    f.late_delivery_risk,

    CASE
        WHEN f.late_delivery_risk = 1 THEN 'Yes'
        ELSE 'No'
    END AS late_delivery_risk_label

FROM fact_order_items AS f
LEFT JOIN dim_order AS o
    ON f.order_id = o.order_id;

-- Product view
-- This view combines product information with product category names.
CREATE OR REPLACE VIEW vw_dim_product AS
SELECT 
    p.product_card_id,
    p.product_name,
    p.product_category_id AS category_id,
    c.category_name,
    p.product_price
FROM dim_product AS p
LEFT JOIN dim_category AS c 
    ON p.product_category_id = c.category_id;

-- Customer view
-- This view creates a readable customer name field for reporting.
CREATE OR REPLACE VIEW vw_dim_customer AS
SELECT customer_id,
CONCAT_WS(' ', customer_first_name,customer_last_name) AS customer_name,
customer_segment
FROM dim_customer;

-- Final check: list all created views.
SHOW FULL TABLES 
WHERE Table_type = 'VIEW';