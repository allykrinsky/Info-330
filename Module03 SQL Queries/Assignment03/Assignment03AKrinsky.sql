--*************************************************************************--
-- Title: Assignment03
-- Author: AKrinksy
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2020-01-23,AKrinsky,Created File
--**************************************************************************--


/********************************* Questions and Answers *********************************/
USE Northwind;

-- Data Request: 0301
-- Date: 1/1/2020
-- From: Jane Encharge CEO
-- Request: I want a list of customer companies and their contact people
-- Needed By: ASAP

SELECT CompanyName, ContactName
FROM dbo.Customers;

-- Data Request: 0302
-- Date: 1/2/2020
-- From: Jane Encharge CEO
-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada
-- Needed By: ASAP

SELECT CompanyName, ContactName, Country
FROM dbo.Customers
WHERE Country IN ('Canada', 'USA');

-- Data Request: 0303
-- Date: 1/2/2020
-- From: Jane Encharge CEO
-- Request: I want a list of products, their standard price and their categories. Order the results by Category Name 
-- and then Product Name, in alphabetical order
-- Needed By: ASAP

SELECT CategoryName, ProductName, Format(UnitPrice, 'C', 'en-US')  as 'Standard Price'
FROM dbo.Products as P
JOIN dbo.Categories as C
    ON P.CategoryID = C.CategoryID
ORDER BY CategoryName, ProductName;


-- Data Request: 0304
-- Date: 1/3/2020
-- From: Jane Encharge CEO
-- Request: I want a list of how many customers we have in the US
-- Needed By: ASAP

SELECT *
FROM
(
    SELECT COUNT(CustomerID) as 'Count', Country
    FROM dbo.Customers
    GROUP BY Country
) AS T
WHERE T.Country LIKE 'USA';

-- Data Request: 0305
-- Date: 1/4/2020
-- From: Jane Encharge CEO
-- Request: I want a list of how many customers we have in the US and Canada, with subtotals for each
-- Needed By: ASAP

SELECT *
FROM
(
    SELECT COUNT(CustomerID) as 'Count', Country
    FROM dbo.Customers
    GROUP BY Country
) AS T
WHERE T.Country IN ('Canada', 'USA');

/***************************************************************************************/