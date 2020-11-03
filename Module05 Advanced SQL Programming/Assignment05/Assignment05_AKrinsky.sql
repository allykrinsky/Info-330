--*************************************************************************--
-- Title: Assignment05
-- Author: AKrinsky
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
-- Step 1: Create the assignment database
USE Master;
GO

IF EXISTS(SELECT Name FROM SysDatabases WHERE Name = 'Assignment05DB_AKrinksy')
 BEGIN
  ALTER DATABASE [Assignment05DB_AKrinksy] SET Single_user With Rollback Immediate;
  DROP DATABASE Assignment05DB_AKrinksy;
 END
GO

CREATE DATABASE Assignment05DB_AKrinksy;
GO

USE Assignment05DB_AKrinksy;
GO

-- Create Tables (Module 01)--
CREATE TABLE Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL
,[CategoryName] [nvarchar](100) NOT NULL
);
GO

CREATE TABLE Products
([ProductID] [int] IDENTITY(1,1) NOT NULL
,[ProductName] [nvarchar](100) NOT NULL
,[CategoryID] [int] NULL
,[UnitPrice] [money] NOT NULL
);
GO

CREATE TABLE Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
GO


-- Add Constraints (Module 02) --
ALTER TABLE Categories
 Add Constraint pkCategories
  Primary Key (CategoryId);
GO

ALTER TABLE Categories
 Add Constraint ukCategories
  Unique (CategoryName);
GO

ALTER TABLE Products
 Add Constraint pkProducts
  Primary Key (ProductId);
GO

ALTER TABLE Products
 Add Constraint ukProducts
  Unique (ProductName);
GO

ALTER TABLE Products
 Add Constraint fkProductsToCategories
  Foreign Key (CategoryId) References Categories(CategoryId);
GO

ALTER TABLE Products
 Add Constraint ckProductUnitPriceZeroOrHigher
  Check (UnitPrice >= 0);
GO

ALTER TABLE Inventories
 Add Constraint pkInventories
  Primary Key (InventoryId);
GO

ALTER TABLE Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
GO

ALTER TABLE Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
GO

ALTER TABLE Inventories
 Add Constraint ckInventoryCountZeroOrHigher
  Check ([Count] >= 0);
GO

--create views for tables

DROP VIEW IF EXISTS vCategories;
GO
CREATE VIEW vCategories
		As
            SELECT CategoryID, CategoryName
            FROM Assignment05DB_AKrinksy.dbo.Categories
GO

DROP VIEW IF EXISTS vProducts;
GO
CREATE VIEW vProducts
		As
            SELECT ProductID, ProductName, CategoryID, UnitPrice
            FROM Assignment05DB_AKrinksy.dbo.Products
GO

DROP VIEW IF EXISTS vInventories;
GO
CREATE VIEW vInventories
		As
            SELECT InventoryID, InventoryDate, ProductID, [Count]
            FROM Assignment05DB_AKrinksy.dbo.Inventories
GO


/* Show the Current data in the Categories, Products, and Inventories Tables
SELECT * FROM vCategories;
GO
SELECT * FROM vProducts;
GO
SELECT * FROM vInventories;
GO
*/

-- Step 2: Add some starter data to the database

INSERT INTO Categories (CategoryName)
  Values('Beverages');

INSERT INTO Products (ProductName, CategoryID, UnitPrice)
  Values('Chai', 1, 18),
  ('Chang', 1, 19);

INSERT INTO Inventories (InventoryDate, ProductID, [Count])
  Values('20170101', 1, 61),
    ('20170101', 2, 17),
    ('20170201',	1, 13),
    ('20170201', 2,	12),
    ('20170302', 1,	18),
    ('20170302', 2, 12);

/* Add the following data to this database using inserts:
Category	Product	Price	Date		Count
Beverages	Chai	18.00	2017-01-01	61
Beverages	Chang	19.00	2017-01-01	17

Beverages	Chai	18.00	2017-02-01	13
Beverages	Chang	19.00	2017-02-01	12

Beverages	Chai	18.00	2017-03-02	18
Beverages	Chang	19.00	2017-03-02	12
*/

-- Step 3: Create transactional stored procedures for each table using the proviced template:

--create insert proc CATEGORIES
GO
CREATE PROC pInsCategories (@CategoryName nvarchar(100))
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc CATEGORIES
** Change Log: When,Who,What
** <2020-01-01>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Categories (CategoryName)
      Values(@CategoryName);
   COMMIT TRAN
   SET @RC = +1
  END Try
  BEGIN Catch
   If(@@Trancount > 0) Rollback TRAN
   Print Error_Message()
   SET @RC = -1
  END Catch
  Return @RC;
 END
GO
--create update proc CATEGORIES
CREATE Proc pUpdCategories (
  @CategoryID int,
  @CategoryName nvarchar(100)
  )
  /* Author: <AKrinksy>
  ** Desc: Create Update Proc CATEGORIES
  ** Change Log: When,Who,What
  ** <2020-01-01>,<AKrinksy>,Created stored procedure.
  */
As
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        Update Categories
          SET CategoryName = @CategoryName
          WHERE CategoryID = @CategoryID
    COMMIT TRAN
    SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO


--create delete proc CATEGORIES
CREATE PROC pDelCategories (@CategoryID int)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc CATEGORIES
** Change Log: When,Who,What
** <2020-01-01>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Categories
            WHERE CategoryID = @CategoryID
      COMMIT TRAN
      SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

