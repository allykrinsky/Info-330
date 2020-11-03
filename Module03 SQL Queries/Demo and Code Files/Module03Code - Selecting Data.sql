--************** SQL Level 1 *****************--
-- This file highlights some of the most commonly used
-- SQL Statements; Select, Insert, Update, and Delete
--**********************************************************--

'*** Select Statements ***'
-----------------------------------------------------------------------------------------------------------------------
-- The SELECT main clauses are: SELECT, FROM, WHERE
SELECT CustomerID, CompanyName, ContactName 
 FROM Northwind.dbo.Customers  
  WHERE (CustomerID = 'alfki');

-- In most cases, SQL ignores SPACES, TAB, and CARRIAGE RETURNS. 
-- So, you will often see the Select Clause written like this.

SELECT -- Stacking the column listing; easier to read, but takes more space.	
	CustomerID, 
	CompanyName, 
	ContactName 
FROM Northwind.dbo.Customers
WHERE 
	(
	CustomerID = 'alfki' 
	OR 
	CustomerID = 'anatr'
	);

-- It even works like this, but it just does not look professional!.
SELECT	
CustomerID, 
			CompanyName, 
	ContactName 
                   FROM Northwind.dbo.Customers

WHERE 	(
								CustomerID = 'alfki' 
	OR 
CustomerID = 'anatr'	)

  
'*** Using the SELECT Clause ***'
-----------------------------------------------------------------------------------------------------------------------
-- This clause lists the columns you want in your result set.
-- even if the column does not exist in the database tables.
SELECT 5 + 4, 5 * 4;

--( Column Aliases )--
-- Alias are used to rename a column in the result set.
SELECT [Sum] = 5 + 4, [Product] = 5 * 4;
  
-- When you are reading code watch for Column Alias STYLE variations.
-- Alias in Front style
USE Northwind;

SELECT 'AVG Sales Price' = AVG(UnitPrice) FROM [Order Details]
SELECT "AVG Sales Price" = AVG(UnitPrice) FROM [Order Details]
SELECT [AVG Sales Price] = AVG(UnitPrice) FROM [Order Details]

-- Alias in Back style
SELECT AVG(UnitPrice) AS 'AVG Sales Price' FROM [Order Details]
SELECT AVG(UnitPrice) AS "AVG Sales Price" FROM "Order Details"
SELECT AVG(UnitPrice) AS [AVG Sales Price] FROM [Order Details]

-- Just being Lazy style
SELECT AVG(UnitPrice) 'AVG Sales Price' FROM [Order Details]

SET QUOTED_IDENTIFIER off
-- This setting changes the way Quotes are used in you scripts 
SELECT AVG(UnitPrice) AS "AVG Sales Price" 
 FROM "Order Details" -- You will get an error! 

-- So, using Square Brackets [] is recommended by many authors.
SELECT AVG(UnitPrice) AS [AVG Sales Price] 
 FROM [Order Details]

SET QUOTED_IDENTIFIER on

'*** Using the From Clause ***'
-----------------------------------------------------------------------------------------------------------------------
-- This clause lets you list one or more tables you want to get
-- data from.
-- Using one table
SELECT ProductName
 FROM Products;
 
-- The From clause recognizes schemas(namespaces) and Database names
SELECT CompanyName
 FROM dbo.Customers; -- using the "Database Owner" schema

SELECT CompanyName
 FROM Northwind.dbo.Customers; -- using the Database name as well as the schema
  
Use Northwind
SELECT CompanyName
 FROM Northwind..Customers; -- using the Database name and the "default" schema  
  
-- Using 2 tables (The Improved ANSI way)      
SELECT ProductName, CategoryName
 FROM Products JOIN Categories
  ON Products.CategoryId = Categories.CategoryId;  
  
--( Table Aliases )--
-- Alias can be used to rename a table names in the query.
SELECT ProductName, CategoryName
 FROM Products as P JOIN Categories as C
  ON P.CategoryId = C.CategoryId;    

'*** Using the Where Clause ***'
-----------------------------------------------------------------------------------------------------------------------
-- The Where clause is used a a boolean filter. 
-- If a statement is true a row is returned if not 
-- the row is not returned. Select statements evaluate the 
-- expression for each row in a table.
USE Northwind 
SELECT  ProductName, UnitsInStock
 FROM Products 
  WHERE ProductName = 'Chai';
  
--( Using a Where clause with Joins )--  
-- One reason that the new "Ansi" Join is considered better is
-- because the Where clause is separated from the Join clause.

-- Example using the "NON ANSI" join syntax
SELECT  CompanyName, OrderDate 
 FROM Orders, Customers 
  WHERE Orders.CustomerID = Customers.CustomerID 
	AND OrderDate = '8/25/97'; 

-- SELECT can query multiple tables with a JOIN. 
SELECT DISTINCT CompanyName, OrderDate 
 FROM Orders INNER JOIN Customers 
  ON Orders.CustomerID = Customers.CustomerID 
  WHERE OrderDate = '8/25/97'; 
    
