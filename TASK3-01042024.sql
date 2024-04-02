-- 1. List all products that have never been ordered.
explain analyze select product_name as unsoldProducts
from products p
left join order_details od on p.product_id=od.product_id
where p.product_id is null;
-- slower executing query below
--explain analyze select product_name as unsoldProducts
--from products p 
--where p.product_id not in (select product_id from order_details od);

-- 2. Find the names of the employees who have taken orders from customers in both Germany and the USA.
select first_name||' '||last_name as name from employees e
join orders o on e.employee_id = o.employee_id 
join customers c on o.customer_id = c.customer_id where c.country in ('Germany','USA')
group by e.employee_id ,name
having count(distinct c.country) = 2;

-- 3. For each month in the year 1997, calculate the total sales amount.
select sum(od.unit_price*od.quantity) as "totalSales", extract(month from o.order_date) as "Month" 
from order_details od
join orders o on od.order_id=o.order_id 
where extract(year from o.order_date)='1997'
group by extract(month from o.order_date);

-- 4. List the customers who have placed orders in every year that they have been a customer. (Hint: Consider order dates and customer registration dates.)
select company_name from customers c
join (select o.customer_id, min(o.order_date) as min_order from orders o group by o.customer_id)
as first_orders on c.customer_id = first_orders.customer_id
join orders o on o.customer_id=c.customer_id
group by c.company_name, extract(year from first_orders.min_order)
having count(distinct extract(year from first_orders.min_order)) =
		(extract(year from (select max(order_date) from orders)) - extract(year from first_orders.min_order))+1;

-- 5. Identify any products where the quantity in stock is below the reorder level, and display how many more units are needed to bring them up to reorder level.
select product_name as "Products below reorder", (reorder_level-units_in_stock) as "Required units" 
from products p 
where units_in_stock < reorder_level;

-- 6. Calculate a running total of sales revenue throughout the year 1997, ordered by date.
-- this query calculates total sales for each day
select sum(od.unit_price*od.quantity) as "totalSales", o.order_date as "Date" 
from order_details od 
join orders o on od.order_id=o.order_id
where extract(year from o.order_date)='1997'
group by o.order_date;
-- this query calculates running (mulitple sales) for each day
select sum(od.unit_price*od.quantity) over (order by o.order_date) as "runningSales", o.order_date as "Date" 
from order_details od 
join orders o on od.order_id=o.order_id
where extract(year from o.order_date)='1997'
order by o.order_date;

-- 7. Find the difference in average order value between customers in the USA and customers in Canada.
select (avg(total_value_usa)-avg(total_value_canada)) as "Avg(order(usa)) - Avg(order(canada))"
from 
	(select sum(od.unit_price*od.quantity) as total_value_usa from orders o 
	join order_details od on o.order_id=od.order_id
	where o.ship_country='USA'
	group by o.order_id
	)
cross join
	(select sum(od.unit_price*od.quantity) as total_value_canada from orders o
	join order_details od on o.order_id=od.order_id
	where o.ship_country = 'Canada'
	group by o.order_id
	);