--create insert proc PRODUCTS
GO
CREATE PROC pInsProducts (
  @ProductName nvarchar(100),
  @CategoryID int,
  @UnitPrice money
  )
  /* Author: <AKrinksy>
  ** Desc: Create Insert Proc Products
  ** Change Log: When,Who,What
  ** <2020-01-01>,<AKrinksy>,Created stored procedure.
  */
AS
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Products (ProductName, CategoryID, UnitPrice)
      Values(@ProductName, @CategoryID, @UnitPrice);
   COMMIT TRAN
   SET @RC = +1
  END Try
  BEGIN Catch
   If(@@Trancount > 0) Rollback TRAN
   Print Error_Message()
   SET @RC = -1
  END Catch
  Return @RC;
 END
GO
--create update proc PRODUCTS
CREATE Proc pUpdProducts (
  @ProductID int,
  @ProductName nvarchar(100),
  @CategoryID int,
  @UnitPrice money
  )
As
/* Author: <AKrinksy>
** Desc: Create Update Proc Products
** Change Log: When,Who,What
** <2020-01-01>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        Update Products
          SET ProductName = @ProductName,
              CategoryID = @CategoryID,
              UnitPrice = @UnitPrice
          WHERE ProductID = @ProductID
      COMMIT TRAN
      SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

--create delete proc PRODUCTS
CREATE PROC pDelProducts (@ProductID int)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc Products
** Change Log: When,Who,What
** <2020-01-01>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Products
            WHERE ProductID = @ProductID --USE ID OVER NAME RIGHT?
      COMMIT TRAN
      Set @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

--create proc INVENTORIES
GO
CREATE PROC pInsInventories (
  @InventoryDate Date,
  @ProductID int,
  @Count int
  )
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc Inventories
** Change Log: When,Who,What
** <2020-01-01>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Inventories (InventoryDate, ProductID, [Count])
      Values(@InventoryDate, @ProductID, @Count);
   COMMIT TRAN
   SET @RC = +1
  END Try
  BEGIN Catch
   If(@@Trancount > 0) Rollback TRAN
   Print Error_Message()
   SET @RC = -1
  END Catch
  Return @RC;
 END
GO
--create update proc INVENTORIES

GO
CREATE Proc pUpdInventories (
  @InventoryID int,
  @InventoryDate Date,
  @ProductID int,
  @Count int
  )
As
/* Author: <AKrinksy>
** Desc: Create Update Proc Inventories
** Change Log: When,Who,What
** <2020-01-01>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        Update Inventories
          SET InventoryDate = @InventoryDate,
              ProductID = @ProductID,
              [Count] = @Count
          WHERE InventoryID = @InventoryID
       COMMIT TRAN
       SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO
--create delete proc INVENTORIES
CREATE PROC pDelInventories (@InventoryID int)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc Inventories
** Change Log: When,Who,What
** <2020-01-01>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Inventories
            WHERE InventoryID = @InventoryID --USE ID OVER NAME RIGHT?
      COMMIT TRAN
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
  End Catch
  Return @RC;
 End
GO

-- Step 4: Create code to test each transactional stored procedure.

--Test Insert to Categories
DECLARE @Status int;
SELECT * FROM vCategories;
EXEC @Status = pInsCategories
            @CategoryName = 'Food';
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vCategories Where CategoryID = @@IDENTITY;


-- Test Update to Categories
EXEC @Status = pUpdCategories
            @CategoryID = @@IDENTITY,
            @CategoryName = 'Place';
SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
SELECT * FROM vCategories WHERE CategoryID = @@IDENTITY;

--Test Delete for Categories
EXEC @Status = pDelCategories
            @CategoryID = 2;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed! Common Issues: Foriegn Key Violation'
  END AS [Status];
SELECT * FROM vCategories WHERE CategoryID = @@IDENTITY;

GO
--Test Insert for Products
DECLARE @Status int;
SELECT * FROM vProducts;
EXEC @Status = pInsProducts
            @ProductName = 'Water',
            @CategoryID = '1',
            @UnitPrice = 5;
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
SELECT * FROM vProducts WHERE ProductID = @@IDENTITY;
--Test Update for Products
EXEC @Status = pUpdProducts
            @ProductID = @@IDENTITY,
            @ProductName = 'Water',
            @CategoryID = '1',
            @UnitPrice = 7;
SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
SELECT * FROM vProducts WHERE ProductID = @@IDENTITY;
--Test Delete
EXEC @Status = pDelProducts
            @ProductID = @@IDENTITY;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed'
  END AS [Status];
SELECT * From vProducts WHERE ProductID = @@IDENTITY;
--Inventories
GO
--Test Insert
DECLARE @Status int;
SELECT * FROM vInventories;
EXEC @Status = pInsInventories
           @InventoryDate = '20170301',
           @ProductID = 2,
           @Count = 40;
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data or Foreign Key Constraint'
  END AS [Status];
SELECT * FROM vInventories WHERE InventoryID = @@IDENTITY;
--Test Update
EXEC @Status = pUpdInventories
            @InventoryID = @@IDENTITY,
            @InventoryDate = '20170302',
            @ProductID = 2,
            @Count = 50;
SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
SELECT * FROM vInventories WHERE InventoryID = @@IDENTITY;
--Test Delete
EXEC @Status = pDelInventories
            @InventoryID = @@IDENTITY;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed'
  END AS [Status];
SELECT * FROM vInventories WHERE InventoryID = @@IDENTITY;
