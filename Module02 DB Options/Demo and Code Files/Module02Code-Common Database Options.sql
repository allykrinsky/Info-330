--*************************************************************************--
-- Title: Module02
-- Author: RRoot
-- Desc: This file demonstrate Typical additions to database tables
--       1) Constraints
--       2) Indexes
--       3) Views
--       4) Stored Procedures
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--

'1) Constraints'
--****************************************************--
-- SQL Server supports four types of data integrity: 
-- Entity integrity, Domain integrity, Referential integrity, 
-- and User-Defined integrity (Found in Stored procedures and
-- Triggers ). 
CREATE -- DROP
DATABASE CommonOptionsDemoDB;
Go

USE CommonOptionsDemoDB;
Go

Create -- DROP
Table Demo (
	col1 int Primary Key,
	col2 int Unique,
	col3 int Check (col3 > 0),
	col4 int Foreign Key References Demo(col2),
	col5 int Default(0),
	col6 int NOT NULL
);

-- You can get general information about a table like this:
EXEC sp_Help Demo;
Go

-- Shows only the constraints on the table.
EXEC sp_HelpConstraint Demo;
Go

-- In SQL there are also System Views for the different constraint types
SELECT * FROM sys.default_constraints;
SELECT * FROM sys.check_constraints;
SELECT * FROM sys.key_constraints;
SELECT * FROM sys.foreign_keys;
Go

-- The code for Check and default constraints are stored in the sys.comments hidden table
SELECT Object_name(ID), * FROM SysComments;
Go

'*** Default and Null Constraints ***'
-----------------------------------------------------------------------------------------------------------------------
-- Create a Products table with Default Constraints
CREATE -- DROP
TABLE dbo.Products ( 
	ProductID int IDENTITY (1, 1) NOT NULL, -- identity is not truly a constraint
	ProductName nvarchar (100) NOT NULL,
	SupplierID int NULL,
	UnitPrice money NULL DEFAULT(0), -- Without an explicit name
	UnitsInStock smallint NULL CONSTRAINT DF_Products_UnitsInStock DEFAULT(0) -- With an explicit name
);
Go

-- If you don't name your constrains SQL does it for you
SELECT * FROM sys.default_constraints 
	WHERE parent_object_id = Object_ID('Products');
Go

'*** Primary Key Constraints ***'
-----------------------------------------------------------------------------------------------------------------------
-- Now create a Suppliers table with a PRIMARY KEY constraint 
-- Defined after the columns are listed (Table level constraint)
CREATE -- DROP
TABLE dbo.Suppliers(
	SupplierID int NOT NULL, 
	ContactID int NOT NULL
CONSTRAINT PK_Suppliers PRIMARY KEY CLUSTERED (SupplierID)
);
Go

-- Primary Keys can also be added after a table is made
ALTER TABLE dbo.Products
	ADD -- DROP
	CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (ProductID);
Go

'*** Adding a Unique Constraint ***'
-----------------------------------------------------------------------------------------------------------------------
ALTER TABLE dbo.Suppliers 
	ADD -- DROP
	CONSTRAINT U_ContactID UNIQUE NonCLUSTERED (ContactID);
Go

'*** Adding a Referential Constraint ***'
-----------------------------------------------------------------------------------------------------------------------
ALTER TABLE dbo.Products  
	ADD -- DROP 
	CONSTRAINT FK_Products_Suppliers  
		FOREIGN KEY (SupplierID)
		REFERENCES dbo.Suppliers (SupplierID)  
		ON UPDATE CASCADE 
		ON DELETE CASCADE;
Go

'*** Adding a Check Constraint ***'
-----------------------------------------------------------------------------------------------------------------------
ALTER TABLE dbo.Products  
	ADD -- DROP
	CONSTRAINT CK_Products_UnitPrice CHECK (UnitPrice >= 0);
Go

'*** Adding a Default Constraint after the table is made ***'
-----------------------------------------------------------------------------------------------------------------------
ALTER TABLE dbo.Suppliers  
	ADD -- DROP 
	CONSTRAINT DF_Suppliers_ContactId DEFAULT (1)
	FOR ContactId;
