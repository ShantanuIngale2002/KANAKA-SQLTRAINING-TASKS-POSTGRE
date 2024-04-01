-- 1. List all products that have never been ordered.
select product_name as "products unsold" 
from products as p 
left join order_details as od 
on od.product_id = p.product_id;

-- 2. Find the names of the employees who have taken orders from customers in both Germany and the USA.
select first_name || last_name as "Name", o.ship_country as "shipping Country" 
from employees e 
join orders o on o.employee_id = e.employee_id 
where o.ship_country in ('Germany','USA');

-- 3. For each month in the year 1997, calculate the total sales amount.
select sum(od.unit_price*od.quantity) as "totalSales", extract(month from o.order_date) as "Month" 
from order_details od
join orders o on od.order_id=o.order_id 
where extract(year from o.order_date)='1997' 
group by extract(month from o.order_date);

-- 4. List the customers who have placed orders in every year that they have been a customer. (Hint: Consider order dates and customer registration dates.)


-- 5. Identify any products where the quantity in stock is below the reorder level, and display how many more units are needed to bring them up to reorder level.
select product_name as "Products below reorder", (reorder_level-units_in_stock) as "Required units" 
from products p 
where units_in_stock < reorder_level;

-- 6. Calculate a running total of sales revenue throughout the year 1997, ordered by date.
select sum(od.unit_price*od.quantity) as "totalSales", o.order_date as "Date" 
from order_details od 
join orders o on od.order_id=o.order_id
where extract(year from o.order_date)='1997' 
group by o.order_date;

-- 7. Find the difference in average order value between customers in the USA and customers in Canada.












