# Northwind MySQL Queries & Reworked Database Structure
## Overview
In the process of learning MySQL, I am reworking the Northwind database to use world regions. I have also written a collection of sample queries based on prompts from [geeksengine.com](https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php), alongside a number of custom prompts. I am adding the world regions because the `suppliers` table containes a `region` column that uses the 4 main regions. The rest of the database does not use these same values whenever a "region" is mentioned. The `ship_region` from the `orders` table, `region` from the `employees` table, `region` from the `customers` table - they all reference states or provinces.
<br><br>
**The purpose of this project** is to get hands-on with MySQL and work with an existing database. From making queries that add and update new data, to altering the structure of the database. To do this, I've laid out some milestones:
- [x] Finish the queries from [geeksengine.com](https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php)
- [x] Update the regions used in the database to use the four main regions of the world (EMEA, NA, LATAM, APAC)<br>
    - [x] Tables to Update<br>
        - [x] Orders<br>
        - [x] Customers<br>
        - [x] Employees<br>
        - [x] Territories<br>
        - [x] Region<br>
        - [x] Suppliers<br>
- [x] Add new territories based on the cities of the `orders` table
- [x] Update `region` column in `customers` table to `state`
- [x] Add `region` column to `customers` table; use the new world regions
- [x] Update `ship_region` column in `orders` table to `state`
- [x] Add `ship_region` column to `orders` table; use the new world regions
- [x] Update `region` column in `employees` table to `state`
- [x] Add `region` column to `employees` table; use the new world regions
- [x] Add some orders from APAC
- [ ] Make some queries with the new data; top products per region, top salesperson per region, etc.
<br><br>
## Installation
The project does not contain any installation steps. To create the tables and add the data, use the [northwind_creation_and_insertion.sql file](https://github.com/andrew-lundy/northwind-mysql/blob/main/northwind_creation_and_insert.sql).