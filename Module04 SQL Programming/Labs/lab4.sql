use Northwind;

--2

SELECT 
    CompanyName,
    City,
    Region = ISNULL(Region, Country),
    Count(OrderID) as countorders
from Northwind.dbo.Customers as c
join Northwind.dbo.Orders as o
    on c.CustomerID = o.CustomerID
group by CompanyName,
    City,
    ISNULL(Region, Country);


--3

SELECT 
    CompanyName,
    City,
    Region = ISNULL(Region, Country),
    Count(OrderID) as countorders,
    YEAR(OrderDate) as year
from Northwind.dbo.Customers as c
join Northwind.dbo.Orders as o
    on c.CustomerID = o.CustomerID
group by CompanyName, year(OrderDate), city, ISNULL(Region, Country);



        



