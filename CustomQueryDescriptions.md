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

The result:<br>

| product_id | product_name | quantity 		   | ship_region
| ---------- | -----------  | ---------------- | ----------
|  60        | C 			| 5735             | 3		   |

### Find the top product for each region; 'top product' meaning highest quantity sold.
This query uses a subquery that joins three tables (`products`, `order_details`, and `orders`). The subquery uses the window function `ROW_NUMBER()` to partition the data based on the region the product was shipped to. It orders these results by the total quantity of each product shipped in descending order. 

In the outer query, the results of the subquery are filtered to records that contain "1" in column `row_num`. This ensures only the products with the highest quantity sold in each region is returned in the main query. Four columns are selected in the main query - the product ID, product name, the sales count for the product, and the region the order was shipped to.


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
This query contains a subquery that uses two inner joins to combine data from three tables, `employees`, `orders`, and `order_details`. The subquery's `SELECT` statement retrieves data from the tables that represents the sales of each salesperson; the `GROUP BY` clause groups this data by the employee's ID and the region the sale took place in. 

There is a window function, `ROW_NUMBER()`, used to partition the data based on the region, and order it based on the subtotal of each salesperson's sales in the region in descending order. This ensures the top sales person in each region is ranked first in the partition.

The outer query selects 4 total columns, concatenating two of them as `salesperson`. The other two columns contain the subtotal and region. Because of the window function `ROW_NUMBER()` in the subquery, the outer query has access to the `row_num` column and can filter the data to only display the top salesperson per region based on the rows that contain `1` in the column.

OPTIMIZATION: If formatting the subtotal is not neccessary on the database layer, `formatted_subtotal` can be removed and the formatting can be done on the application side. In testing, this reduced the mean query duration from 0.0072 to 0.0052.
```
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
```

### View all products and their sales per quarter of each year.
This query combines data from three tables, `products`, `order_details`, and `orders`. The `SELECT` statement specifies five columns; the product name, quarters 1-4 with the product's total sales for the quarter, and the year. This data is grouped together using `product_name` and `order_year` via the `GROUP BY` clause to ensure the data is organized by each product and the year the sales were made.

In the `SELECT` statement, the query uses a `CASE` statement within the `SUM` function to calculate the total sales for each product per quarter. It checks the order date's quarter and calculates the sum of sales for that period by multiplying the `unit_price` by the `quantity` of products sold and adjusting for any `discount` (`order_details.unit_price * order_details.quantity * (1 - discount)`). 

If the condition is not met (i.e., the order date does not fall within the specified quarter in the `CASE` statement), the `ELSE` clause sets the value to `0`; effectively excluding those sales from the sum. A `FORMAT` function is then used to format the sum of sales as a decimal with 0 decimal places. The columns are aliased as `qtr_1`, `qtr_2`, `qtr_3`, and `qtr_4`.

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
This query is aimed at obtaining a seasonal overview of each product's sales; i.e., total sales per quarter of the year. To do this, two `JOIN` clauses are used to combine the data of three tables: `products`, `order_details`, and `orders`. The `SELECT` statement uses four `CASE` statements, each of which check the quarter of `order_date` and calculates the total sales for the product based on the specified quarter in the `CASE` statement. 

If a record does not match the specified order date, the `ELSE` clause sets the value to `0`. This acts as a filter on the data, only retrieving the data for the specified quarter. The sales outside of the specified quarter do not contribute to the sum for that quarter, this is why they are filtered out. Filtering out the sales based on their quarter helps isolate each quarter's data and ensure an accurate analysis of the seasonal sales. 

Each of the `CASE` statements are surrounded by a `SUM` function, which calculates the sum of the product's sales per quarter, taking into account all orders. The results are grouped by `product_name` to ensure there is only one row per product.

```
SELECT product_id, product_name, formatted_subtotal 
FROM (
	SELECT order_details.product_id AS product_id, products.product_name AS product_name, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	GROUP BY product_id
) AS product_subtotals
WHERE subtotal > @average
ORDER BY subtotal DESC;
```

## HERE: The following prompts were recommended by: https://chat.openai.com/share/c0e6a00d-9d36-43fd-84ac-0714af9898ee.
### 1. Product Sales Analysis: How can we assess the performance of individual products in terms of sales? Are there specific products that consistently outperform others?
To accomplish this, I wrote a query that finds all the products and their total sales (subtotals). Then, it filters the results to products that have a subtotal greater than the average, which is stored in the user-defined variable `@average`. This would indicate a product that performs better than average.

There is a subquery in the main query's `FROM` statement which creates a table that represents the products and their total sales by retrieving `product_id`, `product_name`, `subtotal`, and `formatted_subtotal`. The two "subtotal" columns calculate the subtotal by multiplying the product's price (`order_details.unit_price`) by the number of products sold (`order_details.quantity`), and then accounts for any discounts by multiplying these two columns by ***(1 - `order_details.discount`)***.

```
SELECT product_id, product_name, formatted_subtotal 
FROM (
	SELECT order_details.product_id AS product_id, products.product_name AS product_name, SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal, 
    FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as formatted_subtotal
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