Go

EXEC sp_HelpConstraint Products;
EXEC sp_HelpConstraint Suppliers;
Go

'** LAB ******************************************************'
/* -- Do the following (estimated time 20 mins)

-- 1) Run this code to create a simple database with tables:
 
	Create Database CommonOptionsLabDB;
	Go
	Use CommonOptionsLabDB;
	Go
	Create Table Classes (ClassID int Not Null, ClassName nVarchar(100), ClassStandardPrice money);
	Create Table Students (StudentID int Not Null, StudentFirstName nVarchar(100), StudentLastName nVarchar(100));
	Create Table StudentsClasses (StudentID int Not Null, ClassID int Not Null, ClassStartDate Date);
	Go
	Insert Into Classes Values (100,'ClassA',399.00),(200,'ClassB',299.00);
	Insert Into Students Values (1,'Bob','Smith'),(2,'Sue','Jones'); 
	Insert Into StudentsClasses Values (1,100,'01/01/2020'),(1,200,'02/01/2020'),(2,200,'02/01/2020');
		 
-- 2) Alter these tables and add the follwing Constraints:

	a) Make ClassID the Primary Key of the Classes table
	b) Make StudentID the Primary Key of the Students table
	c) Make StudentID and ClassID the Primary Key of the StudentsClasses table
	d) Check that the ClassStandardPrice is never below zero
	e) Create a Foreign Key between the Classes and StudentsClasses Table
	f) Create a Foreign Key between the Students and StudentsClasses Table

-- 3) Add data to the tables to verify the contraints are working

	Insert Into Classes Values (100,'ClassA',399.00); -- Should Fail
	Insert Into Students Values (1,'Bob','Smith'); -- Should Fail
	Insert Into StudentsClasses Values (1,100,'01/01/2020');
	Insert Into Classes Values (300,'ClassC', -1.00); -- Should Fail
	Insert Into StudentsClasses Values (3,100,'01/01/2020'); -- Should Fail
	Insert Into StudentsClasses Values (1,300,'01/01/2020'); -- Should Fail

*/
'*************************************************************'


'2) Indexes' 
--****************************************************--
-- Most databases will include one or more indexes on each table.

'*** a. Heaped vs Clustered tables ***'
-----------------------------------------------------------------------------------------------------------------------
-- Heaps --
-- By default, data is placed in pages in the first available space. 
-- This may start off as being sequential but the sequence is NOT maintained.
-- This type of orgainization is referered to as a HEAP.

-- When a table is first made the configuration of that table is a Heap. 
CREATE -- DROP
TABLE PhoneList (Id int, Name varchar(50), Extension char(5));
Go

INSERT INTO PhoneList 
	VALUES	(1,'Bob Smith','#11'),
			(2,'Sue Jones','#12'),
			(3,'Joe Harris','#13');
Go

SELECT * FROM Phonelist;
Go

-- While the table may appear to be sequentially organized, 
-- if you remove a row and then add one back you will see 
-- that SQL Server uses the first available slot in a page.
DELETE FROM PhoneList WHERE Id = 2;
Go

INSERT INTO PhoneList VALUES (4, 'Tim Thomas', '#14');
Go

SELECT * FROM Phonelist;
Go

-- Clustering --
-- If you would like to have SQL Server maintain the sequence on the page 
-- you can add a Clustered Index to the table and it will do so.
CREATE CLUSTERED INDEX ci_Id ON PhoneList(Id);
Go

SELECT * FROM Phonelist;
Go

'*** b. NonClustered Indexes and Covered Queries ***'
-----------------------------------------------------------------------------------------------------------------------
-- If you want increase the performance for a spacific type of select query, 
-- you can create a copy of the column or columns referenced in you query
-- into an additional set of data pages. These page will be seperate from the 
-- table but linked to in by either a Row Id or a "lookup" value from the 
-- original table. 

CREATE NonCLUSTERED INDEX nci_Name ON PhoneList(Name);
Go 
-- When you select only that indexed column you can get all the data from 
-- the NonClustered Index instead of the table. If the NonClusterd index 
-- contains only some of the tables columns then there will be less pages
-- look through.
SELECT * FROM PhoneList;
Go