--( Using Wild Cards )--   
-- You can also use "Wild Card" place holders in your where clause.
-- By using the "LIKE" operator instead of the "=" operator
SELECT  ProductName, UnitsInStock
 FROM Products 
  WHERE ProductName LIKE 'Ch%';  -- % means zero or more characters

SELECT  ProductName, UnitsInStock
 FROM Products 
  WHERE ProductName LIKE 'C_a%';  -- _ means one character

--( Using Common Operators )--   
-- BETWEEN evaluates as a TRUE expression when
-- a value is between two other values (inclusive)
SELECT  ProductName, UnitsInStock
 FROM Products 
  WHERE UnitsInStock BETWEEN '0' AND '35';

-- The IN keyword is used to test if a values is in a list 
-- of other values
SELECT ProductName, UnitsInStock
 FROM Products 
  WHERE UnitsInStock IN ('0','17');

-- You can use Logical Operators for more complex queries
USE northwind
SELECT productid, productname, supplierid, unitprice
 FROM products
  WHERE ( productname LIKE 'T%' ) 
     OR ( productid = 46 AND unitprice > 16.00 ); 

-- This query shows which customers don't have orders
SELECT Customers.CustomerID, Customers.CompanyName
 FROM Customers
  WHERE CustomerID Not In (SELECT CustomerID FROM Orders);

-- If you want to find rows that have null values you can 
--  use the "IS NULL" operator.
USE northwind
SELECT companyname, fax
 FROM suppliers
  WHERE fax IS NULL; 

SELECT companyname, fax
 FROM suppliers
  WHERE fax = NULL; 

-- Avoid using the "not =" operators, since this logic can be 
-- changed by a connection setting.
SET ANSI_NULLS ON -- | OFF
IF (null = null)
  PRINT 'True'
ELSE
  PRINT 'False';

'*** Using the Order By Clause ***'
-----------------------------------------------------------------------------------------------------------------------
-- The ORDER BY clause sorts a query result by one or more columns.
-- A sort can be ascending (ASC) or descending (DESC). 
SELECT Pub_id, Type, Title_id, Price
 FROM Pubs..Titles
  ORDER BY Pub_id DESC, Type, Price;
  
-- You can also use the column number in the Order By clause 
SELECT Pub_id, Type, Title_id, Price
 FROM Pubs..Titles
  ORDER BY 2 DESC;


'*** Using Aggregate Functions ***'
-----------------------------------------------------------------------------------------------------------------------
-- This example shows who placed orders on the most recent recorded day.
USE Northwind
SELECT OrderID, CustomerID
 FROM Orders
  WHERE OrderDate = (SELECT MAX(OrderDate) FROM Orders);

-- Most aggregate functions exclude Null values
SELECT ShippedDate FROM dbo.Orders;
SELECT MAX(ShippedDate) FROM dbo.Orders;
SELECT MIN(ShippedDate) FROM dbo.Orders;

--  Determining the average of the UnitPrice column 
--  for all products in the Products table with the AVG function.
SELECT AVG(Price) FROM Pubs.dbo.Titles;

-- using mutilple functions
SELECT 
 [grand total] = SUM(ytd_sales),
 [average sales] = AVG(ytd_sales),
 [number of sales] = COUNT(ytd_sales),
 [number of entries] = COUNT(*)  -- This one INCLUDES nulls
 FROM Pubs.dbo.Titles;

-- You can create your own calculations as well
SELECT 
 [Custom Average Sales] = SUM(ytd_sales) / COUNT(*),
 [Standard Average Sales] = AVG(ytd_sales)
 FROM pubs.dbo.titles;
 
'*** Using DISTINCT Clause ***'
-----------------------------------------------------------------------------------------------------------------------
-- The DISTINCT keyword eliminates duplicate rows 
-- Note that this is dependent on the entire row being a duplicate
SELECT DISTINCT Orders.CustomerID, Orders.Orderdate FROM Orders;
 
'*** Using UNION Clause ***'
-----------------------------------------------------------------------------------------------------------------------
-- This code gives you back three results.
SELECT [Customer Orders] = Count(*), [Year] = 'For 1996' 
 FROM Orders 
  WHERE Year(OrderDate) = 1996;

SELECT [Customer Orders] = Count(*), [Year] = 'For 1996' 
 FROM Orders 
  WHERE Year(OrderDate) = 1997;

SELECT [Customer Orders] = Count(*), [Year] = 'For 1996' 
 FROM Orders 
  WHERE Year(OrderDate) = 1998;


-- This code give you only ONE result
SELECT DISTINCT [Customer Orders] = Count(*), [Year] = 'For 1996' -- only one alias 
 FROM Orders 
  WHERE Year(OrderDate) = 1996 -- ;
UNION
SELECT DISTINCT Count(*), 'For 1996'
 FROM Orders 
  WHERE Year(OrderDate) = 1997 --;
UNION
SELECT DISTINCT Count(*), 'For 1996' 
 FROM Orders 
  WHERE Year(OrderDate) = 1998;-- Only one simi-colon


