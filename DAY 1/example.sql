SELECT datname FROM pg_database;

CREATE TABLE example (id INT PRIMARY KEY, f_name VARCHAR(10) NOT NULL, l_name VARCHAR(10) NOT NULL, c_number VARCHAR(15) NOT NULL);

SELECT * FROM example;

/*
ADD GENERATED ALWAYS AS IDENTITY NEW Way of AUTO INCREMENT ADDED AFTER postgresql VERSION 10
CAN ALSO USE 'BY DEFAULT' INSTEAD OF 'ALWAYS' FOR MANUAL OVERRIDE
*/
ALTER TABLE example
	ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY;


/*
First time got to know that instead of "" these we have to use '' these,
while inserting values. 
*/

INSERT INTO example (f_name, l_name, c_number) 
	VALUES ('john', 'doe', '9999999999'), ('alex', 'marshall', '8888888888');


SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable, 
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'example';
