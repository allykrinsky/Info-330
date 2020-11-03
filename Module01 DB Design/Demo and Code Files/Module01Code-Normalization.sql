--*************************************************************************--
-- Title: Creating Databases and Normalization
-- Author: RRoot
-- Desc: This file details common aspects creating database with using
-- the rules of Normalization
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--
/* 
Data is often stored in a Comma Separated Values list or in spreadsheets as follows:

Products,Price,Units,Customer,Address,Date;
Apples,$0.89,12,Bob Smith,123 Main Bellevue Wa,5/5/2006; 
Milk,$1.59,2,Bob Smith,123 Main Bellevue Wa,5/5/2006; 
Bread,$2.28,1,Bob Smith,123 Main Bellevue Wa,5/5/2006; 

Although this works it is not considered the proper way to store data in a 
Relational database. Doing so has proven to be difficult to maintain and 
prone to errors. Instead, you should apply a series of standard rules when you design your tables. 
These rules are collectively known as NORMALIZATION.
https://support.microsoft.com/en-us/kb/283878

-- Normalization Rule 1: Every column in table must be atomic (single value).
-- Normalization Rule 2: Normalization Rule 1 must be met, AND all fields must depend on the entire set of candidate keys (if there is a set).
-- Normalization Rule 3: Normalization Rule 2 must be met, AND all fields in table must be dependent on the chosen primary key.

'NOTE: Instead of talking about the 1NF, 2NF, and 3NF using the academic jargon we will discuss it using practical examples!' 
*/

CREATE -- DROP
DATABASE NormalizationDB;
Go

USE NormalizationDB;
Go

'*** All Table should be about only one Subject or Event ***'
-- Each table should have an identifier used to tell one row from another 
-- and a table should store only data for a single theme, like customers or products 
-- unless it is being used to link other tables together.
CREATE TABLE dbo.CustomersProducts(
	CustomerName varchar(50) NULL,
	CustomerPhone varchar(50) NULL,
	ProductName varchar(50) NULL,
	Price varchar(50) NULL
);
Go

INSERT INTO dbo.CustomersProducts 
 VALUES ('Bob Smith', '555-1212', 'Chia Pet', '$9.99');
Go

-- Let's see what the data looks like now
SELECT * FROM CustomersProducts;
Go

-- This works, but is not a 'Best Practice.' Instead break the table into two tables...
-- Better Design --
DROP TABLE dbo.CustomersProducts;
Go

CREATE TABLE dbo.Customers(
	CustomerName varchar(50) NULL,
	CustomerPhone varchar(50) NULL
); 
Go

CREATE TABLE dbo.Products(
	ProductName varchar(50) NULL,
	ProductPrice varchar(50) NULL
) ;
Go

INSERT INTO dbo.Customers 
	VALUES ('Bob Smith', '555-8888');
Go

INSERT INTO dbo.Products 
	VALUES ('Chia Pet', '$9.99');
Go

SELECT * FROM Customers;
SELECT * FROM Products;
Go

'*** All Tables should have a Primary Key to identify one row from another ***'
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE dbo.Customers;
DROP TABLE dbo.Products;
Go

CREATE TABLE dbo.Customers(
	CustomerId int Primary Key, -- We add a Primary Key to the beginning of each table.
	CustomerName varchar(50) NULL,
	CustomerPhone varchar(50) NULL
); 
Go
CREATE TABLE dbo.Products(
	ProductId int Primary Key, -- We add a Primary Key to the beginning of each table.
	ProductName varchar(50) NULL,
	ProductPrice varchar(50) NULL	
); 
Go
INSERT INTO dbo.Customers 
  VALUES (1,'Bob Smith', '555-1212');
Go

INSERT INTO dbo.Products 
  VALUES (100, 'Chia Pet', '$9.99');
Go

SELECT * FROM Customers;
SELECT * FROM Products;
Go


'*** Your table should not have Multi-PART Fields ***'
-- Normalization Rule 1: Every column in table must be atomic (single value) and not have repeating columns in table.
-----------------------------------------------------------------------------------------------------------------------
DROP TABLE dbo.Customers;
Go