SELECT Name FROM PhoneList;
Go

-- Now the table will be physically sorted on that Indexed column. 
-- This will improve performance on some of your querys, 
-- but will not help all of them.
'NOTE: Turn on the Execution Plan to see when the indexes are used'

SELECT * FROM Phonelist; -- not helpful
Go
 
SELECT * FROM Phonelist  ORDER BY [Id]; -- Somewhat helpful
Go

SELECT * FROM Phonelist  ORDER BY [Name]; -- Somewhat helpful
Go

SELECT * FROM Phonelist  Where [Id] = 4; --  Helpful
Go
SELECT * FROM Phonelist  Where [Name] = 'Joe Harris' --  Helpful
Go

SELECT Name FROM Phonelist;  --  Helpful
Go

SELECT Id, Name FROM Phonelist;  --  Helpful
Go

'** LAB ******************************************************'
/* -- Do the following (estimated time 10 mins)

-- 1) Using the CommonOptionsLabDB, add indexes that might improve
-- the performance of the following queries:

	a) Select * from Classes Where ClassClassStandardPrice > 100;
	b) Select * from Classes Where StudentLastName = 'Smith';

-- 2) Test the the indexes are used when you run the pervious queries
-- Using the Execution Plan feature of Management Studio.
*/
'*************************************************************'


'3) Views' 
--****************************************************--
-- Views are simply saved SELECT statements that abstract
-- access to the data in the database. They have proven 
-- to be a good option for allowing database designs
-- to change over time without having to recreate user 
-- applications.
-- Besides, they are easy to create and take up practically  
-- no space in the database.

USE Northwind;
Go

CREATE -- DROP
VIEW vCustomerOrders
AS
  SELECT Orders.OrderID, Customers.CompanyName, Customers.ContactName
  FROM Orders  
  JOIN Customers
	ON Orders.CustomerID = Customers.CustomerID;
Go

-- You use a View as if it were a table
SELECT * FROM vCustomerOrders;
Go

-- You can see the text of your view by looking in the sysComments "table"
SELECT * FROM sysComments 
	WHERE id = Object_id('vCustomerOrders');
Go

-- You can also use this stored procedure to see the text
-- including the spaces and carriage returns of the original format.
EXEC sp_HelpText vCustomerOrders;
Go

'** LAB ******************************************************'
/* -- Do the following (estimated time 10 mins)

-- 1) Using the CommonOptionsLabDB, create a view for each table:
	a) Classes
	b) Students
	c) StudentsClasses

-- 2)Test your view by creating select quieries for each of them.
*/
'*************************************************************'

'4) Stored Procedures' 
--*************************************************************--
-- Like Views, a Stored Procedure (SProcs, or Procs) 
-- are just saved SQL code. However, unlike Views, Sproc 
-- can include many SQL statement, as long as they will run as 
-- one bacth of code.

Use Northwind;
Go

CREATE -- DROP
PROC pGetEmployeeData
AS
  SELECT FirstName, LastName, HireDate 
	FROM Employees;
Go

-- To Run your saved code you "Execute" the 
-- Stored Procedure like this...
EXECUTE pGetEmployeeData;
-- Or this ...

EXEC pGetEmployeeData;

-- Or even this ...
pGetEmployeeData;
Go

-- The SysComments table shows the text for the 
-- Stored Procedure cross referenced by it's object Id 
SELECT * FROM sysComments
	WHERE id = Object_id('pGetEmployeeData');
Go

-- Microsoft's  sp_HelpText system stored procedure  
-- displays the text of a store procedure in it's 
-- Original format
EXEC sp_HelpText 'pGetEmployeeData';

'** LAB ******************************************************'
/* -- Do the following (estimated time 10 mins)

-- 1) Using the CommonOptionsLabDB, create a Select Stored Procedure for each table:
	a) Classes
	b) Students
	c) StudentsClasses

-- 2)Test your Stored Procedures by executing them.
*/
'*************************************************************'