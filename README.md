# Northwind MySQL Queries & Reworked Database Structure
## Description
In the process of learning MySQL, I have reworked the Northwind database to use world regions. I have also written a collection of sample queries based on prompts from [geeksengine.com](https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php), alongside a number of custom prompts.
<br><br> 
I have added the world regions because the `suppliers` table containes a `region` column that uses the 4 main regions. The rest of the database does not use these same values whenever a "region" is mentioned. The `ship_region` from the `orders` table, `region` from the `employees` table, `region` from the `customers` table - they all reference states or provinces.
<br><br>
**The purpose of this project** is to get hands-on with MySQL and work with an existing database. This entails writing queries that add and update new data, as well as altering the structure of the database. To do this, I've laid out some milestones:
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
- [x] Add orders from APAC
- [x] Write custom queries that focus on product performance; top products per region, top salesperson per region, etc.
<br><br>

## Installation
This Bash script creates a database, then it proceeds to create the tables and insert the Northwind sample data.

1. Clone the repo or download the ZIP file.
2. Locate and open the Bash file named `northwind_table_creation.sh`.
3. Edit the script to enter the username, password, and host information into their respective variables.
4. Navigate to the project directory in your terminal and run the script by executing the command `bash northwind_table_creation.sh`.

## Schema
The database schema can be opened in MySQL Workbench and is found in [Northwind-ER-Diagram](https://github.com/andrew-lundy/northwind-mysql/blob/main/Northwind-ER-Diagram.mwb).

It can also be opened as a PDF in [northwind_schema.pdf](https://github.com/andrew-lundy/northwind-mysql/blob/main/northwind_schema.pdf).


## Custom Query Documentation
The documentation for the custom queries I have written can be found here: [CustomQueryDescriptions.md](https://github.com/andrew-lundy/northwind-mysql/blob/main/CustomQueryDescriptions.md).

## Data Visualizations
There are some [data visualizations in Grafana](https://andrewlundy.grafana.net/dashboard/snapshot/FFZBgH7U9ncMn2dwVfcpdFNn9SWIFm4e) to go along with a few of the queries.