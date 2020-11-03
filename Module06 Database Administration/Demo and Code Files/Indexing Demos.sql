--********* SQL Performace Tuning ************--
-- This file is used to demo the Indexing options found in 
-- SQL Server 
--**********************************************************--

CREATE DATABASE IndexDemo
Go
Use IndexDemo

'*** Heaps and Clusters ***'
-----------------------------------------------------------------------------------------------------------------------
-- Heaps --
-- By default, data is placed in pages in the first available space. 
-- This may start off as being sequential but the sequence is NOT maintained.
-- This type of orgainization is referered to as a HEAP.

-- When a table is first made the configuration of that table is a Heap. 
CREATE TABLE PhoneList
( Id int, Name varchar(50), Extension char(5))
Go
INSERT INTO PhoneList VALUES (1, 'Bob Smith', '11')
INSERT INTO PhoneList VALUES (2, 'Sue Jones', '12')
INSERT INTO PhoneList VALUES (3, 'Joe Harris', '13')
Go
SELECT * FROM Phonelist

-- While the table may appear to be sequentially organized, 
-- if you remove a row and then add one back you will see 
-- that SQL Server uses the first available slot in a page.
DELETE FROM PhoneList WHERE Id = 2
Go
INSERT INTO PhoneList VALUES (4, 'Tim Thomas', '#14')
Go
SELECT * FROM Phonelist

-- This is not a big deal since you can have it display the results sequentially 
-- using an order by statements. However, this causes the server to sort 
-- the results before returing them.
'Note:  Turn on the Execution Plan'
SELECT * FROM Phonelist
Go 
SELECT * FROM Phonelist  ORDER BY [Id]
Go
SELECT * FROM Phonelist  ORDER BY [Name]

-- Clustering --
-- If you would like to have SQL Server maintain the sequence on the page 
-- you can add a Clustered Index to the table and it will do so.
CREATE CLUSTERED INDEX ci_Id ON PhoneList(Id)
Go

-- Now the table will be physically sorted on that Indexed column. 
-- This will improve performance on some of your querys, 
-- but will not help all of them.
SELECT * FROM Phonelist
Go 
SELECT * FROM Phonelist  ORDER BY [Id]
Go
SELECT * FROM Phonelist  ORDER BY [Name]

-- If you believe that more users will search by Name then by Id,
--  you may want to place the Clustered index on the Name column instead.
-- However, the data pages can be sorted only one way at a time. 
-- So, you will have to drop the current Clustered Index before you can 
-- make a new one.
DROP INDEX PhoneList.ci_Id
Go
CREATE CLUSTERED INDEX ci_Name ON PhoneList(Name)
Go
-- See how the statements preform now. 
SELECT * FROM Phonelist
Go 
SELECT * FROM Phonelist  ORDER BY [Id]
Go
SELECT * FROM Phonelist  ORDER BY [Name]

-- While Indexes May increase Select performance they will often 
-- have a negitive impact on inserts and updates. DBAs often drop 
-- an index before doing a large import.

-- Run these tests to see the performance difference on Inserts with an Index
'NOTE: Run all of the following statements as a batch'
'Start Test'
-- Setup Code: Run these statement to get a clean test.
DROP TABLE PhoneList
CREATE TABLE PhoneList ( Id int, Name varchar(50), Extension char(5))
CREATE CLUSTERED INDEX ci_Name ON PhoneList(Name)
Go
BEGIN 
  DECLARE @TestTime datetime
  SELECT @TestTime = GetDate()
  INSERT INTO PhoneList
    SELECT ContactID, FirstName + ' ' + LastName, ContactId + 10
    FROM AdventureWorks.Person.Contact 
    Where ContactId > 4
  SELECT @TestTime = GetDate() -  @TestTime 
  SELECT DatePart(ms, @TestTime) as 'Time with Index'
END
Go
-- Now drop the table and load it again without the index
DROP TABLE PhoneList
CREATE TABLE PhoneList ( Id int, Name varchar(50), Extension char(5))
-- Not needed for this test case: CREATE CLUSTERED INDEX ci_Name ON PhoneList(Name)
Go
BEGIN
  DECLARE @TestTime datetime
  SELECT @TestTime = GetDate()
  SELECT @TestTime = GetDate()
  INSERT INTO PhoneList
    SELECT ContactID, FirstName + ' ' + LastName, ContactId + 10
    FROM AdventureWorks.Person.Contact 
    WHERE ContactId > 4
  SELECT @TestTime = GetDate() -  @TestTime 
  SELECT DatePart(ms, @TestTime) as 'Time without Index'
END
Go
' End Test'

-- NOTES: 
--    a) It is best to run this test several times and then take an average
--    b) With more data in the table the preformance gain is also more noticable.

