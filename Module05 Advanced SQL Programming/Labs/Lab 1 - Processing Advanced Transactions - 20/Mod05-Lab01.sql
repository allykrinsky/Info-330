--*************************************************************************--
-- Title: Module03-Lab01
-- Author: YourNameHere
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Use Northwind;
go

-- Question 1: Select the Category Id and Category Name of the Category 'Seafood'.
Select CategoryID, CategoryName
FROM Northwind.dbo.Categories 
 Where CategoryName = 'Seafood';
go

-- Question 2:  Select the Product Id, Product Name, and Product Price 
-- of all Products with the Seafood's Category Id. Ordered By the Products Price
-- highest to the lowest 

SELECT ProductID, ProductName, UnitPrice
FROM dbo.Products as P
JOIN dbo.Categories as C
    ON c.CategoryID = p.CategoryID  
WHERE CategoryName = 'Seafood';

-- Question 3:  Select the Product Id, Product Name, and Product Price 
-- Ordered By the Products Price highest to the lowest. 
-- Show only the products that have a price greater than $100. 

SELECT ProductID, ProductName, UnitPrice
FROM dbo.Products
WHERE UnitPrice > 100
ORDER BY UnitPrice DESC;

-- Question 4: Select the CATEGORY NAME, product name, and Product Price 
-- from both Categories and Products. Order the results by Category Name 
-- and then Product Name, highest to the lowest
-- (Hint: Join Products to Category)

SELECT CategoryName, ProductName, UnitPrice
FROM dbo.Categories as C
JOIN dbo.Products as P
on c.CategoryID = p.CategoryID
ORDER BY CategoryName, ProductName DESC;


-- Question 5: Select the Category Name, Product Name, and Product Price 
-- from both Categories and Products. Order the results by price highest to lowest.
-- Show only the products that have a PRICE FROM $10 TO $20. 

SELECT CategoryName, ProductName, UnitPrice
FROM dbo.Categories as C
JOIN dbo.Products as P
on c.CategoryID = p.CategoryID
WHERE UnitPrice BETWEEN 10 AND 20
ORDER BY UnitPrice DESC;

select * from dbo.Categories;

--Question 1: How would you add data to the Categories table?
Begin Try
    Begin Tran
        INSERT INTO dbo.categories(CategoryName)
            VALUES('CatA')
        RAISERROR('Test', 15, 1);
    Commit Tran
End Try
Begin Catch
    Rollback Tran
    Print error_message()
End Catch

--Question 2: How would you add data to the Products table?

Begin Try
    Begin Tran
        INSERT INTO dbo.Products(ProductName, UnitPrice, CategoryID)
            VALUES('ProdA', 1.99, @@IDENTITY)
        RAISERROR('Test', 15, 1);
    Commit Tran
End Try
Begin Catch
    Rollback Tran
    Print error_message()
End Catch
--Question 3: How would you update data in the Products table?
Begin Try
    Begin Tran
        UPDATE Products
        SET ProductName = 'ProdA', UnitPrice = 14.99, CategoryID = IDENT_CURRENT('Categories')
        WHERE ProductID = IDENT_CURRENT('products')
        -- RAISERROR('Test', 15, 1);
    Commit Tran
End Try
Begin Catch
    Rollback Tran
    Print error_message()
End Catch

--Question 4: How would you delete data from the Categories table?

Begin Try
    Begin Tran
        DELETE FROM Products
        WHERE ProductID = IDENT_CURRENT('Products') --deleting parent values first
        DELETE FROM Categories
        WHERE CategoryID = IDENT_CURRENT('Categories')
        -- RAISERROR('Test', 15, 1);
    Commit Tran
End Try
Begin Catch
    Rollback Tran
    Print error_message()
End Catch


