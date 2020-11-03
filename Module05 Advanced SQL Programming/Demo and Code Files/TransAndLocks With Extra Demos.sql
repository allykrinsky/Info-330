--****************** SQL Programming *********************--
-- This file is used to demo how locks and transactions 
-- work together in SQL Server 2005
--**********************************************************--

-- Create a new Database for transaction demos
-- Use Master; DROP DATABASE TransDemo
CREATE DATABASE TransDemo
go
USE TransDemo
go

'*** Working with the LOG File ***'
-----------------------------------------------------------------------------------------------------------------------
-- Checking information about the Log file 
SP_HELPDB  TransDemo

-- Change the database's Log size 
USE master
GO
ALTER DATABASE TransDemo 
MODIFY FILE
   (NAME = TransDemo_Log,
   SIZE = 5)
GO

-- Check to see if the size increased
sp_helpDB  TransDemo

-- Shink the log file back to 1 meg. (This will alway work if there was no activity in the log yet)
USE TransDemo
GO
DBCC SHRINKFILE (TransDemo_Log, 500 KB) -- ERROR; must be in MB
DBCC SHRINKFILE (TransDemo_Log, .5) -- ERROR; must be a whole number
DBCC SHRINKFILE (TransDemo_Log, 1) -- Will get as close to 1 MB as it can!
GO

-- Check to see if the size decreased, and if it is back to the original size
sp_helpDB  TransDemo

-- If you don't indicate a size it will shink it down as much as it can
DBCC SHRINKFILE (TransDemo_Log)

-- Check to see if the size decreased, and if it is back to the original size
sp_helpDB  TransDemo

-- Make some additions to the database so that the log is used
USE TransDemo 
Go
CREATE TABLE PartNumberStatusReport
(Id int identity(1,1) not null, Status char(10)Null)
go
-- Used to allow inserts into the Identity column
Declare @intCounter int
SET IDENTITY_INSERT PartNumberStatusReport On 
BEGIN TRAN
Select @intCounter = 1
  While @intCounter <= 30000
    Begin 
	  Insert PartNumberStatusReport (id, status) 
	  Values (@intCounter, 'Active')
	  Select @intCounter = @intCounter + 3
    End

Select @intCounter = 2
  While @intCounter <= 30000
    Begin 
	  Insert PartNumberStatusReport (id, status) 
	  Values (@intCounter, 'Inactive')
	  Select @intCounter = @intCounter + 3
    End

Select @intCounter = 3
  While @intCounter <= 30000
    Begin 
		  Insert PartNumberStatusReport (id, status) 
		  Values (@intCounter, 'Terminated')
		  Select @intCounter = @intCounter + 3
    End
-- NOTE: we have not commited the Transaction yet.

SET IDENTITY_INSERT PartNumberStatusReport OFF

-- Check to see if the size increased
sp_helpDB  TransDemo

-- Now try to shink the log again 
'COPY THE FOLLOWING TO ANOTHER CONNECTION)'
		USE TransDemo
		GO
		DBCC SHRINKFILE (TransDemo_Log)
		GO
		sp_helpDB  TransDemo
'--------------------------------------------------------------------------------------------------'

-- Now Commit the Transaction and Try again
Commit Tran
USE TransDemo
GO
DBCC SHRINKFILE (TransDemo_Log)
GO

-- You "May" see this 'Cannot shrink log file 2 (TransDemo_Log) because all logical log files are in use.'
-- If you do clear out the log by Truncating it with this statement
BACKUP TRANSACTION  TransDemo WITH NO_LOG

-- Other Versions( Note: None of these backup the log file)
DUMP TRANSACTION  BookShopDB WITH NO_LOG
BACKUP LOG BookShopDB WITH NO_LOG
DUMP LOG BookShopDB WITH NO_LOG

 BACKUP TRANSACTION  BookShopDB WITH TRUNCATE_ONLY
 DUMP TRANSACTION  BookShopDB WITH TRUNCATE_ONLY
 BACKUP LOG  BookShopDB WITH TRUNCATE_ONLY
 BACKUP LOG  BookShopDB WITH TRUNCATE_ONLY

