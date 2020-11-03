--*************************************************************************--
-- Title: Mod04-Lab04 Lab Code
-- Author: RRoot
-- Desc: This file demonstrates how to create basic sprocs
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--
-- In this lab, you create stored procedures using Northwind database. 
-- You will work on your own for the first 10 minutes, then we will review the answers together in the last 10 minutes. 
-- Note: This lab can be done individually or with a group of up to 3 people. 
   
-- Step 1: Review Database Tables
-- Run the following code in a SQL query editor and review the names of the tables you have to work with.

Select * From Northwind.Sys.Tables Where type = 'u' Order By Name;
   
-- Step 2: Re-Use the Lab Database
-- You have already created a database for this lab called MyLabsYourNameHere (using your own name, of course!) Use the follow code to force your SQL code to use this database:
Use [MyLabsDB_RRoot];
   
-- Step 3: Create a Query
-- Answer the following questions by writing and executing SQL code.

-- Question 1: How can you create a stored procedure to show a list of customers names 
-- and their locations? Call the procedure pSelCustomersByLocation.
go
If Exists (Select Name From Sysobjects where name = 'pSelCustomersByLocation') 
 Drop Proc pSelCustomersByLocation
go
Create Proc pSelCustomersByLocation
AS
 Select CompanyName, City, [Region] = IsNull(Region, Country), Country From Northwind.dbo.Customers;
go 
Exec pSelCustomersByLocation;
go
-- Question 2: How can you create a stored procedure to show a list of customers names, their locations, 
-- and the number of orders they have placed (hint: use the count() function)? 
-- Call the procedure pSelNumberOfCustomerOrdersByLocation.
go
If Exists (Select Name From Sysobjects where name = 'pSelNumberOfCustomerOrdersByLocation') 
 Drop Proc pSelNumberOfCustomerOrdersByLocation
go
Create Proc pSelNumberOfCustomerOrdersByLocation
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
Exec pSelNumberOfCustomerOrdersByLocation;
go

-- Question 3: How can you create a stored procedure to show a list of customers names, their locations, 
-- and the number of orders they have placed (hint: use the count() function) 
-- on an given year (hint: use the year() function)? Call the procedure pSelNumberOfCustomerOrdersByLocationAndYears.
go
If Exists (Select Name From Sysobjects where name = 'pSelNumberOfCustomerOrdersByLocationAndYears') 
 Drop Proc pSelNumberOfCustomerOrdersByLocationAndYears
go
go
Create Proc pSelNumberOfCustomerOrdersByLocationAndYears
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
Exec  pSelNumberOfCustomerOrdersByLocationAndYears;
go

-- Step 4: Review Your Work
-- Now, you will review your work with your instructor.
