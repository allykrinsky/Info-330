--****************** SQL Programming *********************--
-- This file explains Addtional Types of Stored Procedures
--**********************************************************--
'*** Temporary Stored Procedures ***'
---
--------------------------------------------------------------------------------------------------------------------
-- A local temporary stored procedure will exist for the life 
-- of the connection that made it
Use SprocDemo
Go
CREATE PROCEDURE #localtemp
AS
 SELECT * from [pubs].[dbo].[authors]
Go

-- A Global temporary stored procedure will exist until the last 
-- connection using it closes
CREATE PROCEDURE ##globaltemp
AS
 SELECT * from [pubs].[dbo].[authors]
Go

-- A stored procedure created in the TempDB directly will
-- exist until SQL Server is restarted
USE TEMPDB
Go
CREATE PROCEDURE directtemp
AS
 SELECT * from [pubs].[dbo].[authors]
Go
 
 
'*** Using SYSTEM Stored Procedures ***'
-----------------------------------------------------------------------------------------------------------------------
-- SQL Server ships with many pre-made stored procedures that you can 
-- use to control your server and database
Use Master
Go
SELECT Count(Name) as [Number of System Sprocs] 
FROM SysObjects 
WHERE name like 'xp_%' AND xtype = 'P'

SELECT Name, text
FROM SysObjects Join SysComments
On SysObjects.Id = SysComments.Id
WHERE name like 'sp_%' AND xtype = 'P' Order By Name

-- Some examples --
-- sp_Rename changes of an object in a database 
Use PUBS
Go
EXEC sp_Rename
  @objname = 'byroyalty', 
  @newname = 'RoyaltyByAuthorID', 
  @objtype = 'object'

-- This is an example of how to make modifications to a table 
-- beyond what Alter table can do, such as adding a new 
-- column at to begining of a table.
Use SprocDemo
Go
CREATE TABLE dbo.Tmp_Employees	(
	EmpID int Identity NOT NULL, -- Adding this as a new column
	FirstName nvarchar(10) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	HireDate datetime NULL
	)
Go
INSERT INTO dbo.Tmp_Employees (FirstName, LastName, HireDate)
	SELECT FirstName, LastName, HireDate 
  FROM dbo.Employees 
Go
DROP TABLE dbo.Employees
Go
EXEC sp_rename N'dbo.Tmp_Employees', N'Employees', 'Object' 
Go
SELECT * FROM Employees

-- The following example changes the owner of the authors table.
EXEC sp_ChangeObjectOwner 
  @objname = 'sue.pInsProducts',
  @newowner = 'dbo'
Go
 
-- The following example creates a linked server named "RSLAPTOP1\SQLEXPRESS".
--  Since the product name is SQL Server no provider name is needed. 
USE master
Go
EXEC sp_AddLinkedServer  
  @server = 'RSLAPTOP1\SQLEXPRESS', 
  @srvproduct = 'SQL Server'

-- To remove a linked server you use this command
EXEC sp_DropServer  
  @server='RSLAPTOP1\SQLEXPRESS'


'*** Using Remote Stored Procedures ***'
-----------------------------------------------------------------------------------------------------------------------
-- Remote stored procedures are ones that are called on a different server. 

-- The following statement calls sp_lock on a remote linked server. 
EXECUTE [RSLAPTOP1\SQLEXPRESS].Master.dbo.sp_helpdb

-- this is the same call but to the Local server
EXECUTE Master.dbo.sp_helpdb


'*** Using EXTENDED Stored Procedures ***'
-----------------------------------------------------------------------------------------------------------------------
 'Extended Stored Procedures are now turned off by default' 
-- This example shows the xp_cmdshell Extended stored procedure
CREATE PROC CreateBackupFolder
 (@FolderName VarChar(20) )
AS
 SET @FolderName = 'md ' + @FolderName
 EXEC master.dbo.xp_cmdshell @FolderName

'*** Using .NET Stored Procedures ***'
-----------------------------------------------------------------------------------------------------------------------
"You can now write stored procedures, triggers, user-defined types, 
user-defined functions (scalar and table-valued), and 
user-defined aggregate functions using any 
.NET Framework language, including Microsoft Visual Basic .NET 
and Microsoft Visual C#." -- B.O.L.

-- Step 1: Creating the .Net Assembly
-- Create a .NET .dll that preforms a task you wish to do from 
-- within SQL Server.
--  Step 1a: Create a C# class library project called SQLServerCLRProcedures
--  Step 1b: Add the following code and using statements
'
using System.IO ;

namespace SQLServerCLRProcedures
{
    public class SystemInfo
    {

