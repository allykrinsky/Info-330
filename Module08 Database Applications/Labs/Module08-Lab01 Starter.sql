--*************************************************************************--
-- Title: Module08-Lab01
-- Author: YourNameHere
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
-- Step 1: Create the Lab database
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

-- Step 2: Create the table
-- Run the following SQL code, understand what it does, and then use it to create 
-- a reporting view called, "vSalesByCategories";
Select c.CategoryName
     , Year(o.OrderDate) as OrderYear
     , Sum(od.Quantity) as TotalQuantity
     , Sum(od.UnitPrice) as TotalDollars 
From Northwind.dbo.Categories as c
 Join Northwind.dbo.Products as p
  On c.CategoryID = p.CategoryID
 Join Northwind.dbo.[Order Details] as od
  On p.ProductID = od.ProductID
 Join Northwind.dbo.Orders as o
  On od.OrderID = o.OrderID
Group By c.CategoryName, Year(o.OrderDate) 
Order By CategoryName, OrderYear 

