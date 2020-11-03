--*************************************************************************--
-- Title: Module04-Lab02
-- Author: RRoot
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--
/*
In this lab, you create views using Northwind database. 
You will work on your own for the first 10 minutes, then we will review the answers together in the last 10 minutes. 
Note: This lab can be done individually or with a group of up to 3 people. 
*/

--Step 1: Review Database Tables
--Run the following code in a SQL query editor and review the names of the tables you have to work with.

Select * From Northwind.Sys.Tables Where type = 'u' Order By Name;

-- Step 2: Create a Lab Database
-- Create new database for this lab called MyLabsDB_RRoot (using your own name, of course!) Modify and use the follow code to accomplish this:

Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'MyLabsDB_RRoot')
 Begin 
  Alter Database [MyLabsDB_RRoot] set Single_user With Rollback Immediate;
  Drop Database MyLabsDB_RRoot;
 End
go

Create Database MyLabsDB_RRoot;
go

Use MyLabsDB_RRoot;
go
   
-- Step 3: Create a Query
-- Answer the following questions by writing and executing SQL code.

-- Question 1: How can you create a view to show a list of customers names and their locations? 
--Call the view vCustomersByLocation.
--Select * From Northwind.dbo.Customers;
--go
--Select CompanyName, City, Region, Country From Northwind.dbo.Customers;
--go
--Select CompanyName, City, IsNull(Region, Country), Country From Northwind.dbo.Customers;
go
Create View vCustomersByLocation
AS
 Select CompanyName, City, [Region] = IsNull(Region, Country), Country From Northwind.dbo.Customers;
go 
Select * From vCustomersByLocation;
go

-- Question 2: How can you create a view to show a list of customers names, their locations, 
-- and the number of orders they have placed (hint: use the count() function)? 
-- Call the view vNumberOfCustomerOrdersByLocation.
--Select * From Northwind.dbo.Orders;
--go

--Select 
--  CompanyName
-- ,City
-- ,[Region] = IsNull(Region, Country)
-- ,Country
-- ,[Number of Orders] = Count(OrderID)
--From Northwind.dbo.Customers as c
--Join Northwind.dbo.Orders as o
-- On c.CustomerID = o.CustomerID
--Group By
--  CompanyName
-- ,City
-- ,IsNull(Region, Country)
-- ,Country
-- ;
--go

go
Create View vNumberOfCustomerOrdersByLocation
AS
	Select 
	  CompanyName
	 ,City
	 ,[Region] = IsNull(Region, Country)
	 ,Country
	 ,[Number of Orders] = Count(OrderID)
	From Northwind.dbo.Customers as c
	Join Northwind.dbo.Orders as o
	 On c.CustomerID = o.CustomerID
	Group By
	  CompanyName
	 ,City
	 ,IsNull(Region, Country)
	 ,Country
;
go

Select * From vNumberOfCustomerOrdersByLocation;
go

-- Question 3: How can you create a view to show a list of customers names, their locations, 
--and the number of orders they have placed (hint: use the count() function) 
--on an given year (hint: use the year() function)? 
--Call the view vNumberOfCustomerOrdersByLocationAndYears.
-- Select * From Northwind.dbo.Orders;
--	Select 
--	  CompanyName
--	 ,City
--	 ,[Region] = IsNull(Region, Country)
--	 ,Country
--   ,[OrderYear] = Year(o.orderdate)
--	 ,[Number of Orders] = Count(OrderID)
--	From Northwind.dbo.Customers as c
--	Join Northwind.dbo.Orders as o
--	 On c.CustomerID = o.CustomerID
--	Group By
--	  CompanyName
--	 ,City
--	 ,IsNull(Region, Country)
--	 ,Country
--   ,Year(o.orderdate)
--;

go
Create View vNumberOfCustomerOrdersByLocationAndYears
AS
	Select 
	  CompanyName
	 ,City
	 ,[Region] = IsNull(Region, Country)
	 ,Country
   ,[OrderYear] = Year(o.orderdate)
	 ,[Number of Orders] = Count(OrderID)
	From Northwind.dbo.Customers as c
	Join Northwind.dbo.Orders as o
	 On c.CustomerID = o.CustomerID
	Group By
	  CompanyName
	 ,City
	 ,IsNull(Region, Country)
	 ,Country
   ,Year(o.orderdate)
;
go
Select * From vNumberOfCustomerOrdersByLocationAndYears;
go

-- Step 4: Review Your Work
-- Now, you will review your work with your instructor.