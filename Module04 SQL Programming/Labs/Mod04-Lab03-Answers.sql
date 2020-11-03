--*************************************************************************--
-- Title: Module04-Lab03
-- Author: RRoot
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--

Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'MyLabsDB_RRoot')
 Begin 
  Alter Database [MyLabsDB_RRoot] set Single_user With Rollback Immediate;
  Drop Database MyLabsDB_RRoot;
 End
go

Create Database MyLabsDB_RRoot;
go

Use MyLabsDB_RRoot;
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

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
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

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
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

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers ********************************
'NOTES------------------------------------------------------------------------------------ 
-- You can use any name you like for you views, but be descriptive and consistent!
-- Quantities may vary, since I use a random function to create the data!
-- Make sure your code is well formatted!
-- You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
*/

-- Question 1: How can you create BASIC views to show data from each table in the database.
-- 1.	Do not use a *, list out each column!
-- 2.	Create one view per table!
-- 3.	Use SchemaBinding to protect the views from being orphaned!
go
Create View vCategories
With SchemaBinding
AS
  Select 
   c.CategoryID
  ,c.CategoryName 
  From dbo.Categories as c;
go
Create View vProducts
With SchemaBinding
AS
  Select 
   [ProductID]
  ,[ProductName]
  ,[CategoryID]
  ,[UnitPrice]
  From dbo.Products;
go
Create View vEmployees
With SchemaBinding
AS
  Select 
    [EmployeeID]
   ,[EmployeeFirstName]
   ,[EmployeeLastName]
   ,[ManagerID]
  From [dbo].[Employees];
go
go
Create View vInventories
With SchemaBinding
AS
  Select 
   [InventoryID]
  ,[InventoryDate]
  ,[EmployeeID]
  ,[ProductID]
  ,[Count]
  From [dbo].[Inventories];
go

-- Question 2: How can you set permissions, so that the public group CANNOT select data from each table, but can select data from each view?
-- Deny access to the tables
Deny Select On [dbo].[Categories] to Public;
Deny Select On [dbo].[Products] to Public;
Deny Select On [dbo].[Employees] to Public;
Deny Select On [dbo].[Inventories] to Public;

-- Grant access to the tables
Grant Select On [dbo].[vCategories] to Public;
Grant Select On [dbo].[vProducts] to Public;
Grant Select On [dbo].[vEmployees] to Public;
Grant Select On [dbo].[vInventories] to Public;

-- Question 3: How can you create a view to show a list of Category and Product names, 
-- and the price of each product? Order the result by the Category and Product!
go
Create View [vProductsByCategories]
AS
  Select Top 100000 
    CategoryName
   ,ProductName
   ,UnitPrice
  From Categories as c Inner Join Products as p
   on c.CategoryID = p.CategoryID
  Order By CategoryName, ProductName 
go
-- Question 4: How can you create a view to show a list of Product names and Inventory Counts 
-- on each Inventory Date? 
-- Order the results by the Product, Date, and Count!
go
Create View [vInventoriesByProductsByDates]
AS
  Select Top 100000 
    p.[ProductName]
   ,i.[Count]
   ,i.[InventoryDate]
  From [dbo].[Products] as p Inner Join [dbo].[Inventories] as i
   On p.[ProductID] = i.[ProductID]
  Order By 
    p.[ProductName]
   ,i.[InventoryDate]
   ,i.[Count]
  ;
go

-- Question 5: How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count? Order the results by the Date 
-- and return only one row per date!
go
Create View [vInventoriesByEmployeesByDates]
AS 
Select Distinct Top 100000
  e.[EmployeeFirstName]
 ,e.[EmployeeLastName]
 ,i.[InventoryDate]
From [dbo].[Inventories] as i Join [dbo].[Employees] as e
 on i.[EmployeeID] = e.[EmployeeID]
Order By i.[InventoryDate]
;
go

-- Question 6: How can you create a function to show a list of Inventory Dates 
--and the Employee that took the count? Order the results by the Date 
--and return only one row per date! Add a parameter 
--to filter by the employee's first and last name.

Create Function dbo.[fInventoriesByDatesPerEmployee]
(@EmployeeFirstName nvarchar(100), @EmployeeLastName nvarchar(100)) 
Returns Table
AS
 Return(
  Select Distinct Top 100000
    e.[EmployeeFirstName]
   ,e.[EmployeeLastName]
   ,i.[InventoryDate]
  From [dbo].[Inventories] as i Join [dbo].[Employees] as e
   on i.[EmployeeID] = e.[EmployeeID]
  Where 
    e.[EmployeeFirstName] = @EmployeeFirstName
    and 
    e.[EmployeeLastName] = @EmployeeLastName
  Order By i.[InventoryDate]
);
go

-- Test your Views and Function (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[fInventoriesByDatesPerEmployee]('Steven','Buchanan')

/***************************************************************************************/