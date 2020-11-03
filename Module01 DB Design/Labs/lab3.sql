/* 
Title: Info 330 - Lab 3
Description: A lab in class
ChangeLog (When, Who, What)
    2020/01/09
    AKrinsky
    Created Scrip
*/
USE master;
GO
IF EXISTS(SELECT Name FROM Sysdatabases WHERE name = 'Lab3AKrinsky')
BEGIN
    DROP DATABASE Lab3AKrinsky; 
END

Create DATABASE Lab3AKrinsky;
go
USE Lab3AKrinsky;
go

Create Table Customers

(
CustID int PRIMARY KEY,
CustFirstName VARCHAR(100),
CustLastName VARCHAR(100),
CustPhone VARCHAR(100)
);

Select * From CustAddresses;

CREATE TABLE CustAddresses

(
    CustAddID int PRIMARY KEY,
    CustAddress VARCHAR(100),
    City VARCHAR(100), 
    CustState VARCHAR(100)
);


CREATE TABLE CustEmails 

(
    CustID int ,
    CustEmailAddressID INT PRIMARY KEY,
    CustEmailAdd VARCHAR(100), 

);


