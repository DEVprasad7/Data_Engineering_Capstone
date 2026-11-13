USE brazilianecommerce;

SHOW TABLES;

-- cleanning data and removing duplicate values from the tables
DESC customers;
DESC geolocation;
DESC order_items;
DESC orders;

SELECT * 
FROM orders
WHERE (
	order_purchase_timestamp IS NULL
    OR
    order_approved_at IS NULL
    OR
    order_delivered_carrier_date IS NULL
    OR
    order_delivered_customer_date IS NULL
    OR
    order_estimated_delivery_date IS NULL
); -- no null values

DESC orders;

