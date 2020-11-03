
'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, using a Subquery
'*************************************************' 
OK, I need...
 ProductName, [OrderDate]

from
 Products Orders

Where 
 OrderDate = 1996 

--1 Find the Order Ids from 1996
Select OrderId 
from Orders 
Where YEAR(Orders.OrderDate) = 1996

--2 Find the Product Ids for the list of orders in 1996
Select ProductId 
From [Order Details] 
Where OrderId in (
	Select OrderId 
	from Orders 
	Where YEAR(Orders.OrderDate) = 1996)


--3 Find the Product Name for the list of ProductIds
Select ProductName 
From Products
Where ProductID in ( 
	Select ProductId 
	From [Order Details] 
	Where OrderId in (
		Select OrderId 
		From Orders 
		Where YEAR(Orders.OrderDate) = 1996 )
		)

--4 Find the Product Name for the list of ProductIds
Select ProductName , OrderId
From Products 
JOIN [Order Details] 
	ON Products.ProductId = [Order Details].ProductID
	Where OrderId in (
		Select OrderId from Orders 
		Where YEAR(Orders.OrderDate) = 1996 )

-- 5 Pure Join version
SELECT Products.ProductName, Orders.OrderID
FROM  [Order Details] 
INNER JOIN Orders 
  ON [Order Details].OrderID = Orders.OrderID 
INNER JOIN Products 
ON [Order Details].ProductID = Products.ProductID
Where YEAR(Orders.OrderDate) = 1996 




'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, using a Temp table
'*************************************************'

Create Table #1996OrderIds(OrderId int)

Insert Into #1996OrderIds
	Select OrderId 
	Into #aaa
	from Orders 
	where Year(OrderDate) = 1996 


Select Distinct ProductName
From Products
JOIN [Order Details]
  On Products.ProductId = [Order Details].ProductId
Where OrderId in (Select OrderId from #aaa)



'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, using a CTE
'*************************************************'
WITH ListOFOrder1996 -- 1 get a list of ids
AS (
	Select OrderId 
	from Orders 
	where Year(OrderDate) = 1996 )
Select Distinct ProductName -- get the products based on the list
From Products
JOIN [Order Details]
  On Products.ProductId = [Order Details].ProductId
Where OrderId in (Select OrderId from ListOFOrder1996)

-- Regular Subquery 
Select ProductName , OrderId
From Products 
JOIN [Order Details] 
	ON Products.ProductId = [Order Details].ProductID
	Where OrderId in (
		Select OrderId from Orders 
		Where YEAR(Orders.OrderDate) = 1996 )


'******************** LAB ***********************'
-- Do the following:
-- 1) Use the Northwind database to produce a 
--   Report that shows a list of Products sold in
--   the year 1996, using a Table Variable
'*************************************************'
-- 1 get a list of ids
Declare @ListOFOrder1996 Table(OrderId int)
Insert Into @ListOFOrder1996
	Select OrderId 
	From Orders 
	Where YEAR(Orders.OrderDate) = 1996
--Select * from @ListOFOrder1996
-- get the products based on the list
Select ProductName 
From Products 
JOIN [Order Details] 
	ON Products.ProductId = [Order Details].ProductID
	Where OrderId in (Select OrderId from @ListOFOrder1996)