        [Microsoft.SqlServer.Server.SqlProcedure]
        public static int GetFolderInfo(string FolderName, out string FolderInfo)
        {
            // Specify the directories you want to manipulate.
            string target = @"c:\" + FolderName;
            int rc = 0;
           if (Directory.Exists(target )== false )
            {
                FolderInfo = "Folder not found";
                rc = -1;

            }
            else
            {
                // Count the files in the target directory.
                FolderInfo = "The number of files in "
                  + target + ": "
                  + Convert.ToString(Directory.GetFiles(target).Length);
                rc = 0;
            }
           return rc;

       }//end of GetFolderInfo
    }//end of SystemInfo
}//end of SQLServerCLRProcedures

'
--  Step 1c: Build the project to create the .Net 
-- assembly(SQLServerProcedures.dll)

-- Step 2: Turning on the CLR option --
-- You verify that .NET procedures will run on this server
-- by viewing "clr enabled" option with this Sproc.
    --  0 = Assembly execution not allowed on SQL Server.
    --  1 = Assembly execution allowed on SQL Server.
EXEC sp_Configure
Go

-- To turn this option on run the following commands
EXEC sp_Configure 'clr enabled', 1
Go

-- With some settings, the change will not take effect immediately
EXEC sp_Configure 
Go

-- You also need to force the change to happen 
RECONFIGURE
Go

-- Now, verify the change has taken effect
EXEC sp_Configure 
Go

--  Step 3: Adding an Assembly to SQL Server --
--  Next, you add the assembly 
--  using the CREATE ASSEMBLY statement.
use SprocDemo
Go
CREATE ASSEMBLY CLRCodeDemo
FROM 'C:\SQLDandI\SQLServerCLRProcedures.dll'
WITH PERMISSION_SET = SAFE

-- Step 4: Creating the Stored Procedure -- 
-- Once the Assembly is added you can create a Stored
-- procedure that maps to it. 
USE SprocDemo
Go
CREATE PROCEDURE FileCounter 
  (@FolderName nVarchar(50), @data nVarchar(200) out)
AS  
  EXTERNAL NAME  
  CLRCodeDemo.[SQLServerCLRProcedures.SystemInfo].GetFileCount
Go

-- Step 5: Attempting to Execute the Sproc --
-- You can execute the CLR procedure as follows but in this example
'you will see an error since we are trying to access protected resources'
"When code in an assembly runs under the SAFE permission set, 
it can only do computation and data access 
within the server through the in-process managed provider." -- B.O.L.
Use SprocDemo
Go
DECLARE @data nVarchar(200)
DECLARE @rc int
EXEC @rc = FileCounter 'C:\Windows', @data output
SELECT @data as [Files Found], @rc as [Return Code]
Go

-- Step 6: Configuring the Server and Permission Set -- 
--  The following example ATTEMPS to changes the permission 
--  set of the assembly  from SAFE to EXTERNAL ACCESS. 
--  You could also use UNSAFE, but UNSAFE is only for 
--  situations where an assembly requires additional access to 
--  restricted resources, such as the Microsoft Win32 API.
'Another Error will be raised with this next statement'
ALTER ASSEMBLY CLRCodeDemo
WITH PERMISSION_SET = EXTERNAL_ACCESS
Go

-- To fix this error do as the message instructed.
USE Master
Go
GRANT EXTERNAL ACCESS ASSEMBLY 
TO [RSLAPTOP1\Admin]
Go
USE master;
GO
ALTER DATABASE SprocDemo
SET TRUSTWORTHY On

-- Now you are ready to change the permissions
USE SprocDemo
Go
ALTER ASSEMBLY CLRCodeDemo
WITH PERMISSION_SET = EXTERNAL_ACCESS
Go

-- Now that the permissions are correct, you can execute
-- the CLR procedure as follows
Use SprocDemo
Go
DECLARE @data nVarchar(200)
DECLARE @rc int
EXEC @rc = FileCounter 'C:\Windows', @data output
SELECT @data as [Files Found], @rc as [Return Code]
Go

-- Step 7: Reverse the changes and Drop Assembly after the Demo
USE master
Deny EXTERNAL ACCESS ASSEMBLY 
TO [RSLAPTOP1\Admin]
Go
ALTER DATABASE SprocDemo
SET TRUSTWORTHY Off
Go
USE SprocDemo
DROP PROCEDURE MemoryInfo
Go 
DROP ASSEMBLY CLRCodeDemo
Go
USE Master
EXEC sp_Configure 'clr enabled', 0
RECONFIGURE
Go
