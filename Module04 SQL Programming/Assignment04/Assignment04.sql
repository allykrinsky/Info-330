--*************************************************************************--
-- Title: Assignment04
-- Author: YourNameHere
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2020-01-01,YourNameHere,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment04DB_YourNameHere')
 Begin 
  Alter Database [Assignment04DB_YourNameHere] set Single_user With Rollback Immediate;
  Drop Database Assignment04DB_YourNameHere;
 End
go

Create Database Assignment04DB_YourNameHere;
go

Use Assignment04DB_YourNameHere;
go

-- Add Your Code Below ---------------------------------------------------------------------

-- Data Request: 0301
-- Request: I want a list of customer companies and their contact people
/*
  -- Columns
  c.CompanyName
  c.ContactName

  -- Tables
  Northwind.dbo.Customers
*/

Select * from vCustomerContacts;

-- Data Request: 0302
-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada
/*
  -- Columns
  c.CompanyName
  c.ContactName
  c.Country

  -- Tables
  Northwind.dbo.Customers
*/

Select * from vUSAandCanadaCustomerContacts;
  
-- Data Request: 0303
-- Request: I want a list of products, their standard price and their categories. 
-- Order the results by Category Name and then Product Name, in alphabetical order.
/*
  -- Columns 
  c.CategoryName
  p.ProductName
  p.UnitPrice

  -- Tables
  Northwind.dbo.Products 
  Northwind.dbo.Categories

  -- Connections
  ???
*/

Select * from vProductPricesByCategories;

-- Data Request: 0323
-- Request: I want a list of products, their standard price and their categories. 
-- Order the results by Category Name and then Product Name, in alphabetical order but only for the seafood category
/*
  -- Columns 
  c.CategoryName
  p.ProductName
  p.UnitPrice

  -- Tables
  Northwind.dbo.Products 
  Northwind.dbo.Categories

  -- Connections
  ???
*/

Select * from dbo.fProductPricesByCategories('seafood');

-- Data Request: 0317
-- Request: I want a list of how many orders our customers have placed each year
/*
  -- Columns
  c.CompanyName
  od.OrderID
  o.OrderDate

  -- Tables
  Northwind.dbo.Customers
  Northwind.dbo.Orders

  -- Connections
  ???

  -- Functions
  Year()
  Count() 
*/

Select * from vCustomerOrderCounts

-- Data Request: 0318
-- Request: I want a list of total order dollars our customers have placed each year
/*
  -- Columns
  c.CompanyName
  od.OrderID
  od.Quantity
  od.UnitPrice
  o.OrderDate

  -- Tables
  Northwind.dbo.Customers
  Northwind.dbo.Orders
  Northwind.dbo.[Order Details]

  -- Connections
  ???

  -- Functions
  Year()
  Count() 
  Sum()
  Format()
*/

Select * from vCustomerOrderDollars;