'*** Measuring Index Performance ***'
-----------------------------------------------------------------------------------------------------------------------
-- Another way to measure of performance is by comparing how 
-- many pages of data SQL Server had to access before the results 
-- were returned. 
-- You can see this "page count" by turn on the STATISTICS IO option.
SET STATISTICS IO ON
Go
SELECT * FROM Phonelist 
-- The message will show numbers similar to this:
'(19968 row(s) affected)
Table 'PhoneList'. Scan count 1, logical reads 89, physical reads 0, ...'
-- The important number for us is the Logical reads since it indicates
-- the number of pages loaded from the Buffer cache.


-- To get a more accurate view of performance you can clear out the cache 
-- with these commands:
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE

-- With the cache cleared try running the statements and compare the number 
-- pages accessed. Why are they all the Same?
SET STATISTICS IO ON
Go
SELECT * FROM Phonelist
Go 
SELECT * FROM Phonelist  WHERE Id = 1
Go
SELECT * FROM Phonelist  WHERE  Extension = '518'
Go
SELECT * FROM Phonelist  WHERE NAME like 'Bob%'

-- This query last query could be much faster if all of the Names
-- were "CLUSTERED" together.
CREATE CLUSTERED  -- Drop Index Phonelist.Ci_name
INDEX ci_Name ON PhoneList(Name)
Go
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
Go
SELECT * FROM Phonelist  WHERE NAME like 'Bob%'
Go


--  Microsoft has included a new view for measuring the use of an index
--  You can use the view to determine which indexes are 
--  being used and how often. 
SELECT Object_Name(object_id) as [Object Name], * 
FROM sys.dm_db_index_usage_stats
ORDER BY Database_id Desc

SELECT  DB_Name([database_id]) as DB, Object_Name([Object_id]) as Object, * 
FROM sys.dm_db_index_usage_stats
Where [Object_id] = Object_id('PhoneList')  and [database_id] = DB_ID()
Go


SELECT * FROM Phonelist
Go 
SELECT * FROM Phonelist  WHERE Id = 1
Go
SELECT * FROM Phonelist  WHERE  Extension = '518'
Go
SELECT * FROM Phonelist  WHERE NAME like 'Bob%'



'*** Creating Indexes ***'
-----------------------------------------------------------------------------------------------------------------------
USE IndexDemo
GO
DROP TABLE PhoneList
CREATE TABLE PhoneList ( Id int, Name varchar(50), Extension char(5))

--  Creating a Clustered Index. Won't work if there is already 
-- a clustered index on the table. You can only have one!
CREATE CLUSTERED INDEX ci_Name 
ON PhoneList(name)

--  Creating a  Non Clustered Index.
CREATE nonCLUSTERED INDEX nci_Id
ON PhoneList(Id)

-- Same as...
CREATE INDEX nci_Id
ON PhoneList(Id)
 
-- Dropping Indexes.
DROP INDEX PhoneList.ci_Name

-- you can  also make an index by adding a PK or Unique constraint 
-- to a table
Alter Table Phonelist
Add  Constraint PK_Phonelist  Primary Key (Id)

--Note you cannot add a PK to a column that allows nulls
-- So, you would have to change it to null, like this...
Alter Table PhoneList 
Alter Column Id int not null

-- However, you cannot do this if the Id column is being 
-- referenced by an existing index. So, you must drop
-- the current index and then put it back on...
--1)
DROP INDEX PhoneList.nci_Id
go
--2)
Alter Table PhoneList Alter Column Id int not null
go
--3)
Alter Table Phonelist
Add  Constraint PK_Phonelist  Primary Key (Id)
go
-- 4)
CREATE nonCLUSTERED INDEX nci_Id
ON PhoneList(Id)
go

-- you can  also make an index by adding a Unique constraint 
-- to a table
Alter Table Phonelist
Add  Constraint u_Name  Unique (Name)

-- Check the indexes with the UI or this code
Sp_help Phonelist
-- or
Sp_helpIndex Phonelist
-- or
Select * from SysIndexes where Id = Object_id('PhoneList')
-- or
Select * from Sys.Indexes where [Object_Id] = Object_id('PhoneList')
Go

-- Microsoft has created several new views for investigating your indexes.
Select  * From sys.dm_db_index_usage_stats

'NOTE: Demo making an index in the UI'	

-- The most common way to create an index is like this
USE IndexDemo
GO
DROP TABLE PhoneList
CREATE TABLE PhoneList 
( 
Id int Primary Key Clustered,  -- Clustered is the default, and therefore optional
Name varchar(50) Unique NonClustered,  -- NonClustered is the default, and therefore optional
Extension char(5)
)

