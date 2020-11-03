--*************************************************************************--
-- Title: Module08 
-- Author: RRoot
-- Desc: This file demonstrates creating and using Stored Procedures
 
--		Stored Procedure Basics
--      Getting Info About Stored Procedures
--		Stored Procedures For Transaction 
--      Stored Procedures For Abstraction
--      Stored Procedures With Error Handling
--      Stored Procedures With Return Codes
--      Creating a Stored Procedure Template 

-- Change Log: When,Who,What
-- 2017-08-01,RRoot,Created File
--**************************************************************************--

'*** Begin Setup Code ***'
-----------------------------------------------------------------------------------------------------------------------
-- Let's make a demo database for this module
Begin Try
	Use Master;
	If Exists(Select * from Sys.Databases where Name = 'Module08Demos')
	 Begin 
	  Alter Database [Module08Demos] set Single_user With Rollback Immediate;
	  Drop Database Module08Demos;
	 End
	Create Database Module08Demos;
End Try
Begin Catch
	Print Error_Message();
End Catch
go
Use Module08Demos;
go
-- Create some tables to STORE data
Create Table Customers
(CustomerID int Primary Key Identity(1,1)
,CustomerFirstName nvarchar(100)
,CustomerLastName nvarchar(100)
,CustomerEmail nvarchar(100) Unique
);
go

-- Add some data
Begin Transaction 
 Insert Into Customers (CustomerFirstName, CustomerLastName, CustomerEmail)
  Values ('Bob', 'Smith', 'BSmith@MyCo.com');
Commit Transaction

-- Create Basic Views
Create View vCustomers As
 Select CustomerID, CustomerFirstName, CustomerLastName, CustomerEmail From Customers;
go

-- Let's see what data we currently have
Select CustomerID, CustomerFirstName, CustomerLastName, CustomerEmail From vCustomers;
go

'*** End Setup Code ***'


'*** Stored Procedure Basics ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Like Views or Functions, Stored Procedures (Sprocs) are 
-- just a Named Set of SQL Statements.
Create --Drop
Procedure pAddValues
As
 Begin
  Select [Sum] = 1 + 2;
 End
go

-- However, unlike Views or Function, you do not use them in a Select statement.
-- Instead, you Execute them like this...
Execute pAddValues;
go
-- or this...
Exec pAddValues;
go
-- or even this..
pAddValues;
go

-- Stored Procedures can Print or Select data
-- Views and Function can only Select
Alter Proc pAddValues -- TIP: you can use either Proc or Procedure
As
 Begin
  Select [Sum] = 2 + 3; 
  Print  2 + 4;
 End
go
Exec pAddValues;
go

-- Like Functions, Stored Procedures can be use Input Parameters
Alter Procedure pAddValues
(@Value1 float, @Value2 float)
As
 Begin
  Select [Sum] = @Value1 + @Value2;
 End
go

-- You pass arguments to the parameter like this
Exec pAddValues @Value1 = 4, @Value2 = 5;
go
-- Or this...
Exec pAddValues 4,5;
go
-- BUT, NOT like this...
Exec pAddValues(4,5); -- Note that Functions can use Parentheses, but Sprocs cannot!
go

-- A Store Procedure's parameters can have default values
Alter Procedure pAddValues 
(@Value1 float = 0, @Value2 float = 0)
As
 Begin
  Select [Sum] = @Value1 + @Value2;
 End
go

-- Now you can execute it with argument values
Exec pAddValues @Value1 = 5, @Value2 = 3;
-- or without
Exec pAddValues;
-- in a number of ways 
Exec pAddValues @Value1 = 5;
Exec pAddValues @Value2 = 3;
Exec pAddValues @Value1 = 5, @Value2 = Default;

'*** Getting Info About Stored Procedures ***'
-----------------------------------------------------------------------------------------------------------------------
-- As with all objects in a database, 
-- Stored Procedures METADATA info can be viewed in the SysObjects View
Select * From SysObjects Where Name = 'pAddValues';

-- The SysComments View shows the text for the 
-- Stored Procedure cross-referenced by it's object Id 
Select * From sysComments Where id = Object_id('pAddValues');

-- Microsoft provides a system stored procedure that 
-- display's an overview of a store procedure 
Exec sp_Help 'pAddValues';
go