-- This statement WILL back up the file AND Truncate it as well
 BACKUP LOG  BookShopDB TO DISK='C:\myData.bak'

-- Check to see if the size decreased
sp_helpDB  TransDemo

-- Once again try to shink the log.
USE TransDemo
GO
DBCC SHRINKFILE (TransDemo_Log, 1)
GO

-- Check to see if the size decreased
sp_helpDB  TransDemo

'*** How the Log File Works ***'
-----------------------------------------------------------------------------------------------------------------------
-- Create two tables to demo transaction issues 
CREATE TABLE dbo.Checking 
( AcctNo INT, Balance MONEY)
Go
CREATE TABLE dbo.Savings 
( AcctNo INT, Balance MONEY)
Go

-- Add some starting data
INSERT INTO dbo.Checking(AcctNo, Balance) VALUES(1, 100)
INSERT INTO dbo.Savings(AcctNo, Balance) VALUES(1,100)
Go

-- Review where the data is at right now
SELECT * FROM Checking
SELECT * FROM Savings
Go

-- View how the log is tracking these inserts (note the LSN and how it uses AUTO COMMIT MODE)
-- This command shows the Active portion of the Log with an "Unsupported" Command 
-- This command is for Demonstrations only
DBCC LOG(TransDemo)
Go

-- Tell the Log File to write all of the changes to the Database
-- This is not normally required is SQL will do it automatically as some point
CHECKPOINT
Go

-- Notice how the ACTIVE Portion of the Log is cleared after a Checkpoint
DBCC LOG(TransDemo)
Go

-- Add some more starting data
INSERT INTO dbo.Checking(AcctNo, Balance) VALUES(2, 100)
Go
INSERT INTO dbo.Savings(AcctNo, Balance) VALUES(2,100)
Go

-- View how the log is tracking these inserts (note the LSN and how it uses AUTO COMMIT MODE)
-- This command shows the Active portion of the Log with an "Unsupported" Command 
-- This command is for Demonstrations only
DBCC LOG(TransDemo)
Go

-- Now look at what happens when you explicitly start and complete the transaction manually
Begin Tran
  UPDATE Checking SET Balance = (Balance - 10) WHERE AcctNo = 1
Go

-- Check the Log now and see that the commit is not automatic now 
-- (The actual update is in the last two rows the other rows are showing locking actions)
DBCC LOG(TransDemo)
Go

-- Note that the row is locked by this connection with an eXclusive lock
SELECT OBJECT_ID('Checking') as [Id for this table], 
              @@Spid as [Process ID use by this connection]
EXEC SP_LOCK
Go

-- Try Running a SELECT Statement on this row from...
'Another connection'
SELECT * FROM Checking
Go

-- Look at SP_LOCK again and notice that the new connection is (WAIT)ing 
EXEC SP_LOCK
Go

-- finish the transaction by rolling back or committing it
-- COMMIT TRAN
ROLLBACK TRAN
Go

-- Notice that the lock was released and the log records the action
EXEC SP_LOCK
DBCC LOG(TransDemo)
Go

'*** Viewing and Controlling locks SQL locks ***' 
-----------------------------------------------------------------------------------------------------------------------
/* There are several lock types in SQL Server
	* Intent Shared (IS)
	* Shared (S)
	* Update (U)
	* Intent Exclusive (IX)
	* Shared with Intent Exclusive(SIX)
	* Exclusive(X)
	* Bulk Update(BU)
*/

-- To see all the locks on the SERVER use SP_LOCK:
BEGIN TRAN
USE TransDemo
DELETE FROM TestBatch
Go

USE Pubs -- Note that it doesn't matter which database you use 
EXEC SP_LOCK
Go

USE TransDemo 
EXEC SP_LOCK
Go

-- To display information about about an individule process add the SPID
EXEC sp_lock 51
Go

-- Use SP_WHO to find out who a SPID is mapped to
SP_WHO 51
SP_WHO2 51
Go

