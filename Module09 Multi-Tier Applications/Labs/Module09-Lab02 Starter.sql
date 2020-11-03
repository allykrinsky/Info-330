--*************************************************************************--
-- Title: Mod09 Labs Database 
-- Author: YourNameHere
-- Desc: This file creates reporting structures
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
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

Create Table Products
(ProductId int Identity, ProductName nvarchar(100) Unique, ProductPrice money);
go
 
Create Procedure pInsProducts
(@ProductID int Output 
,@ProductName nVarchar(100)
,@ProductPrice money
)
-- Author: RRoot
-- Desc: Processes Product Data Inserts 
-- Change Log: When,Who,What
-- 2017-11-21,RRoot,Created Sproc.
AS
 Begin
  Set NoCount On; -- For Some Reason, PyPyODBC Needs this to work correctly!!!
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
   -- Transaction Code --
    Insert Into Products
     (ProductName, ProductPrice)
     Values 
     (@ProductName, @ProductPrice);
   Set @ProductID = @@IDENTITY;
   Commit Transaction
   Set @RC = +100
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -100
  End Catch
  Return @RC;
 End
go

Create View vProducts 
As
 Select ProductID, ProductName, ProductPrice From Products;
go

Select ProductID, ProductName, ProductPrice From vProducts;
Declare @Status int = 0
Exec @Status = pInsProducts
     @ProductID = null
    ,@ProductName = 'prodA'
	,@ProductPrice = '$9.99'
Select @Status;
Select ProductID, ProductName, Format(ProductPrice, 'c', 'en-US') From vProducts;
