--*************************************************************************--
-- Title: Basic Transaction Demos
-- Author: RRoot
-- Desc: This file demonstrates the basic transaction statements
--       1) Insert
--       2) Update
--       3) Delete
--       4) Transactions
--       5) Try-Catch

-- Change Log: When,Who,What
-- 2017-10-01,RRoot,Created File
--**************************************************************************--

'*** Set Up Code ***'
-----------------------------------------------------------------------------------------------------------------------
Use Master;
go
If Exists(Select Name from SysDatabases Where Name = 'BasicTransactionsRRoot')
 Begin 
  Alter Database BasicTransactionsRRoot set Single_user With Rollback Immediate;
  Drop Database BasicTransactionsRRoot;
 End
go
Create Database BasicTransactionsRRoot;
go
use BasicTransactionsRRoot;
go
CREATE TABLE dbo.Contacts (
	ContactId int Not Null Constraint pkContacts Primary Key IDENTITY,
	FirstName varchar(100) Not Null,
	LastName varchar(100) Not Null ,
	EmailAddress varchar(100) Not Null  Constraint uqContacts Unique, 
);
go

CREATE TABLE dbo.ContactLog (
	ContactLogId int Constraint pkContactLog Primary Key IDENTITY,
	ContactDate datetime Not Null ,
    ContactID int Not Null ,
	Message varchar(8000) Not Null  
);
go

'*** Insert Statements ***'
-----------------------------------------------------------------------------------------------------------------------
-- Best
Insert Into dbo.Contacts
 (FirstName,LastName, EmailAddress)
Values 
 ('Bob', 'Smith', 'BSmith@MyCo.Com');
go
Select * from Contacts;

-- See what the new ID is
Select @@IDENTITY 

-- Works, but not as good
Insert Into dbo.Contacts
-- (FirstName,LastName, EmailAddress)
Values 
 ('Sue', 'Jones', 'SJones@MyCo.Com');
go
Select * from Contacts;

-- Will not work
Insert Into dbo.Contacts
(ContactID, FirstName,LastName, EmailAddress)
Values 
 (3, 'Tim', 'Thomas', 'TThomas@MyCo.Com');
go

Insert Into dbo.Contacts
( LastName, EmailAddress)
Values 
 ('Thomas', 'TThomas@MyCo.Com');
go

Insert Into dbo.Contacts
(FirstName,LastName, EmailAddress)
Values 
 ('Tim', 'Thomas', 'SJONES@MyCo.Com'); -- ERROR!
go

-- Adding multiple rows at once
Insert Into dbo.Contacts
(FirstName,LastName, EmailAddress)
Values 
 ('Tim', 'Thomas', 'TThomas@MyCo.Com'),
 ('Pat', 'Pruit', 'PPruit@MyCo.Com')
 ;
go
Select * from Contacts; -- NOTE the GAP in the numbering!
go


-- Adding rows from another table
Select au_fname, au_lname from Pubs.dbo.Authors;
go

-- Creating the data we need by transforming it!
Select
  au_fname
, au_lname, SUBSTRING(au_fname,1,1) + au_lname + '@MyCo.com' as Email 
From Pubs.dbo.Authors;
go

-- Trying to insert data (will cause duplicate data error for 'ARinger@MyCo.Com')!
Insert Into Contacts
(FirstName,LastName, EmailAddress)
Select 
  au_fname
, au_lname
, SUBSTRING(au_fname,1,1) + au_lname + '@MyCo.com' as Email 
From Pubs.dbo.Authors;
go

-- Was data was added ???
Select * from Contacts;
go

-- Filter out the 'bad' data
Insert Into Contacts
(FirstName,LastName, EmailAddress)
Select 
  au_fname
, au_lname
, SUBSTRING(au_fname,1,1) + au_lname + '@MyCo.com' as Email 
From Pubs.dbo.Authors
Where au_lname != 'Ringer'
go
-- Was data was added ???
Select * from Contacts; -- NOTE the GAP in the numbering!
go

-- Inserting Dates and Times
Insert Into dbo.ContactLog 
(ContactDate,ContactID,[Message]) 
Values 
('20170101 03:01:05', 1, 'Hey, Bob! How are things?'),
(GetDate(), 2, 'Hey, Sue! How are things?')
go
Select * from dbo.ContactLog;
go
 
