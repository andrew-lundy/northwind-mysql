-- Start of "Part 1" (https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php)
-- For each order, calculate a subtotal. 
SELECT orders.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal, COUNT(products.product_id) AS products
FROM orders 
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
GROUP BY orders.order_id
ORDER BY orders.order_id;

-- Find the total amount of orders for each year.
SELECT YEAR(orders.order_date) AS Year, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY Year;

-- Find all sales; describe each sale (order id, shipped date, subtotal, year) and order by the most recent orders.
SELECT orders.order_id AS OrderID, orders.shipped_date AS shipped_date, b.subtotal, YEAR(orders.shipped_date) as year
FROM orders
JOIN (
	SELECT order_details.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal
	FROM order_details
	GROUP BY order_details.order_id
) AS b
ON orders.order_id = b.order_id
ORDER BY Year DESC;

-- For each employee, get their total sales amount per country.
SELECT orders.ship_country, employees.first_name, employees.last_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
JOIN employees ON orders.employee_id = employees.employee_id
GROUP BY orders.employee_id, orders.ship_country
ORDER BY orders.employee_id;


-- For each employee, get their sales details broken down by country.
SELECT orders.ship_country, orders.order_id, employees.first_name, employees.last_name, b.subtotal
FROM orders
JOIN employees ON orders.employee_id = employees.employee_id
JOIN (
	SELECT order_details.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal
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
SELECT order_details.order_id as order_id, order_details.product_id as product_id, products.product_name as product_name, order_details.unit_price as unit_price, order_details.quantity as quantity, order_details.discount as order_discount, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal
FROM order_details
JOIN products ON order_details.product_id = products.product_id
GROUP BY order_id, product_id, unit_price, quantity, order_discount;

-- Sales by category; for each category, we get the list of products sold and the total sales amount.
SELECT categories.category_name, products.product_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal
FROM categories
JOIN products USING (category_id)
JOIN order_details USING (product_id)
GROUP BY categories.category_id, categories.category_name, products.product_name;

-- Ten most expensive producs
SELECT products.product_name, products.unit_price
FROM products
ORDER BY products.unit_price DESC
LIMIT 10;

-- Top 5 selling products
SELECT product_name, formatted_subtotal
FROM (
	SELECT order_details.product_id, products.product_name, products.units_in_stock, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	WHERE products.units_in_stock > (
		SELECT AVG(products.units_in_stock)
		FROM products
	)
	GROUP BY order_details.product_id, products.product_name, products.units_in_stock
	ORDER BY subtotal DESC
    LIMIT 5
) AS LowSalesHighInventoryProducts;

-- Products by category
SELECT DISTINCT categories.category_name, products.product_name
FROM categories
JOIN products ON categories.category_id = products.category_id
ORDER BY categories.category_name, products.product_name;

-- How many products per category
SELECT DISTINCT categories.category_name, COUNT(products.product_name) AS products_per_category
FROM categories
JOIN products ON categories.category_id = products.category_id
GROUP BY categories.category_name
ORDER BY categories.category_name;

-- Active products by category
SELECT DISTINCT categories.category_name, products.product_name, products.discontinued
FROM categories
JOIN products ON categories.category_id = products.category_id
WHERE products.discontinued = 0
ORDER BY categories.category_name, products.product_name;

-- Customers and suppliers by city
SELECT customers.city, customers.company_name, customers.contact_name, 'Customers' AS relationship
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
SELECT orders.order_id, categories.category_name, products.product_name, order_details.quantity, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
JOIN categories ON products.category_id = categories.category_id
WHERE YEAR(orders.order_date) = 1997
GROUP BY orders.order_id, categories.category_name, products.product_name, order_details.quantity;

-- Category sales for 1997
SELECT categories.category_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as subtotal
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
    customers.company_name AS customer_company, 
    customers.contact_name AS customer_contact, 
    customers.phone AS customer_phone,
    orders.employee_id AS employee_of_sale, 
    CONCAT(employees.first_name, " ", employees.last_name) AS sales_person,
    order_details.quantity AS product_count,
    products.product_name AS product_name,
    order_details.unit_price * order_details.quantity * (1 - discount) as subtotal,
    orders.order_date AS order_date, 
    orders.required_date AS required_date, 
    orders.shipped_date AS shipped_date, 
    shippers.company_name AS shipping_company,
    shippers.phone AS shipping_co_phone,
    orders.freight AS freight,
    orders.ship_name AS shipping_label_name, 
    orders.ship_address AS shipping_label_address, 
    orders.ship_city AS shipping_label_city,
    orders.ship_postal_code AS shipping_label_zip, 
    orders.ship_country AS shipping_label_country
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN customers ON orders.customer_id = customers.customer_id
JOIN products ON order_details.product_id = products.product_id
JOIN employees ON orders.employee_id = employees.employee_id
JOIN shippers ON orders.ship_via = shippers.shipper_id
ORDER BY orders.order_id;

-- Number of units in stock by category and supplier continent
SELECT categories.category_name AS category, suppliers.region AS Region, SUM(products.units_in_stock) AS units_in_stock
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN suppliers ON products.supplier_id = suppliers.supplier_id
GROUP BY categories.category_name, suppliers.region;

-- OR
SELECT categories.category_name AS category,
	CASE
		WHEN suppliers.country IN ('UK', 'Sweden', 'Germany', 'France', 'Italy', 'Spain', 'Denmark', 'Netherlands', 'Finland', 'Norway') THEN 'EMEA'
        WHEN suppliers.country IN ('USA', 'Canada') THEN 'NA'
        WHEN suppliers.country IN ('Brazil') THEN 'LATAM'
        WHEN suppliers.country IN ('Japan', 'Singapore', 'Australia') THEN 'APAC'
        ELSE 'Unknown country; cannot find region'
    END as 'supplier_continent', 
    SUM(products.units_in_stock) AS units_in_stock
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
    
-- ---------------------------------------------------------------------------------------------------------------------

-- HERE: Start of custom queries; focused on product performance.
-- 1. Top categories per region
SELECT category_name, ship_region, total_quantity
FROM (
	SELECT categories.category_name, orders.ship_region, SUM(order_details.quantity) as total_quantity, ROW_NUMBER() OVER(PARTITION BY orders.ship_region ORDER BY SUM(order_details.quantity) DESC) as row_num
	FROM products
	JOIN categories ON products.category_id = categories.category_id
	JOIN order_details ON products.product_id = order_details.product_id
	JOIN orders ON order_details.order_id = orders.order_id
	GROUP BY categories.category_name, orders.ship_region
) AS TopCategories
WHERE row_num = 1;

-- The same query can be done using a Common Table Expression
WITH TopCategoriesCTE AS (
	SELECT categories.category_name, orders.ship_region, SUM(order_details.quantity) as total_quantity, ROW_NUMBER() OVER(PARTITION BY orders.ship_region ORDER BY SUM(order_details.quantity) DESC) as row_num
	FROM products
	JOIN categories ON products.category_id = categories.category_id
	JOIN order_details ON products.product_id = order_details.product_id
	JOIN orders ON order_details.order_id = orders.order_id
	GROUP BY categories.category_name, orders.ship_region
)
SELECT category_name, ship_region, total_quantity
FROM TopCategoriesCTE
WHERE row_num = 1;

-- 2. Find the top product for a single region; 'top product' meaning highest quantity sold.
SELECT products.product_id, products.product_name, order_details.quantity, orders.ship_region
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
JOIN products ON order_details.product_id = products.product_id
WHERE ship_region = 3
ORDER BY quantity DESC
LIMIT 1;

-- 3. Find the top product for each region; 'top product' meaning highest quantity sold.
SELECT product_id, product_name, sales_count, ship_region, row_num
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

SELECT
	products.product_id,
	products.product_name,
	order_details.quantity AS sales_count,
	orders.ship_region,
	ROW_NUMBER() OVER(PARTITION BY orders.ship_region ORDER BY order_details.quantity DESC) as row_num
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id;

-- 4. Find the top salesperson for each region; 'top' meaning they have the most sales by total dollar amount.
-- OPTIMIZATION: If formatting the subtotal is not neccessary on the database layer, `formatted_subtotal` can be removed and the formatting can be done on the application side. In testing, this reduced the mean query duration from 0.0072 to 0.0052.
SELECT CONCAT(first_name, ' ', last_name) AS salesperson, formatted_subtotal, ship_region AS region
FROM (
	SELECT 
		employees.employee_id,
		employees.first_name,
		employees.last_name,
		orders.ship_region,
        FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as formatted_subtotal,
		ROW_NUMBER() OVER(PARTITION BY ship_region ORDER BY SUM(order_details.unit_price * order_details.quantity * (1 - discount)) DESC) as row_num
	FROM employees
	JOIN orders on employees.employee_id = orders.employee_id
	JOIN order_details ON orders.order_id = order_details.order_id
	GROUP BY employee_id, ship_region
) AS top_salesperson
WHERE row_num = 1;

-- 5. View all products and their sales per quarter of each year.
SELECT products.product_name,
    FORMAT(SUM(CASE WHEN QUARTER(orders.order_date) = 1 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END), 0) AS 'qtr_1',
	FORMAT(SUM(CASE WHEN QUARTER(orders.order_date) = 2 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END), 0) AS 'qtr_2',
    FORMAT(SUM(CASE WHEN QUARTER(orders.order_date) = 3 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END), 0) AS 'qtr_3',
    FORMAT(SUM(CASE WHEN QUARTER(orders.order_date) = 4 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END), 0) AS 'qtr_4',
    YEAR(orders.order_date) AS order_year
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY products.product_name, order_year;

-- 6. View all products and their total sales per quarter.
SELECT products.product_name,
    SUM(CASE WHEN QUARTER(orders.order_date) = 1 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS 'qtr_1',
	SUM(CASE WHEN QUARTER(orders.order_date) = 2 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS 'qtr_2',
    SUM(CASE WHEN QUARTER(orders.order_date) = 3 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS 'qtr_3',
    SUM(CASE WHEN QUARTER(orders.order_date) = 4 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS 'qtr_4'
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY products.product_name;

-- HERE: The following prompts were recommended by: https://chat.openai.com/share/c0e6a00d-9d36-43fd-84ac-0714af9898ee.
DELIMITER //
CREATE PROCEDURE FindAverageSubtotal(OUT average DECIMAL(10,2))
BEGIN
	SELECT AVG(subtotal) INTO average
	FROM (
		SELECT products.product_name, 
		SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal,
		FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal
		FROM products
		JOIN order_details ON products.product_id = order_details.product_id
		GROUP BY products.product_name
		ORDER BY subtotal DESC
	) AS product_subtotal_averages;
END //
DELIMITER ;

CALL FindAverageSubtotal(@average);
SELECT @average;

-- 1. Product Sales Analysis: How can we assess the performance of individual products in terms of sales? Are there specific products that consistently outperform others?
-- To accomplish this, I wrote a query that finds all products and their total sales (subtotals). Then, it finds the average of those subtotals.
-- This would indicate a product that performs better than average.
SELECT product_id, product_name, formatted_subtotal 
FROM (
	SELECT order_details.product_id AS product_id,
	products.product_name AS product_name, 
	SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal, 
    FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	GROUP BY product_id
) AS product_subtotals
WHERE subtotal > @average
ORDER BY subtotal DESC;

-- 2. Inventory Management: Are there products in the database that have low sales and high inventory levels? How can we identify and address potential overstock issues for these products?
-- First, define 'low sales' and 'high inventory'. 'High inventory' = `units_in_stock` is greater than the average of all `units_in_stock` count combined. 'Low sales' = less than average, based on the subtotal.

-- Query that finds products, their current "in stock" total, and subtotal of sales.
SELECT
	LowSalesHighInventoryProducts.product_name,
    LowSalesHighInventoryProducts.units_in_stock,
    LowSalesHighInventoryProducts.formatted_subtotal
FROM (
	SELECT 
		products.product_name, 
        products.units_in_stock, 
        SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal, 
        FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	WHERE products.units_in_stock > (
		SELECT AVG(products.units_in_stock)
		FROM products
	)
	GROUP BY order_details.product_id, products.product_name, products.units_in_stock
	HAVING subtotal < @average  
	ORDER BY subtotal DESC
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

-- Seasonal Trends: Do certain products exhibit seasonal sales patterns?
-- Top 3 products per quarter (by sales)
WITH RankedProducts AS (
	SELECT products.product_id, products.product_name, categories.category_name, QUARTER(orders.order_date) AS quarter,
		SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal,
		RANK() OVER(PARTITION BY QUARTER(orders.order_date) ORDER BY SUM(order_details.unit_price * order_details.quantity * (1 - discount)) DESC) AS product_rank
    FROM order_details
    JOIN products ON order_details.product_id = products.product_id
    JOIN orders ON order_details.order_id = orders.order_id
    JOIN categories ON categories.category_id = products.category_id
	GROUP BY products.product_id, categories.category_name, QUARTER(orders.order_date)
)
SELECT product_name, quarter, FORMAT(subtotal, 2) AS subtotal, category_name
FROM RankedProducts
WHERE product_rank <= 3;

-- List the products and their sales per quarter.
-- This can be modified to use a WHERE clause to filter by year. Example: WHERE YEAR(orders.order_date) = 1997
SELECT products.product_name,
	SUM(CASE WHEN QUARTER(orders.order_date) = 1 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_1,
    SUM(CASE WHEN QUARTER(orders.order_date) = 2 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_2,
	SUM(CASE WHEN QUARTER(orders.order_date) = 3 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_3,
    SUM(CASE WHEN QUARTER(orders.order_date) = 4 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_4
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY products.product_name;

-- Find the top 3 suppliers based on the number of products they sell.
WITH RankedSuppliers AS (
	SELECT suppliers.supplier_id, 
		suppliers.company_name,
		COUNT(suppliers.supplier_id) AS product_count,
		RANK() OVER(ORDER BY COUNT(*) DESC) as supplier_rank
	FROM products
    JOIN suppliers ON products.supplier_id = suppliers.supplier_id
	GROUP BY supplier_id
)
SELECT supplier_id, company_name, product_count, supplier_rank
FROM RankedSuppliers
WHERE supplier_rank <= 3;

-- Find the top shipper.
SELECT ship_via AS shipper_id, shippers.company_name, COUNT(ship_via) AS shipment_count
FROM orders
JOIN shippers ON orders.ship_via = shippers.shipper_id
GROUP BY ship_via
ORDER BY shipment_count DESC
LIMIT 1;

-- Categories and their subtotals only
WITH CategorySales AS (
	SELECT categories.category_name, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal, COUNT(DISTINCT products.product_id) AS product_count
	FROM categories
	JOIN products USING (category_id)
	JOIN order_details USING (product_id)
	GROUP BY categories.category_id, categories.category_name
	ORDER BY subtotal DESC
)
SELECT category_name, formatted_subtotal
FROM CategorySales;

-- Total sales per product
SELECT product_name, subtotal
FROM (
	SELECT order_details.product_id, products.product_name, products.units_in_stock, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	WHERE products.units_in_stock > (
		SELECT AVG(products.units_in_stock)
		FROM products
	)
	GROUP BY order_details.product_id, products.product_name, products.units_in_stock
	ORDER BY subtotal DESC
) AS TotalSalesPerProduct;

-- Category product count
SELECT categories.category_name, COUNT(DISTINCT products.product_id) AS product_count
FROM categories
JOIN products USING (category_id)
JOIN order_details USING (product_id)
GROUP BY categories.category_id, categories.category_name;
