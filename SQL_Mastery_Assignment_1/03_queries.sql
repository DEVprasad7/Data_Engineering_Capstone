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
