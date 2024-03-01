# Northwind MySQL Custom Query Descriptions
## Overview
Documentation of the custom queries I have written. The queries are focused on product performance and start on [line 236](https://github.com/andrew-lundy/northwind-mysql/blob/main/northwind_queries.sql#L236).

### Find the top categories per region.
```
SELECT category_name, ship_region, total_quantity
FROM (
	SELECT categories.category_name, 
		orders.ship_region,
		SUM(order_details.quantity) as total_quantity, 
		ROW_NUMBER() OVER(PARTITION BY orders.ship_region ORDER BY SUM(order_details.quantity) DESC) as row_num
	FROM products
	JOIN categories ON products.category_id = categories.category_id
	JOIN order_details ON products.product_id = order_details.product_id
	JOIN orders ON order_details.order_id = orders.order_id
	GROUP BY categories.category_name, orders.ship_region
) AS TopCategories
WHERE row_num = 1;
```
The window function, `ROW_NUMBER()`, is used in the `FROM` clause of the main query to partition the data by the region the order was shipped to (`orders.ship_region`). Within each partition, the rows are ordered based on the sum of `order_details.quantity`, in descending order. `ROW_NUMBER()` assigns a unique sequential integer to each row within a partition result set. In this query, the number gets reset to "1" for each new region (i.e., each new partition).

In the main query, the results of the subquery are filtered to records that contain "1" in column `row_num`. This ensures only the category with the most products sold in a region are returned in the main query. Three columns are selected in the main query - the category name, region number, and total number of products sold from the category.

The result:<br>

| category_name | ship_region | total_quantity |
| ----------- | ----------- | -----------      |
| Beverages   | 1 			| 5735             |
| Beverages   | 2           | 2214             | 
| Beverages   | 3           | 1577             |
| Beverages   | 4           | 73               |

-- The same query can be done using a Common Table Expression --
```
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
```

### Find the top product for a single region; 'top product' meaning highest quantity sold.
This query uses two inner joins to combine data from three tables, `order_details`, `orders`, and `products`. It filters the results by the region the product was shipped in (3 in this example), and orders the results by the quantity of the product shipped in descending order. It then limits the amount of results by 1 to ensure we get the top product.

```
SELECT products.product_id, products.product_name, order_details.quantity, orders.ship_region
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
JOIN products ON order_details.product_id = products.product_id
WHERE ship_region = 3
ORDER BY quantity DESC
LIMIT 1;
```
### Find the top product for each region; 'top product' meaning highest quantity sold.
```
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
```

### Find the top salesperson for each region; 'top' meaning they have the most sales by total dollar amount.
OPTIMIZATION: If formatting the subtotal is not neccessary on the database layer, `formatted_subtotal` can be removed and the formatting can be done on the application side. In testing, this reduced the mean query duration from 0.0072 to 0.0052.
```
SELECT CONCAT(first_name, ' ', last_name) AS salesperson, formatted_subtotal, ship_region AS region
FROM (
	SELECT 
		employees.employee_id,
		employees.first_name,
		employees.last_name,
		orders.ship_region,
		SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal,
		FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as formatted_subtotal,
		ROW_NUMBER() OVER(PARTITION BY ship_region ORDER BY SUM(order_details.unit_price * order_details.quantity * (1 - discount)) DESC) as row_num
	FROM employees
	JOIN orders on employees.employee_id = orders.employee_id
	JOIN order_details ON orders.order_id = order_details.order_id
	GROUP BY employee_id, ship_region
) AS top_salesperson
WHERE row_num = 1;
```

### View all products and their sales per quarter of each year.
```
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
```

### View all products and their total sales per quarter.
```
SELECT products.product_name,
    SUM(CASE WHEN QUARTER(orders.order_date) = 1 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS 'qtr_1',
	SUM(CASE WHEN QUARTER(orders.order_date) = 2 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS 'qtr_2',
    SUM(CASE WHEN QUARTER(orders.order_date) = 3 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS 'qtr_3',
    SUM(CASE WHEN QUARTER(orders.order_date) = 4 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS 'qtr_4'
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY products.product_name;
```

## HERE: The following prompts were recommended by: https://chat.openai.com/share/c0e6a00d-9d36-43fd-84ac-0714af9898ee.
### 1. Product Sales Analysis: How can we assess the performance of individual products in terms of sales? Are there specific products that consistently outperform others?
To accomplish this, I wrote a query that finds all products and their total sales (subtotals). Then, it finds the average of those subtotals.
This would indicate a product that performs better than average.
```
SELECT product_id, product_name, formatted_subtotal FROM (
	SELECT order_details.product_id AS product_id, products.product_name AS product_name, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	GROUP BY product_id
) AS product_subtotals
WHERE subtotal > @average
ORDER BY subtotal DESC;
```

### 2. Inventory Management: Are there products in the database that have low sales and high inventory levels? How can we identify and address potential overstock issues for these products?
First, define 'low sales' and 'high inventory'. 'High inventory' = `units_in_stock` is greater than the average of all `units_in_stock` count combined. 'Low sales' = less than average, based on the subtotal.
```
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
```

**Query that finds products with less than average sales and greater than the average "in stock" total.**
```
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
```

### 3. Product Category Performance: Are there particular product categories that perform better than others? Can we analyze sales, profitability, and customer preferences within different categories?
Find categories and their total sales (add "total amount of products for each category")
```
SELECT categories.category_name, 
	FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal,
    COUNT(order_details.quantity) AS orders_with_cat,
    COUNT(DISTINCT products.product_id) AS products_per_cat
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN order_details ON products.product_id = order_details.product_id
GROUP BY categories.category_id
ORDER BY SUM(order_details.unit_price * order_details.quantity * (1 - discount)) DESC;
```

## Seasonal Trends: Do certain products exhibit seasonal sales patterns?
### Top 3 products per quarter (by sales).
```
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
```

### List the products and their sales per quarter.
(This can be modified to use a WHERE clause to filter by year. Example: WHERE YEAR(orders.order_date) = 1997)
```
SELECT products.product_name,
	SUM(CASE WHEN QUARTER(orders.order_date) = 1 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_1,
    SUM(CASE WHEN QUARTER(orders.order_date) = 2 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_2,
	SUM(CASE WHEN QUARTER(orders.order_date) = 3 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_3,
    SUM(CASE WHEN QUARTER(orders.order_date) = 4 THEN order_details.unit_price * order_details.quantity * (1 - discount) ELSE 0 END) AS qtr_4
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY products.product_name;
```

### Find the top 3 suppliers based on the number of products they sell.
```
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
```

### Find the top shipper.
```
SELECT ship_via AS shipper_id, shippers.company_name, COUNT(ship_via) AS shipment_count
FROM orders
JOIN shippers ON orders.ship_via = shippers.shipper_id
GROUP BY ship_via
ORDER BY shipment_count DESC
LIMIT 1;
```

### Categories and their subtotals only.
```
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
```

### Total sales per product.
```
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
```

### Category product count.
```
SELECT categories.category_name, COUNT(DISTINCT products.product_id) AS product_count
FROM categories
JOIN products USING (category_id)
JOIN order_details USING (product_id)
GROUP BY categories.category_id, categories.category_name;
```