-- This is what you will sometimes see...
CREATE TABLE dbo.Customers	(
	CustomerId int Primary Key,
	CustomerName varchar(50) ,
	CustomerPhone varchar(50) ,
	CustomerAddress varchar(200)	
);
Go

INSERT INTO dbo.Customers 
  VALUES (1, 'Bob Smith', '555-1212', '123 Main, Bellevue, WA, 98223');
Go

-- This is an example of a table violating the first normal form...
SELECT * FROM Customers;
Go

-- Better Design --
-- However, you should break up multi-part fields (non-atomic fields containing more than one piece of data) by adding more columns.
DROP TABLE dbo.Customers;
Go

CREATE TABLE dbo.Customers	(
	CustomerId int Primary Key,
	FirstName varchar(50) ,
	LastName varchar(50) ,
	Phone varchar(50) ,
	Address varchar(100),
	City varchar(50),
	State char(2),
	Zip char(5)	
);
Go

INSERT INTO dbo.Customers 
  VALUES (1, 'Bob', 'Smith', '555-1212', '123 Main', 'Bellevue', 'WA', '98223');
Go

SELECT * FROM Customers;
Go

'*** Tables should not have Multi-VALUED Fields ***'
-- Normalization Rule 1: Every column in a table must be atomic (single value) and not have repeating columns in table.
-----------------------------------------------------------------------------------------------------------------------

-- Here is another example of a table violating the first normal form...
CREATE TABLE dbo.BadDesignSales(
	SalesId int Primary Key,
	CustomerId int,
	ProductId varchar(50) NULL,
	Qty varchar(50) NULL
); 
Go

INSERT INTO dbo.BadDesignSales
	VALUES (1001, 1, '100, 101, 102', '2, 5, 3');
Go

SELECT * FROM Customers;
SELECT * FROM BadDesignSales;
SELECT * FROM Products;
Go

-- Better Design --
-- Break up multi-Value fields (non-atomic fields containing more than one piece of data) by adding more columns.
DROP TABLE dbo.BadDesignSales;
Go

CREATE TABLE dbo.Sales(
	SalesId int Primary Key,
	CustomerId int 
);
Go

CREATE TABLE dbo.SalesLineItems(
	SalesId int,
	LineItemId int,
	ProductId int, 
	Qty int,
Primary Key(SalesId, LineItemId)  
); 
Go

INSERT INTO dbo.Sales VALUES (1001, 1);
Go

INSERT INTO dbo.SalesLineItems 
	VALUES (1001, 1, 100, 2),(1001, 2, 101, 5),(1001, 3, 102, 3);
Go

SELECT * FROM Customers;
SELECT * FROM Sales;
SELECT * FROM SalesLineItems;
SELECT * FROM Products;
Go

'*** If a Table has a composite Primary Key then all columns must depend on the combination of both key columns  ***'
-- Normalization Rule 2: Normalization Rule 1 must be met, AND all fields must be dependent on ENTIRE primary key.
-----------------------------------------------------------------------------------------------------------------------

-- Here is an example of a table violating the second normal form...
DROP TABLE dbo.SalesLineItems;
Go
CREATE TABLE dbo.SalesLineItems(
	SalesId int,
	LineItemId int,
	SalesDate date, -- This Column only depends on the SalesId and not on BOTH the SalesId and the LineItemId!
	ProductId int,
	Qty int,
Primary Key(SalesId, LineItemId)  
);
Go

INSERT INTO dbo.SalesLineItems 
	VALUES (1001, 1, '20170101', 100, 2),(1001, 2,'20170101', 101, 5),(1001, 3,'20170101', 102, 3);
Go
-- Note how the values for date repeat in the table. This is because it is not about a given SalesID AND a LineItemID, 
-- but only about the SalesID!
Select * From dbo.SalesLineItems;

-- Let's put it back as it was!
DROP TABLE dbo.SalesLineItems;
Go