-- Microsoft also provides a system stored procedure that 
-- display's the text of a store procedure in it's Original format
Exec sp_HelpText 'AddValues';
go

'*** Stored Procedures For Transaction ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Store Procedures are most often used to PROCESS Table Data
-- You do this by creating transaction processing sprocs
Alter Proc pInsCustomers
 (@CustomerFirstName nvarchar(100)
 ,@CustomerLastName nvarchar(100)
 ,@CustomerEmail nvarchar(100)
 )
As
 Begin
  Begin Tran;
   Insert Into Customers (CustomerFirstName, CustomerLastName, CustomerEmail)
    Values (@CustomerFirstName, @CustomerLastName, @CustomerEmail);
  Commit Tran;
 End
go

-- Now we test that the Sproc works
Exec pInsCustomers 
  @CustomerFirstName = 'Sue'
 ,@CustomerLastName = 'Jones'
 ,@CustomerEmail = 'SJones@MyCo.com'
 ;
go

-- Each table in a database should have an insert, update, and delete sproc! 
-- (Select Sprocs are optional)
-- We already have an Insert Sproc, so we make an Update Sproc
Create Proc pUpdCustomers
 (@CustomerID int
 ,@CustomerFirstName nvarchar(100)
 ,@CustomerLastName nvarchar(100)
 ,@CustomerEmail nvarchar(100)
 )
As
 Begin
  Begin Tran
   Update Customers 
    Set CustomerFirstName = @CustomerFirstName
	   ,CustomerLastName = @CustomerLastName
	   ,CustomerEmail = @CustomerEmail
     Where CustomerID = @CustomerID;
  Commit Tran
 End
go

select * from vCustomers
Exec pUpdCustomers 
  @CustomerID = 2
 ,@CustomerFirstName = 'Susan'
 ,@CustomerLastName = 'Jones'
 ,@CustomerEmail = 'SJones@MyCo.com'
 ;
go

-- And then a Delete Sproc
Create Proc pDelCustomers
 (@CustomerID int 
 )
As
 Begin
  Begin Tran
   Delete 
    From Customers 
     Where CustomerID = @CustomerID;
  Commit Tran
 End
go


'*** Stored Procedures For Abstraction ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Like Views and Functions, Store Procedures allow us to 
-- work with table data "in the Abstact"

-- This is true both of our Transaction Sprocs, 
-- and any Reporting Sprocs we create
Create Proc pSelCustomers
As
 Begin
  Select 
    CustomerID
   ,CustomerFirstName
   ,CustomerLastName
   ,CustomerEmail 
   From Customers;
 End
go
Exec pSelCustomers;
go

-- And, like Functions, Stored Procedures can use Parameters to filter results
Alter Proc pSelCustomers
(@CustomerID int = 0)
As
 Begin
  Select 
    CustomerID
   ,CustomerFirstName
   ,CustomerLastName
   ,CustomerEmail 
   From Customers
    Where CustomerID = @CustomerID 
	OR @CustomerID = 0;
 End
go
Exec pSelCustomers;
Exec pSelCustomers @CustomerID = 1;
go

--{ IMPORTANT! }--
-- A Proven BEST PRACTICE is to use both Views and Stored Procedures to 
-- abstact access to your tables! 

-- DB Admins, will enforce this by restricting access to a table, 
-- while allowing access to its views and sprocs.
Deny 
Select, Insert, Update, Delete On Customers
  To Public;
go
Grant 
 Select On vCustomers
  To Public;
go
Grant 
 Exec On pSelCustomers
  To Public;
go
Grant 
 Exec On pInsCustomers
  To Public;
 
'*** Stored Procedures With Error Handling ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- When Sprocs process data you should include 
-- Error Handling code.
Alter Proc pInsCustomers
 (@CustomerFirstName nvarchar(100)
 ,@CustomerLastName nvarchar(100)
 ,@CustomerEmail nvarchar(100)
 )
As
 Begin
  Begin Try
   Begin Tran;
    Insert Into Customers (CustomerFirstName, CustomerLastName, CustomerEmail)
     Values (@CustomerFirstName, @CustomerLastName, @CustomerEmail);
   Commit Tran;
  End Try
  Begin Catch
   Print 'There was a error. Common issues include: Duplicate Email Addresses!' 
   Print Error_Number();  
   Print Error_Message();
   Rollback Tran;
  End Catch
 End
