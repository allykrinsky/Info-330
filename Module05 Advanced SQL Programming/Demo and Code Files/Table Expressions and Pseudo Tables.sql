--********************** SQL Extras *************************--
-- This file describes how to design and test advanced
-- data retrieval statements using Table Expressions and Psudo tables.
--**************************************************************--

'*** Derived Tables AKA, subquery ***'
-----------------------------------------------------------------------------------------------------------------------   
-- Derived tables allow you to use a fraction of data from a table and then join it to another. 
Use Northwind
SELECT C.CustomerID, C.CompanyName,
COUNT(Orders1996.OrderID) AS TotalOrders
FROM Customers AS C LEFT OUTER JOIN
-- Capture a fraction of data from the orders table
	(SELECT OrderId, CustomerId  FROM Orders WHERE YEAR(Orders.OrderDate) = 1996) AS Orders1996	-- This is the Derived table
ON
C.CustomerID = Orders1996.CustomerID
GROUP BY C.CustomerID, C.CompanyName 


'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, USING A SUBQUERY
'*************************************************' 

'*** Temporary Tables ***'
-----------------------------------------------------------------------------------------------------------------------   
-- SQL has two Basic types of temporary tables Local and Global:
  -- Local --
Create Table #TempCustomers (Id int , CustomerName varchar(50))
	-- Add data
	INSERT INTO #TempCustomers Values(1, 'Bob')
	Select * from #TempCustomers
	-- Modify data
	UPDATE #TempCustomers SET CustomerName = 'Robert' WHERE Id = 1
	Select * from #TempCustomers
	-- Delete data
	Delete from #TempCustomers WHERE Id = 1
	Select * from #TempCustomers

-- Global --
Create Table #GlobalTempCustomers (Id int , CustomerName varchar(50))
	-- Add data
	INSERT INTO #GlobalTempCustomers Values(1, 'Bob')
	Select * from #GlobalTempCustomers
	-- Modify data
	UPDATE #GlobalTempCustomers SET CustomerName = 'Robert' WHERE Id = 1
	Select * from #GlobalTempCustomers
	-- Delete data
	Delete from #GlobalTempCustomers WHERE Id = 1
	Select * from #GlobalTempCustomers

'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, USING A TEMPORARY TABLE
'*************************************************' 

'*** Common Table Expressions ***'
-----------------------------------------------------------------------------------------------------------------------  
 Use Northwind
 WITH CategoryProductAndPrice (ProductName, CategoryName, UnitPrice) AS
(
   SELECT
      c.CategoryName,
      p.ProductName,
	  p.UnitPrice
   FROM Products p
      INNER JOIN Categories c ON
         c.CategoryID = p.CategoryID ) -- The CTE expression 
SELECT *
FROM CategoryProductAndPrice
ORDER BY CategoryName ASC, UnitPrice ASC, ProductName ASC


'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, USING A CTE
'*************************************************' 

'*** Table Variables (Psuedo Tables) ***'
-----------------------------------------------------------------------------------------------------------------------   
Begin -- Must run all the code from Begin to End points
	DECLARE @PsuedoTableCustomers TABLE (Id int , CustomerName varchar(50))
	-- Add data
	INSERT INTO @PsuedoTableCustomers Values(1, 'Bob')
	Select * from @PsuedoTableCustomers
	-- Modify data
	UPDATE @PsuedoTableCustomers SET CustomerName = 'Robert' WHERE Id = 1
	Select * from @PsuedoTableCustomers
	-- Delete data
	Delete from @PsuedoTableCustomers WHERE Id = 1
	Select * from @PsuedoTableCustomers
End
Go

-- Using a Psuedo Tables with the Output clause --
Create Table Table1
(
 ID int identity,  -- Note the Identity Clause
 Name nvarchar (20)
) 

Begin -- Must run all the code from Begin to End points
	-- Make a new Psuedo Table
	Declare @InsDetails Table
	(ID int ,  Name nvarchar(20) , InsertedBy sysName ) --sysname is a data type for holding SQL Server system names

	-- Add some data to a Table and Capture the changed data it the Psuedo table
	INSERT 
	INTO Table1 (Name)
		OUTPUT Inserted.ID, Inserted.Name, suser_name()
			INTO @InsDetails  -- This adds data to the table variable
	VALUES ( 'Bob')

	-- Display the Results from the Psuedo table and the normal table
	Select * from @InsDetails
	Select * from Table1
End

'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, USING A TABLE VARIABLE
'*************************************************' 

'*** Table Producting Functions (Inline and Multistatment Table Functions) ***'
-----------------------------------------------------------------------------------------------------------------------   
Use Northwind
Go
-- Example of an In–line Table-valued Function
CREATE FUNCTION fn_CustomerNamesInRegion ( @RegionParameter nvarchar(30) )
RETURNS table
AS
RETURN (
   SELECT CustomerID, CompanyName
   FROM Northwind.dbo.Customers
   WHERE Region = @RegionParameter
   )

-- Calling the Function with a Parameter
SELECT * FROM fn_CustomerNamesInRegion('WA')

-- Example of a Multi-statement Table-valued Function
CREATE FUNCTION fn_Employees (@length nvarchar(9))
RETURNS @fn_Employees TABLE
   (EmployeeID int PRIMARY KEY NOT NULL,
   [Employee Name] Nvarchar(61) NOT NULL)
AS
BEGIN
   IF @length = 'ShortName'
      INSERT @fn_Employees SELECT EmployeeID, LastName 
      FROM Employees
   ELSE IF @length = 'LongName'
      INSERT @fn_Employees SELECT EmployeeID, 
      (FirstName + ' ' + LastName) FROM Employees
RETURN
END
-- Calling the Function
SELECT * FROM dbo.fn_Employees('LongName')
SELECT * FROM dbo.fn_Employees('ShortName')



'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, USING A Table Function
'*************************************************' 

---------------------------------------------------------------------
-- Common Table Expressions
---------------------------------------------------------------------

WITH USACusts AS
(
  SELECT custid, companyname
  FROM Sales.Customers
  WHERE country = N'USA'
)
SELECT * FROM USACusts;

---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------

-- Inline column aliasing
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

-- External column aliasing
WITH C(orderyear, custid) AS -- Note the Column Aliases here!
(
  SELECT YEAR(orderdate), custid
  FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

DECLARE @empid AS INT = 3;

WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
  WHERE empid = @empid
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Defining Multiple CTEs
---------------------------------------------------------------------

WITH C1 AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
),
C2 AS
(
  SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
  FROM C1 -- This is similar to the Nested subquery.
  GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;

