--*************************************************************************--
-- Title: Mod05-Lab05 Lab Code
-- Author: RRoot
-- Desc: This file demonstrates how to use Temporary Tables
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--
/*
In this lab, you create temporary table using the Northwind database. 
You will work on your own for the first 15 minutes, then we will review the answers together in the last 5 minutes. 
Note: This lab should be done individually or in groups of three or less. 
*/

Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'MyLabsDB_YourNameHere')
 Begin 
  Alter Database [MyLabsDB_YourNameHere] set Single_user With Rollback Immediate;
  Drop Database MyLabsDB_YourNameHere;
 End
go

Create Database MyLabsDB_YourNameHere;
go

Use MyLabsDB_YourNameHere;
go

-- 1) Review the existing data
Select * From Northwind.dbo.[Order Details];
Select * From Northwind.dbo.[Products];
Select * From Northwind.dbo.[Categories];

-- 2) Get the total by Product Name with Category Id
Select CategoryID, ProductName, Sum(Quantity) as [Total By Product]
 From Northwind.dbo.[Order Details] as OD 
  Join Northwind.dbo.[Products] as P
   On OD.ProductID = P.ProductID
  Group By P.CategoryID, P.ProductName
  Order By 1,2;

-- 3) Get the total by Category Name with Category Id
Select C.CategoryID, C.CategoryName, Sum(Quantity) as [Total By Category]
 From Northwind.dbo.[Order Details] as OD 
  Join Northwind.dbo.[Products] as P
   On OD.ProductID = P.ProductID
  Join Northwind.dbo.[Categories] as C
   On P.CategoryID = C.CategoryID
  Group By C.CategoryID, C.CategoryName
  Order By 1,2;

-- 4) Store the total by Product Name with Category Id in a temp table called #QtyByProduct
Select CategoryID, ProductName, Sum(Quantity) as [Total By Product]
INTO #QtyByProduct
 From Northwind.dbo.[Order Details] as OD 
  Join Northwind.dbo.[Products] as P
   On OD.ProductID = P.ProductID
  Group By P.CategoryID, P.ProductName
  Order By 1,2;

-- 5) Store the total by Category Name with Category Id in a temp table called #QtyByCategory
Select C.CategoryID, C.CategoryName, Sum(Quantity) as [Total By Category]
INTO #QtyByCategory
 From Northwind.dbo.[Order Details] as OD 
  Join Northwind.dbo.[Products] as P
   On OD.ProductID = P.ProductID
  Join Northwind.dbo.[Categories] as C
   On P.CategoryID = C.CategoryID
  Group By C.CategoryID, C.CategoryName
  Order By 1,2;

-- 6) Join the two tables based on the category ids
Select C.CategoryName, P.ProductName, C.[Total By Category], P.[Total By Product]
 From #QtyByProduct as P
  Join #QtyByCategory as C 
   On P.CategoryID = C.CategoryID
  Order By 1,2;

-- 6) Delete the temporary tables
If (Object_ID('tempdb..#QtyByProduct') is not null) Drop Table #QtyByProduct;
If (Object_ID('tempdb..#QtyByCategory') is not null) Drop Table #QtyByCategory;