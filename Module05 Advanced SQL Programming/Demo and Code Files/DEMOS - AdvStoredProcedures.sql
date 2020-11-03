--*************************************************************************--
-- Title: Module09 
-- Author: RRoot
-- Desc: This file demonstrates creating and using Stored Procedures

--	Variables
--	Stored Procedure Input Parameters
--  Debugging Stored Procedures
--  Stored Procedures With Return Codes
--	Stored Procedure Output Parameters
--  Using Output Parameters 
--	Stored Procedures for Validation

-- Change Log: When,Who,What
-- 2017-08-01,RRoot,Created File
--**************************************************************************--

'*** Begin Setup Code ***'
-----------------------------------------------------------------------------------------------------------------------
-- Let's make a demo database for this module
Begin Try
	Use Master;
	If Exists(Select * from Sys.Databases where Name = 'Module09Demos')
	 Begin 
	  Alter Database [Module09Demos] set Single_user With Rollback Immediate;
	  Drop Database Module09Demos;
	 End
	Create Database Module09Demos;
End Try
Begin Catch
	Print Error_Message();
End Catch
go
Use Module09Demos;
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
go

-- Create Basic Views
Create View vCustomers As
 Select CustomerID, CustomerFirstName, CustomerLastName, CustomerEmail From Customers;
go

-- Let's see what data we currently have
Select CustomerID, CustomerFirstName, CustomerLastName, CustomerEmail From vCustomers;
go

-- Now let's add some transactional Data
Create Table Checking
(AcctNo int Primary Key identity(100,200), CustomerID int Unique, Balance Money);
go

Create Table Savings
(AcctNo int Primary Key identity(200,200), CustomerID int Unique, Balance Money);
go

-- Add some data
Begin Transaction 
 Insert Into Checking (CustomerID, Balance) Values (1, $50);
 Insert Into Savings (CustomerID, Balance) Values (1, $50);
Commit Transaction
go

-- Create the Basic Views
Create View vChecking As
 Select AcctNo, CustomerID, Balance From Checking
go
Create View vSavings As
 Select AcctNo, CustomerID, Balance From Savings
go

-- Create a Report Views
Create View vAccounts As
 Select AcctNo, CustomerID, Balance From vChecking
  Union 
 Select AcctNo, CustomerID, Balance From vSavings;
go

-- Let's see what data we currently have
Select A.*, C.*
 From vAccounts as A 
  Join vCustomers as C 
   On A.CustomerID = C.CustomerID;
go
'*** End Setup Code ***'


'*** Variables ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Variables are used to temporally hold values so that they can be used 
-- in later lines of code.
Declare @N1 int = 10, @N2 int = 3;
Select [Sum] = @N1 + @N2;
go

-- Variable will only last for the life of the SQL Bacth.
-- When and Where a variable's data can be used is called its "Scope"
/*

Declare @N1 int = 10, @N2 int = 3;
go -- THIS Separates the code into two batchs
Select [Sum] = @N1 + @N2; --< So, this will NOT Work!

*/
go

-- You can pass values from one variable to another.
Declare @N1 int = 10, @N2 int = 3;
Declare @N3 int = @N1; -- The VALUE of N1 in passed to @N3
Select [Sum] = @N1 + @N2 + @N3;
go

'*** Stored Procedure Input Parameters ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Parameters are just variables, used as "Parameters". 
-- The term describes the task it is performing.
Create Procedure pAddValues
(@Value1 int = 0, @Value2 int = 0)
As
 Begin -- All code in a stored procedure is ONE BATCH
  Select [Sum] = @Value1 + @Value2; -- The Scope of a Parameter is the Sproc's Batch
  -- go -- You cannot use GO inside of a Sproc
 End
go

-- When you execute or "Call" a stored procedues with Parameters 
-- You must pass in "Arguments" (Unless the parameter has a "Default Value")
Exec pAddValues @Value1 = 10, @Value2 = 3;
go

-- You will often see developers create variable to hold the Argument Values
Declare @N1 int = 10, @N2 int = 3;
Exec pAddValues @Value1 = @N1, @Value2 = @N2;
go

-- And, since the code that calls the stored procedure is a separate batch
-- then the code inside of the stored procedure, your argument variables and 
-- a Sproc's parameters can have the same name!
Declare @Value1 int = 10, @Value2 int = 3;
Exec pAddValues @Value1 = @Value1, @Value2 = @Value2; -- This looks odd, but works!
go

'*** Debugging Stored Procedures ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- In the newer versions of SQL and Sql Server Management Studio (SSMS),
-- you can use the Built in Debugger to "Walk through your code.
-- 1) Connect SQL as an Administrator
-- 2) Set a Break point
-- 3) Highlight the code you want to debug 
-- 3a) Optionally, Copy the code you want to run into another code window 
Declare @N1 int = 10, @N2 int = 3;
Exec pAddValues @Value1 = @N1, @Value2 = @N2;
go

