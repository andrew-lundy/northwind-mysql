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

## The following prompts were recommended by: https://chat.openai.com/share/c0e6a00d-9d36-43fd-84ac-0714af9898ee.
For this section, there were a couple of queries where I needed to know the average subtotal of all the products. I used a stored procedure to accomplish this.

The first thing to do is change the delimiter using the `DELIMITER` command. I changed it from `;` to `//`. This allows the use of `;` within the stored procedure.

Then, the stored procedure is created with an `OUT` parameter named `average`. This parameter holds the result of the procedure. The data returned from the queries within the stored procedure will be held in this parameter and returned when calling the procedure.

The body of a procedure is enclosed in the `BEGIN` and `END` block. The body contains the queries that are executed when the procedure is called. The `SELECT` statement calculates the average of `subtotal`, which is derived from a subquery within the `FROM` statement. The `FROM` statement pulls data from two tables, `order_details` and `products`, that represents the total sales per product. These results act as a temporary table for the outer query. It selects the product name (`products.product_name`) and calculates the subtotals of the product orders (`SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal`). The results are grouped by `products.product_name` and ordered by `subtotal` in descending order, placing the product with the most sales at the top. The body is closed with `END`. 

The delimiter gets changed back to `;`. The stored procedure is called by using the `CALL` statement. To select the value of the stored procedure's `OUT` parameter, use `SELECT @average`.

```
DELIMITER //
CREATE PROCEDURE FindAverageSubtotal(OUT average DECIMAL(10,2))
BEGIN
	SELECT AVG(subtotal) INTO average
	FROM (
		SELECT products.product_name, 
		SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal,
		FROM products
		JOIN order_details ON products.product_id = order_details.product_id
		GROUP BY products.product_name
		ORDER BY subtotal DESC
	) AS product_subtotal_averages;
END //
DELIMITER ;

CALL FindAverageSubtotal(@average);
SELECT @average;
```

### 1. Product Sales Analysis: How can we assess the performance of individual products in terms of sales? Are there specific products that consistently outperform others?
To accomplish this, I wrote a query that finds all the products and their total sales (subtotals). Then, it filters the results to products that have a subtotal greater than the average subtotal of all products, which is stored in the user-defined variable `@average`. The results are ordered by their subtotals, in descending order.

There is a subquery in the main query's `FROM` statement which creates a table that represents the products and their total sales by retrieving `product_id`, `product_name`, `subtotal`, and `formatted_subtotal` from two tables, `order_details` and `products`. These two tables are joined on `product_id`.

The two "subtotal" columns calculate the subtotal by multiplying the product's price (`order_details.unit_price`) by the number of products sold (`order_details.quantity`), and then accounts for any discounts by multiplying these two columns by ***(1 - `order_details.discount`)***.

Since the aggregate function `SUM` is used, the data must be grouped. Here, the data is grouped by `product_id`, with the total sales of that product represented in the `subtotal` column. 

```
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
```

### 2. Inventory Management: Are there products in the database that have low sales and high inventory levels? How can we identify and address potential overstock issues for these products?
First, define 'low sales' and 'high inventory'. 'High inventory' = higher than average `units_in_stock` value. 'Low sales' = a less than average subtotal.


**Query that finds products with less than average sales and greater than the average "in stock" total.**

A subquery is used in the `FROM` statement to retrieve information from two tables (`order_details` and `products`) about products such as the name, units in stock, and subtotal. The `WHERE` clause filters results by selecting all records that have more than the average amount of items in stock. Because of the use of the aggregate function `SUM()`, the results are grouped by `product_id`, `product_name`, and `units_in_stock` - representing a single, unique product per group.


The `HAVING` clause filters the aggregated results by records that contain sales totals which are below the average. `subtotal` represents the aggregated subtotals of the groups defined by `GROUP BY`. `@average` is a placeholder that contains the value of the average subtotal across all products; this value is set in a stored procedure ($16,278.50). The results are then ordered by the `subtotal` in descending order. Finally, a table alias must be used on the `FROM` statement. Here, `LowSalesHighInventoryProducts` is used.

