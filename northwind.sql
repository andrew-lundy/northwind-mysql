-- Start of "Part 1" (https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php)
-- For each order, calculate a subtotal. 
SELECT orders.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal, COUNT(products.product_id) as "Products"
FROM orders 
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
GROUP BY orders.order_id
ORDER BY orders.order_id;

-- Find the total amount of orders for each year.
SELECT YEAR(orders.order_date) AS Year, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY Year;

-- Find all sales; describe each sale (order id, shipped date, subtotal, year) and order by the most recent orders.
SELECT orders.order_id AS OrderID, orders.shipped_date AS ShippedDate, b.Subtotal, YEAR(orders.shipped_date) as Year
FROM orders
JOIN (
	SELECT order_details.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
	FROM order_details
	GROUP BY order_details.order_id
) AS b
ON orders.order_id = b.order_id
ORDER BY Year DESC;

-- For each employee, get their total sales amount per country.
SELECT orders.ship_country, employees.first_name, employees.last_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
JOIN employees ON orders.employee_id = employees.employee_id
GROUP BY orders.employee_id, orders.ship_country
ORDER BY orders.employee_id;

-- For each employee, get their sales details broken down by country.
SELECT orders.ship_country, orders.order_id, employees.first_name, employees.last_name, b.Subtotal
FROM orders
JOIN employees ON orders.employee_id = employees.employee_id
JOIN (
	SELECT order_details.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
	FROM order_details
	GROUP BY order_details.order_id
) as b
ON orders.order_id = b.order_id
ORDER BY employees.first_name, employees.last_name, orders.ship_country;

-- Alphabetical List of Products
SELECT DISTINCT products.*
FROM products
WHERE products.discontinued = 0
ORDER BY products.product_name;

-- Current Product List
SELECT DISTINCT products.*
FROM products
WHERE products.discontinued = 0;

-- Start of "Part 2" (https://www.geeksengine.com/database/problem-solving/northwind-queries-part-2.php)
-- Order details extended; This query calculates sales price for each order after discount is applied.
SELECT order_details.order_id as OrderID, order_details.product_id as ProductID, products.product_name as ProductName, order_details.unit_price as UnitPrice, order_details.quantity as Quantity, order_details.discount as OrderDiscount, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM order_details
JOIN products ON order_details.product_id = products.product_id
GROUP BY OrderID, ProductID, UnitPrice, Quantity, OrderDiscount;

-- Sales by Category; For each category, we get the list of products sold and the total sales amount.
SELECT categories.category_id, categories.category_name, products.product_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM categories
JOIN products USING (category_id)
JOIN order_details USING (product_id)
GROUP BY categories.category_id, categories.category_name, products.product_name;