CREATE TABLE dbo.SalesLineItems(
	SalesId int,
	LineItemId int,
	ProductId int, 
	Qty int,
Primary Key(SalesId, LineItemId)  
); 
Go
INSERT INTO dbo.SalesLineItems 
  VALUES (1001, 1, 100, 2),(1001, 2, 101, 5),(1001, 3, 102, 3);
Go
 
-- Date should instead be added to the Sales table...
Drop Table dbo.Sales;
Go

CREATE TABLE dbo.Sales(
	SalesId int Primary Key,
	CustomerId int,
	SalesDate date 
);
Go

INSERT INTO dbo.Sales VALUES (1001, 1, '20170101');
Go

SELECT * FROM Customers;
SELECT * FROM Sales;
SELECT * FROM SalesLineItems;
SELECT * FROM Products;
Go

'*** All columns should depend on the Primary Key Column ***'
-- Normalization Rule 3: Normalization Rule 2 must be met, AND all fields in table must be dependent on primary key.
-----------------------------------------------------------------------------------------------------------------------

-- Here is an example of a table violating the third normal form...
Drop Table dbo.Sales;
Go
CREATE TABLE dbo.Sales(
	SalesID int Primary Key,
	CustomerId int,
	CustomerName varchar(50) NULL, -- This depends of the CustomerID not the SalesID
	CustomerPhone varchar(50) NULL, -- This depends of the CustomerID not the SalesID 
	SalesDate date, 
); 
Go

INSERT INTO dbo.Sales 
  VALUES (1001,1, 'Bob Smith', '555-1212', '20170101');
Go

SELECT * FROM Customers;
SELECT * FROM Sales;
Go
-- Let's put it back as it was!
DROP TABLE dbo.Sales;
Go

CREATE TABLE dbo.Sales(
	SalesId int Primary Key,
	CustomerId int,
	SalesDate date 
);
Go

INSERT INTO dbo.Sales VALUES (1001, 1, '20170101');
Go

'*** One-One, One-Many, or Many-Many Relationships ***'
-----------------------------------------------------------------------------------------------------------------------
-- One to One related tables are used for performance and security
CREATE TABLE dbo.Employees	(
	EmployeeId int Primary Key,
	FirstName varchar(50) ,
	LastName varchar(50) ,
	Phone varchar(50) ,
	HireDate datetime 
);
Go

CREATE TABLE dbo.EmployeeSensitiveData	(
	EmployeeId int Primary Key,
	SSNumber varchar(50) ,
	Salary money,
	Address varchar(100),
	City varchar(50),
	State char(2),
	Zip char(5)	
);
Go

INSERT INTO dbo.Employees 
  VALUES (1, 'Sue', 'Jones', '555-3333', '1/1/2000');
Go

INSERT INTO dbo.EmployeeSensitiveData 
  VALUES (1, '555-55-1234', '100000', '111 First', 'Bellevue', 'WA', '98223');
Go

SELECT * FROM Employees;
SELECT * FROM EmployeeSensitiveData;
Go

-- One to Many related tables are very common in a relational database
DROP TABLE dbo.Products;
Go

CREATE TABLE dbo.Products	(
	ProductId int Primary Key,
	ProductName varchar(50) ,
	Price varchar(50), 
	CategoryId int 
);
Go

CREATE TABLE dbo.Categories	(
	CategoryId  int Primary Key,
	CategoryName varchar(50),
	Description varchar(200) 
);
Go

INSERT INTO dbo.Categories 
  VALUES (1, 'As Seen On TV', 'Cheap and catchy products')
Go

INSERT INTO dbo.Products 
  VALUES (100, 'Chia Pet', '$9.99', 1),
		 (101, 'Pet Rock', '$9.99', 1),
		 (102, 'Spray-On Tan ', '$19.99', 1);
Go

SELECT * FROM Categories;
SELECT * FROM Products;
Go

-- Many to Many related tables need to be represented by a Junction (Bridge) Table
SELECT * FROM Sales;
SELECT * FROM SalesLineItems; -- Bridge Table
SELECT * FROM Products;

-- One to Many in a self-referencing table.
DROP TABLE dbo.Products;
Go