Set NoCount On -- Turns off the annoying "One Row affected" messages 
-- Note: Do not place the Set NoCount On option inside a Stored Procedure, since it 
-- will send a false error to an ADO.NET DataAdpater object.

-- 1) Make the database
USE [master]
GO
If Exists(Select Name from master.Sys.databases where name = 'EmployeeProjects')
 Begin 
  ALTER DATABASE [EmployeeProjects] SET SINGLE_USER WITH ROLLBACK IMMEDIATE 
	Drop Database[EmployeeProjects]
 End 
GO
 
CREATE DATABASE [EmployeeProjects]
GO

USE [EmployeeProjects]
GO

-- 2) Make the tables
CREATE TABLE [dbo].[Employees]
(
	[EmployeeId] [int] NOT NULL PRIMARY KEY Identity ,
	[EmployeeName] [nvarchar](100) NOT NULL,
)
GO

CREATE TABLE [dbo].[Projects]
(
	[ProjectId] [int] NOT NULL PRIMARY KEY Identity (100, 1),
	[ProjectName] [nvarchar](100) NOT NULL,
	[ProjectDescription] [nvarchar](3000) NOT NULL,
)
GO

CREATE TABLE [dbo].[EmployeeProjectHours]
(
	[EmployeeId] [int] NOT NULL references Employees(EmployeeID),
	[ProjectId] [int] NOT NULL references Projects(ProjectID),
	[Date] [datetime] NOT NULL,
	[Hours] [decimal](18, 2) NOT NULL,
	CONSTRAINT [PK_EmployeeProjectHours] PRIMARY KEY CLUSTERED 
		([EmployeeId] ASC,[ProjectId] ASC,[Date] ASC)
)
GO

CREATE TABLE [dbo].[ThisYearsDates]
(
	[DateId] [int] Identity NOT NULL PRIMARY KEY,
	[DateName] [nvarchar](100) NOT NULL,
)
GO

CREATE TABLE [dbo].[ValidHourEntries]
(
	[TimePeriodId] [int] Identity NOT NULL PRIMARY KEY,
	[TimePeriod] [nvarchar](100) NOT NULL,
)
GO

-- 3) Fill the tables with test data
-- Add two test employees
Insert into [dbo].[Employees] Values ('Bob Smith')
Insert into [dbo].[Employees] Values ('Sue Jones')
GO
-- Add two test Projects
Insert into [dbo].[Projects] Values ('Accounting DB Upgrade', 'Upgrade the Accounting Database to our new SQL 2008 Server')
Insert into [dbo].[Projects] Values ('Accounting Application Upgrade', 'Modify our existing Accounting Application to connect to the new upgraded server')
GO
-- Add four test Employee Project Hours
Insert into [dbo].[EmployeeProjectHours] Values (1,100,'1/1/' + Cast(Year(Getdate()) as varchar(4)), 6)
Insert into [dbo].[EmployeeProjectHours] Values (1,100,'1/2/' + Cast(Year(Getdate()) as varchar(4)), 4)
Insert into [dbo].[EmployeeProjectHours] Values (2,101,'1/1/' + Cast(Year(Getdate()) as varchar(4)), 5.5)
Insert into [dbo].[EmployeeProjectHours] Values (2,101,'1/2/' + Cast(Year(Getdate()) as varchar(4)), 6)
GO

-- Add This years dates
Declare @DateId int = 1
Declare @Date datetime = '1/1/' + Cast(Year(GetDate()) as Varchar(4));
While (Year(@Date) < (Year(GetDate()) + 1))
	Begin
		Insert into [dbo].[ThisYearsDates]Values(Convert(varchar(50), @Date, 101) )
		Set @DateId = @DateId + 1
		Set @Date = DateAdd(dd, 1, @Date)
	End
GO

-- Add Valid Hourly Entries
Declare @TimePeriod decimal(18,2) = 0
While ( @TimePeriod <= 24)
	Begin 
		Insert into [ValidHourEntries]( TimePeriod) Values (@TimePeriod)
		Set @TimePeriod = @TimePeriod + .25 
	End
Go

-- 4) Review everything you have so far
Select * From [dbo].[Employees]
Select * From [dbo].[Projects]
Select * From [dbo].[EmployeeProjectHours]
Select * From [dbo].[ThisYearsDates]
Select * From [dbo].[ValidHourEntries]
GO


-- 5) Create Select Sprocs for Tables
Create Proc pSelEmployees(@EmployeeID int = -1)
  AS
  Begin
    Declare @RC int = 0
    Begin Try
  		Select EmployeeID, EmployeeName 
		From [dbo].[Employees]
		Where EmployeeID = @EmployeeID
		OR @EmployeeID = -1;
		Set @RC = 100 -- Indicates Success	
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
    End Catch	
    Return @RC
  End	
