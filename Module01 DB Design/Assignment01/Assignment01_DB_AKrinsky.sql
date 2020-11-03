--*************************************************************************--
-- Title: Creating Databases and Normalization
-- Author: AKrinsky
-- Desc: This file details common aspects creating database with using
-- the rules of Normalization
-- Change Log: When,Who,What
-- 2020-01-11,AKrinsky,Created File, Completed Assignment
--**************************************************************************--

-- create (and drop) database
DROP DATABASE IF EXISTS dbo.ProjectLog;
Go

CREATE DATABASE AKrinksyNormalizationDB;
Go
USE AKrinksyNormalizationDB;
Go

-- create (and drop) Project Log table
DROP TABLE IF EXISTS dbo.ProjectLog;
Go

CREATE TABLE dbo.ProjectLog(
    ProjectLogID int primary key,
    ProjectID int,
    EmployeeID int,
	EntryDate varchar(50),
    EntryAmount float
);
Go

--insert values into table
INSERT INTO dbo.ProjectLog
    VALUES  (1, 1, 1, '2017-01-01 00:00:00.000', 6.00),
            (2, 1, 1, '2017-01-02 00:00:00.000', 4.00),
            (3, 2, 2, '2017-01-01 00:00:00.000', 5.50),
            (4, 2, 2, '2017-01-02 00:00:00.000', 6.00);
Go

--create (and drop) Projects table
DROP TABLE IF EXISTS dbo.Projects;
Go

CREATE TABLE dbo.Projects(
    ProjectID int primary key,
    ProjectName varchar(50),
    ProjectDescription varchar(50)
);
Go

--insert values into table
INSERT INTO dbo.Projects
    VALUES  (1, 'Accounting DB Upgrade', 'description 1'),
            (2, 'Accounting Application Upgrade', 'description 2');
Go

--create (and drop) Employees table
DROP TABLE IF EXISTS dbo.Employees;
Go

CREATE TABLE dbo.Employees(
    EmployeeID int primary key,
    EmployeeName varchar(50)
);
Go

--insert values into table
INSERT INTO dbo.Employees
    VALUES  (1, 'Bob Smith'),
            (2, 'Sue Jones');
Go