-- Using Explict Transaction Statements
Begin Transaction
 Insert Into dbo.ContactLog 
 (ContactDate,ContactID,[Message]) 
 Values 
 (GetDate(), 3, 'Hey, Tim! How are things?')
Commit Transaction
go
Select * from dbo.ContactLog;
go
 
-- Using Rollback Transaction Statements
Begin Tran --saction
 Insert Into dbo.ContactLog 
 (ContactDate,ContactID,[Message]) 
 Values 
 (GetDate(), 3, 'Hey, Tim! How are things?')
Rollback Tran
go
Select * from dbo.ContactLog;
go

-- Seeing if there is an open Transaction
Select @@TRANCOUNT;
go

-- Using Try-Catch blocks for Error handling
Begin Try
  Begin Tran
	Insert Into dbo.ContactLog 
	(ContactDate,ContactID,[Message]) 
	Values 
	(GetDate(), 4, 'Hey, Pat! How are things?')
  Commit Tran
End Try
Begin Catch
 Rollback Transaction
End Catch
go
Select @@TRANCOUNT;
go
Select * from dbo.ContactLog;
go

-- Handling Error Messages
Begin Try
  Begin Tran
	Insert Into dbo.Contacts
	(FirstName,LastName, EmailAddress)
	Values 
	 ('Pat', 'Pruit', 'PPruit@MyCo.Com')
	 ;
  Commit Tran
End Try
Begin Catch
 Rollback Transaction
 Print 'There was an Error! Please check the data you are entering!'
 Print Error_Message()
End Catch
go

Select @@TRANCOUNT;
go
Select * from dbo.Contacts;
go


'*** Update Statements ***'
-----------------------------------------------------------------------------------------------------------------------
-- A Simple update
Update Contacts 
Set LastName = 'Smith'
Where ContactId = 2;
go

Select * from dbo.Contacts;
go

-- Updating multiple columns
Update Contacts 
Set LastName = 'Smith'
   ,EmailAddress = 'SSmith@MyCo.com'
Where ContactId = 2;
Select @@ROWCOUNT;
go

Select * from dbo.Contacts;
go


-- Updating multiple Rows!
Begin Tran;
Update Contacts 
Set LastName = 'Smith';
-- Where ContactId = 2;
Select @@ROWCOUNT;
Rollback Tran;
go

Select * from dbo.Contacts;
go


-- Handling Error Messages
Begin Try
  Begin Tran
    Update Contacts 
	  Set LastName = 'Smith';
    -- Where ContactId = 2;
    If(@@ROWCOUNT > 1) RaisError('Do not change more than one row!', 15,1);
  Commit Tran
End Try
Begin Catch
 Rollback Transaction
 Print Error_Message()
End Catch
go

Select @@TRANCOUNT
Select * from dbo.Contacts;
go


'*** Delete Statements ***'
-----------------------------------------------------------------------------------------------------------------------
-- Simple Delete
Delete 
 From dbo.Contacts
  Where ContactId = 5;
go

-- Delete with transasctions and error handling
Begin Try
  Begin Tran
    Delete 
	 From dbo.Contacts
    If(@@ROWCOUNT > 1) RaisError('Do not change more than one row!', 15,1);
  Commit Tran
End Try
Begin Catch
 Rollback Transaction
 Print Error_Message()
End Catch
go

Select * from dbo.Contacts;
go

-- Using multiple transaction statements
Begin Try
  Begin Tran

    Delete 
	 From dbo.ContactLog  
	  Where ContactID in (Select ContactID From Contacts 
						    Where FirstName = 'Bob' and LastName = 'Smith');
    Delete 
	 From dbo.Contacts 
	  Where ContactID = 1;

  Commit Tran
End Try
Begin Catch
 Rollback Transaction
 Print Error_Message()
End Catch
go

Select * from dbo.Contacts;
Select * from dbo.ContactLog;
go

-- A Delete with a Join
Begin Try
  Begin Tran

    Delete CL -- Tell SQL which table to delete from since we now have 2
	From dbo.ContactLog as CL
	 Join Contacts as C
	  On CL.ContactID = C.ContactID 
     Where C.FirstName = 'Bob' and C.LastName = 'Smith';

    Delete From dbo.Contacts 
	  Where ContactID = 1;

  Commit Tran
End Try
Begin Catch
 Rollback Transaction
 Print Error_Message()
End Catch
go