-- The KILL command terminates a  process based on the SPID 
-- If the specified SPID has a lot of work to undo, the KILL statement may take awhile
KILL 51
Go

-- You can check to see if it is indeed killed.
KILL 51 WITH STATUSONLY
Go

-- If the process is killed you will see:
'Process ID 51 is not an active process ID.'

-- If the process is still being killed you will see:
'spid 54: Transaction rollback in progress. Estimated rollback completion: 80% Estimated time left: 10 seconds.'

-- The SET LOCK_TIMEOUT statement enables an application to set 
-- the maximum time that a statement will wait for a blocked resource. 
-- It also displays the current lock timeout setting (in milliseconds) for the current session, 
SELECT @@LOCK_TIMEOUT -- (-1) means that it is using the default of NEVER timing out!
Go

--This example sets the lock timeout period to 2000 milliseconds.
SET LOCK_TIMEOUT 2000
Go

SELECT @@lock_timeout
Go


'*** Controlling Transactions ***'
-----------------------------------------------------------------------------------------------------------------------
-- Add a Check Constraint so that a error will be generated when a negitive balance occurs
ALTER TABLE Checking 
	ADD CONSTRAINT ckCheckingNotBelowZero CHECK (Balance > 0)
Go

ALTER TABLE Savings 
	ADD CONSTRAINT ckSavingsNotBelowZero CHECK (Balance > 0)
Go

-- Let's see where the balance is now
SELECT * FROM Checking
SELECT * FROM Savings
Go

-- Try the Transaction without error handling
BEGIN TRAN
	  UPDATE Checking SET Balance = (Balance - 110) WHERE AcctNo = 1 
	  UPDATE Savings SET Balance = (Balance + 110) WHERE AcctNo = 1
COMMIT TRAN
Go

-- Let's see where the balance is now( Notice the this is NOT what you might expect!)
SELECT * FROM Checking
SELECT * FROM Savings
Go

-- Fix the problem manually and try to catch the error and rollback next time
UPDATE Savings SET Balance = (Balance - 110) WHERE AcctNo = 1
Go

-- Using Error handling with IF-ELSE
BEGIN TRAN
  UPDATE Checking SET Balance = (Balance - 110) WHERE AcctNo = 1
    IF @@ERROR <> 0 
	    BEGIN
	        ROLLBACK TRAN
	        RETURN
	    END
	  ELSE
      BEGIN
        UPDATE Savings SET Balance = (Balance + 110) WHERE AcctNo = 1
          IF @@ERROR <> 0 -- NOTE: This is a nested if
	          BEGIN
	              ROLLBACK TRAN
	              RETURN
	          END
	        ELSE
            BEGIN
	              COMMIT TRAN
	              RETURN
	          END
      END
Go

-- Let's see where the balance is now( Notice the this IS what you might expect!)
SELECT * FROM Checking
SELECT * FROM Savings
Go
-- Using Error handling with TRY-CATCH
BEGIN TRY
  BEGIN TRAN
  UPDATE Checking SET Balance = (Balance - 100) Where AcctNo = 1
  UPDATE Savings SET Balance = (Balance + 110) Where AcctNo = 1
  COMMIT TRAN
END TRY
BEGIN CATCH
  RAISERROR('Error detected. The Transaction has been rolled back', 15, 1)
  ROLLBACK TRAN
END CATCH
Go
-- Let's see where the balance is now( Notice the this IS what you might expect!)
SELECT * FROM Checking
SELECT * FROM Savings
Go

'*** Using Transaction Modes ***'
--***************************************************
-- Behavior of Statements vary depending on when an error happens
-- when you are using the default AUTOCOMMIT mode

