--*************************************************************************--
-- Title: Module06 
-- Author: RRoot
-- Desc: This file demonstrates selecting data using Views 
--		Views vs Tables
--		Views as an Abstraction Layer
--      Views for Reporting
--		Views vs Temp Tables

-- Change Log: When,Who,What
-- 2017-07-28,RRoot,Created File
--**************************************************************************--

'*** Views vs Tables ***'
-----------------------------------------------------------------------------------------------------------------------
-- Let's make a demo database for this module
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Module06Demos')
	 Begin 
	  Alter Database [Module06Demos] set Single_user With Rollback Immediate;
	  Drop Database Module06Demos;
	 End
	Create Database Module06Demos;
End Try
Begin Catch
	Print Error_Message();
End Catch
go
Use Module06Demos;

-- Tables are used to STORE data
Create -- Drop
Table Categories
( CategoryID int, CategoryName nVarchar(50));
go

-- Add some data
Insert into Categories Values(1, 'CatA'), (2,'CatB');
go

-- See the data in the table
Select CategoryID, CategoryName From Categories;
go

-- Views are used to DISPLAY Data
Create -- Drop 
View vCategories
AS
  Select CategoryID, CategoryName 
   From Categories;
go

-- DISPLAY the data in the table
Select CategoryID, CategoryName From vCategories;
go

-- You can insert data THROUGH a view into a table. 
Insert into vCategories Values(3, 'CatC');
go

-- NOTE: This can confuse people into thinking a view is the same as a table. 
-- It is not! The view never stores data, only its table does!
Select CategoryID, CategoryName From Categories;
Select CategoryID, CategoryName From vCategories;
go

-- Both Views and Tables can be altered, but the syntax is different
-- Changing a table...
Alter Table Categories Alter Column CategoryID int Not Null;
go
Alter Table Categories Add Constraint pkCategories Primary Key (CategoryID);
go

-- Changing a view...
Alter View vCategories
AS
 Select CategoryID, CategoryName as [CatName] --<< Note the aliased column name  
  From Categories;
go

-- Now the view and the table look a bit different
Select CategoryID, CategoryName From Categories Order By 1,2;
Select CategoryID, [CatName] From vCategories Order By 1,2;
go

-- Tables have Foreign Keys constaints, but views do not
-- Foreign Key constraints ENFORCE relations between data between tables
Create -- Drop
Table Products
( ProductID int
, ProductName nVarchar(50)
, CategoryID int References Categories(CategoryID) -- This creates a FK constraint
);
go
Insert into Products Values (1, 'ProdA',1),(2,'ProdB',1),(3,'ProdC',2);
go

Select ProductID,ProductName,CategoryID From Products;
go

-- Views can DISPLAY data from multiple tables into a single result set
Create -- Drop
View vProductsByCategory
AS
Select ProductID, ProductName, CategoryName
 From Products Join Categories
  ON Products.CategoryID = Categories.CategoryID;
go
Select * From vProductsByCategory;
go

-- Foreign Keys will not protect a Parent table from being Dropped
Drop Table Categories;
go

-- Views use SCHEMABINDING to stop tables from changing 
-- so much the the view does not work any more!
Alter -- Drop
View vCategories
WITH SCHEMABINDING-- this Requiers you to use the table's 2 part name!
AS
 Select CategoryID, CategoryName as [CatName] From dbo.Categories; --<< 2 part name
go

-- If a table's changes will not break it's View, then the change is allowed
Alter Table Categories Add IsDiscontinued int; -- SYNTAX TIP: Here you don't use the word "Column"
go
Select * From Categories;
Select * From vCategories; 
go

-- But, other changes are NOT are not allowed. Ones that would break the table's views
Alter Table Categories Drop Column CategoryName; -- SYNTAX TIP: You use the word "Column" (Odd, but true)
go

-- Also, you cannot drop the whole table!
Begin Try
 Begin Tran;
  Drop Table Products;
  Drop Table Categories;
 Commit Tran;
