-- ..............................
--  Question 1 : orders where sales are greater than the average sales. 
-- ..............................
SELECT *
FROM orders
WHERE sales >
		(
			SELECT AVG(sales)
			from orders
		);



-- ..............................
--  Question 2 : the highest sales order for each customer.
-- ..............................
SELECT
    o.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.ship_date,
    o.ship_mode,
    o.order_state,
    o.order_city,
    o.product_id,
    p.product_name,
    o.sales,
    o.quantity
FROM orders o
JOIN customers c
	ON c.customer_id = o.customer_id
JOIN products p
	ON o.product_id=p.product_id
WHERE o.sales = (
    SELECT MAX(sales)
    FROM orders
    WHERE customer_id = o.customer_id
)
ORDER BY o.customer_id;



-- ..............................
--  Question 3: total sales for each customer.
-- ..............................
WITH TOTAL_SALES_PER_CUSTOMER AS 
(
SELECT 	
	customer_id,
    SUM(o.sales) as total_sales
FROM orders o
GROUP BY o.customer_id
)

SELECT 
	ts.customer_id,
    c.customer_name,
	ts.total_sales
FROM TOTAL_SALES_PER_CUSTOMER ts
JOIN customers c
	ON ts.customer_id = c.customer_id;



-- ..............................
--  Question 4: customers whose total sales are above average
-- ..............................
WITH TOTAL_SALES_PER_CUSTOMER AS 
(
SELECT 	
	customer_id,
    SUM(o.sales) as total_sales
FROM orders o
GROUP BY o.customer_id
)

SELECT 
	ts.customer_id,
    c.customer_name,
	ts.total_sales
FROM TOTAL_SALES_PER_CUSTOMER ts
JOIN customers c
	ON ts.customer_id = c.customer_id
WHERE ts.total_sales >
	(
		SELECT AVG(total_sales)
        from TOTAL_SALES_PER_CUSTOMER 
    );



-- ..............................
--  Question 5: Rank all customers based on total sales
-- ..............................
SELECT 	
	customer_id,
    SUM(sales) as total_sales,
    ROW_NUMBER() OVER(ORDER BY SUM(sales) desc) as rank_
FROM orders o
GROUP BY o.customer_id
ORDER BY rank_;



-- ..............................
--  Question 6: Assign row numbers to each order within a customer. 
-- 		(ordered by order date Asecending)
-- ..............................
SELECT
	customer_id,
    order_id,
    order_date,
    ship_date,
    product_id,
    sales,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) as rank_
FROM orders 
ORDER BY customer_id,rank_;



-- ..............................
--  Question 7: top 3 customers based on total sales. 
-- ..............................
WITH TOTAL_SALES_PER_CUSTOMER AS 
(
SELECT 	
	customer_id,
    SUM(sales) as total_sales,
    DENSE_RANK() OVER(ORDER BY SUM(sales) DESC) as rank_
FROM orders o
GROUP BY o.customer_id

)

SELECT
	*
FROM TOTAL_SALES_PER_CUSTOMER
WHERE rank_ < 4;




-- ..............................
--  COMBINED query
-- ..............................

WITH TOTAL_SALES_PER_CUSTOMER AS 
(
SELECT 	
	customer_id,
    SUM(sales) as total_sales,
    ROW_NUMBER() OVER(ORDER BY SUM(sales) desc) as rank_
FROM orders o
GROUP BY customer_id
)


SELECT
    ts.customer_id,
    ts.total_sales,
    c.customer_name,
    c.segment,
    ts.rank_
FROM TOTAL_SALES_PER_CUSTOMER ts
JOIN customers c
	ON c.customer_id = ts.customer_id
ORDER BY rank_;