-- 1) In the following example, none of the INSERT statements in the third batch
-- are executed because of a compile error in the third INSERT statement. 
-- The first two INSERT statements are rolled back because of the SYNTAX error, and 
-- no data is added to the TestBatch table: 
CREATE TABLE TestBatch (ColA INT PRIMARY KEY, ColB CHAR(3))
Go
INSERT INTO TestBatch VALUES (1, 'aaa')
INSERT INTO TestBatch VALUES (2, 'bbb')
INSERT INTO TestBatch VALUSE (3, 'ccc')  /* Syntax error */
Go
SELECT * FROM TestBatch   /* Returns NO rows */
Go

-- 2) In the next example, the third INSERT statement generates a RUN-TIME, 
--duplicate primary key error. The first two INSERT statements are 
--successful and committed, so the values are added to the TestBatch table: 
INSERT INTO TestBatch VALUES (1, 'aaa')
INSERT INTO TestBatch VALUES (2, 'bbb')
INSERT INTO TestBatch VALUES (1, 'ccc')  /* run-time error */
Go
SELECT * FROM TestBatch   /* Returns both rows 1 and 2 */
Go

-- 3) SQL Server uses delayed name resolution, in which object names are not resolved 
-- until execution time. In the following example, the first two INSERT 
-- statements are executed and committed, and those two rows remain in the 
-- TestBatch table after the third INSERT statement generates a run-time error 
-- (by referring to a table that does not exist): 
DROP TABLE TestBatch
Go
CREATE TABLE TestBatch (Cola INT PRIMARY KEY, Colb CHAR(3))
Go
INSERT INTO TestBatch VALUES (1, 'aaa')
INSERT INTO TestBatch VALUES (2, 'bbb')
INSERT INTO TestBch VALUES (3, 'ccc')  /* Table name error */
Go
SELECT * FROM TestBatch   /* Returns rows 1 and 2 */
Go

-- When using IMPLICIT transaction mode the process is different

-- 1) The following statement first creates the ImplicitTran table, 
-- then starts implicit transaction mode, 
-- then runs two transactions, and 
-- then turns off implicit transaction mode: 
CREATE TABLE ImplicitTran ( ColA INT PRIMARY KEY, ColB CHAR(3) NOT NULL)
Go
SET IMPLICIT_TRANSACTIONS ON -- then starts implicit transaction mode
Go

-- First implicit transaction is started by an INSERT statement and are left open
INSERT INTO ImplicitTran VALUES (1, 'aaa')
Go
INSERT INTO ImplicitTran VALUES (2, 'bbb')
Go

-- Find out how many Transactions are open
SELECT @@TRANCOUNT
Go
-- Commit first transaction 
COMMIT TRANSACTION
Go

-- Find out how many Transactions are open now
SELECT @@TRANCOUNT

-- Now check the table
SELECT * FROM ImplicitTran
Go

-- Find out how many Transactions are open (Does a Select Start One?)
SELECT @@TRANCOUNT
Go

/* Second implicit transaction started by an INSERT statement */
INSERT INTO ImplicitTran VALUES (3, 'ccc')
Go

SELECT * FROM ImplicitTran
Go

'Now try closing the connection to see the warning SQL gives you'  
-- Add a nested Transaction and look at the Tran Count
BEGIN TRAN
SELECT @@TRANCOUNT
Go

-- Note that commit just commits the most recents Transaction not both
COMMIT TRAN
SELECT @@TRANCOUNT
Go

-- Note that Rolling back the transaction closes all perviously open ones
ROLLBACK TRAN
Go

-- Find out how many Transactions are open now
SELECT @@TRANCOUNT
Go

-- It is recommended that you run in AutoCommit Mode
SET IMPLICIT_TRANSACTIONS OFF
Go

'*** Different issues with Locks ***'
-----------------------------------------------------------------------------------------------------------------------
-- (NOTE: This is just a list of issues that can happen)
-- Dirty Reads
-- Non-Repeatable Reads
-- Phantom Reads
-- Lost Updates

'*** Using Isolation Levels ***'
-----------------------------------------------------------------------------------------------------------------------
--Users can control the locking of read operations by 
--using SET TRANSACTION ISOLATION LEVEL or using locking table hints 
-- Use this to check the current settings this connection is using
DBCC USEROPTIONS

