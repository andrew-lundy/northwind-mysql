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
    
    
-- HERE: Start of custom queries; focused on product performance.
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

-- Find the top product for each region; 'top product' meaning highest quantity sold.
SELECT product_id, product_name, sales_count, ship_region
FROM (
	SELECT
		products.product_id,
        products.product_name,
		order_details.quantity AS sales_count,
		orders.ship_region,
		ROW_NUMBER() OVER(PARTITION BY orders.ship_region ORDER BY order_details.quantity DESC) as row_num
	FROM products
	JOIN order_details ON products.product_id = order_details.product_id
	JOIN orders ON order_details.order_id = orders.order_id
) AS ProductSales
WHERE row_num = 1;

-- Find the top salesperson for each region; 'top' meaning they have the most sales by total dollar amount.
SELECT CONCAT(first_name, ' ', last_name) AS Salesperson, FormattedSubtotal, ship_region AS Region
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

-- View all products and their sales per quarter of each year.
SELECT products.product_name,
    FORMAT(SUM(CASE WHEN QUARTER(orders.order_date) = 1 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END), 0) AS 'Qtr 1',
	FORMAT(SUM(CASE WHEN QUARTER(orders.order_date) = 2 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END), 0) AS 'Qtr 2',
    FORMAT(SUM(CASE WHEN QUARTER(orders.order_date) = 3 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END), 0) AS 'Qtr 3',
    FORMAT(SUM(CASE WHEN QUARTER(orders.order_date) = 4 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END), 0) AS 'Qtr 4',
    YEAR(orders.order_date) AS order_year
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY products.product_name, order_year;

-- HERE: The following prompts were recommended by: https://chat.openai.com/share/c0e6a00d-9d36-43fd-84ac-0714af9898ee.

-- 1. Product Sales Analysis: How can we assess the performance of individual products in terms of sales? Are there specific products that consistently outperform others?
-- To accomplish this, I wrote a query that finds all products and their total sales (subtotals). Then, it finds the average of those subtotals.
-- This would indicate a product that performs better than average.
SELECT product_id, product_name, formatted_subtotal FROM (
	SELECT order_details.product_id AS product_id, products.product_name AS product_name, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	GROUP BY product_id
) AS product_subtotals
WHERE subtotal > @average
ORDER BY subtotal DESC;

-- 2. Inventory Management: Are there products in the database that have low sales and high inventory levels? How can we identify and address potential overstock issues for these products?
-- First, define 'low sales' and 'high inventory'. 'High inventory' = `units_in_stock` is greater than the average of all `units_in_stock` count combined. 'Low sales' = less than average, based on the subtotal.
CALL FindAverageSubtotal(@average);
SELECT @average;

DELIMITER //
CREATE PROCEDURE FindAverageSubtotal(OUT average DECIMAL(10,2))
BEGIN
	SELECT AVG(subtotal) INTO average
	FROM (
		SELECT products.product_name, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal
		FROM products
		JOIN order_details ON products.product_id = order_details.product_id
		GROUP BY products.product_name
		ORDER BY subtotal DESC
	) AS product_subtotal_averages;
END //
DELIMITER ;

-- Query that finds products, their current "in stock" total, and subtotal of sales.
SELECT product_name, units_in_stock, formatted_subtotal
FROM (
	SELECT order_details.product_id, products.product_name, products.units_in_stock, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	WHERE products.units_in_stock > (
		SELECT AVG(products.units_in_stock)
		FROM products
	)
	GROUP BY order_details.product_id, products.product_name, products.units_in_stock
	HAVING subtotal < @average  
	ORDER BY subtotal ASC
) AS LowSalesHighInventoryProducts;

-- 3. Product Category Performance: Are there particular product categories that perform better than others? Can we analyze sales, profitability, and customer preferences within different categories?
-- Find categories and their total sales (add "total amount of products for each category")
SELECT categories.category_name, 
	FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal,
    COUNT(order_details.quantity) AS orders_with_cat,
    COUNT(DISTINCT products.product_id) AS products_per_cat
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN order_details ON products.product_id = order_details.product_id
GROUP BY categories.category_id
ORDER BY SUM(order_details.unit_price * order_details.quantity * (1 - discount)) DESC;

-- Change employee_id to unsigned tinyint; see how much space is saved


-- Top 3 products per quarter (by sales)
SELECT products.product_name,
	SUM(CASE WHEN QUARTER(orders.order_date) = 1 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_1,
    SUM(CASE WHEN QUARTER(orders.order_date) = 2 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_2,
	SUM(CASE WHEN QUARTER(orders.order_date) = 3 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_3,
    SUM(CASE WHEN QUARTER(orders.order_date) = 4 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_4
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY products.product_name
HAVING qtr_1 > 2000 AND qtr_2 > 2000 AND qtr_3 > 2000 AND qtr_4 > 2000
ORDER BY (qtr_1 + qtr_2 + qtr_3 + qtr_4) DESC;


WITH RankedProducts AS (
	SELECT products.product_id, products.product_name, QUARTER(orders.order_date) AS quarter,
		SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal,
		RANK() OVER(PARTITION BY QUARTER(orders.order_date) ORDER BY SUM(order_details.unit_price * order_details.quantity * (1 - discount)) DESC) AS product_rank
    FROM order_details
    JOIN products ON order_details.product_id = products.product_id
    JOIN orders ON order_details.order_id = orders.order_id
	GROUP BY products.product_id, QUARTER(orders.order_date)
)

SELECT product_name, quarter, FORMAT(subtotal, 2) AS subtotal
FROM RankedProducts
WHERE product_rank <= 3;


