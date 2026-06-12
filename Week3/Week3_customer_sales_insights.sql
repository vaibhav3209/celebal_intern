-- .....................................
--  1.	Who are the top 5 customers? 
-- .....................................
WITH TOTAL_SALES_PER_CUSTOMER AS 
(
SELECT 	
	customer_id,
    SUM(sales) as total_sales,
    ROW_NUMBER() OVER(ORDER BY SUM(sales) desc) as rank_
FROM orders o
GROUP BY customer_id
)

SELECT *
FROM TOTAL_SALES_PER_CUSTOMER
WHERE rank_ < 6;


-- .....................................
--  2.	Who are the bottom 5 customers? 
-- 		(JUST CHANGED IN WINDOW FUNCTION ORDER BY)
-- .....................................
WITH TOTAL_SALES_PER_CUSTOMER AS 
(
SELECT 	
	customer_id,
    SUM(sales) as total_sales,
    ROW_NUMBER() OVER(ORDER BY SUM(sales) ) as rank_
FROM orders o
GROUP BY customer_id
)

SELECT *
FROM TOTAL_SALES_PER_CUSTOMER
WHERE rank_ < 6;
;


-- .....................................
--  3.	Which customers made only one order? 
-- .....................................
SELECT 
	customer_id,
    COUNT(order_id) as total_orders
FROM orders 
GROUP BY customer_id
HAVING total_orders <2;

-- .....................................
--  4.	Which customers have above-average sales? 
-- .....................................
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


-- .....................................
--  5.	What is the highest order value per customer?
-- .....................................
SELECT 
	customer_id,
    MAX(sales) as highest_sale
FROM orders 
GROUP BY customer_id
ORDER BY customer_id;