'*** Stored Procedures With Return Codes ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- You can get data from a Sproc using Select, Print, or a Return Code
Alter Procedure pAddValues
(@Value1 int = 0, @Value2 int = 0)
As
 Begin
  Select [Sum] = @Value1 + @Value2; -- Selects a Value
  Print @Value1 + @Value2; -- Prints a Value
  Return @Value1 + @Value2; -- Returns a Value
 End
go

-- To get a Return Code's Value you must create a variable to hold its data
Declare @RC int; -- Return Code Values are always integers
Declare @Value1 int = 10, @Value2 int = 3;
Exec @RC = pAddValues @Value1 = @Value1, @Value2 = @Value2; 
-- Note that the return code is used before procedures name 
Select [ReturnCode] = @RC;
-- Note the return code's value us not displayed automatically 
go

-- Return codes do not work well for returning most data, due to its integer data type
Create Procedure pDivideValues
(@Value1 Float = 0, @Value2 Float = 0)
As
 Begin
  Select [Quotient] = @Value1 / @Value2; -- Selects a Value
  Print @Value1 / @Value2; -- Prints a Value
  Return @Value1 / @Value2; -- Returns a Value
 End
go

-- To get a Return Code's Value you must create a variable to hold its data
Declare @RC int; -- Return Code Values are always integers
Declare @Value1 FLOAT = 10, @Value2 FLOAT = 3;
Exec @RC = pDivideValues @Value1 = @Value1, @Value2 = @Value2; 
-- Note that the return code is used before procedures name 
Select [ReturnCode] = @RC; -- We have lost the precision of the value
go

-- Return codes should be used to return the Status of a Stored Procedure 
Alter Procedure pDivideValues
(@Value1 float = 0, @Value2 float = 0)
As
 Begin
   Begin Try
   Select [Quotient] = @Value1 / @Value2; -- Selects a Value
   Print @Value1 / @Value2; -- Prints a Value
   Return +1; -- Returns a Status Code (Use Positive numbers for a good status)
  End Try
  Begin Catch
   Return -1 -- Returns a Status Code (Use Negitive numbers for a bad status)
  End Catch
 End
go

-- Now, the RC will tell us the status of the code inside the sproc.
-- Rather, is was a positive outcome...
Declare @RC int, @Value1 float = 10, @Value2 float = 3;
Exec @RC = pDivideValues @Value1 = @Value1, @Value2 = @Value2; 
Select [ReturnCode] = @RC;
go

-- Or rather, is was a negitive outcome
Declare @RC int, @Value1 float = 10, @Value2 float = 0;
Exec @RC = pDivideValues @Value1 = @Value1, @Value2 = @Value2; 
Select [ReturnCode] = @RC;
go

-- Having more then one Exit point in a Stored Procedure has 
-- creates opportunities for errors (BUGS)
-- So, professional developers only create one return point
-- by using variables in a Sproc like this...
Alter Procedure pDivideValues
(@Value1 float = 0, @Value2 float = 0)
As
 Begin
   Declare @RC int = 0 -- This will be used to hold the Return Code's value
   Begin Try
   Select [Quotient] = @Value1 / @Value2; -- Selects a Value
   Print @Value1 / @Value2; -- Prints a Value
   Set @RC = +1; -- The Return Status is set here...
  End Try
  Begin Catch
   Set @RC = -1 -- and here.
  End Catch
  Return @RC -- Then returned here!
 End
go

-- The Sproc runs the same as it did, but not it has more professional code
Declare @RC int, @Value1 float = 10, @Value2 float = 0;
Exec @RC = pDivideValues @Value1 = @Value1, @Value2 = @Value2; 
Select [ReturnCode] = @RC;
go

'*** Stored Procedure Output Parameters ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Instead of using Select, Print, or a Return Code to display values 
-- you can "Return" values from a Sproc using Output Parameters.
Create Procedure pAlgebraValues
( @Value1 float = 0 -- Input
, @Value2 float = 0 -- Input
, @Sum float = 0 Output
, @Difference float = 0 Output
, @Product float = 0 Output
, @Quotient float = 0 Output
)As
 Begin
  Declare @RC int = 0 -- This will be used to hold the Return Code's value
  Begin Try
   Set @Sum = @Value1 + @Value2;
   Set @Difference = @Value1 - @Value2;
   Set @Product = @Value1 * @Value2;
   Set @Quotient = @Value1 / @Value2;
   Set @RC = +1; -- The Return Status is set here...
  End Try
  Begin Catch
   Set @RC = -1 -- and here.
  End Catch
  Return @RC -- Then returned here!
 End
go

-- Now you declare more variables to hold the Output Results
Declare @RC int -- Variable
      , @Value1 float = 10 -- Variable
	  , @Value2 float = 3 -- Variable
	  , @S float -- Variable
	  , @D float -- Variable
	  , @P float -- Variable
	  , @Q float -- Variable
Exec @RC = pAlgebraValues @Value1 = @Value1 -- Parameter <- Variable
                        , @Value2 = @Value2 -- Parameter <- Variable
					    , @Sum = @S Output -- Parameter -> Variable
                        , @Difference = @D Output -- Parameter -> Variable
					    , @Product = @P Output -- Parameter -> Variable
					    , @Quotient = @Q Output;  -- Parameter -> Variable
