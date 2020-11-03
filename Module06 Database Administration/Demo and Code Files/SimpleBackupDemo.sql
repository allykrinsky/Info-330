Use BackupDemoDB
go
Create Table BackupDemo (Id int)
go
Insert into BackupDemo Values(1)
-- Check the data
Select * from BackupDemo

-- Backup data
Backup
Database BackupDemoDB -- daily, weekly
To Disk ='C:\BackupDemoDB_Full.bak'

-- Add more data after the backup
Insert into BackupDemo Values(2)
-- and back up the insert
Backup
Log BackupDemoDB -- 6 hours, daily
To Disk ='C:\BackupDemoDB_Log.bak'

-- Check the data
Select * from BackupDemo

-- test the Full DB backup
Use Master
Restore
Database BackupDemoDB
From  Disk ='C:\BackupDemoDB_Full.bak'
-- With Recovery,  Replace -- Both are optional but recommend 

-- Check the data
use BackupDemoDB
Select * from BackupDemo

'This will not work because the DB has already RECOVERED'
Restore
Database BackupDemoDB
From  Disk ='C:\BackupDemoDB_Log.bak'

-- test the Log backup
-- test the Full DB backup
Use Master
Restore
Database BackupDemoDB
From  Disk ='C:\BackupDemoDB_Full.bak'
With NoRecovery, Replace
Go

Restore
Database BackupDemoDB
From  Disk ='C:\BackupDemoDB_Log.bak'
With Recovery -- This is the default, so its optional

-- Check the data
use BackupDemoDB
Select * from BackupDemo
