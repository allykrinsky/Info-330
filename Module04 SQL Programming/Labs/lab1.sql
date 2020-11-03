Use Northwind;
--1
select CategoryName
from dbo.Categories;

--2
select ProductName, UnitPrice
from dbo.Products
order by ProductName;

--3
select CategoryName, ProductName, UnitPrice
from dbo.Categories as C
join dbo.Products as P
    on C.CategoryID = P.CategoryID
order by CategoryName, ProductName;

--4
select OD.OrderID,   P.ProductName, C.CategoryName, OD.Quantity
from dbo.[Order Details] as OD   
join dbo.Products as P
    on OD.ProductID = P.ProductID
join dbo.Categories as C
    on P.CategoryID = C.CategoryID
order by OD.OrderID, P.ProductName, C.CategoryName, OD.Quantity;

--5
select o.OrderID, o.OrderDate, p.ProductName, c.CategoryName, Quantity
from dbo.[Order Details] as OD
join dbo.Orders as O
    on OD.OrderID = O.OrderID
join dbo.Products as P
    on OD.ProductID = P.ProductID
join dbo.Categories as C
    on P.CategoryID = C.CategoryID
order by o.OrderID, OrderDate, CategoryName, ProductName, Quantity;