```
SELECT lowPerformingProducts.product_name,
    lowPerformingProducts.units_in_stock,
    lowPerformingProducts.formatted_subtotal
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
	GROUP BY order_details.product_id
	HAVING subtotal < @average  
	ORDER BY subtotal DESC
) AS lowPerformingProducts;
```

### 3. Product Category Performance: Are there particular product categories that perform better than others? Can we analyze sales, profitability, and customer preferences within different categories?
This query retrieves data from three tables, `categories`, `products`, and `order_details`; which are joined together by two `JOIN` statements. Four columns are retrieved, which represent categories alongside their subtotal (`formatted_subtotal`), the number of times a product from the category is ordered, (`orders_with_cat`), and the total number of products within the category (`products_per_cat`).


To ensure each row represents a single category, results are grouped by `category_id`. Finally, the aggregated results are ordered by the subtotal, which is calculated by `SUM(order_details.unit_price * order_details.quantity * (1 - discount))`.

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
This query uses a Common Table Expression (CTE) to retrieve data from four tables (`order_details`, `products`, `orders`, and `categories`) that represents each product's total sales for each quarter. It does this by selecting the product name (`product_name`), category name (`category_name`), quarter of the product's order date (`QUARTER(orders.order_date)`), and subtotal (`SUM(order_details.unit_price * order_details.quantity * (1 - discount))`).

It also uses the window function `RANK()` to rank the results within partitions, which are defined by the order date's quarter (`QUARTER(orders.order_date)`). The partitions are ordered by `subtotal` in descending order to ensure the products with the most sales per quarter are at the top of the list.

The results are then grouped by `product_id`, `category_name`, and `QUARTER(orders.order_date)`. This grouping ensures that each `subtotal` represents a single product and category for each quarter. Also note the `RANK()` function depends on the grouping to accurately calculate and order the results.

After the CTE `RankedProducts` is used to rank the products, the final `SELECT` statement retrieves four columns from the CTE: `product_name`, `quarter`, `FORMAT(subtotal, 2)`, and `category_name`. Then, the results are filtered by the ranking order produced by the window function `RANK()`; only the top three products from each partition will be included in the results.

```
WITH RankedProducts AS (
	SELECT products.product_name, 
        categories.category_name, 
        QUARTER(orders.order_date) AS quarter,
		SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal,
		RANK() OVER(PARTITION BY QUARTER(orders.order_date) ORDER BY SUM(order_details.unit_price * order_details.quantity * (1 - discount)) DESC) AS product_rank
    FROM order_details
    JOIN products ON order_details.product_id = products.product_id
    JOIN orders ON order_details.order_id = orders.order_id
    JOIN categories ON categories.category_id = products.category_id
	GROUP BY products.product_name, categories.category_name, QUARTER(orders.order_date)
)
SELECT product_name, quarter, FORMAT(subtotal, 2) AS subtotal, category_name
FROM RankedProducts
WHERE product_rank <= 3;
```

### List the products and their sales per quarter.
(This can be modified to use a WHERE clause to filter by year. Example: WHERE YEAR(orders.order_date) = 1997)

This query uses the `SELECT` statement to retrieve a product's name (`product_name`) and the subtotal for each quarter of the year. To represent the subtotal for each quarter, the `CASE` statement is used to check the quarter of `order_date`, and based on the value (`1`, `2`, `3` or `4`) it calculates the subtotal using the same formula used in previous queries: `order_details.unit_price * order_details.quantity * (1 - discount)`. If the product has no subtotal for the quarter, `0` is placed in the column.

To retrieve this data, three tables are joined together: `products`, `order_details`, and `orders`. The results are grouped by `product_name`.

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
This query uses a Common Table Expression that retrieves the supplier ID (`suppliers.supplier_id`), the company name of the supplier (`suppliers.company_name`), and the total product count for the supplier (`COUNT(products.supplier_id)`), where this `COUNT()` function only counts non-null records in the `products.supplier_id` column. 

It also uses the window function `RANK()` to rank the suppliers based on how many products they supply. This is done by counting the total rows in each group using the function `COUNT(*)` and ordering them in descending order. There is no `PARTITION BY` clause because this query is ranking the overall results. The `GROUP BY` statement is used to group the results by `suppliers.supplier_id` and `suppliers.company_name`. This ensures the results are grouped by each supplier. 

