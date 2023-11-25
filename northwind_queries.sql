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

-- Alphabetical list of products
SELECT DISTINCT products.*
FROM products
WHERE products.discontinued = 0
ORDER BY products.product_name;

-- Current product list
SELECT DISTINCT products.*
FROM products
WHERE products.discontinued = 0;

-- Start of "Part 2" (https://www.geeksengine.com/database/problem-solving/northwind-queries-part-2.php)
-- Order details extended; this query calculates sales price for each order after discount is applied.
SELECT order_details.order_id as OrderID, order_details.product_id as ProductID, products.product_name as ProductName, order_details.unit_price as UnitPrice, order_details.quantity as Quantity, order_details.discount as OrderDiscount, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM order_details
JOIN products ON order_details.product_id = products.product_id
GROUP BY OrderID, ProductID, UnitPrice, Quantity, OrderDiscount;

-- Sales by category; for each category, we get the list of products sold and the total sales amount.
SELECT categories.category_name, products.product_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM categories
JOIN products USING (category_id)
JOIN order_details USING (product_id)
GROUP BY categories.category_id, categories.category_name, products.product_name;

-- Ten most expensive producs
SELECT products.product_name, products.unit_price
FROM products
ORDER BY products.unit_price DESC
LIMIT 10;

-- Products by category
SELECT DISTINCT categories.category_name, products.product_name
FROM categories
JOIN products ON categories.category_id = products.category_id
ORDER BY categories.category_name, products.product_name;

-- Active products by category
SELECT DISTINCT categories.category_name, products.product_name, products.discontinued
FROM categories
JOIN products ON categories.category_id = products.category_id
WHERE products.discontinued = 0
ORDER BY categories.category_name, products.product_name;

-- Customers and suppliers by city
SELECT customers.city, customers.company_name, customers.contact_name, 'Customers' AS Relationship
FROM customers
UNION
SELECT suppliers.city, suppliers.company_name, suppliers.contact_name, 'Suppliers'
FROM suppliers;

-- Start of "Part 3" (https://www.geeksengine.com/database/problem-solving/northwind-queries-part-3.php)
-- Products above average price
SELECT products.product_name, products.unit_price
FROM products
WHERE products.unit_price > (
	SELECT AVG(products.unit_price)
	FROM products
)
ORDER BY products.unit_price;

-- Product sales for 1997
SELECT orders.order_id, categories.category_name, products.product_name, order_details.quantity, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
JOIN categories ON products.category_id = categories.category_id
WHERE YEAR(orders.order_date) = 1997
GROUP BY orders.order_id, categories.category_name, products.product_name, order_details.quantity;

-- Category sales for 1997
SELECT categories.category_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
JOIN categories ON products.category_id = categories.category_id
WHERE YEAR(orders.order_date) = 1997
GROUP BY categories.category_name;



-- Quarterly Orders by Product
SELECT products.product_name, customers.company_name, YEAR(orders.order_date),
	FORMAT(SUM(CASE QUARTER(orders.order_date) 
					WHEN '1' THEN order_details.unit_price * order_details.quantity * (1 - discount) 
						ELSE 0 
                    END), 0) AS "Qtr 1",
	FORMAT(SUM(CASE QUARTER(orders.order_date) 
					WHEN '2' THEN order_details.unit_price * order_details.quantity * (1 - discount) 
						ELSE 0 
                    END), 0) AS "Qtr 2",
	FORMAT(SUM(CASE QUARTER(orders.order_date) 
					WHEN '3' THEN order_details.unit_price * order_details.quantity * (1 - discount) 
						ELSE 0 
                    END), 0) AS "Qtr 3",        
	FORMAT(SUM(CASE QUARTER(orders.order_date) 
					WHEN '4' THEN order_details.unit_price * order_details.quantity * (1 - discount) 
						ELSE 0 
                    END), 0) AS "Qtr 4"
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
JOIN customers ON orders.customer_id = customers.customer_id
WHERE YEAR(orders.order_date) = 1997
GROUP BY products.product_name, customers.company_name, YEAR(orders.order_date)
ORDER BY products.product_name, customers.company_name;

-- Invoice; A simple query to get detailed information for each sale so that invoice can be issued.
SELECT orders.order_id AS OrderID,
    customers.company_name AS CustomerCompany, 
    customers.contact_name AS CustomerContact, 
    customers.phone AS CustomerPhone,
    orders.employee_id AS EmployeeOfSale, 
    CONCAT(employees.first_name, " ", employees.last_name) AS SalesPerson,
    order_details.quantity AS ProductCount,
    products.product_name AS ProductName,
    order_details.unit_price * order_details.quantity * (1 - discount) as Subtotal,
    orders.order_date AS OrderDate, 
    orders.required_date AS RequiredDate, 
    orders.shipped_date AS ShippedDate, 
    shippers.company_name AS ShippingCompany,
    shippers.phone AS ShippingCoPhone,
    orders.freight AS Freight,
    orders.ship_name AS ShippingLabelName, 
    orders.ship_address AS ShippingLabelAddress, 
    orders.ship_city AS ShippingLabelCity,
    orders.ship_postal_code AS ShippingLabelZIP, 
    orders.ship_country AS ShippingLabelCountry
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN customers ON orders.customer_id = customers.customer_id
JOIN products ON order_details.product_id = products.product_id
JOIN employees ON orders.employee_id = employees.employee_id
JOIN shippers ON orders.ship_via = shippers.shipper_id
ORDER BY orders.order_id;

-- Number of units in stock by category and supplier continent
SELECT categories.category_name AS Category, suppliers.region AS Region, SUM(products.units_in_stock) AS UnitsInStock
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN suppliers ON products.supplier_id = suppliers.supplier_id
GROUP BY categories.category_name, suppliers.region;

-- OR
SELECT categories.category_name AS Category,
	CASE
		WHEN suppliers.country IN ('UK', 'Sweden', 'Germany', 'France', 'Italy', 'Spain', 'Denmark', 'Netherlands', 'Finland', 'Norway') THEN 'EMEA'
        WHEN suppliers.country IN ('USA', 'Canada') THEN 'NA'
        WHEN suppliers.country IN ('Brazil') THEN 'LATAM'
        WHEN suppliers.country IN ('Japan', 'Singapore', 'Australia') THEN 'APAC'
        ELSE 'Unknown country; cannot find region'
    END as 'SupplierContinent', 
    SUM(products.units_in_stock) AS UnitsInStock
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN suppliers ON products.supplier_id = suppliers.supplier_id
GROUP BY categories.category_name, 
	CASE
		WHEN suppliers.country IN ('UK', 'Sweden', 'Germany', 'France', 'Italy', 'Spain', 'Denmark', 'Netherlands', 'Finland', 'Norway') THEN 'EMEA'
        WHEN suppliers.country IN ('USA', 'Canada') THEN 'NA'
        WHEN suppliers.country IN ('Brazil') THEN 'LATAM'
        WHEN suppliers.country IN ('Japan', 'Singapore', 'Australia') THEN 'APAC'
        ELSE 'Unknown country; cannot find region'
    END;
    
    
-- Start of custom queries; focused on product performance
-- Top categories per region
SELECT products.product_name, categories.category_name, orders.ship_region
FROM products
JOIN categories ON products.category_id = categories.category_id
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
WHERE orders.ship_region IS NOT NULL;

-- Find the top product for a single region; 'top product' meaning highest quantity sold.
SELECT products.product_id, products.product_name, order_details.quantity, orders.ship_region
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
JOIN products ON order_details.product_id = products.product_id
WHERE ship_region = 4
ORDER BY quantity DESC
LIMIT 1;

SELECT * FROM orders;

-- Find the top product for each region; 'top product' meaning highest quantity sold.
SELECT product_id, sales_count, ship_region
FROM (
	SELECT
		products.product_id,
		order_details.quantity AS sales_count,
		orders.ship_region,
		ROW_NUMBER() OVER(PARTITION BY orders.ship_region ORDER BY order_details.quantity DESC) as row_num
	FROM products
	JOIN order_details ON products.product_id = order_details.product_id
	JOIN orders ON order_details.order_id = orders.order_id
) AS ProductSales
WHERE row_num = 1;

-- Find the top salesperson for each region; 'top' meaning they have the most sales by total dollar amount.
SELECT first_name, last_name, FormattedSubtotal
FROM (
	SELECT 
		employees.employee_id,
		employees.first_name,
		employees.last_name,
		orders.ship_region,
        SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as Subtotal,
        FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as FormattedSubtotal,
		ROW_NUMBER() OVER(PARTITION BY ship_region ORDER BY SUM(order_details.unit_price * order_details.quantity * (1 - discount)) DESC) as row_num
	FROM employees
	JOIN orders on employees.employee_id = orders.employee_id
	JOIN order_details ON orders.order_id = order_details.order_id
	GROUP BY employee_id, ship_region
) AS TopSalesperson
WHERE row_num = 1;

-- Change employee_id to unsigned tinyint; see how much space is saved