End Try
Begin Catch
 Print Error_Message();
 Rollback Tran;
End Catch
go


'*** Views as an Abstraction Layer ***'
-----------------------------------------------------------------------------------------------------------------------
-- Each table in a database should have a view to show data from that table.
-- When you make a table...
Create -- Drop 
Table tblCustomers -- Note: "tbl" is a common prefix in some databases
( CustomerID int Identity Primary Key, CustomerName nVarchar(100) );
go
Insert Into tblCustomers (CustomerName) 
 Values ('Bob Smith'),('Sue Jones');
go

-- Make a matching view!
Create -- Drop 
View Customers With SchemaBinding
AS 
 Select CustomerID, CustomerName From dbo.tblCustomers;
go

-- Without a prefix in the name, like vCustomers, people may think your view is a table! 
Select * from Customers;
go

-- If later the database table needs to be changed, applications that use 
-- the view can continue to work, but just modifying the code in the view
-- to hide those changes.
	-- Step 1) Drop the existing table
	Drop View Customers;
	Select * Into #TempCustomers from tblCustomers;
	Drop Table tblCustomers;

	-- Step 2) Make the changes
	Create -- 2.1 
	Table tblCustomers -- Note: tbl is a common prefix in some databases
	( CustomerID int Identity Primary Key
	, CustomerFirstName nVarchar(100) 
	, CustomerLastName nVarchar(100) 
	);
	go

	Insert -- 2.2
	Into tblCustomers (CustomerFirstName, CustomerLastName)
	 Select 
	   CustomerFirstName = Substring(CustomerName, 1,3)  --<< Normally you use PatIndex to find the space! More on this in next module!
	  ,CustomerLastName = Substring(CustomerName, 4,100) 
	  From #TempCustomers;
	go

	Create -- 2.3
	View Customers With SchemaBinding
	AS 
	 Select CustomerID, CustomerName = CustomerFirstName + ' ' + CustomerLastName 
	  From dbo.tblCustomers;
	go

	Create -- 2.4
	View CustomersNormalized With SchemaBinding
	AS 
	 Select CustomerID, CustomerFirstName , CustomerLastName 
	  From dbo.tblCustomers;
	go

	-- Step 3) Verify the changes
	-- Now the table and View look different
	Select * From tblCustomers;
	Select * From Customers;
	Select * From CustomersNormalized;
	go

-- You set permissions to force developers into using the view and not the actual table
Deny Select On tblCustomers to Public;
Grant Select On Customers to Public;


'*** Views for Reporting ***'
-----------------------------------------------------------------------------------------------------------------------
-- If you display data from multiple tables often, you should create reporting views
-- This is especially important as your code become more complex
Create -- Drop
View vAuthorsByTitles
AS 
  Select 
    [Title] = T.title
   ,[Author]= A.au_fname + ' ' + A.au_lname
   ,[Order On Title] = Choose(TA.au_ord, '1st', '2nd', '3rd') 
   From pubs.dbo.titles as T
   Join pubs.dbo.titleauthor as TA
    On T.title_id = TA.title_id
   Join pubs.dbo.authors as A
    On TA.au_id = A.au_id
go

-- Now we can run the complex view code, using only a simple Select statement!
Select * from vAuthorsByTitles Order By 1,3;;
go

-- Unless you use the TOP clause. Views cannot include the Order By clause, 
Alter View vCategories
AS 
Select TOP 1000000000  --< Need this
  CategoryID, CategoryName as [CatName]
 From Categories
  Order By CategoryName --< If you want to include this
go
Select * from vCategories


-- Views allow split data stored in one table (At least from a visual aspect)
-- You can divide data by rows
Select * from Pubs.dbo.Sales;
go
Create View Store6380Sales AS
	Select St.stor_name as Store, S.*
	From Pubs.dbo.Sales as S Join Pubs.dbo.stores as St
	 On S.stor_id = St.stor_id Where S.stor_id = 6380;
