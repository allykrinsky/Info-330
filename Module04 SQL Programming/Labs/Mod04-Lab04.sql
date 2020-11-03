--*************************************************************************--
-- Title: Mod04-Lab04 Lab Code
-- Author: RRoot
-- Desc: This file demonstrates how to create basic sprocs
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--
-- In this lab, you create stored procedures using Northwind database. 
-- You will work on your own for the first 10 minutes, then we will review the answers together in the last 10 minutes. 
-- Note: This lab can be done individually or with a group of up to 3 people. 
   
-- Step 1: Review Database Tables
-- Run the following code in a SQL query editor and review the names of the tables you have to work with.

Select * From Northwind.Sys.Tables Where type = 'u' Order By Name;
   
-- Step 2: Re-Use the Lab Database
-- You have already created a database for this lab called Mod04LabsYourNameHere (using your own name, of course!) Use the follow code to force your SQL code to use this database:
Use Mod04LabsYourNameHere;
   
-- Step 3: Create a Query
-- Answer the following questions by writing and executing SQL code.

-- Question 1: How can you create a stored procedure to show a list of customers names and their locations? Call the procedure pSelCustomersByLocation.

-- Question 2: How can you create a stored procedure to show a list of customers names, their locations, and the number of orders they have placed (hint: use the count() function)? Call the procedure pSelNumberOfCustomerOrdersByLocation.

-- Question 3: How can you create a stored procedure to show a list of customers names, their locations, and the number of orders they have placed (hint: use the count() function) on an given year (hint: use the year() function)? Call the procedure pSelNumberOfCustomerOrdersByLocationAndYears.

-- Step 4: Review Your Work
-- Now, you will review your work with your instructor.