The final three lines of the query retrieve data from the CTE that represents the top three suppliers based on their rank. The columns retrieved include `supplier_id`, `company_name`, `product_count`, and `supplier_rank`. The `WHERE` clause is used to filter records to only the top 3 suppliers.

As SQL does not allow the `WHERE` clause to filter using results from a window function, such as `RANK()`, using a CTE offers a workaround to this as it allows us to calculate the `supplier_rank` and then filter the results.

```
WITH RankedSuppliers AS (
	SELECT suppliers.supplier_id, 
		suppliers.company_name,
		COUNT(products.supplier_id) AS product_count,
		RANK() OVER(ORDER BY COUNT(*) DESC) as supplier_rank
	FROM products
    JOIN suppliers ON products.supplier_id = suppliers.supplier_id
	GROUP BY suppliers.supplier_id, suppliers.company_name
)
SELECT supplier_id, company_name, product_count, supplier_rank
FROM RankedSuppliers
WHERE supplier_rank <= 3;
```

### Find the top shipper.
This query retrieves data from two tables (`shippers` and `orders`) that represents the shipping company (`shippers.company_name`) and the number of orders they have shipped (`COUNT(orders.ship_via)`). The results are grouped by `shippers.company_name` name and ordered by `shipment_count` in descending order. To ensure only the top shipping company is listed, `LIMIT 1` is used.

```
SELECT shippers.company_name, COUNT(orders.ship_via) AS shipment_count
FROM orders
JOIN shippers ON orders.ship_via = shippers.shipper_id
GROUP BY shippers.company_name
ORDER BY shipment_count DESC
LIMIT 1;
```

### Categories and their subtotals and product count.
This query uses a CTE named `CategorySales` and retrieves data from three tables, `categories`, `products`, and `order_details`. The columns retrieved include the category's name (`categories.category_name`), the subtotal (`SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal`) and formatted subtotal (`FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal`). The formatted subtotal wraps the `SUM()` function with the `FORMAT()` function, which formats the subtotal into a currency (USD). The query also retrieves the total product count (`COUNT(DISTINCT products.product_id)`).

The results are grouped by `categories.category_name` and ordered by `subtotal` in descending order. In this query, the `JOIN` clauses utilize the `USING` keyword instead of `ON`, which makes the `JOIN` statement more readable since the columns have identical names. The tables `categories` and `products` are joined using the `category_id` column, while `products` and `order_details` are joined using the `product_id` column.

The final part of the query retrieves the category name, formatted subtotal, and total product count for each category from the `CategorySales` CTE.

```
WITH CategorySales AS (
	SELECT categories.category_name, 
		SUM(order_details.unit_price * order_details.quantity * (1 - discount)) as subtotal, 
        FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal, 
        COUNT(DISTINCT products.product_id) AS product_count
	FROM categories
	JOIN products USING (category_id)
	JOIN order_details USING (product_id)
	GROUP BY categories.category_name
	ORDER BY subtotal DESC
)
SELECT category_name, formatted_subtotal, product_count
FROM CategorySales;
```

### Total sales per product.
This query uses a subquery that retrieves data from two tables, `order_details` and `products`. The subquery retrieves the columns `products.product_name`, and the subtotal as calculated by the equation `SUM(order_details.unit_price * order_details.quantity * (1 - discount))`. It also retrieves the formatted subtotal by wrapping the same equation in the `FORMAT()` function.

The results of the subquery are grouped by the product name (`products.product_name`) and then ordered by their subtotals (`subtotal`) in descending order.

The outer query retrieves the product name (`product_name`) and formatted subtotal of each product (`formatted_subtotal`).

```
SELECT product_name, formatted_subtotal
FROM (
	SELECT products.product_name,
        SUM(order_details.unit_price * order_details.quantity * (1 - discount)) AS subtotal, 
        FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) AS formatted_subtotal
	FROM order_details
	JOIN products ON order_details.product_id = products.product_id
	GROUP BY products.product_name
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