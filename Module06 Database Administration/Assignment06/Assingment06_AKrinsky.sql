--**********************************************************************************************--
-- Title: Assigment06 - Midterm
-- Author: AKrinsky
-- Desc: This file demonstrates how to design and create; 
--       tables, constraints, views, stored procedures, and permissions
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--***********************************************************************************************--
BEGIN TRY
	USE Master;
	IF EXISTS(SELECT Name FROM SysDatabases WHERE Name = 'Assignment06DB_AKrinsky')
	 BEGIN 
	  	ALTER DATABASE [Assignment06DB_AKrinsky] SET Single_user With Rollback Immediate;
		DROP DATABASE  Assignment06DB_AKrinsky;
	 END
	CREATE DATABASE  Assignment06DB_AKrinsky;
END TRY
BEGIN CATCH
	PRINT Error_Number();
END CATCH
GO
USE Assignment06DB_AKrinsky;
CREATE USER [WebUser] FOR LOGIN [webuser] WITH DEFAULT_SCHEMA=[dbo]

-- Create Tables (Module 01)-- 

--Create students table and view
CREATE TABLE Students(
	[StudentID] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[StudentNumber] NVARCHAR(100) UNIQUE NOT NULL,
	[StudentFirstName] NVARCHAR(100) NOT NULL,
	[StudentLastName] NVARCHAR(100) NOT NULL,
	[StudentEmail] NVARCHAR(100) UNIQUE NOT NULL,
	[StudentPhone] NVARCHAR(100) NULL,
	[StudentAddress1] NVARCHAR(100) NOT NULL,
	[StudentAddress2] NVARCHAR(100) NULL ,
	[StudentCity] NVARCHAR(100)NOT NULL ,
	[StudentStateCode] NVARCHAR(100) NOT NULL ,
	[StudentZipCode] NVARCHAR(100) NOT NULL 		
)


--Create Course table 
CREATE TABLE Courses(
	[CourseID] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[CourseName] NVARCHAR(100) UNIQUE NOT NULL,
	[CourseStartDate] DATE NULL,
	[CourseEndDate] DATE NULL ,
	[CourseStartTime] TIME NULL,
	[CourseEndTime] TIME NULL,
	[CourseWeekDays] NVARCHAR(100) NULL,
	[CourseCurrentPrice] MONEY NULL
)

--Create Enrollments table 
CREATE TABLE Enrollments(
	[EnrollmentID] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[StudentID] INT NOT NULL, 
	[CourseID] INT NOT NULL, 
	[EnrollmentDateTime] DATETIME Default GetDate() NOT NULL,
	[EnrollmentPrice] MONEY NOT NULL, 

)

