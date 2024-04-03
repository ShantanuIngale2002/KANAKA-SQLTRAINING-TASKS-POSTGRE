-- CODE OPTIMIZATIONS PRACTICE




-- 1 query
select p.product_name, c.company_name, o.order_date
from products p 
inner join order_details od on p.product_id = od.product_id 
inner join orders o on od.order_id = o.order_id 
inner join customers c on o.customer_id = c.customer_id 
where o.order_date between '1997-01-01' and '1997-12-31'
and c.country in (select country from customers c2 where city='London');

-- 1 query optimized
-- desc : actually this is already the best query for the task
-- bootleneck : without indexes it may act slow for huge data
-- changes :

--create index orders_order_date_index on orders(order_date);
--create index customers_city_country_index on customers(city,country);
--create index order_details_order_id_index on order_details(order_id);
--create index products_product_id_index on products(product_id);



-- 2 query
select p.product_name,
(select avg(od.unit_price) from order_details od
where od.product_id = p.product_id) as avgPrice
from products p;

-- 2 query optimized
-- desc : sub query is used to get avg price
-- bottleneck : sub query take much time compared to join
-- changes : use join query to get avg price
-- more optimization : index on productid, productname, unitprice
select p.product_name, avg(od.unit_price) from products p
join order_details od on od.product_id = p.product_id
group by p.product_id;



-- 3. query
select * from orders o
order by order_date desc limit 10;

-- 3. query optimized
-- desc : the query is good for the task
-- bootleneck : ordering by order_date becomes low efficient
-- changes :

-- create index orders_order_date_index on orders(order_date);



-- 4. query
select p.product_name,
(select count(*) from order_details od where od.product_id=p.product_id)
as orderCount,
(select avg(od.unit_price) from order_details od where od.product_id=p.product_id)
as avgPrice,
(select max(o.order_date) from orders o 
inner join order_details od on o.order_id=od.order_id
where od.product_id = p.product_id) as lastOrderDate
from products p;

-- 4. query optimized
-- desc : the subqueries performs degrading compared to joins
-- bootleneck : subqueries decreases performance and increase exe. time
-- changes : subqueries -> join queries
-- more optimization : indexing the columns

-- create index products_product_name_index on products(product_name);
-- create index order_details_order_id_index on order_details(order_id,unit_price);
-- create index order_order_id_index on orders(order_id);
-- create index orders_order_date_index on orders(order_date);
select p.product_name as productName, count(od.order_id) as ordercount, avg(od.unit_price) as avgPrice, max(o.order_date) as lastOrderDate
from products p
join order_details od on p.product_id = od.product_id
join orders o on od.order_id = o.order_id
group by p.product_name;



-- query 5
select c.company_name, sum(od.unit_price * od.quantity) as totalSpent
from customers c 
inner join orders o on c.customer_id = o.customer_id
inner join order_details od on o.order_id = od.order_id
where c.country = 'USA'
group by c.company_name
order by totalSpent desc;

-- query 5 - optimized
-- desc : the query seems good for the work given
-- bottleneck : without indexing low efficient performance
-- changes : create indexes

-- create index customers_country_index on customers(country);
-- create index customers_customer_id_index on customers(customer_id);
-- create index order_details_order_id_index on order_details(order_id);



-- query 6
select * from orders o
where order_id in (select order_id from order_details od
	where product_id in (select product_id from products p
		where category_id=1
	)
);

-- query 6
-- desc : subqueries acts independant hence low performace, high time, less efficiency, confusing exe.plan
-- bootleneck : huge data can crash processing
-- changes : using join query
-- more optimization : create index for order ids and category

-- create index orders_order_id_index on orders(order_id);
-- create index order_details_order_id_index on order_details(order_id);
-- create index products_product_id_index on products(product_id);
-- create index products_category_id_index on products(category_id);
select o.* from orders o
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
where p.category_id =1;




