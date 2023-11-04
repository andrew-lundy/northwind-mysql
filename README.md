# northwind-mysql-queries
A collection of sample queries I wrote for the Northwind database using MySQL. Query prompts come from [geeksengine.com](https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php).
<br><br>
I'm in the process of reworking the database to use world regions. The changes to the database itself can be found here: https://github.com/andrew-lundy/northwind_mysql. The repo holds the queries needed to create the tables and insert the data.
<br><br>
The queries making those changes are found in the commits of the [repo you are currently viewing](https://github.com/andrew-lundy/northwind-mysql-queries/commits/dev).
<br><br>
**The purpose of this project** is to get hands-on with MySQL and work with an existing database. From making queries that add and update new data, to altering the structure of the database. To do this, I've laid out some milestones:
- [x] Finish the queries from [geeksengine.com](https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php)
- [ ] Update the regions used in the database to use the four main regions of the world (EMEA, NA, LATAM, APAC)<br>
    - [ ] Tables to Update<br>
        - [ ] Territories<br>
        - [ ] Employees<br>
        - [ ] Orders<br>
        - [ ] Customers<br>
        - [x] Region<br>
        - [x] Suppliers<br>
- [x] Add new territories based on the cities of the `orders` table
- [ ] Update `region` column in `customers` table to `state`
- [ ] Add `region` column to `customers` table; use the new world regions
- [ ] Update `ship_region` column in `orders` table to `state`
- [ ] Add `ship_region` column to `orders` table; use the new world regions
<br>