-- For each order, calculate a subtotal. 
SELECT order_id, SUM(OrderDetails.Quantity * Products.Price) as Subtotal, COUNT(ProductID) as "Products"
FROM Orders JOIN OrderDetails USING (OrderID)
JOIN Products USING (ProductID)
GROUP BY OrderID
ORDER BY OrderID;

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
SELECT orders.ship_country, orders.employee_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY orders.employee_id, orders.ship_country
ORDER BY orders.employee_id;

-- For each employee, get their sales amount, broken down by country name.
SELECT orders.ship_country, orders.employee_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY orders.employee_id, orders.ship_country
ORDER BY orders.employee_id;

SELECT orders.ship_country, orders.order_id, orders.employee_id, employees.first_name, employees.last_name, b.Subtotal
FROM orders
JOIN employees USING (employee_id)
JOIN (
	SELECT order_details.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
	FROM order_details
	GROUP BY order_details.order_id
) as b
ON orders.order_id = b.order_id
ORDER BY employees.employee_id;

-- Alphabetical List of Products
SELECT DISTINCT products.*
FROM products
WHERE products.discontinued = 0
ORDER BY products.product_name;

-- Current Product List
SELECT DISTINCT products.*
FROM products
WHERE products.discontinued = 0;