GO

Create Proc pSelProjects(@ProjectID int = -1)
  AS
  Begin
    Declare @RC int = 0
    Begin Try
		Select ProjectID, ProjectName, ProjectDescription
		From [dbo].[Projects]
		Where ProjectID = @ProjectID
		OR @ProjectID = -1;
		Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
    End Catch	
    Return @RC
  End	
GO

Create Proc pSelEmployeeProjectHours(@EmployeeID int = -1, @ProjectID int = -1)
  AS
  Begin
    Declare @RC int = 0
    Begin Try  
		SELECT 
			dbo.EmployeeProjectHours.[Date],
			dbo.Employees.EmployeeID, 			 
			dbo.Employees.EmployeeName,
			dbo.Projects.ProjectID, 			 
			dbo.Projects.ProjectName, 
			dbo.EmployeeProjectHours.Hours
        FROM  dbo.EmployeeProjectHours 
		INNER JOIN dbo.Employees 
			ON dbo.EmployeeProjectHours.EmployeeId = dbo.Employees.EmployeeId 
        INNER JOIN dbo.Projects 
			ON dbo.EmployeeProjectHours.ProjectId = dbo.Projects.ProjectId
		WHERE (Employees.EmployeeId = @EmployeeID AND Projects.ProjectID = @ProjectID)
		OR (Employees.EmployeeId = @EmployeeID)
		OR (Projects.ProjectID = @ProjectID)
		OR (@EmployeeID = -1 AND @ProjectID = -1);
	Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
    End Catch	
    Return @RC
  End		
GO

Create Proc pSelThisYearsDates
  AS
  Begin
    Declare @RC int = 0
    Begin Try
	  SELECT 
	   [DateId]
      ,[DateName] 
	  FROM [ThisYearsDates]
		Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
    End Catch	
    Return @RC
  End	
GO


Create Proc pSelValidHours
  AS
  Begin
    Declare @RC int = 0
    Begin Try
		Select
		TimePeriodId,
		TimePeriod
		From ValidHourEntries
		Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
    End Catch	
    Return @RC
  End	
GO


	-- 5a) Review everything you have so far
Exec pSelEmployees
Exec pSelEmployees @EmployeeID = 1

Exec pSelProjects
Exec pSelProjects @ProjectID = 101

Exec pSelEmployeeProjectHours
Exec pSelEmployeeProjectHours @EmployeeID = 1, @ProjectID = 100
Exec pSelEmployeeProjectHours @EmployeeID = 1
Exec pSelEmployeeProjectHours @ProjectID = 100

Exec pSelThisYearsDates
Exec pSelValidHours
GO
		
-- 6) Insert Sprocs
Create Proc pInsEmployees
( @EmployeeName varchar(100), @NewRowID int out)
  AS
  Begin
    Declare @RC int = 0
    Begin Try  
	  Begin Transaction  
		Insert into [dbo].[Employees] Values (@EmployeeName)
	  Commit Transaction
	  Select @NewRowID = SCOPE_IDENTITY(); 
	Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction			
    End Catch	
    Return @RC
  End	
GO

Create Proc pInsProjects
( @ProjectName varchar(100), @ProjectDescription varchar(5000), @NewRowID int out)
  AS
  Begin
    Declare @RC int = 0
    Begin Try  
	  Begin Transaction    
		Insert into [dbo].[Projects] Values (@ProjectName, @ProjectDescription)
	  Commit Transaction
	  Select @NewRowID = SCOPE_IDENTITY(); 
	Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction			
    End Catch	
    Return @RC
  End	
GO

Create Proc pInsEmployeeProjectHours
( @EmployeeID varchar(100), @ProjectID varchar(100), @Date datetime, @Hours decimal(18,2))
  AS
  Begin
    Declare @RC int = 0   
    Begin Try  
	  Begin Transaction  		
	 	Insert into [dbo].[EmployeeProjectHours] Values(@EmployeeID, @ProjectID, @Date, @Hours)
	  Commit Transaction	
	  Set @RC = 100;	
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction		
    End Catch	
    Return @RC
  End	
GO

	-- 6a) Review everything you have so far
Declare @NewID int 
Exec pInsEmployees @EmployeeName = 'Test User', @NewRowID = @NewID out
Exec pInsProjects @ProjectName = 'Test Project' , @ProjectDescription = 'Test Desc', @NewRowID = @NewID out
Exec pInsEmployeeProjectHours @EmployeeID = 3, @ProjectID = 102, @Date = '1/1/2011', @Hours = 1
GO

