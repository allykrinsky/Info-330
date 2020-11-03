Create Database SecDB
go
use SecDB
go

SP_AddLogin 'WebUser', 'Pa$$w0rd'
Go
SP_addUser 'WebUser', 'WebUser'
Go

Select 
[My DB User Name] = USER 
,[My Login Name] =  Suser_Sname()
,[Name of DB I am connected to] =  DB_Name()
Go

Create Table Students
(StudentId int Primary Key, StudentName nvarchar(50) )

-- To a Group (Role)
Grant Select On Students To Public
Revoke Select On Students To Public
Deny Select On Students To Public

-- Or to a indivdual
Grant Select On Students To WebUser
Revoke Select On Students To WebUser

-- Open a connect as SQL User and test the combonation of perms

-- Create a role for all the users dev user accounts
CREATE ROLE [DevAppUsers] 
GO

-- Add the users to the role
EXEC sp_AddRoleMember N'DevAppUsers', N'WebUser'
Go

-- No block access DIRECTLY to the role
Deny Select On Students To DevAppUsers

-- Now create a view to allow access
Create View vStudents
AS
	Select StudentId, StudentName 
	From Students
Go

Create Proc pInsStudents
(@StudentId int, @StudentName nvarchar(50))
AS
	Insert Into Students(StudentId, StudentName)
	Values (@StudentId, @StudentName)
Go
-- now they can use the view but not the table directly
Grant Select On vStudents To DevAppUsers	
Grant Execute On pInsStudents To DevAppUsers	


-- If you need to change the table design it will 
-- normally break the appliacitons, but not if 
-- the view makes it look the same as it was

Create -- Drop
Table Students
( StudentId int Primary Key
, StudentFirstName nvarchar(50) 
, StudentLastName nvarchar(50) 
)
Deny Select On Students To DevAppUsers

-- Now change the view to make the table 
-- look as it did

Alter View vStudents
AS
	Select 
	  StudentId
	, StudentName = StudentFirstName + ' ' + StudentLastName
	From Students
Go

Alter
 Proc pInsStudents
(@StudentId int, @StudentFirstName nvarchar(50), @StudentLastName nvarchar(50))
AS
	Insert Into Students(StudentId, StudentFirstName, StudentLastName)
	Values (@StudentId, @StudentFirstName , @StudentLastName)
Go

Exec pInsStudents 
	  @StudentId = 1
	, @StudentFirstName = 'Bob'
	, @StudentLastName = 'Smith' 


