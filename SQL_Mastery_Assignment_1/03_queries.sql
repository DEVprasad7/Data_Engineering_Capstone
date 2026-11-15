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

-- The Above Query gives us duplicate orders



