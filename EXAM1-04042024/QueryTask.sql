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
-- trying this good method
with 
	obtained_order as (
	  select c.customer_id, sum(od.quantity) as order_quantity,
	  extract(year from o.order_date) as order_year
	  from customers c
	  join orders o on c.customer_id = o.customer_id 
	  join order_details od on o.order_id = od.order_id
	  where extract(year from o.order_date) in (1996,1997)
	  group by c.customer_id, order_year
	  order by c.customer_id, order_year
	 )
select (case 
			when ob.customer_id = lead(ob.customer_id) over(order by ob.customer_id)
				 and ob.order_quantity < lead(ob.order_quantity) over(order by ob.customer_id)
			then c.customer_id
		end)
from customers c
join obtained_order ob on c.customer_id = ob.customer_id
;
-- this is correct but lengthy method
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



