USE brazilianecommerce;

-- Queries Mentioned from the assignment

SHOW TABLES;

SELECT * FROM orders;

SELECT DISTINCT order_status
FROM orders;

/*
UNIQUE order_status (
approved, canceled, created, delivered, invoiced, processing, shipped, unavailable
)
*/

SELECT *
FROM orders
WHERE order_status IN ('unavailable', 'canceled');

SELECT COUNT(*)
FROM orders
WHERE order_status IN ('unavailable', 'canceled');

# Total 1158 unavailable or canceled orders

SELECT 
	p.order_id, 
    oi.product_id, 
    oi.seller_id, 
    p.payment_value, 
    oi.price, 
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_amount
FROM payments p
JOIN order_items oi
ON p.order_id = oi.order_id;


SELECT 
	DISTINCT oi.order_id,
    SUM(p.payment_value) AS payment_price,
    SUM(oi.price + oi.freight_value) AS order_price
FROM payments p
JOIN order_items oi
ON p.order_id = oi.order_id
GROUP BY oi.order_id
HAVING payment_price != order_price;

-- The Above Query gives us duplicate order_id's


-- Detect potential fraud where payment value differs from order total. 
SELECT * FROM customers;
SELECT * FROM orders;

SELECT *
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_status ='unavailable';


SELECT
	oi.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    oi.price,
    oi.freight_value,
    p.payment_value
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN payments p
ON p.order_id = oi.order_id
WHERE p.payment_value != (oi.price + oi.freight_value);


WITH total_revenue AS (SELECT
	oi.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    SUM(oi.price + oi.freight_value) AS total_price
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY oi.order_id)
SELECT 
	t.order_id,
    t.total_price,
    SUM(p.payment_value) AS paid_amount
FROM total_revenue t
JOIN payments p
ON t.order_id = p.order_id
GROUP BY t.order_id
HAVING total_price != paid_amount;

-- The above query return the potential fraud orders where total amount is different then payment amount



-- Calculate monthly revenue with Month-over-Month growth percentage. 
SELECT * FROM orders;
SELECT * FROM payments;

WITH monthly_revenue_table AS (SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS payment_date,
    SUM(p.payment_value) AS monthly_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY payment_date)
SELECT 
	payment_date,
    monthly_revenue AS current_month_revenue,
    LAG(monthly_revenue, 1) OVER(ORDER BY payment_date) AS previous_month_revenue,
    CONCAT(ROUND(
		(monthly_revenue - (LAG(monthly_revenue, 1) OVER(ORDER BY payment_date)))
        / (LAG(monthly_revenue, 1) OVER(ORDER BY payment_date)) * 100
    , 2), '%') AS mom
FROM monthly_revenue_table
ORDER BY payment_date;


-- Find top 10 products by revenue in each category
SHOW TABLES;
SELECT * FROM products;
SELECT * FROM product_category_translation;
SELECT * FROM order_items;

SELECT
	oi.order_id,
	p.product_id,
    pc.product_category_name_english,
    oi.price
FROM products p
JOIN product_category_translation pc
ON p.product_category = pc.product_category_name
JOIN order_items oi
ON oi.product_id = p.product_id
ORDER BY oi.price DESC LIMIT 10;

-- Calculate Customer Lifetime Value (CLV) and categorize customers.
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items;

SELECT
    c.customer_id,
    c.customer_city,
    o.order_id,
    SUM(oi.price) AS total_purchase,
    CASE
        WHEN SUM(oi.price) >= 5000 THEN 'High Value'
        WHEN SUM(oi.price) >= 2000 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_purchasing_category
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY 
    c.customer_id, 
    c.customer_city, 
    o.order_id
ORDER BY total_purchase DESC;

-- Find customers who bought electronics but never books
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM product_category_translation ORDER BY product_category_name_english;

WITH customer_purchase AS (SELECT
    o.order_id,
    o.customer_id,
    oi.product_id,
    pc.product_category_name_english
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
JOIN products p
ON p.product_id = oi.product_id
JOIN product_category_translation pc
ON p.product_category = pc.product_category_name)

SELECT
	customer_id,
    order_id,
    COUNT(order_id) AS Total_orders_made
FROM customer_purchase
GROUP BY order_id;

-- Find customers spending above their state's average.
SELECT * FROM customers;
SELECT * FROM order_items;
SELECT * FROM orders;

SELECT 
    customer_id,
    customer_state,
    total_spend,
    avg_state_spend
FROM (
    -- Subquery: Calculates total spend per customer and the state average in one go
    SELECT 
        c.customer_id,
        c.customer_state,
        SUM(oi.price + oi.freight_value) AS total_spend,
        AVG(SUM(oi.price + oi.freight_value)) OVER (PARTITION BY c.customer_state) AS avg_state_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_state
) AS sub
WHERE total_spend >= avg_state_spend;

-- Get the 2nd highest revenue-generating product in each category

SELECT 
    product_id,
    product_category_name_english,
    total_product_revenue,
    category_ranking
FROM (
    SELECT 
        p.product_id,
        pc.product_category_name_english,
        SUM(oi.price + oi.freight_value) AS total_product_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY pc.product_category_name_english 
            ORDER BY SUM(oi.price + oi.freight_value) DESC
        ) AS category_ranking
    FROM products p
    JOIN product_category_translation pc ON p.product_category = pc.product_category_name
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.product_id, pc.product_category_name_english
) AS ranked_products
WHERE category_ranking = 2;

-- Calculate a 7-day moving average of daily order count.

WITH daily_orders AS (
SELECT 
	CAST(order_purchase_timestamp AS DATE) AS order_date,
	COUNT(order_id) AS order_count
FROM orders
GROUP BY order_date
ORDER BY order_date
)
SELECT 
    order_date,
    order_count,
    AVG(order_count * 1.0) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day
FROM daily_orders
ORDER BY order_date;

-- Rank sellers by revenue within each state.
SELECT * FROM order_items;
SELECT * FROM sellers;

SELECT
	*
FROM order_items oi
JOIN sellers s
ON oi.seller_id = s.seller_id;


