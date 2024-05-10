/* Creation of tables for the data warehouse*/

-- Use the name you have chosen for your database
USE superstore_data_warehouse;

/* Change the names of the foreign keys to avoid problems when joining tables
for denormalization */

EXEC sp_rename 'country.continent_id', 'continent_id1', 'COLUMN';
EXEC sp_rename 'city_state.country_id', 'country_id1', 'COLUMN';
EXEC sp_rename 'order.city_state_id', 'city_state_id1', 'COLUMN';
EXEC sp_rename 'order_line.order_id', 'order_id1', 'COLUMN';
EXEC sp_rename 'order_line.product_id', 'product_id1', 'COLUMN';
EXEC sp_rename 'product.product_subcategory_id', 'product_subcategory_id1', 'COLUMN';
EXEC sp_rename 'product_subcategory.product_category_id', 'product_category_id1', 'COLUMN';

/* Join the relevant tables to answer the business questions */ 

SELECT c.*, ct.*, cs.*, o.*, ol.*, p.*, ps.*, pc.*
INTO dbo.denormalized_table
FROM dbo.continent c
INNER JOIN dbo.country ct ON ct.continent_id1 = c.continent_id
INNER JOIN dbo.city_state cs ON ct.country_id = cs.country_id1
INNER JOIN dbo.[order] o ON cs.city_state_id = o.city_state_id1
INNER JOIN dbo.order_line ol ON o.order_id = ol.order_id1
INNER JOIN dbo.product p ON ol.product_id1 = p.product_id
INNER JOIN dbo.product_subcategory ps ON p.product_subcategory_id1 = ps.product_subcategory_id
INNER JOIN dbo.product_category pc ON ps.product_category_id1 = pc.product_category_id;

/* Now we have a big denormalized table */

SELECT *
FROM dbo.denormalized_table;

/* Let's get rid of the foreign keys in the
denormalized table */

ALTER TABLE denormalized_table
DROP COLUMN continent_id1,
            country_id1,
            city_state_id1,
            order_id1,
            product_id1,
            product_subcategory_id1,
            product_category_id1;

/* Create the table subcategory as a dimension this table
contains category and subcategory, the transitive dependency
came back */

SELECT DISTINCT product_subcategory_id, product_subcategory, product_category
INTO subcategory_dim
FROM denormalized_table;

/* Eliminate columns */

ALTER TABLE denormalized_table
DROP COLUMN product_subcategory,
			product_category,
			product_category_id;

/* Create the table product as a dimension */

SELECT DISTINCT product_id, product_name, product_attributes
INTO product_dim
FROM denormalized_table;

/* Eliminate columns */

ALTER TABLE denormalized_table
DROP COLUMN product_name;

ALTER TABLE denormalized_table
DROP COLUMN product_attributes;

/* Create the table geography as a dimension this table
contains continent and country, the transitive dependency
came back */

SELECT DISTINCT country_id, country, continent
INTO country_dim
FROM denormalized_table;

/* Eliminate columns */

ALTER TABLE denormalized_table
DROP COLUMN country,
			continent_id,
			continent;

/* Eliminate the rest of unnecessary columns for our data warehouse */

ALTER TABLE denormalized_table
DROP COLUMN city_state_id,
			city,
			[state],
			order_id,
			customer_id,
			order_priority_id,
			ship_mode_id,
			postal_code,
			order_line_id,
			ship_date;

select *
from denormalized_table;

/* Create a time dimension table and assign a unique principal key to each
time */

-- Create the time_dim table
CREATE TABLE time_dim (
    time_id INT IDENTITY(1,1) PRIMARY KEY,
    order_date DATE NOT NULL
);

-- Insert unique values into the time_dim table, ordered from oldest to newest
INSERT INTO time_dim (order_date)
SELECT DISTINCT order_date
FROM denormalized_table
ORDER BY order_date;

/* Add the column time_id to the normalized table to link each row with its order_date */

ALTER TABLE denormalized_table
ADD time_id INT;

UPDATE dt
SET dt.time_id = td.time_id
FROM denormalized_table dt
INNER JOIN time_dim td ON dt.order_date = td.order_date;

/* Let's delete unneccesary columns */

ALTER TABLE denormalized_table
DROP COLUMN order_date;

/* Let's create the fact table */

SELECT *
INTO fact_table
FROM denormalized_table;

select *
from fact_table;

/* Let's set primary and foreign keys */

ALTER TABLE subcategory_dim
ADD CONSTRAINT PK_subcategory_dim PRIMARY KEY (product_subcategory_id);

ALTER TABLE product_dim
ADD CONSTRAINT PK_product_dim PRIMARY KEY (product_id);

ALTER TABLE country_dim
ADD CONSTRAINT PK_country_dim PRIMARY KEY (country_id);

/* Foreign keys in the fact table */

ALTER TABLE fact_table
ADD CONSTRAINT FK_country_id FOREIGN KEY (country_id) REFERENCES country_dim(country_id);

ALTER TABLE fact_table
ADD CONSTRAINT FK_product_id FOREIGN KEY (product_id) REFERENCES product_dim(product_id);

ALTER TABLE fact_table
ADD CONSTRAINT FK_product_subcategory_id FOREIGN KEY (product_subcategory_id) REFERENCES subcategory_dim(product_subcategory_id);

ALTER TABLE fact_table
ADD CONSTRAINT FK_time_id FOREIGN KEY (time_id) REFERENCES time_dim(time_id);







