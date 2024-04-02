-- 1. List the city and country of all customers.
SELECT city,country FROM customers;

-- 2. Find the total number of orders placed in 1997.
SELECT COUNT(order_id) FROM orders WHERE order_date>='1997-1-1' AND order_date<='1997-12-31';

-- 3. Calculate the total freight cost for the order with OrderID 10250.
select o.freight*count(od.order_id) from orders as o join order_details as od on o.order_id=od.order_id where o.order_id=10250 group by o.order_id;

-- 4. Display the product name and unit price for the most expensive product in the database.
SELECT product_name, unit_price FROM products WHERE unit_price=(SELECT MAX(unit_price) FROM products);

-- 5. List the names of employees along with the number of orders they have handled.
SELECT e.first_name ||' '|| e.last_name AS name, count(o.order_id) FROM employees AS e JOIN orders AS o on e.employee_id=o.employee_id GROUP BY e.employee_id;

-- 6. Find the top 3 customers based on the total amount they have spent on orders.
SELECT c.company_name AS top3customers FROM customers AS c JOIN orders AS o ON c.customer_id=o.customer_id JOIN order_details as od ON o.order_id=od.order_id GROUP BY c.company_name ORDER BY SUM(od.unit_price*od.quantity) DESC LIMIT 3;



