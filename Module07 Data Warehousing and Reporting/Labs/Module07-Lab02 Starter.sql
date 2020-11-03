--*************************************************************************--
-- Title: Module07-Lab03
-- Author: YourNameHere
-- Desc: This file demonstrates how to create an ETL process for a data warehouse database
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
-- Step 1: Create the Lab database
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

--1: Create the data warehouse table 
-- using the "Mod07 Labs BISolutionWorksheets.xlsx"

--2: Create the ETL Process Script
-- using the "Mod07 Labs BISolutionWorksheets.xlsx" 

--3: Test the Code:
---- Declare @Status int;
---- Exec @Status = pETLTableName;

