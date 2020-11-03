--*************************************************************************--
-- Title: Module03-Lab01
-- Author: YourNameHere
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
/*
Lab 1: Using Joins and Unions - 30

In this lab, you create some advanced select statements using Northwind database. 
You will work on your own for the first 20 minutes, then we will review the answers together in the last 10 minutes. 

Note: This lab should be done individually. 
*/

--Step 1: Review Database Tables
--Run the following code in a SQL query editor and review the names of the tables you have to work with.

Select * From Northwind.Sys.Tables Where type = 'u' Order By Name;

-- Step 2: Create Queries
-- Answer the following questions by writing and executing SQL code.

-- Question 1: How can you show a list of category names? Order the result by the category!

-- Question 2: How can you show a list of product names and the price of each product? Order the result by the product!

-- Question 3: How can you show a list of category and product names, and the price of each product? Order the result by the category and product!

-- Question 4: How can you show a list of order Ids, category names, product names, and order quantities the results by the Order Ids, category, product, and quantity!

-- Question 5: How can you show a list of order ids, order date, category names, product names, and order quantities the results by the order id, order date, category, product, and quantity!

-- Step 3: Review Your Work
-- Now, you will review your work with your instructor.
-- NOTE: Unlike assignments, labs do not need to be turned in to Canvas!

