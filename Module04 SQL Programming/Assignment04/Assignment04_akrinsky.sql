--*************************************************************************--
-- Title: Assignment04
-- Author: AKrinsky
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2020-02-03,AKrinksy, Created Doc
--**************************************************************************--

USE Master;
GO

IF EXISTS(SELECT Name from SysDatabases WHERE Name = 'Assignment04DB_AKrinsky')
 Begin 
  ALTER DATABASE [Assignment04DB_AKrinsky] SET Single_user With Rollback Immediate;
  DROP DATABASE Assignment04DB_AKrinsky;
 END
GO

CREATE DATABASE Assignment04DB_AKrinsky;
GO

USE Assignment04DB_AKrinsky;
GO
--- Request: I want a list of customer companies and their contact people

DROP VIEW IF EXISTS vCustomerContacts;
GO
CREATE VIEW vCustomerContacts
		As
            SELECT CompanyName, ContactName
            FROM Northwind.dbo.Customers
GO

SELECT * FROM vCustomerContacts;

-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada

DROP VIEW IF EXISTS vUSAandCanadaCustomerContacts;
GO
CREATE VIEW vUSAandCanadaCustomerContacts
		As
            SELECT TOP 100000 CompanyName, ContactName, Country
            FROM Northwind.dbo.Customers
            WHERE Country IN ('Canada', 'USA')
            ORDER BY Country
GO

SELECT * FROM vUSAandCanadaCustomerContacts;

-- Request: I want a list of products, their standard price and their categories. 
--Order the results by Category Name and then Product Name, in alphabetical order.
DROP VIEW IF EXISTS vProductPricesByCategories;
GO
CREATE VIEW vProductPricesByCategories
		As
            SELECT TOP 100000 CategoryName, ProductName, Format(UnitPrice, 'C', 'en-US')  as 'Standard Price'
            FROM Northwind.dbo.Products as P
            JOIN Northwind.dbo.Categories as C
                ON P.CategoryID = C.CategoryID
            ORDER BY CategoryName, ProductName
GO

SELECT * FROM vProductPricesByCategories;
-- Request: I want a list of products, their standard price and their categories. 
--Order the results by Category Name and then Product Name, in alphabetical order 
--but only for the seafood category

DROP FUNCTION IF EXISTS fProductPricesByCategories;
GO
CREATE FUNCTION fProductPricesByCategories(@Category VARCHAR(100))
    RETURNS TABLE
		As
            RETURN (
                SELECT TOP 1000000 CategoryName, ProductName, Format(UnitPrice, 'C', 'en-US')  as 'Standard Price'
                FROM Northwind.dbo.Products as P
                JOIN Northwind.dbo.Categories as C
                    ON P.CategoryID = C.CategoryID
                WHERE CategoryName = @Category
                ORDER BY CategoryName, ProductName
            )
            
GO

SELECT * FROM fProductPricesByCategories('seafood');

-- Request: I want a list of how many orders our customers have placed each year

DROP VIEW IF EXISTS vCustomerOrderCounts;
GO
CREATE VIEW vCustomerOrderCounts
		As
            SELECT CompanyName, Count(OrderID) as NumberOfOrders, YEAR(OrderDate) as 'Order Year'
            FROM Northwind.dbo.Customers as c
            JOIN Northwind.dbo.Orders as o
                on c.CustomerID = o.CustomerID
            GROUP BY YEAR(OrderDate), CompanyName;
GO

SELECT * FROM vCustomerOrderCounts;

--I want a list of total order dollars our customers have placed each year
--are these numbers right?

DROP VIEW IF EXISTS vCustomerOrderDollars;
GO
CREATE VIEW vCustomerOrderDollars
		As
            SELECT TOP 100000 CompanyName, Format(SUM(UnitPrice*Quantity), 'C', 'en-US') as TotalDollars, YEAR(OrderDate) as OrderYear
            FROM Northwind.dbo.Customers as c
            JOIN Northwind.dbo.Orders as o
                ON c.CustomerID = o.CustomerID
            JOIN Northwind.dbo.[Order Details] as od
                ON od.OrderID = o.OrderID
            GROUP BY CompanyName, YEAR(OrderDate)
            ORDER BY CompanyName;      
GO

SELECT * FROM vCustomerOrderDollars;