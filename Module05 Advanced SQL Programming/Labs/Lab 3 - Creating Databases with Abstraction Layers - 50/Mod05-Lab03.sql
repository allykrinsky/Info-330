--*************************************************************************--
-- Title: Module05-Lab03
-- Author: YourNameHere
-- Desc: This file demonstrates how to create transaction stored procedures
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'MyLabsDB_YourNameHere')
 Begin 
  Alter Database [MyLabsDB_YourNameHere] set Single_user With Rollback Immediate;
  Drop Database MyLabsDB_YourNameHere;
 End
go
Create Database MyLabsDB_YourNameHere;
go
Use MyLabsDB_YourNameHere;
go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go
-- Adding Data (Module 03) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Exec sp_help Categories;
go
Exec sp_help Products;
go 

--Step 2: Create SQL Transaction Stored Procedures
--Use the provided stored procedure template to create insert, update, and delete stored procedures for each of the three tables.
Create Procedure <pTrnTableName>
(<@P1 int = 0>)
/* Author: <YourNameHere>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<Your Name Here>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
-- Step 3: Create SQL Transaction Stored Procedures 
-- Modify and use the following code to test your stored procedures.
/* Testing Code:
 Declare @Status int;
 Exec @Status = pTrnTableName @P1 = 1;
 Print @Status;
*/



