SHOW DATABASES;

CREATE DATABASE BrazilianEcommerce;

SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL local_infile = 1;
SET autocommit = 0;
USE brazilianecommerce;

SHOW TABLES;

-- CREATING PARENT TABLES AND DEFINING RELATIONSHIPS
CREATE TABLE customers (
	customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) UNIQUE NOT NULL,
    customer_zip_code_prefix VARCHAR(15) NOT NULL, #Assigning CHAR length to 15 safer side
    customer_city VARCHAR(100) NOT NULL,
    customer_state VARCHAR(5) NOT NULL
);

DESC customers;
SHOW CREATE TABLE customers;

CREATE TABLE geolocation (
	geolocation_zip_code_prefix VARCHAR(15) NOT NULL,
    geolocation_lat DECIMAL(8, 6) NOT NULL,
    geolocation_lng DECIMAL(9, 6) NOT NULL,
    geolocation_city VARCHAR(100) NOT NULL,
    geolocation_state VARCHAR(5) NOT NULL
);

DESC geolocation;

CREATE TABLE sellers (
	seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(15) NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state VARCHAR(5) NOT NULL
);

DESC sellers;
CREATE TABLE product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);


CREATE TABLE products (
	product_id VARCHAR(50) PRIMARY KEY,
    product_category VARCHAR(100),
    product_name_length INT, #Wrong spelling in CSV
    product_description_length INT, #Wrong spelling in CSV
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    
    CONSTRAINT fk_p_category
		FOREIGN KEY (product_category)
        REFERENCES product_category_translation(product_category_name)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

DESC products;

-- Creating Remaining tables

CREATE TABLE orders (
	order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    
    CONSTRAINT fk_cust_id
		FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

DESC orders;

SHOW CREATE TABLE orders;

SHOW TABLES;

CREATE TABLE order_items (
	order_id VARCHAR(50) NOT NULL,
    order_items_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    
    PRIMARY KEY (order_id, order_items_id),
    CONSTRAINT fk_p_id
		FOREIGN KEY (product_id)
        REFERENCES products(product_id),
	
    CONSTRAINT fk_o_id
		FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
        
	CONSTRAINT fk_s_id
		FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
);


DESC order_items;
SHOW TABLES;


CREATE TABLE payments (
	order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL,
    
    PRIMARY KEY (order_id, payment_sequential),
    
    CONSTRAINT fk_o_p_id
		FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


DESC payments;

CREATE TABLE reviews (
	review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    
    review_score INT NOT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME NOT NULL,
    review_answer_timestamp DATETIME NOT NULL,
    
    PRIMARY KEY (review_id, order_id),
    
    CONSTRAINT fk_o_r_id
		FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
        
	CONSTRAINT chk_rev_sc
		CHECK (review_score BETWEEN 1 AND 5)
);

DESC reviews;

SHOW TABLES;


-- INSERTING DATA INTO THE

SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE  'autocommit';
SET GLOBAL local_infile = 1;
SET autocommit = 0; -- Turning off autocommit so that i can verify the transactions before commiting the changes
USE brazilianecommerce;

-- started transaction for customers data insertion.
START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/olist_customers_dataset.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
);
SHOW WARNINGS; -- This showed warning after loading the data showed that there were duplicate entries so the duplicates were never inserted into the table.
SELECT * FROM customers; -- Total 96096 rows were added.

COMMIT;

-- started transaction for sellers data insertion.
DESC sellers;
START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/olist_sellers_dataset.csv'
INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
);

SHOW WARNINGS; -- no warnings so no duplicates or any issues
COMMIT;

SELECT * FROM sellers;

-- started transaction for product_category_translation data insertion.

SHOW TABLES;
DESC product_category_translation;
START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/product_category_name_translation.csv'
INTO TABLE product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	product_category_name,
    product_category_name_english
); -- no warnings

COMMIT;

-- starting transaction for data insertion in products.

SHOW TABLES;
DESC products;
SELECT * FROM products;

START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/olist_products_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	product_id,
    product_category,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
);

SHOW WARNINGS; -- null values from the product_name_length column and false product_category_name total 1024 rows are not inserted.

COMMIT;

SELECT * FROM products; -- total 32328 rows inserted out off 32951

-- starting transaction for data insertion in orders.

SHOW TABLES;
DESC orders;
SELECT * FROM orders;

START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/olist_orders_dataset.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
);

SHOW WARNINGS;
SELECT * FROM orders; -- exact total rows inserted into the orders count is 96096
COMMIT;

-- starting transaction for data insertion in order_items.

SHOW TABLES;
DESC order_items;

START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/olist_order_items_dataset.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	order_id,
    order_items_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
);

SHOW WARNINGS; 
SELECT * FROM order_items; -- 107037 ROWS inserted
COMMIT;

-- starting transaction for data insertion in payments.

SHOW TABLES;
DESC payments;

START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/olist_order_payments_dataset.csv'
INTO TABLE payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
);

SELECT * FROM payments;
SHOW WARNINGS; -- total 100356 rows inserted
COMMIT;

-- starting transaction for data insertion in reviews.

SHOW TABLES;
DESC reviews;

START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/olist_order_reviews_dataset.csv'
INTO TABLE reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
);

SHOW WARNINGS;
SELECT * FROM reviews; -- 95k plus rows inserted

COMMIT;


-- starting transaction for data insertion in geolocation.

SHOW TABLES;
DESC geolocation;

START TRANSACTION;

LOAD DATA LOCAL INFILE 'C:/Users/prasa/OneDrive/Desktop/Data_Engineering_Capstone/SQL_Mastery_Assignment_1/Dataset/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
);

SHOW WARNINGS;
SELECT * FROM geolocation; -- total 1000163 rows inserted
COMMIT;