'*** Using TOP Clause ***'
-----------------------------------------------------------------------------------------------------------------------
-- The TOP n keyword specifies that the first n rows of the result set are to be returned.
USE northwind
SELECT TOP 5 orderid, productid, quantity
  FROM [order details]
  ORDER BY quantity DESC;

-- This result set lists a total of 10 products, because 
-- additional rows with the same values as the last row also are included.
SELECT TOP 5 WITH TIES orderid, productid, quantity
  FROM [order details]
  ORDER BY quantity DESC; 

-- SQL Server includes a Percent option.
Select [Number of Rows in Orders Details] = Count(*) From [Order Details];
go
SELECT TOP (1) PERCENT orderid , productid, quantity
  FROM [order details] 
  ORDER BY quantity DESC; 
go
 
-- SQL Server allows you to use Top in Delete and Update Statements.
SELECT * INTO #OrdersDemo From Orders;  -- This Creates a Tempory Table with a copy of all the data 
SELECT * INTO #OrdersToProcess From #OrdersDemo WHERE 5 = 7;
go
TempDB..Sp_help [#OrdersToProcess];
go
SET IDENTITY_INSERT #OrdersToProcess On -- Need this since the table has an Identity option on it!
Go
INSERT INTO #OrdersToProcess 
 ( OrderID
 , CustomerID
 , EmployeeID
 , OrderDate
 , RequiredDate
 , ShippedDate
 , ShipVia
 , Freight
 , ShipName
 , ShipAddress
 , ShipCity
 , ShipRegion
 , ShipPostalCode
 , ShipCountry
 )
 SELECT TOP (10) * FROM #OrdersDemo
go
SET IDENTITY_INSERT #OrdersToProcess Off

-- Now we can delete a few at a time using the Top command (This technique can be used to create Buffers!)
DELETE TOP (10) #OrdersDemo
 SELECT 'Orders left in Queue : ' + Cast(COUNT(*) as varchar)
  FROM #OrdersDemo
go
SELECT * FROM #OrdersToProcess
go 

'*** Grouping for SubTotals ***'
-----------------------------------------------------------------------------------------------------------------------

--( Group By )-- 
-- SELECT statement uses the CUBE operator in the GROUP BY clause: 
SELECT * 
  FROM Pubs.dbo.Titles
  WHERE title_id = 'BU1032';

SELECT * 
  FROM Pubs.dbo.Sales
  WHERE title_id = 'BU1032';

-- The Group By command returns totals
SELECT Title_id, SUM(qty) AS 'Quantity'
  FROM Pubs.dbo.Sales
  WHERE title_id = 'BU1032'
  GROUP BY Title_id;

-- The Group By with Rollup returns a Grand Total too
SELECT Title_id, SUM(qty) AS 'Quantity'
  From Pubs.dbo.Sales
  GROUP BY Title_id
    WITH ROLLUP
  ORDER BY Title_id;

-- The Rollup command can return subtotals with the grand total
SELECT Stor_id, Title_id, SUM(qty) AS 'Quantity'
  FROM Pubs.dbo.Sales
  GROUP BY Stor_id, Title_id
    WITH Rollup -- subtotals based on Stor_id
  ORDER BY 1, 2;

-- The subtotals depend on the column order in the Group By Clause
SELECT Stor_id, Title_id, SUM(qty) AS 'Quantity'
  FROM Pubs.dbo.Sales 
  GROUP BY Title_id, Stor_id
    WITH Rollup -- subtotals based on Title
  ORDER BY 1;


-- The Cube command returns all combonations of subtotals
SELECT Stor_id, Title_id, SUM(qty) AS 'Quantity'
  FROM Pubs.dbo.Sales
  GROUP BY Stor_id,Title_id
    WITH Cube  -- subtotals based on both Stor_id and Title
  ORDER BY 1;


-- The Join can be used to make the results better looking!
SELECT Stor_name, Title, SUM(qty) AS 'Quantity'
  FROM Pubs.dbo.Sales 
   JOIN Pubs.dbo.Titles
    ON Pubs.dbo.Sales.Title_id = Pubs.dbo.Titles.Title_id
   JOIN Pubs.dbo.Stores
    On Pubs.dbo.Sales.stor_id = Pubs.dbo.Stores.stor_id
  GROUP BY Stor_name,Title
    WITH Cube  -- subtotals based on both Stor_id and Title
  ORDER BY 1,2;

'*** Using SELECT with other built in Functions ***'
-----------------------------------------------------------------------------------------------------------------------
-- The Join can be used to make the results better looking!
SELECT IsNull(Stor_name, 'All Stores'), IsNull(Title, 'All Titles'), SUM(qty) AS 'Quantity'
  FROM Pubs.dbo.Sales 
   JOIN Pubs.dbo.Titles
    ON Pubs.dbo.Sales.Title_id = Pubs.dbo.Titles.Title_id
   JOIN Pubs.dbo.Stores
    On Pubs.dbo.Sales.stor_id = Pubs.dbo.Stores.stor_id
  GROUP BY Stor_name,Title
    WITH Cube  -- subtotals based on both Stor_id and Title
  ORDER BY 1,2;
