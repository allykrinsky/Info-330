-- Working with Transaction Log Backups

-- Cannot do a log backup when DB is in simple mode
ALTER DATABASE [Pubs] 
SET RECOVERY FULL 
	WITH NO_WAIT
	
-- Make a new Full backup of Pubs
BACKUP DATABASE [Pubs] 
TO  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
WITH 
 INIT -- Clears out the contents of the backup file

-- Make a new Log backup of Pubs
BACKUP Log [Pubs] 
TO  DISK = N'C:\MySQLBackups\PubsBackups.bak' 

-- This should FAIL
Exec pubs.dbo.pAfterLogBackup

Go
Use Pubs
Go
Create -- Drop
Proc pAfterLogBackup AS print 'test'

-- Make a new Log backup of Pubs
BACKUP Log [Pubs] 
TO  DISK = N'C:\MySQLBackups\PubsBackups.bak' 


-- This will WORK!
Exec pubs.dbo.pAfterLogBackup

-- LAB
--1)  Restore the DB to a time JUST before the Stored Procedure was made!

-- Look inside file
Restore HeaderOnly
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 

Restore FileListOnly
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With File =  1

Restore FileListOnly
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With File =  2

-- Restore the Full backup
Use Master
ALTER DATABASE [Pubs] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
Restore Database Pubs
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With 
  File =  1
, NoRecovery -- Lets you add more backups
, Replace
go
-- Retore the first log backup
Restore Log Pubs
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With 
  File =  2
, Recovery -- Lets the user access the DB 

-- Test 
-- This should FAIL
Exec pubs.dbo.pAfterLogBackup

--2) Now, restore the DB to a time just AFTER the Stored Procedure was made!
Use Master
ALTER DATABASE [Pubs] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
Restore Database Pubs
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With 
  File =  1
, NoRecovery -- Lets you add more backups
, Replace
go
-- Retore the first log backup
Restore Log Pubs
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With 
  File =  2
, NoRecovery -- Lets  you add more backups

-- Retore the second log backup
Restore Log Pubs
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With 
  File =  3
, Recovery -- Lets the user access the DB


-- Test 
-- This should FAIL
Exec pubs.dbo.pAfterLogBackup


-- Working with Tranactions
Use pubs
Create Table LogTest (id int)
Go
Insert into LogTest Values (1)
Go
Select * from LogTest 

-- Backup Pubs again, Full with init
BACKUP DATABASE [Pubs] 
TO  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
WITH 
 INIT -- Clears out the contents of the backup file


Begin Transaction 
Insert into LogTest Values (2)
Go
Select * from LogTest 
-- Do not Commit

-- Create a Separate connection and backup the log
-- Backup the Log 
BACKUP Log [Pubs] 
TO  DISK = N'C:\MySQLBackups\PubsBackups.bak' 


-- Do this on a different connection too!
--2) Now, restore the DB to a time just AFTER the Stored Procedure was made!
Use Master
ALTER DATABASE [Pubs] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
Restore Database Pubs
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With 
  File =  1
, NoRecovery -- Lets you add more backups
, Replace
go
-- Retore the first log backup
Restore Log Pubs
From  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
With 
  File =  2
, Recovery -- Finish


-- Not look and see if the insert was "Lost"
Select * from LogTest 
Commit Transaction -- Opps, The COMMIT TRANSACTION request has no corresponding BEGIN TRANSACTION.



-- Standby Mode
Use pubs
Drop Table LogTest
Go
Create Table LogTest (id int)
Go
Insert into LogTest Values (1)
Go
Select * from LogTest 

-- Backup Pubs again, Full with init
BACKUP DATABASE [Pubs] 
TO DISK = N'C:\MySQLBackups\PubsBackups.bak' 
WITH 
 INIT -- Clears out the contents of the backup file

-- Add some data
Insert into LogTest Values(2);

-- Make a log backup
BACKUP Log [Pubs] 
TO DISK = N'C:\MySQLBackups\PubsBackups.bak' 



-- Restore with Standby
RESTORE DATABASE [PubsReports] 
FROM  DISK = N'C:\MySQLBackups\PubsBackups.bak' 
WITH  
   FILE = 1
,  MOVE N'Pubs' 
	TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.Dev\MSSQL\DATA\PubsReports.mdf'
,  MOVE N'Pubs_log' 
	TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.Dev\MSSQL\DATA\PubsReports_1.LDF'
,  STANDBY = N'C:\MySQLBackups\ROLLBACK_UNDO_PubsReports.BAK'
,  NOUNLOAD
,  REPLACE
,  STATS = 10
GO

-- Can only see the first row
Select * From [PubsReports].dbo.LogTest 

-- Restore with Standby
RESTORE Log [PubsReports] 
FROM DISK = N'C:\MySQLBackups\PubsBackups.bak' 
WITH  
   FILE = 2 -- Get the log backup!
,  MOVE N'Pubs' 
	TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.Dev\MSSQL\DATA\PubsReports.mdf'
,  MOVE N'Pubs_log' 
	TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.Dev\MSSQL\DATA\PubsReports_1.LDF'
,  STANDBY = N'C:\MySQLBackups\ROLLBACK_UNDO_PubsReports.BAK'
,  NOUNLOAD
,  REPLACE
,  STATS = 10
GO

-- Can now see the second Row
Select * From [PubsReports].dbo.LogTest 