-- ..............................
--  Creating tables
--  Note:: 
-- 		1. Can't add country,city,state to CUSTOMERS table,
--   		as it has duplicate values.
-- ..............................



CREATE TABLE customers(
customer_id varchar(20) primary key,
customer_name varchar(100),
segment varchar(55)
);


CREATE TABLE products(
product_id varchar(20) ,
category varchar(30),
sub_category varchar(30),
product_name varchar(255)
);


CREATE TABLE orders(
order_id varchar(20) ,
customer_id varchar(20) ,
Foreign key (customer_id) references customers(customer_id),
product_id varchar(20) ,
order_date date,
ship_date date,
ship_mode varchar(30),
order_country varchar(55),
order_city varchar(55),
order_state varchar(55),
order_postal_code varchar(10),
order_region varchar(10),
sales DECIMAL(9,4),
quantity integer,
discount decimal(5,2),
profit DECIMAL(9,4)
);


-- ..............................
--  INserting Data using `SELECT DITINCT` 
-- ..............................

-- 793 records
insert into customers(	customer_id ,customer_name ,segment)
(
SELECT DISTINCT
	customer_id ,
	customer_name ,
	segment
from superstore_raw
);



-- 1894 records
insert into products(product_id, category, sub_category, product_name ) 
(
SELECT DISTINCT
	product_id, category, sub_category, product_name
from superstore_raw
);


-- 9994 records
insert into orders
(
select 
order_id  ,
customer_id  ,
product_id ,
order_date_clean ,
ship_date_clean ,
ship_mode ,
country ,
city,
state ,
postal_code ,
region ,
sales,
quantity ,
discount ,
profit 
from superstore_raw
);

