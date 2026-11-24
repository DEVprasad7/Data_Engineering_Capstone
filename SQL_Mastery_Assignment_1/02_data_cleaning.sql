USE brazilianecommerce;

SHOW TABLES;

/*
customers
geolocation
order_items
orders
payments
product_category_translation
products
reviews
sellers
*/

-- cleanning data and removing duplicate values from the tables
DESC customers;
/*
customer_id	varchar(50)	NO	PRI		
customer_unique_id	varchar(50)	NO	UNI		
customer_zip_code_prefix	varchar(15)	NO			
customer_city	varchar(100)	NO			
customer_state	varchar(5)	NO			
*/

DESC geolocation;
/*
geolocation_zip_code_prefix	varchar(15)	NO			
geolocation_lat	decimal(8,6)	NO			
geolocation_lng	decimal(9,6)	NO			
geolocation_city	varchar(100)	NO			
geolocation_state	varchar(5)	NO			
*/

DESC order_items;
/*
order_id	varchar(50)	NO	PRI		
order_items_id	varchar(50)	NO	PRI		
product_id	varchar(50)	NO	MUL		
seller_id	varchar(50)	NO	MUL		
shipping_limit_date	datetime	NO			
price	decimal(10,2)	NO			
freight_value	decimal(10,2)	NO			
*/

DESC orders;
/*
order_id	varchar(50)	NO	PRI		
customer_id	varchar(50)	NO	MUL		
order_status	varchar(30)	NO			
order_purchase_timestamp	datetime	YES			
order_approved_at	datetime	YES			
order_delivered_carrier_date	datetime	YES			
order_delivered_customer_date	datetime	YES			
order_estimated_delivery_date	datetime	YES			
*/

DESC payments;
/*
order_id	varchar(50)	NO	PRI		
payment_sequential	int	NO	PRI		
payment_type	varchar(30)	NO			
payment_installments	int	NO			
payment_value	decimal(10,2)	NO			
*/

DESC product_category_translation;
/*
product_category_name	varchar(100)	NO	PRI		
product_category_name_english	varchar(100)	YES			
*/

DESC products;
/*
product_id	varchar(50)	NO	PRI		
product_category	varchar(100)	YES	MUL		
product_name_length	int	YES			
product_description_length	int	YES			
product_photos_qty	int	YES			
product_weight_g	int	YES			
product_length_cm	int	YES			
product_height_cm	int	YES			
product_width_cm	int	YES			
*/

DESC reviews;
/*
review_id	varchar(50)	NO	PRI		
order_id	varchar(50)	NO	PRI		
review_score	int	NO			
review_comment_title	text	YES			
review_comment_message	text	YES			
review_creation_date	datetime	NO			
review_answer_timestamp	datetime	NO			
*/

DESC sellers;
/*
seller_id	varchar(50)	NO	PRI		
seller_zip_code_prefix	varchar(15)	NO			
seller_city	varchar(100)	NO			
seller_state	varchar(5)	NO			
*/

START TRANSACTION;
SET SQL_SAFE_UPDATES = 0; -- Disabled the safe mode because it was not allowing the UPDATE query without where clause might have used a dummy but this one is easy

UPDATE customers
SET
    customer_city = TRIM(customer_city),
    customer_state = UPPER(TRIM(customer_state)),
    customer_zip_code_prefix = TRIM(customer_zip_code_prefix);

UPDATE sellers
SET
    seller_city = TRIM(seller_city),
    seller_state = UPPER(TRIM(seller_state)),
    seller_zip_code_prefix = TRIM(seller_zip_code_prefix);

UPDATE geolocation
SET
    geolocation_city = TRIM(geolocation_city),
    geolocation_state = UPPER(TRIM(geolocation_state)),
    geolocation_zip_code_prefix = TRIM(geolocation_zip_code_prefix);

UPDATE orders
SET order_status = LOWER(TRIM(order_status));

UPDATE payments
SET
    payment_type = LOWER(TRIM(payment_type));

UPDATE product_category_translation
SET
    product_category_name = TRIM(product_category_name),
    product_category_name_english = NULLIF(TRIM(product_category_name_english), '');

UPDATE products
SET product_category = NULLIF(TRIM(product_category), '');

UPDATE reviews
SET
    review_comment_title = NULLIF(TRIM(review_comment_title), ''),
    review_comment_message = NULLIF(TRIM(review_comment_message), '');


-- ROLLBACK; can rollback if anything goes wrong
COMMIT;



SELECT DISTINCT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM geolocation;


SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'geolocation_raw', COUNT(*) FROM geolocation;


SELECT order_status, COUNT(*) AS row_count
FROM orders
GROUP BY order_status
ORDER BY row_count DESC;


SELECT COUNT(*) AS delivered_late
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date > order_estimated_delivery_date;
