--*************************************************************************--
-- Title: Mod05-Lab04 Lab Code
-- Author: RRoot
-- Desc: This file demonstrates how to import data
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--
/*
In this lab, you import data to a new table using an Insert command and some data generated for you by the website, https://www.mockaroo.com/.
You will work on your own for the first 10 minutes, then we will review the answers together in the last 10 minutes. 
Note: This lab should be done individually or in groups of three or less. 
*/

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


-- Step 1: Create a new Table
Create Table Contacts 
( ContactID int identity Primary Key
, ContactFirstName nvarchar(100)
, ContactLastName nvarchar(100)
, ContactEmail nvarchar(100)
);
go

-- Step 2: Generate some fake data using the Mockaroo website
https://www.mockaroo.com


-- Step 3: Import the data from Mockaroo into the Contacts Table
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Elwood', 'Spilstead', 'espilstead0@joomla.org');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Chucho', 'Pethrick', 'cpethrick1@dot.gov');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Urbain', 'Liebrecht', 'uliebrecht2@nhs.uk');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Elsa', 'Walworche', 'ewalworche3@edublogs.org');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Saba', 'Braddick', 'sbraddick4@businessinsider.com');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Sheffield', 'Hackney', 'shackney5@youku.com');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Lenee', 'Jirka', 'ljirka6@ovh.net');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Kenton', 'Flooks', 'kflooks7@tripod.com');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Nicolea', 'Michieli', 'nmichieli8@ovh.net');
insert into Contacts (ContactFirstName, ContactLastName, ContactEmail) values ('Kandy', 'Liebrecht', 'kliebrecht9@mozilla.com');