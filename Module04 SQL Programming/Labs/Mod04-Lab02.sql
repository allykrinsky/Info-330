--*************************************************************************--
-- Title: Module04-Lab02
-- Author: YourNameHere
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
/*
In this lab, you create views using Northwind database. 
You will work on your own for the first 10 minutes, then we will review the answers together in the last 10 minutes. 
Note: This lab can be done individually or with a group of up to 3 people. 
*/

--Step 1: Review Database Tables
--Run the following code in a SQL query editor and review the names of the tables you have to work with.

Select * From Northwind.Sys.Tables Where type = 'u' Order By Name;

-- Step 2: Create a Lab Database
-- Create new database for this lab called MyLabsDB_YourNameHere (using your own name, of course!) Modify and use the follow code to accomplish this:

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
   
-- Step 3: Create a Query
-- Answer the following questions by writing and executing SQL code.

-- Question 1: How can you create a view to show a list of customers names and their locations? Call the view vCustomersByLocation.

-- Question 2: How can you create a view to show a list of customers names, their locations, and the number of orders they have placed (hint: use the count() function)? Call the view vNumberOfCustomerOrdersByLocation.

-- Question 3: How can you create a view to show a list of customers names, their locations, and the number of orders they have placed (hint: use the count() function) on an given year (hint: use the year() function)? Call the view vNumberOfCustomerOrdersByLocationAndYears.
   
-- Step 4: Review Your Work
-- Now, you will review your work with your instructor.