'NOTE: Open a new connection and copy the following code to demo these settings'
--1) Let's see where the balance is now
SELECT * FROM Checking
SELECT * FROM Savings

--2) Start a Transaction and leave it open to demo Read Commited and Read UnCommited
BEGIN TRAN
  UPDATE Checking SET Balance = (Balance - 20) Where AcctNo = 1
  UPDATE Savings SET Balance = (Balance + 20) Where AcctNo = 1

--3) Rollback the Transaction to demo how reading UnCommited data can impact the user
  ROLLBACK TRAN
'--------------------------------------------------------------------------------------------------------------------------------'
'Do Step 1 and 2'
-- Read Commited: Will NOT let you SEE data that is being changed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
DBCC USEROPTIONS
SET LOCK_TIMEOUT 2000
SELECT * FROM Checking

EXEC SP_LOCK 

-- Read UnCommited: WILL let you SEE data that is being changed
SET TRANSACTION ISOLATION LEVEL READ unCOMMITTED
DBCC USEROPTIONS
SELECT * FROM Checking

EXEC SP_LOCK 

'Do Step 3'
-- NOTE that if the Transaction is rolled back this will not be correct information!
SELECT * FROM Checking

-- Repeatable Read: Issues Locks on the table so that no one can change the values until you are done
-- But Phantom Reads can still occur.
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
  UPDATE Checking SET Balance = Balance +1000
  EXEC SP_LOCK 51 -- Since no locks are on the table users could ADD a new Row at the same time
COMMIT TRAN
SELECT * FROM Checking

-- Serializable: Issues Locks on the table so that no one can change the values 
-- OR add new rows until you are done
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
  UPDATE Checking SET Balance = Balance - 1000
  EXEC SP_LOCK 51 -- Since locks ARE on the table users could NOT ADD a new Row at the same time
COMMIT TRAN
SELECT * FROM Checking

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

'*** Using Optimizer Hints  ***'
-----------------------------------------------------------------------------------------------------------------------
-- Find out what the ID of the Checking table
select Object_Id('Checking')

-- Use a Table Hint to force a Table Lock
BEGIN TRAN
  SELECT * FROM Checking(TABLOCKX)
go 
EXECUTE sp_lock 51
' COMMIT TRAN - Run this after you check what locks are open'

-- With the isolation level is set to SERIALIZABLE exclusive looks will be placed on the table,
-- but the table-level locking hint NOLOCK will override this. 
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
  INSERT INTO Checking VALUES(3, 100)
  EXECUTE sp_lock 51

-- You can use this command from ANOTHER connection to Override and read dirty data
SELECT *  FROM Checking WITH (NoLOCK) 

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

'*** Avoiding DeadLocks ***'
-----------------------------------------------------------------------------------------------------------------------
'NOTE: Run Connection 1 and 2 code in different windows to see the deadlock example'
-- Connection 1: Using Checking table first
USE TransDemo
BEGIN
  BEGIN TRAN
    UPDATE Checking SET Balance = (Balance - 20) Where AcctNo = 1
    WAITFOR DELAY '00:00:05'  -- Add 5 sec delay to widen the window for the deadlock
    UPDATE Savings SET Balance = (Balance + 20) Where AcctNo = 1
  COMMIT TRAN
END

-- Connection 2: Using Savings table first
USE TransDemo
BEGIN
   BEGIN TRAN
    UPDATE Savings SET Balance = (Balance - 20) Where AcctNo = 1
    WAITFOR DELAY '00:00:05'  -- Add 5 sec delay to widen the window for the deadlock
    UPDATE Checking SET Balance = (Balance + 20) Where AcctNo = 1
    COMMIT TRAN
  END

-- Let's see where the balance is now
-- NOTE: It will be up to the APPLICATION Developer to handle this error
-- By rerunning the updates when a deadlock happens
SELECT * FROM Checking
SELECT * FROM Savings

-- SET DEADLOCK_PRIORITY { LOW | NORMAL | @deadlock_var }
 SET DEADLOCK_PRIORITY LOW