Select * from Sys.Indexes where [Object_Id] = Object_id('PhoneList')
Go

-- You  can also use this syntax if you want more control over the
-- name or to create a composit index
USE IndexDemo
GO
DROP TABLE PhoneList
CREATE TABLE PhoneList 
( 
Id int, 
Name varchar(50) Unique NonClustered,  
Extension char(5)

Constraint Pk_PhoneList Primary Key Clustered
(Id)

)


Select * from Sys.Indexes where [Object_Id] = Object_id('PhoneList')
Go

-- Creating Unique Indexes.
use Northwind 
Go

CREATE UNIQUE NONCLUSTERED INDEX U_CustID
	ON customers(CustomerID)
	
EXEC sp_helpindex Customers 

-- TEST the index (SHOW EXECUTION PLAN and note which index is used)
SELECT CustomerID, COUNT(CustomerID) AS '# of Duplicates'
FROM Northwind.dbo.Customers
GROUP BY CustomerID
HAVING COUNT(CustomerID)>1
ORDER BY CustomerID

DROP INDEX customers.U_CustID

-- Creating Composite Indexes.
CREATE UNIQUE NONCLUSTERED INDEX U_OrdID_ProdID
ON [Order Details] (OrderID, ProductID)

-- Obtaining Information on Existing Indexes.
EXEC sp_helpindex Customers
EXEC sp_helpindex [Order Details]

-- Which index would these Quieres use?
Select * from  [Order Details] -- Would use PK_Order_Details index
Select ProductId, OrderId from  [Order Details] -- Would use U__OrdId_ProdId index


-- Using the FILLFACTOR and PAD_INDEX Option.
Use Northwind
CREATE INDEX OrderID_ind
	ON Orders(OrderID)
	WITH PAD_INDEX, FILLFACTOR= 10 -- 10% full and 90% empty

-- You can see the indexes on a table with the sys.Indexes view
Select * from Sys.Indexes
Where Name = 'OrderID_ind' -- note the index Id

-- USing DBCC SHOWCONTIG Statement to show how full the pages are
DBCC SHOWCONTIG -- shows index 0 or 1 (the First index) for all of the tables in the DB
DBCC SHOWCONTIG (Territories) -- shows index 0 (heap table)
DBCC SHOWCONTIG (Orders) -- shows index 1 (Clustered table)
DBCC SHOWCONTIG (Orders, ShippedDate)
DBCC SHOWCONTIG (Orders, OrderID_ind)


-- REBUILDING a Index with Drop Existing
CREATE UNIQUE NONCLUSTERED INDEX OrderID_ind
ON [Orders] (OrderID)
WITH DROP_EXISTING, FILLFACTOR=70 
Go

DBCC SHOWCONTIG (Orders, OrderID_ind)

-- Getting information from SysIndexes (not the same as sys.Indexes)
SELECT id, indid, reserved, used, origfillfactor, name
FROM Northwind.dbo.sysindexes
WHERE name = 'PK_customers'

-- To view all indexes assigned to a database,
USE Northwind
GO
SELECT name, IndID, rows, rowcnt, keycnt from sysindexes
WHERE name NOT LIKE '%sys%'
ORDER BY keycnt

-- Note: The results  in IndID of the above query indicate the following
-- ID of index: 
'
	0 = Table is in a HEAP
	1 = Clustered index
	>1 = Nonclustered
	255 = Entry for tables that have text or image data
'

'The following query types, separately or in combination, 
benefit from indexes:'
--A CLUSTERED index is a good choice for: 
--Exact match queries,
-- if the WHERE clause returns a distinct value.
SELECT contactname, customerid
FROM customers
WHERE customerid = 'bergs'

-- Range queries.  
--Queries that search for a sequence of values: 
-- Clustered indexes are an excellent choice for this type of query because 
--the index pages are physically sorted in sequential order. 
-- Therefore, once the first record is located, it is likely that the other records 
--in the range will be adjacent or at least nearby. 
SELECT contactname, customerid 
FROM customers 
WHERE customerid BETWEEN 'b%' AND 'c%'


-- A CLUSTERED or NON CLUSTERED index is a good choice for Table joins.  
-- Queries that build a result set based on values in another table: 
SELECT c.contactname, c.customerid c, o.orderid 
FROM customers c INNER JOIN orders o 
	ON c.customerid = o.customerid

'Querys that do not benifit much from a Index'
-- Wildcard queries.  
-- Queries that use the LIKE clause for finding values: 
-- Wildcard queries starting with the percentage sign ( % ) are not aided by indexes, 
-- because index keys start with a specific character or numeric value. 
SELECT contactname, customerid
FROM customers
WHERE customerid LIKE '%bl%'

