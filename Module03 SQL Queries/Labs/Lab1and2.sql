USE Northwind;

SELECT CategoryID, CategoryName
FROM Categories
WHERE CategoryName = 'Seafood';

--Select the Product Id, Product Name, and Product Price 
--of all Products with the Seafood's Category Id. 
-- Ordered by the highest to the lowest products price. 

SELECT ProductID, ProductName, UnitPrice as 'ProductPrice' 
FROM Products
WHERE CategoryID = 8
ORDER BY ProductPrice DESC;

--Select the product Id, product name, and product price 
--ordered by the products price highest to the lowest. 
--Show only the products that have a price greater than $100. 

SELECT ProductID, ProductName, UnitPrice as 'ProductPrice'
FROM Products
WHERE UnitPrice > 100
ORDER BY ProductPrice DESC;

--Select the category name, product name, and product price 
-- from both categories and products. 
--Order the results by category name and then product name, in alphabetical order. 
--(Hint: Join Products to Category)

SELECT CategoryName, ProductName, UnitPrice as 'ProductPrice'
FROM Products as P
JOIN Categories as C
    ON p.CategoryID = c.CategoryID
ORDER BY CategoryName, ProductName DESC;

--elect the Category Name, Product Name, and Product Price 
--from both Categories and Products. 
--Order the results by price highest to lowest. 
--Show only the products that have a price from $10 to $20. 

SELECT CategoryName, ProductName, UnitPrice as 'ProductPrice'
FROM Products as P
JOIN Categories as C
    ON p.CategoryID = c.CategoryID
WHERE UnitPrice BETWEEN 10 and 20
ORDER BY UnitPrice DESC;
