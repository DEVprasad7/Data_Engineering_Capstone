SHOW DATABASES;

CREATE DATABASE BrazilianEcommerce;

USE BrazilianEcommerce;

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
