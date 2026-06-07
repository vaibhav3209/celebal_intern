-- ***********************************************
## 	1. First make a table according to the csv columns
-- ***********************************************

CREATE TABLE if not exists orders_bronze (
    row_id INT,   
    order_id VARCHAR(20), 
    order_date VARCHAR(10) NULL,
    ship_date VARCHAR(10) NULL,
    ship_mode VARCHAR(50) NULL,
    customer_id VARCHAR(20) NULL,
    customer_name VARCHAR(100) NULL,
    segment VARCHAR(50) NULL,
    country VARCHAR(100) NULL,
    city VARCHAR(100) NULL,
    state VARCHAR(100) NULL,
    postal_code VARCHAR(20) NULL, 				## Don't convert to INT as leading zeros will be lost 
    region VARCHAR(50) NULL,
    product_id VARCHAR(30) NULL,
    category VARCHAR(50) NULL,
    sub_category VARCHAR(50) NULL,
    product_name VARCHAR(255) NULL,
    sales DECIMAL(12,4) NULL,
    quantity INT NULL,
    discount DECIMAL(5,2) NULL,
    profit DECIMAL(12,4) NULL
);


-- ***********************************************
##	2. Loading the data from csv
##		using File import wizard (RIGHT CLICK ON table)

--   NOTE:
--        - Set some variables and copy the file in location of line42
--        - Some column have itself comma and "" between values
--            they will be enclosed by "" with microsoft excel .
-- ***********************************************

SHOW VARIABLES LIKE 'secure_file_priv';

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Orders_data2.csv'
INTO TABLE orders_bronze
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ***********************************************
##	3. Explore table (schema, sample data). 
	-- Correcting Date formats
    -- Seeing full data
    -- Querying columns for distinct values
-- ***********************************************
select count(*)
from orders_bronze
where 
order_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' 
or 
order_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';


# *** Check how many records are targetted ***
select count(order_date) from orders_bronze;

ALTER TABLE orders_bronze
ADD COLUMN order_date_clean DATE,
ADD COLUMN ship_date_clean DATE;


SET SQL_SAFE_UPDATES = 1;


UPDATE orders_bronze
SET
    order_date_clean =
        CASE
            WHEN order_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
                THEN STR_TO_DATE(order_date, '%m-%d-%Y')

            WHEN order_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
                THEN STR_TO_DATE(order_date, '%m/%d/%Y')

            ELSE NULL
        END,

    ship_date_clean =
        CASE
            WHEN ship_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
                THEN STR_TO_DATE(ship_date, '%m-%d-%Y')

            WHEN ship_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
                THEN STR_TO_DATE(ship_date, '%m/%d/%Y')

            ELSE NULL
        END;
        
        
ALTER TABLE orders_bronze
DROP COLUMN order_date,
DROP COLUMN ship_date;


-- ***********************************************
# 	SEE full data
-- ***********************************************

select *
from orders_bronze;



-- ***********************************************
# see unique values in columns
-- ***********************************************

select distinct country
from orders_bronze;

# country
-- UNITED States 

select distinct ship_mode
from orders_bronze;

# ship_mode
-- 'Standard Class'
-- 'Second Class'
-- 'Same Day'
-- 'First Class'


select distinct region
from orders_bronze;

# region
-- 'Central'
-- 'East'
-- 'South'
-- 'West'


select distinct category
from orders_bronze;
# category
-- 'Furniture'
-- 'Office Supplies'
-- 'Technology'


select distinct segment
from orders_bronze;
# segment
-- 'Consumer'
-- 'Corporate'
-- 'Home Office'


-- ***********************************************
##	4. Apply WHERE filters (region, category, date, sales).
	-- Loss making Items
-- ***********************************************


SELECT DIStinct
        product_id,
        product_name,
        category,
        sub_category,
        round(profit/quantity,3) as loss_per_item,
        region
from orders_bronze
where profit <0
order by product_name,region;


-- ***********************************************
-- 4.Use GROUP BY for aggregations (sales, quantity, averages).
-- ***********************************************


# aggregrating Sales by hierarchy (use for top categories, top state, YOY analysis)


-- CREATE TABLE celebal_internship.Sales_hierarchy AS
-- WITH Sales_hierarchy AS
-- (
--     SELECT
--         YEAR(order_date_clean) AS Financial_year,
--         region,
--         state,
--         city,
--         category,
--         SUM(sales) AS total_sales,
--         SUM(quantity) AS units_sold,
--         SUM(profit) AS total_profit
--     FROM orders_bronze
--     GROUP BY
--         YEAR(order_date_clean),
--         region,
--         state,
--         city,
--         category
-- )


select * 
from Sales_hierarchy;

# TOP category by PROFIT
select 
	category,
	sum(total_profit) as total_profit
from Sales_hierarchy
group by category
order by total_profit desc;

# category, total_profit
-- 'Furniture', '18451.2728'
-- 'Office Supplies', '122490.8008'
-- 'Technology', '145454.9481'


# TOP state
select 
	state,
	sum(total_profit) as total_profit
from Sales_hierarchy
group by state
order by total_profit desc
LIMIT 3;

# state, total_profit
-- 'California', '76381.3871'
-- 'New York', '74038.5486'
-- 'Washington', '33402.6517'



-- ........................................
 
with cte as 
(
select distinct 
	category,
    product_id,
    product_name,
    sum(quantity) over(partition by product_id) as units_sold
from orders_bronze
order by category,product_id
),
cte2 as 
(
select 
	category,
    product_id,
    product_name,
    units_sold,
    row_number() over(partition by category order by units_sold desc) as rn 
from cte
order by category,rn
)


# TOP 3 products by every category
select 
	category,
    product_id,
    product_name,
    units_sold
from cte2
where rn <4;


# TOP customers
SELECT 
	customer_id,
    customer_name,
    sum(quantity) as items_bought
from orders_bronze
group by customer_id,customer_name
order by items_bought desc
limit 10;