-- Add Constraints (Module 02)
ALTER TABLE Students
	Add CONSTRAINT chStudentPhone
		CHECK(StudentPhone LIKE '([0-9][0-9][0-9])-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Students
	Add CONSTRAINT chStudentZip
		CHECK(
			StudentZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR
 			StudentZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' 
		);
GO

ALTER TABLE Courses
	Add CONSTRAINT chCourseDate
		CHECK(CourseEndDate > CourseStartDate);
GO

ALTER TABLE Courses
	Add CONSTRAINT chCourseTime
		CHECK(CourseEndTime > CourseStartTime);
GO

DROP FUNCTION IF EXISTS dbo.CheckFunction;
Go
CREATE FUNCTION dbo.CheckFunction(@CourseID INT)
RETURNS DATE
AS BEGIN
    RETURN (SELECT CourseStartDate FROM Courses WHERE CourseID = @CourseID)
End
GO

ALTER TABLE Enrollments
	Add CONSTRAINT chEnrollDate
		CHECK(EnrollmentDateTime < dbo.CheckFunction(CourseID));

Alter TABLE Enrollments
	Add CONSTRAINT FK_Students
		Foreign Key (StudentID) References Students(StudentID);

ALTER TABLE Enrollments
	Add CONSTRAINT FK_Courses
		Foreign Key (CourseID) References Courses(CourseID);
-- Add Views (Module 03 and 04) -- 
DROP VIEW IF EXISTS vStudents;
GO
CREATE VIEW vStudents
		As
            SELECT  StudentID,
					StudentNumber,
					StudentFirstName, 
					StudentLastName,
					StudentEmail,
					StudentPhone,
					StudentAddress1,
					StudentAddress2,
					StudentCity,
					StudentStateCode,
					StudentZipCode

            FROM Assignment06DB_AKrinsky.dbo.Students
GO

DROP VIEW IF EXISTS vCourses;
GO
CREATE VIEW vCourses
		As
            SELECT  [CourseID],
				[CourseName],
				[CourseStartDate],
				[CourseEndDate],
				Convert(varchar, CourseStartTime, 0) as [CourseStartTime],
				Convert(varchar, CourseEndTime, 0) as [CourseEndTime],
				[CourseWeekDays],
				Format([CourseCurrentPrice], 'N', 'en-US') as [CourseCurrentPrice]
            FROM Assignment06DB_AKrinsky.dbo.Courses
GO

DROP VIEW IF EXISTS vEnrollments;
GO
CREATE VIEW vEnrollments
		As
            SELECT 
			 	[EnrollmentID],
				[StudentID],
				[CourseID],
				Convert(varchar, EnrollmentDateTime , 0)  as [EnrollmentDateTime],
				Format([EnrollmentPrice], 'N', 'en-US')	as [EnrollmentPrice]
            FROM Assignment06DB_AKrinsky.dbo.Enrollments
GO

--create reporting view 

DROP VIEW IF EXISTS vReporting;
GO
CREATE VIEW vReporting
	AS
		SELECT
			CourseName,
			CONCAT(Format(CourseStartDate, 'MM/dd/yyyy'),' to ', FORMAT(CourseEndDate, 'MM/dd/yyyy')) as Dates,
			Convert(varchar, CourseStartTime, 0) as [Start],
			Convert(varchar, CourseEndTime, 0) as [End],
			CourseWeekDays as [Days],
			Format([CourseCurrentPrice], 'N', 'en-US') as [Price],
			CONCAT(StudentFirstName, ' ', StudentLastName) as [Name],
			CONCAT(SUBSTRING(StudentFirstName, 1, 1),'-', StudentLastName,'-', StudentNumber) as [Number],
			StudentEmail as Email,
			StudentPhone as Phone,
			CONCAT(StudentAddress1, ' ', StudentCity, ', ',StudentStateCode, ', ', StudentZipCode) as [Address],
			Format(EnrollmentDateTime, 'MM/dd/yyyy') as [Signup Date],
			Format([EnrollmentPrice], 'N', 'en-US')	as Paid
		FROM Assignment06DB_AKrinsky.dbo.Students as S
		JOIN Assignment06DB_AKrinsky.dbo.Enrollments as E
			ON S.StudentID = E.StudentID
		JOIN Assignment06DB_AKrinsky.dbo.Courses as C
			ON C.CourseID = E.CourseID
GO

SELECT * FROM vReporting;

-- Add Stored Procedures (Module 04 and 05) --

--STUDENTS
GO
CREATE PROC pInsStudents (
	@StudentNumber INT, 
	@StudentFirstName NVARCHAR(100),
	@StudentLastName NVARCHAR(100),
	@StudentEmail  NVARCHAR(100),
	@StudentPhone  NVARCHAR(100),
	@StudentAddress1  NVARCHAR(100),
	@StudentAddress2  NVARCHAR(100),
	@StudentCity  NVARCHAR(100),
	@StudentStateCode  NVARCHAR(100),
	@StudentZipCode  NVARCHAR(100)
	)
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc Students
** Change Log: When,Who,What
** <2020-02-18>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Students (
		StudentNumber,
		StudentFirstName, 
		StudentLastName,
		StudentEmail,
		StudentPhone,
		StudentAddress1,
		StudentAddress2,
		StudentCity,
		StudentStateCode,
		StudentZipCode
	)
      Values(
			@StudentNumber,
			@StudentFirstName, 
			@StudentLastName,
			@StudentEmail,
			@StudentPhone,
			@StudentAddress1,
			@StudentAddress2,
			@StudentCity,
			@StudentStateCode,
			@StudentZipCode
		);
   COMMIT TRAN
   SET @RC = +1
  END Try
  BEGIN Catch
   If(@@Trancount > 0) Rollback TRAN
   Print Error_Message()
   SET @RC = -1
  END Catch
  Return @RC;
 END
GO

CREATE Proc pUpdStudents (
	@StudentID INT,
	@StudentNumber INT, 
	@StudentFirstName NVARCHAR(100),
	@StudentLastName NVARCHAR(100),
	@StudentEmail  NVARCHAR(100),
	@StudentPhone  NVARCHAR(100),
	@StudentAddress1  NVARCHAR(100),
	@StudentAddress2  NVARCHAR(100),
	@StudentCity  NVARCHAR(100),
	@StudentStateCode  NVARCHAR(100),
	@StudentZipCode  NVARCHAR(100)
)
  /* Author: <AKrinksy>
  ** Desc: Create Update Proc Students
  ** Change Log: When,Who,What
  ** <2020-02-18>,<AKrinksy>,Created stored procedure.
  */
As
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        Update Students
          SET StudentNumber = @StudentNumber,
			StudentFirstName = @StudentFirstName, 
			StudentLastName = @StudentLastName,
			StudentEmail = @StudentCity,
			StudentPhone = @StudentPhone,
			StudentAddress1 = @StudentAddress1,
			StudentAddress2 = @StudentAddress2,
			StudentCity = @StudentCity,
			StudentStateCode = @StudentStateCode,
			StudentZipCode = @StudentZipCode
          WHERE StudentID = @StudentID
    COMMIT TRAN
    SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

CREATE PROC pDelStudents (@StudentID INT)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc Students
** Change Log: When,Who,What
** <2020-02-18>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Students
            WHERE StudentID = @StudentID
      COMMIT TRAN
      SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

--Courses
GO
CREATE PROC pInsCourses (
	@CourseName NVARCHAR(100),
	@CourseStartDate DATE,
	@CourseEndDate DATE,
	@CourseStartTime TIME,
	@CourseEndTime TIME,
	@CourseWeekDays NVARCHAR(100),
	@CourseCurrentPrice MONEY
	)
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc Courses
** Change Log: When,Who,What
** <2020-02-18>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Courses (
		CourseName,
		CourseStartDate,
		CourseEndDate,
		CourseStartTime,
		CourseEndTime,
		CourseWeekDays,
		CourseCurrentPrice	
	)
      Values(
		@CourseName,
		@CourseStartDate,
		@CourseEndDate,
		@CourseStartTime,
		@CourseEndTime,
		@CourseWeekDays,
		@CourseCurrentPrice	
		
		);
   COMMIT TRAN
   SET @RC = +1
  END Try
  BEGIN Catch
   If(@@Trancount > 0) Rollback TRAN
   Print Error_Message()
   SET @RC = -1
  END Catch
  Return @RC;
 END
GO

CREATE Proc pUpdCourses (
	@CourseID INT,
	@CourseName NVARCHAR(100),
	@CourseStartDate DATE,
	@CourseEndDate DATE,
	@CourseStartTime TIME,
	@CourseEndTime TIME,
	@CourseWeekDays NVARCHAR(100),
	@CourseCurrentPrice MONEY
)
  /* Author: <AKrinksy>
  ** Desc: Create Update Proc Courses
  ** Change Log: When,Who,What
  ** <2020-02-18>,<AKrinksy>,Created stored procedure.
  */
As
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        Update Courses
          SET CourseName = @CourseName,
			CourseStartDate = @CourseStartDate,
			CourseEndDate = @CourseEndDate,
			CourseStartTime = @CourseStartTime,
			CourseEndTime = @CourseEndTime,
			CourseWeekDays = @CourseWeekDays,
			CourseCurrentPrice = @CourseCurrentPrice
		WHERE CourseID = @CourseID
    COMMIT TRAN
    SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

CREATE PROC pDelCourses (@CourseID INT)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc Courses
** Change Log: When,Who,What
** <2020-02-18>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Courses
            WHERE CourseID = @CourseID
      COMMIT TRAN
      SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

GO
CREATE PROC pInsEnrollment (
	@StudentID INT,
	@CourseID INT,
	@EnrollmentDateTime DATE,
	@EnrollmentPrice MONEY
	)
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc Enrollments
** Change Log: When,Who,What
** <2020-02-18>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Enrollments (
 		StudentID,
		CourseID,
		EnrollmentDateTime,
		EnrollmentPrice	
	)
      Values(
 		@StudentID,
		@CourseID,
		@EnrollmentDateTime,
		@EnrollmentPrice
	);
   COMMIT TRAN
   SET @RC = +1
  END Try
  BEGIN Catch
   If(@@Trancount > 0) Rollback TRAN
   Print Error_Message()
   SET @RC = -1
  END Catch
  Return @RC;
 END
GO

CREATE Proc pUpdEnrollment (
	@EnrollmentID INT,
	@StudentID INT,
	@CourseID INT,
	@EnrollmentDateTime DATE,
	@EnrollmentPrice MONEY
)
  /* Author: <AKrinksy>
  ** Desc: Create Update Proc Enrollments
  ** Change Log: When,Who,What
  ** <2020-02-18>,<AKrinksy>,Created stored procedure.
  */
As
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        Update Enrollments
          SET 
			StudentID = @StudentID,
			CourseID = @CourseID,
			EnrollmentDateTime = @EnrollmentDateTime,
			EnrollmentPrice	= @EnrollmentPrice
		WHERE EnrollmentID = @EnrollmentID
    COMMIT TRAN
    SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

CREATE PROC pDelEnrollment (@EnrollmentID INT)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc Enrollments
** Change Log: When,Who,What
** <2020-02-18>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Enrollments
            WHERE EnrollmentID = @EnrollmentID
      COMMIT TRAN
      SET @RC = +1
    END TRY
    BEGIN CATCH
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message()
      Set @RC = -1
    End Catch
    Return @RC;
 End
GO

-- Set Permissions (Module 06) --

--allow select permissions on views
Grant Select On vStudents To webuser;
Grant Select On vCourses To webuser;
Grant Select On vEnrollments To webuser;
Grant Select On vReporting To webuser;

--allow exec permission on sproc
Grant Execute On pInsStudents To webuser;
Grant Execute On pUpdStudents To webuser;
Grant Execute On pDelStudents To webuser;
Grant Execute On pInsCourses To webuser;
Grant Execute On pUpdCourses To webuser;
Grant Execute On pDelCourses To webuser;
Grant Execute On pInsEnrollment To webuser;
Grant Execute On pUpdEnrollment To webuser;
Grant Execute On pDelEnrollment To webuser;

--deny access to tables
Deny Select, Insert, Update, Delete On Students To PUBLIC; 
Deny Select, Insert, Update, Delete On Courses To PUBLIC; 
Deny Select, Insert, Update, Delete On Enrollments To PUBLIC; 

--< Test Views and Sprocs >-- 
--Test Insert Students
DECLARE @Status int;
SELECT * FROM vStudents;
EXEC @Status = pInsStudents
			@StudentNumber = 1, 
			@StudentFirstName = 'Bob' ,
			@StudentLastName = 'Smith',
			@StudentEmail  = 'Bsmith@HipMail.com',
			@StudentPhone  = '(206)-111-2222',
			@StudentAddress1 = '123 Main St.',
			@StudentAddress2  = NULL,
			@StudentCity = 'Seattle',
			@StudentStateCode  = 'WA',
			@StudentZipCode  ='98001-1234';
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vStudents Where StudentID = @@IDENTITY;

 
--Courses

SELECT * FROM vCourses;
EXEC @Status = pInsCourses
        @CourseName = 'SQL1 - Winter 2020',
		@CourseStartDate = '20200106',
		@CourseEndDate = '20200318',
		@CourseStartTime = '01:30:00',
		@CourseEndTime = '03:30:00',
		@CourseWeekDays = 'T-Th',
		@CourseCurrentPrice = 399
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vStudents Where StudentID = @@IDENTITY;


--Enrollment

SELECT * FROM vEnrollments;
EXEC @Status = pInsEnrollment
	@StudentID = 1,
	@CourseID = 1,
	@EnrollmentDateTime = '20190218',
	@EnrollmentPrice = '399'
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vEnrollments Where EnrollmentID = @@IDENTITY;

GO


-- Test Updates
--Students
DECLARE @Status int;
EXEC @Status = pUpdStudents
            @StudentID = @@IDENTITY,
			@StudentNumber = 1, 
			@StudentFirstName = 'Bob' ,
			@StudentLastName = 'Smith',
			@StudentEmail  = 'Bsmith@HipMail.com',
			@StudentPhone  = '(206)-111-2222',
			@StudentAddress1 = '124 Main St. ',
			@StudentAddress2  = NULL,
			@StudentCity = 'Seattle',
			@StudentStateCode  = 'WA',
			@StudentZipCode  ='98001-1234';
SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vStudents Where StudentID = @@IDENTITY;


--Courses
EXEC @Status = pUpdCourses
		@CourseID = @@IDENTITY,
        @CourseName = 'SQL1 - Winter 2020',
		@CourseStartDate = '20200105',
		@CourseEndDate = '20200318',
		@CourseStartTime = '1:30:00',
		@CourseEndTime = '03:30:00',
		@CourseWeekDays = 'T-Th',
		@CourseCurrentPrice = 399

SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vCourses Where CourseID = @@IDENTITY;

--Enrollment
EXEC @Status = pUpdEnrollment
	@EnrollmentID = @@IDENTITY,
	@StudentID = 1,
	@CourseID = 1,
	@EnrollmentDateTime = '20190218',
	@EnrollmentPrice = '499'
SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vEnrollments Where EnrollmentID = @@IDENTITY;

GO
--Test Deletes 
--Enrollment
DECLARE @Status int;
SELECT * FROM vEnrollments;
EXEC @Status = pDelEnrollment
            @EnrollmentID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed! Common Issues: Foriegn Key Violation'
  END AS [Status];
Select * From vEnrollments Where EnrollmentID = @@IDENTITY;

--Students

SELECT * FROM vStudents;
EXEC @Status = pDelStudents
            @StudentID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed! Common Issues: Foriegn Key Violation'
  END AS [Status];
Select * From vStudents Where StudentID = @@IDENTITY;

--Course
SELECT * FROM vCourses;
EXEC @Status = pDelCourses
            @CourseID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed! Common Issues: Foriegn Key Violation'
  END AS [Status];
Select * From vCourses Where CourseID = @@IDENTITY;

GO


TRUNCATE TABLE Enrollments;

ALTER TABLE Enrollments
DROP CONSTRAINT FK_Students;

ALTER TABLE Enrollments
DROP CONSTRAINT FK_Courses;

TRUNCATE TABLE Courses;
TRUNCATE TABLE Students;

Alter TABLE Enrollments
	Add CONSTRAINT FK_Students
		Foreign Key (StudentID) References Students(StudentID);

ALTER TABLE Enrollments
	Add CONSTRAINT FK_Courses
		Foreign Key (CourseID) References Courses(CourseID);


--Inserting Data

EXEC pInsStudents 
	@StudentNumber = 071,
	@StudentFirstName = 'Bob',
	@StudentLastName = 'Smith',
	@StudentEmail = 'Bsmith@HipMail.com',
	@StudentPhone = '(206)-111-2222',
	@StudentAddress1 = '123 Main St.',
	@StudentAddress2 = NULL,
	@StudentCity = 'Seattle',
	@StudentStateCode = 'WA.',
	@StudentZipCode = '98001';

EXEC pInsStudents 
	@StudentNumber = 003,
	@StudentFirstName = 'Sue',
	@StudentLastName = 'Jones',
	@StudentEmail = 'SueJones@YaYou.com',
	@StudentPhone = '(206)-231-4321',
	@StudentAddress1 = '333 1st Ave.',
	@StudentAddress2 = NULL,
	@StudentCity = 'Seattle',
	@StudentStateCode = 'WA.',
	@StudentZipCode = '98001';

EXEC pInsCourses
	@CourseName = 'SQL1 - Winter 2017',
	@CourseStartDate = '20170110',
	@CourseEndDate = '20170124',
	@CourseStartTime = '18:00:00',
	@CourseEndTime = '20:50:00',
	@CourseWeekDays = 'T',
	@CourseCurrentPrice = '399';

EXEC pInsCourses
	@CourseName = 'SQL2 - Winter 2017',
	@CourseStartDate = '20170131',
	@CourseEndDate = '20170214',
	@CourseStartTime = '18:00:00',
	@CourseEndTime = '20:50:00',
	@CourseWeekDays = 'T',
	@CourseCurrentPrice = '399';

EXEC pInsEnrollment
	@StudentID = 1, 
	@CourseID = 1,
	@EnrollmentDateTime = '20170103',
	@EnrollmentPrice = 399;

EXEC pInsEnrollment
	@StudentID = 2, 
	@CourseID = 1,
	@EnrollmentDateTime = '20161214',
	@EnrollmentPrice = 349;

EXEC pInsEnrollment
	@StudentID = 2, 
	@CourseID = 2,
	@EnrollmentDateTime = '20161214',
	@EnrollmentPrice = 399;

EXEC pInsEnrollment
	@StudentID = 1, 
	@CourseID = 2,
	@EnrollmentDateTime = '20170112',
	@EnrollmentPrice = 399; 

SELECT * FROM vStudents;
SELECT * From vCourses;
SELECT * from vEnrollments;
SELECT * FROM vReporting;

--{ IMPORTANT }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/