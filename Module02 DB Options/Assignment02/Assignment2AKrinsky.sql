/***************************************************************************************
Title: Info 330 - Module 3: Writing SQL code
Desc: This file demonstrates typical additions to database tables
    - Constraints
    - Indexes
    - Views
    - Stored Producedures
Dev: AKrinsky
Change Log: 1/20/2020, AKrinsky, Creates Module2 Script
***************************************************************************************/
--create and drop datebase
DROP DATABASE IF EXISTS Assignment02DB_AllyKrinsky;
CREATE DATABASE Assignment02DB_AllyKrinsky;


USE Assignment02DB_AllyKrinsky;

--create prodcuts table
CREATE TABLE Products(
    ProductID int IDENTITY (1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    SubCategory VARCHAR(100) NOT NULL
);

--create produdcts VIEW
GO
CREATE VIEW dbo.vProducts
AS
    SELECT
        ProductID,
        ProductName,
        Category,
        SubCategory
    FROM dbo.Products;
GO

--create customers table
CREATE TABLE Customers(
    CustomerID int IDENTITY (1,1) PRIMARY KEY,
    CustomerFirstName VARCHAR(100) NOT NULL,
    CustomerLastName VARCHAR(100) NOT NULL
);

--create customers VIEW
GO
CREATE VIEW dbo.vCustomers
AS
    SELECT
        CustomerID,
        CustomerName = CustomerFirstName + ' ' + CustomerLastName
    FROM dbo.Customers;
GO

--create orders table
CREATE TABLE Orders(
    OrderID int IDENTITY (1,1) PRIMARY KEY,
    OrderDate DATETIME NOT NULL,
    OrderPrice VARCHAR(100) check (OrderPrice LIKE '$%.%') ,
    OrderQty int NOT NULL,
    CustomerID int FOREIGN KEY REFERENCES Customers(CustomerID) NOT NULL,
    ProductID int FOREIGN KEY REFERENCES Products(ProductID) NOT NULL
);

--create orders VIEW
GO
CREATE VIEW dbo.vOrders
AS
    SELECT
        OrderID,
        OrderDate,
        OrderPrice,
        OrderQty,
        CustomerID,
        ProductID
    FROM dbo.Orders;
GO