Exec pSelEmployees
Exec pSelProjects
Exec pSelEmployeeProjectHours
GO

-- 7) Update Sprocs
Create Proc pUpdEmployees
( @EmployeeId int, @EmployeeName varchar(100))
  AS
  Begin
    Declare @RC int = 0
    Begin Try  
	  Begin Transaction  
		Update [dbo].[Employees] 
		Set 
			[EmployeeName] = @EmployeeName
		Where 
			[EmployeeId] = @EmployeeId 
	  Commit Transaction
	Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction
    End Catch	
    Return @RC
  End	
GO

Create Proc pUpdProjects
( @ProjectId int, @ProjectName varchar(100),  @ProjectDescription varchar(5000))
  AS
  Begin
    Declare @RC int = 0
    Begin Try  
	  Begin Transaction    
		Update [dbo].[Projects]
		Set 
			[ProjectName] = @ProjectName,
			[ProjectDescription] = @ProjectDescription 			
		Where 
			[ProjectId] = @ProjectId  
	  Commit Transaction
	Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction		
    End Catch	
    Return @RC
  End	
GO

Create Proc pUpdEmployeeProjectHours
( @EmployeeID varchar(100), @ProjectID varchar(100), @Date datetime, @Hours decimal(18,2))
  AS
  Begin
    Declare @RC int = 0
    Begin Try  
   	  Begin Transaction   
	  	Update [dbo].[EmployeeProjectHours]
		Set 
			[Hours]= @Hours 			
		Where 
 			[EmployeeId] = @EmployeeID 
 			AND
			[ProjectId] = @ProjectID 
			AND
			[Date] = @Date
	  Commit Transaction		
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction			
    End Catch	
    Return @RC
  End	
GO

	-- 7a) Review everything you have so far
	Exec pUpdEmployees @EmployeeId = 3 , @EmployeeName = 'Test User 2' 
	Exec pUpdProjects @ProjectId = 103, @ProjectName = 'Test Project 2' , @ProjectDescription = 'Test Desc 2'
	Exec pUpdEmployeeProjectHours @EmployeeID = 3, @ProjectID = 102 , @Date = '1/1/2011' , @Hours = 10.5
	GO
	
	Exec pSelEmployees
	Exec pSelProjects
	Exec pSelEmployeeProjectHours
	GO

-- 8) Delete Sprocs
Create Proc pDelEmployees
( @EmployeeId int)
  AS
  Begin
    Declare @RC int = 0
    Begin Try  
	  Begin Transaction  
		Delete From [dbo].[Employees] 
		Where 
			[EmployeeId] = @EmployeeId 
	  Commit Transaction
	Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction
    End Catch	
    Return @RC
  End	
GO

Create Proc pDelProjects
( @ProjectId int)
  AS
  Begin
    Declare @RC int = 0
    Begin Try  
	  Begin Transaction    
		Delete From [dbo].[Projects]
		Where 
			[ProjectId] = @ProjectId 
	  Commit Transaction
	Set @RC = 100 -- Indicates Success			
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction
    End Catch	
    Return @RC
  End	
GO

Create Proc pDelEmployeeProjectHours
( @EmployeeID varchar(100), @ProjectID varchar(100), @Date datetime )
  AS
  Begin
    Declare @RC int = 0
    Begin Try    
	  Begin Transaction     
		Delete From [dbo].[EmployeeProjectHours]
		Where 
 			[EmployeeId] = @EmployeeId 
 			AND
			[ProjectId] = @ProjectId 
			AND
			[Date] = @Date
	  Commit Transaction		
    End Try
    Begin Catch
		Set @RC = -100 --Indicates Error
		Rollback Transaction
    End Catch	
    Return @RC
  End	
GO

	-- 8a) Review everything you have so far
	Exec pDelEmployees @EmployeeId = 3 
	Exec pDelProjects @ProjectId = 102
	Exec pDelEmployeeProjectHours @EmployeeID = 3 , @ProjectID = 102, @Date = '1/1/2011'
	GO
	
	Exec pSelEmployees
	Exec pSelProjects
	Exec pSelEmployeeProjectHours
	GO

/*

SELECT 
 C.name	
--,C.column_id	
--,C.system_type_id	
,T.Name
,C.max_length	
,C.precision	
,C.scale	
,C.is_nullable	
,C.is_identity
FROM Sys.Columns as C
JOIN Sys.types as T
  ON C.system_type_id = T.system_type_id
WHERE [object_ID] In (Select [ID] from SysObjects Where xType = 'u')
AND T.NAME != 'sysname'
ORDER BY C.[object_id], C.column_id

*/