Select [ReturnCode] = @RC -- Alias <- Variable
     , [Sum] = @S -- Alias <- Variable
	 , [Difference] = @D -- Alias <- Variable
	 , [Product] = @P -- Alias <- Variable 
	 , [Quotient] = @Q; -- Alias <- Variable
go

'*** Using Output Parameters ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Output Parameter are often used to capture facts to be used later
Alter Procedure pSelAccountsByCustomer
( @CustomerId int
, @CheckingAcctNo int = 0 Output
, @SavingsAcctNo int = 0 Output
)As
 Begin
  Declare @RC int = 0;
  Begin Try
   Select @CheckingAcctNo = AcctNo From vChecking Where CustomerID = @CustomerId;
   Select @SavingsAcctNo = AcctNo From vSavings Where CustomerID = @CustomerId;
   Select * From vAccounts Where CustomerID = @CustomerId;
   Set @RC = +1;
  End Try
  Begin Catch
   Set @RC = -1;
  End Catch
  Return @RC; 
 End
go

-- Now we execute the Sproc to collect data about a customer's accounts.
Declare @RC int -- Variable
      , @CustomerID int -- Variable
	  , @CheckingAcctNo int -- Variable
	  , @SavingsAcctNo int; -- Variable
Set @CustomerID = 1;
Exec @RC = pSelAccountsByCustomer 
            @CustomerID = @CustomerID -- Parameter <- Variable 
		  , @CheckingAcctNo = @CheckingAcctNo Output -- Parameter -> Variable 
		  , @SavingsAcctNo = @SavingsAcctNo Output;  -- Parameter -> Variable  
Select [ReturnCode] = @RC -- Alias <- Variable  
       , CustomerID = @CustomerID -- Alias <- Variable 
	   , CheckingAcctNo = @CheckingAcctNo -- Alias <- Variable  
	   , SavingsAcctNo = @SavingsAcctNo; -- Alias <- Variable 
Select * From Checking Where AcctNo = @CheckingAcctNo;
go



'*** Stored Procedures for Validation ***'
-----------------------------------------------------------------------------------------------------------------------
go
-- Often developers will create procedures used for data validation
-- Let's looks an example that validates if an account's balance will be  
-- about Zero if we add or subtract an amount.
Create Procedure pValWillBalanceBeAboveOrEqualToZero
( @AcctNo int 
, @NewAmount money
, @Balance money output
)As
 Begin  
  Declare @RC int = 0;
  Begin Try
   Select @Balance = Balance From vAccounts Where AcctNo = @AcctNo;
   If (@Balance + @NewAmount >= 0 ) Set @RC = +1
   Else Raiserror('Below Zero Error', 19, 1)
  End Try
  Begin Catch
   Set @RC = -1;
  End Catch
  Return @RC 
 End
go

-- We need to test our validation Sproc before we try using it. So...
Select * from Checking;
go
Declare @RC int = 0, @CurrentBalance money
Exec @RC = pValWillBalanceBeAboveOrEqualToZero 100, -40, @CurrentBalance output
Select IIF(@RC = +1,  'T', 'F'), @CurrentBalance
go 
Declare @RC int = 0, @CurrentBalance money
Exec @RC = pValWillBalanceBeAboveOrEqualToZero 100, -400, @CurrentBalance output
Select IIF(@RC = +1,  'T', 'F'), @CurrentBalance
go

-- Now we use our validation Sproc within a transaction Sproc
Create Procedure pUpdCheckingBalance
( @AcctNo int 
, @Amount money -- Can be a positive or negitive value
, @CurrentBalance money Output
)As
 Begin
  Declare @RC int = 0
  Begin Try
   -- Validate that this amount can be added or deducted from Acct.
   Exec @RC = pValWillBalanceBeAboveOrEqualToZero
                @AcctNo = @AcctNo
              , @NewAmount = @Amount
			  , @Balance = @CurrentBalance output;
   If (@RC = +1) -- If if can then...
    Begin
     Begin Tran
	  Update Checking 
	   Set Balance = @CurrentBalance + @Amount
	    Where AcctNo = @AcctNo;  
	 Commit Tran
	End
   Else -- If if cannot then...
	Begin 
	 Print 'Balance Exceeded! A $10 charge will be deducted from this account';
     Begin Tran
	  Update Checking 
	   Set Balance = @CurrentBalance - 10
	    Where AcctNo = @AcctNo;  
	 Commit Tran
	End 
   Set @RC = +1; 
  End Try
  Begin Catch
   Set @RC = -1
  End Catch
  -- In any case, provide the current balance of the account
  Select @CurrentBalance = Balance From vAccounts Where AcctNo = @AcctNo;
  Return @RC 
 End
go

-- Now when we perform an update transaction the validation Sproc will 
-- be used automatically.
Declare @RC int = 0, @Amt money = -40, @Bal money;
Exec @RC = pUpdCheckingBalance @AcctNo = 100, @Amount = @Amt, @CurrentBalance = @Bal Output;
Exec pSelAccountsByCustomer @CustomerID = 1;
Select Balance = @Bal;
go