go

-- Now we test that the Sproc works (Should cause an Error!)
Exec pInsCustomers 
  @CustomerFirstName = 'Tim'
 ,@CustomerLastName = 'Thomas'
 ,@CustomerEmail = 'TThomas@MyCo.com';
go


'*** Stored Procedures With Return Codes ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- In addition to the Error Messaging, you should 
-- include "Return Code".
-- Return codes indicates the Status of your Sproc 
-- and are used by developers to troubleshoot and track the 
-- branches of logic begin processed.
Alter Proc pInsCustomers
 (@CustomerFirstName nvarchar(100)
 ,@CustomerLastName nvarchar(100)
 ,@CustomerEmail nvarchar(100)
 )
As
 Begin
  Declare @RC int = 0; -- Return Codes are Always an Integer!
  Begin Try
   Begin Tran;
    Insert Into Customers (CustomerFirstName, CustomerLastName, CustomerEmail)
     Values (@CustomerFirstName, @CustomerLastName, @CustomerEmail);
   Commit Tran;
   Set @RC = +1; -- You can use any number you wish to, but I recommend using a positive one 
  End Try
  Begin Catch
   Print Error_Number();  
   Print Error_Message();
   Set @RC = -1; -- Except when thing go wrong! For that I use a negitive number
   Rollback Tran;
  End Catch
  Return @RC; -- The Return Statement is always the last one in the Sproc!
 End
go

-- Now we test that the Sproc works by capturing the Return Code
Declare @Status int;
Exec @Status = pInsCustomers 
                @CustomerFirstName = 'Tim'
               ,@CustomerLastName = 'Thomas'
               ,@CustomerEmail = 'TThomasz@MyCo.com';
Select [The Return Code Was] = @Status; 
go

Declare @Status int;
Exec @Status = pInsCustomers 
                @CustomerFirstName = 'Sue'
               ,@CustomerLastName = 'Jones'
               ,@CustomerEmail = 'SJones@MyCo.com';
Select [The Return Code Was] = @Status; 
go


-- An Application Developer will often use Return Codes to 
-- Create thier own Custom Error Messages; 
Declare @Status int;
Exec @Status = pInsCustomers 
                @CustomerFirstName = 'Sue'
               ,@CustomerLastName = 'Jones'
               ,@CustomerEmail = 'SJones@MyCo.com';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
go

-- By capturing the new ID value created during an Insert
-- A developer can test all the transactions sprocs like this...
Declare @Status int;
Select * From vCustomers;
-- Test Insert
Exec @Status = pInsCustomers 
                @CustomerFirstName = 'Jim'
               ,@CustomerLastName = 'James'
               ,@CustomerEmail = 'JJames@MyCo.com';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCustomers Where CustomerID = @@IDENTITY;
go

-- Test Update
Declare @Status int;
Exec @Status = pUpdCustomers
                @CustomerID = @@IDENTITY
               ,@CustomerFirstName = 'James'
               ,@CustomerLastName = 'James'
               ,@CustomerEmail = 'JJames@MyCo.com';
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Common Issues: Duplicate Data or Foriegn Key Violation'
  End as [Status]; -- Will be Null unless we add a Return Code to this Sproc!
Select * From vCustomers Where CustomerID = @@IDENTITY;
go

-- Test Delete
Declare @Status int;
Exec @Status = pDelCustomers
                @CustomerID = @@IDENTITY
Select Case @Status
  When +1 Then 'Delete was successful!'
  When -1 Then 'Delete failed! Common Issues: Foriegn Key Violation'
  End as [Status]; -- Will be Null unless we add a Return Code to this Sproc!
Select * From vCustomers Where CustomerID = @@IDENTITY;
go



'*** Creating a Stored Procedure Template ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Since Tranaction stored procedure code becomes so complex
-- it is important to be organized! 
-- You shold create a template like this on and use it to 
-- create all the sproc in your database.
Create Procedure <pTrnTableName>
(<@P1 int = 0>)
/* Author: <YourNameHere>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<Your Name Here>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
/* Testing Code:
 Declare @Status int;
 Exec @Status = pTrnTableName @P1 = 1;
 Print @Status;
*/