go
Create View Store7066Sales AS
	Select St.stor_name as Store, S.*
	From Pubs.dbo.Sales as S Join Pubs.dbo.stores as St
	 On S.stor_id = St.stor_id Where S.stor_id = 7066;
go

Select * From Store6380Sales;
Select * From Store7066Sales;

-- You can divide data by Columns too
Select * From Northwind.dbo.Employees;
Go
-- Public Information
Create View vPublicEmployeeInfo
As
 Select 
   TitleOfCourtesy
  ,FirstName
  ,LastName
  ,Title
  ,City
  ,Region
  ,PostalCode
  ,Country
  ,HomePhone
  ,ReportsTo
  ,PhotoPath
  From Northwind.dbo.Employees;
go

Create View vPrivateEmployeeInfo
As
 Select
   EmployeeID
  ,LastName
  ,FirstName
  ,Title
  ,TitleOfCourtesy
  ,BirthDate
  ,HireDate
  ,Address
  ,City
  ,Region
  ,PostalCode
  ,Country
  ,HomePhone
  ,Extension
  ,Photo
  ,Notes
  ,ReportsTo
  ,PhotoPath
  From Northwind.dbo.Employees;
Go

-- Now we protect the private data with permissions
Use Northwind;
Deny Select On Employees to Public;

Use Module06Demos;
Deny Select vPrivateEmployeeInfo to Public;
Grant Select On vPublicEmployeeInfo to Public;

'*** Views vs Temp Tables ***'	 
-----------------------------------------------------------------------------------------------------------------------
-- Views are just saved select statements. So, every time you run the view 
-- it has to run the query, which can be a lot of work for SQL
Create -- Drop
View vCustomerProductOrderSummary 
AS 
Select Top 1000000
 C.CompanyName 
,P.ProductName
,[TotalQty] = Sum(OD.Quantity)
,[TotalPrice] = Format(Sum(OD.UnitPrice), 'C', 'en-us')
,[ExtendedPrice] = Format((Sum(OD.Quantity) * Sum(OD.UnitPrice)), 'C', 'en-us')
From Northwind.dbo.Customers as C
Join Northwind.dbo.Orders as O
 On C.CustomerID = O.CustomerID
Join Northwind.dbo.[Order Details] as OD
 On O.OrderID = OD.OrderID
Join Northwind.dbo.Products as P
 On OD.ProductID = P.ProductID
Group By 
 P.ProductName
,P.ProductID
,C.CompanyName
Order By 1,2,3,4;
go

-- Now we use the view an apply additional fomatting and ordering
-- NOTE to TEACHER: Turn on and talk about the Execution Plan 
Select * From vCustomerProductOrderSummary;
Go

-- If you think you will use this a lot you can choose to create a Local Temporary Table 
-- Local Temp tables can only be used by the connection it is made on and last until you close the connection
Select * 
  Into #CustomerProductOrderSummary
 From vCustomerProductOrderSummary;
Go

-- Check out how simple the execution plan has become!
Select * from #CustomerProductOrderSummary;


-- If you need to let someone else see the data you can create a Global Temporary Table
-- Global Temp tables can be used by many connections.
Select *
  Into ##CustomerProductOrderSummary
 From vCustomerProductOrderSummary;
Go

Select * from #CustomerProductOrderSummary; -- Works only for this connection
Select * from ##CustomerProductOrderSummary; -- Works for many connections!
go 

-- If you think you will use this result often you can just create a Reporting table
Select *
  Into CustomerProductOrderSummary
 From vCustomerProductOrderSummary;
Go
-- TIP: People often automate the re-creation of reporting tables each night

Select * from #CustomerProductOrderSummary; -- Works only for this connection
Select * from ##CustomerProductOrderSummary; -- Works for many connections!
Select * from CustomerProductOrderSummary; -- Works for many connections and must be deleted manually!
go 

-- If you want to delete the table manually
Drop Table #CustomerProductOrderSummary; 
Drop Table ##CustomerProductOrderSummary;
Drop Table CustomerProductOrderSummary;
go
