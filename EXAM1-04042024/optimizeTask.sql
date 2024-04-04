-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- QUERIES CODING TASKS
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- 1. Find the top 3 employees who have generated the highest total revenue in the year 1997.
select e.first_name ||' '|| e.last_name as emp_name, sum(od.unit_price*od.quantity) as total_revenue from employees e
join orders o on e.employee_id = o.employee_id
join order_details od on o.order_id = od.order_id
where extract(year from o.order_date)=1997
group by emp_name
order by total_revenue desc limit 3
;

-- 2. List all products that have been ordered by customers in both France and Italy
select product_name ,o.ship_country as customer_country from products p
join order_details od on p.product_id = od.product_id
join orders o on od.order_id = o.order_id
join customers c on o.customer_id = c.customer_id
where c.country in ('France','Italy')
order by customer_country
;

-- 3. For  each product category, calculate the average order quantity and the total sales revenue.
select p.category_id, avg(od.quantity) as avg_order_quantity,
sum(od.quantity*od.unit_price) as total_sales_revenue
from products p
join order_details od on p.product_id = od.product_id
group by p.category_id
order by p.category_id
;

-- 4. Find the customers who have placed more orders in 1997 than in 1996
 with 
 	order_data_1996 as
 	(
	 	select c.customer_id as customer_id, 
	 	sum(od.quantity) as order_quantity,
		extract(year from o.order_date) as order_year
		from customers c
		join orders o on c.customer_id = o.customer_id 
		join order_details od on o.order_id = od.order_id
		where extract(year from o.order_date) = 1996
		group by c.customer_id, order_year
	)
	,
	order_data_1997 as 
	(
		select c.customer_id as customer_id, 
		sum(od.quantity) as order_quantity,
		extract(year from o.order_date) as order_year
		from customers c
		join orders o on c.customer_id = o.customer_id 
		join order_details od on o.order_id = od.order_id
		where extract(year from o.order_date) = 1997
		group by c.customer_id, order_year
	)
select c.company_name, 
od96.order_quantity as orders_quantity_1996, 
od97.order_quantity as orders_quantity_1997 
from customers c
join order_data_1996 od96 on c.customer_id=od96.customer_id
join order_data_1997 od97 on od96.customer_id=od97.customer_id
where od96.order_quantity < od97.order_quantity
group by c.customer_id, od96.order_quantity, od97.order_quantity
;

-- 5. Identify the orders that have more than 5 different products and calculate the total value of each order.
select od.order_id, sum(od.unit_price*od.quantity) total_value
from order_details od
join(
		select order_id,count(product_id) from order_details od
		group by order_id
		having count(product_id)>5 
	) final_order
	on od.order_id = final_order.order_id
group by od.order_id
;





-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- QUERIES OPTIMIZATOIN TASKS
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- >>> QUERY 1
-- original
explain analyze select p.product_name, c.company_name, o.order_date
from products p 
inner join order_details od on p.product_id = od.product_id 
inner join orders o on od.order_id = o.order_id 
inner join customers c on o.customer_id = c.customer_id
where o.order_date between '1997-01-01' and '1997-12-31'
and c.city = 'London'
;
-- explaination : Already good-fit for the task.
-- bootlenecks  : Without INDEXING may perform less efficient.
-- Optimizations :
create index products_productid_index on products(product_id);
create index products_productname_index on products(product_name);
create index customers_companyname_city_index on customers(company_name, city);
create index orders_orderdate_index on orders(order_date);


-- >>> QUERY 2
-- original
SELECT p.product_name ,
(SELECT AVG(od.unit_price) FROM order_details od WHERE od.product_id = p.product_id)
AS avgPrice
FROM Products p
;
-- explaination : Subquery finds avgPrice everytime for product_id.
-- bootlenecks  : Joins works more efficiently.
-- Optimizations :
select p.product_name, avg(od.unit_price) as avg_price
from products p
join order_details od on p.product_id = od.product_id
group by p.product_name
;


-- >>> QUERY 3
-- original
SELECT * FROM Orders
ORDER BY order_date DESC
LIMIT 10
;
-- explaination : Already good-fit for the task.
-- bootlenecks  : Without INDEXING may perform less efficient.
-- Optimizations :
create index orders_order_date_index on orders(order_date);


-- >>> QUERY 4
-- original
SELECT c.company_name , SUM(od.unit_price * od.quantity) AS totalSpent
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id 
INNER JOIN order_details od ON o.order_id = od.order_id
WHERE c.Country = 'USA'
GROUP BY c.company_name
ORDER BY totalSpent DESC
;
-- explaination : Already good-fit for the task.
-- bootlenecks  : Without INDEXING may perform less efficient.
-- Optimizations :
create index customers_companyname_city_index on customers(company_name, city);


-- >>> QUERY 5
-- original
SELECT count(*) FROM Orders
WHERE order_id IN 
(
	SELECT order_id FROM order_details od WHERE product_id IN (
	SELECT product_id FROM Products WHERE category_id = 1)
);
-- explaination : Subquery finds avgPrice everytime for product_id.
-- bootlenecks  : Joins works more efficiently.
-- Optimizations :
create index products_categoryid on products(category_id);

select distinct * from orders o
inner join order_details od on o.order_id = od.order_id
inner join products p on od.product_id = p.product_id
where p.category_id = 1
;
	


-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- QUERIES TO DELETE INDEXES

-- query 1's drop:indexes
drop index products_productid_index;
drop index products_productname_index;
drop index customers_companyname_city_index;
drop index orders_orderdate_index;
-- query 3's drop:indexes
drop index orders_order_date_index;
-- query 4's drop:indexes
drop index customers_companyname_city_index;
-- query 5's drop:indexes
drop index products_categoryid;





