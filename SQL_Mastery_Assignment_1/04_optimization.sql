-- Optimiazing base table retrievals

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