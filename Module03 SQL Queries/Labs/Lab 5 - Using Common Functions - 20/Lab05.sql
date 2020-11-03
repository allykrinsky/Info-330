--*************************************************************************--
-- Title: Module03-Lab05
-- Author: YourNameHere
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Use Northwind;
go

--Question 1:  Show a list of Product names, and the price of each product, with the price formatted as US dollars?
-- Order the result by the Product!

SELECT ProductName, Format(UnitPrice, 'C', 'en-US')
FROM dbo.Products
ORDER BY ProductName;

--Question 2: Show a list of the top five Order Ids and Order Dates based on the ordered date. 
--Format the results as a US date with back-slashes.

SELECT top 5 OrderID, Convert(varchar(50), OrderDate, 101) as 'Order Date'
FROM dbo.Orders
ORDER BY OrderDate;