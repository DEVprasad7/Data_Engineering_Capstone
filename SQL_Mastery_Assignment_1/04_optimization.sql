-- Optimiazing base table retrievals
USE brazilianecommerce;
SELECT * FROM customers;
/*
'-> Table scan on customers  (cost=9743 rows=94627) (actual time=0.0967..21.6 rows=96096 loops=1)'
*/
EXPLAIN ANALYZE SELECT * FROM customers;

CREATE INDEX c_id_idex
ON customers(customer_id);
/*
'-> Table scan on customers  (cost=9743 rows=94627) (actual time=0.0606..19.2 rows=96096 loops=1)'
*/
EXPLAIN ANALYZE SELECT * FROM customers;




-- Creating composite indexes for multiple columns

SELECT * FROM orders;
/*
'-> Table scan on orders  (cost=9234 rows=89232) (actual time=0.141..32.3 rows=96096 loops=1)'
*/
EXPLAIN ANALYZE SELECT * FROM orders;

CREATE INDEX com_idx_ord
ON orders(order_id, customer_id);
/*
'-> Table scan on orders  (cost=9234 rows=89232) (actual time=0.108..27.3 rows=96096 loops=1)'
*/
EXPLAIN ANALYZE SELECT * FROM orders;

SELECT * FROM order_items;
/*
'-> Table scan on order_items  (cost=10927 rows=106620) (actual time=0.0701..30.3 rows=107037 loops=1)'
*/
EXPLAIN ANALYZE SELECT * FROM order_items;

CREATE INDEX com_idx_oi
ON order_items(order_id, product_id, seller_id);

/*
'-> Table scan on order_items  (cost=10927 rows=106620) (actual time=0.0589..23.9 rows=107037 loops=1)'
*/
EXPLAIN ANALYZE SELECT * FROM order_items;



-- Optimizing Fillter queries

EXPLAIN ANALYZE SELECT
    a.product_id AS product_1,
    b.product_id AS product_2,
    COUNT(DISTINCT a.order_id) AS times_bought_together
FROM order_items a
JOIN order_items b
    ON a.order_id = b.order_id
    AND a.product_id < b.product_id
GROUP BY
    a.product_id,
    b.product_id
HAVING COUNT(DISTINCT a.order_id) >= 5
ORDER BY times_bought_together DESC
LIMIT 20;

/*Before indexing result -> Limit: 20 row(s)  (actual time=605..605 rows=20 loops=1)
     -> Sort: times_bought_together DESC  (actual time=605..605 rows=20 loops=1)
         -> Filter: (`count(distinct order_items.order_id)` >= 5)  (actual time=598..605 rows=21 loops=1)
          ...*/
          
CREATE INDEX com_idx_oi
ON order_items(order_id, product_id, seller_id);

/*
After results -> Limit: 20 row(s)  (actual time=521..521 rows=20 loops=1)
     -> Sort: times_bought_together DESC  (actual time=521..521 rows=20 loops=1)
         -> Filter: (`count(distinct order_items.order_id)` >= 5)  (actual time=513..521 rows=21 loops=1)
          ...
*/


EXPLAIN ANALYZE SELECT
    YEAR(o.order_purchase_timestamp) AS sales_year,
    MONTH(o.order_purchase_timestamp) AS sales_month,
    COALESCE(p.product_category, 'Uncategorized') AS category,
    SUM(oi.price) AS total_revenue,
    SUM(oi.freight_value) AS total_freight,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp),
    p.product_category
WITH ROLLUP;

/*
Before indexing and optimiazation -> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=1584..1584 rows=1272 loops=1)
     -> Temporary table  (cost=0..0 rows=0) (actual time=1584..1584 rows=1272 loops=1)
         -> Group aggregate with rollup: sum(order_items.price), sum(orde...
*/

SELECT * FROM products;

CREATE INDEX p_idx ON products(product_id, product_category);


EXPLAIN ANALYZE SELECT
    YEAR(o.order_purchase_timestamp) AS sales_year,
    MONTH(o.order_purchase_timestamp) AS sales_month,
    COALESCE(p.product_category, 'Uncategorized') AS category,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp),
    p.product_category
WITH ROLLUP;

/*
After optimiazation and indexes -> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=1065..1066 rows=1272 loops=1)
     -> Temporary table  (cost=0..0 rows=0) (actual time=1065..1065 rows=1272 loops=1)
         -> Group aggregate with rollup: sum(tmp_field), count(distinct o...
*/