-- Getting ALL of the data will not improve with an index
SELECT * FROM Customers


'*** NonClustered Indexes and Covered Queries ***'
-----------------------------------------------------------------------------------------------------------------------
-- If you want increase the performance for a spacific type of select query, 
-- you can create a copy of the column or columns referenced in you query
-- into an additional set of data pages. These page will be seperate from the 
-- table but linked to in by either a Row Id or a "lookup" value from the 
-- original table. 

USE IndexDemo
GO
DROP TABLE PhoneList
CREATE TABLE PhoneList 
( 
	Id int, 
	Name varchar(50) Unique NonClustered,  
	Extension char(5)
		Constraint Pk_PhoneList Primary Key Clustered (Id)
)

CREATE NonCLUSTERED INDEX nci_Extension ON PhoneList(Extension)

-- When you select only that indexed column you can get all the data from 
-- the NonClustered Index instead of the table. If the NonClusterd index 
-- contains only some of the tables columns then there will be less pages
-- look through.
Go 
SELECT * FROM PhoneList -- Has to to get the data from the Clustered table 
Go
SELECT Extension FROM PhoneList -- Get data from the NonClustered Index

Go
-- When the table is Clustered the reference pointer from the NonClustered
-- index to the actual table will be a copy of the Clustered index values. 

SELECT Id, Extension FROM Phonelist -- The NonClustered index has the Id in it!

-- But, adding the Name column would have to use the the actual table 
-- since it is not in the NonClustered index
SELECT Name, Extension FROM Phonelist

-- When the table is in a Heap, SQL Server uses a Row ID (RID) as a pointer 
-- and so the NonClustered index will only contain the chosen column or columns.
Alter Table PhoneList
	Drop Constraint PK_PhoneList
Go
SELECT Extension FROM PhoneList
Go
SELECT Id, Extension FROM Phonelist


'The Include Option'
-----------------------------------------------------------------------------------------------------------------------
USE IndexDemo
GO
DROP TABLE PhoneList
CREATE TABLE PhoneList 
( 
	Id int, 
	Name varchar(50),    
	Extension nVarchar(25)
)

-- Fill the table with data
-- Drop Table #Temp1
Select  
	Identity(int, 1,1) as Id, 
	LastName as Name, 
	Phone as Extension
Into #Temp1
From AdventureWorks.Person.Contact

Insert into PhoneList (Id, Name, Extension) 
Select * from #Temp1

-- Check that the data is in there and how many pages are used
Set Statistics IO ON
SELECT Id, Extension FROM Phonelist

-- Create a Composite Index on the table
Create NonClustered index nci_IdAndExtension
On PhoneList( Extension, Id) -- Sorted on BOTH Extension AND Id

-- Use a covered query
SELECT Id, Extension 
	FROM Phonelist  
	Where Extension like '9%'

-- Is ALMOST the sames as this...
Create index nci_IdAndIncludeExtension
On PhoneList(Id) 
	Include ( Extension) -- This is NOT added to any NON Leaf index pages
	-- It also does not affect the actual Sort order of the pages

-- Note that the optimizer ignores the new index	
SELECT Id, Extension 
	FROM Phonelist
	Order by Extension desc
			
-- we can force it to use the new index but it wont make a difference	
SELECT Id, Extension 
	FROM Phonelist   With (Index (nci_IdAndIncludeExtension))
	Order by Extension desc	
	
-- Note that the optimizer ignores the new index	
SELECT Id, Extension 
	FROM Phonelist  
	Where Extension like '9%'
	
-- If you force it to use it you can see why...
SELECT Id, Extension 
	FROM Phonelist  With (Index (nci_IdAndIncludeExtension))
	Where Extension like '9%'
-- Since the Extension is not part of the non leaf levels you 
-- cannot do a seek operation on that column, and so it does a scan


'Index Fragmentation'
-----------------------------------------------------------------------------------------------------------------------
Select * 
Into TestTitles
from pubs..titles

DBCC ShowContig (TestTitles)

Select *
into TestPublishers
From Pubs..publishers

DBCC ShowContig (TestPublishers)

Select TestPublishers.Pub_Name ,  TestTitles.* 
From TestTitles Join TestPublishers
On TestTitles.pub_id = TestPublishers.Pub_id

Create index nciPub_id
On TestTitles(pub_id)

Create Clustered index nciPub_id
On TestPublishers(pub_id)


Sp_helpIndex TestTitles

DBCC ShowContig (TestTitles)
DBCC ShowContig (TestPublishers)


Use Northwind
DBCC ShowContig (Customers)

ALTER INDEX [PK_Customers] ON [dbo].[Customers] 
REBUILD
Go
DBCC ShowContig (Customers)
Go

