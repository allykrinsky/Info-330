--**********************************************************************************************--
-- Title: Assigment08 - Milestone 02
-- Author: AKrinsky
-- Desc: This file demonstrates how to design and create; 
--       tables, constraints, views, stored procedures, and permissions
-- Change Log: When,Who,What
-- 2020-03-03,AKrinsky,Created File
--***********************************************************************************************--
BEGIN TRY
	USE Master;
	IF EXISTS(SELECT Name FROM SysDatabases WHERE Name = 'PatientAppointmentsDB_AKrinsky')
	 BEGIN 
	  	ALTER DATABASE [PatientAppointmentsDB_AKrinsky] SET Single_user With Rollback Immediate;
		DROP DATABASE  PatientAppointmentsDB_AKrinsky;
	 END
	CREATE DATABASE  PatientAppointmentsDB_AKrinsky;
END TRY
BEGIN CATCH
	PRINT Error_Number();
END CATCH
GO
USE PatientAppointmentsDB_AKrinsky;
CREATE USER [WebUser] FOR LOGIN [webuser] WITH DEFAULT_SCHEMA=[dbo]

--Creating Tables
CREATE TABLE Clinics(
    ClinicID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    ClinicName NVARCHAR(100) UNIQUE NOT NULL ,
    ClinicPhoneNumber NVARCHAR(100) NOT NULL,
    ClinicAddress NVARCHAR(100) NOT NULL,
    ClinicCity NVARCHAR(100) NOT NULL,
    ClinicState NCHAR(100) NOT NULL,
    ClinicZipCode NVARCHAR(100) NOT NULL

)

CREATE TABLE Patients(
    PatientID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    PatientFirstName NVARCHAR(100) NOT NULL,
    PatientLastName NVARCHAR(100) NOT NULL,
    PatientPhoneNumber NVARCHAR(100) NOT NULL,
    PatientAddress NVARCHAR(100) NOT NULL,
    PatientCity NVARCHAR(100) NOT NULL,
    PatientState NCHAR(100) NOT NULL,
    PatientZipCode NVARCHAR(100) NOT NULL

)

CREATE TABLE Doctors(
    DoctorID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    DoctorFirstName NVARCHAR(100) NOT NULL,
    DoctorLastName NVARCHAR(100) NOT NULL,
    DoctorPhoneNumber NVARCHAR(100) NOT NULL,
    DoctorAddress NVARCHAR(100) NOT NULL,
    DoctorCity NVARCHAR(100) NOT NULL,
    DoctorState NCHAR(100) NOT NULL,
    DoctorZipCode NVARCHAR(100) NOT NULL
)

CREATE TABLE Appointments(
    AppointmentID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    AppointmentDateTime DATETIME NOT NULL,
    AppointmentPatientID int NOT NULL,
    AppointmentDoctorID int NOT NULL,
    AppointmentClinicID int NOT NULL
)


--Add Check Constraints
ALTER TABLE Clinics
	Add CONSTRAINT chClinicPhoneNumber
		CHECK(ClinicPhoneNumber LIKE '([0-9][0-9][0-9])-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Clinics
	Add CONSTRAINT chClinicZipCode
		CHECK(
			ClinicZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR
 			ClinicZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' 
		);
GO

ALTER TABLE Patients
	Add CONSTRAINT chPatientPhoneNumber
		CHECK(PatientPhoneNumber LIKE '([0-9][0-9][0-9])-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Patients
	Add CONSTRAINT chPatientZipCode
		CHECK(
			PatientZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR
 			PatientZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' 
		);
GO

ALTER TABLE Doctors
	Add CONSTRAINT chDoctorPhoneNumber
		CHECK(DoctorPhoneNumber LIKE '([0-9][0-9][0-9])-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Doctors
	Add CONSTRAINT chDoctorZipCode
		CHECK(
			DoctorZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR
 			DoctorZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' 
		);
GO

Alter TABLE Appointments
	Add CONSTRAINT FK_Patients
		Foreign Key (AppointmentPatientID) References Patients(PatientID);

Alter TABLE Appointments
	Add CONSTRAINT FK_Doctors
		Foreign Key (AppointmentDoctorID) References Doctors(DoctorID);

Alter TABLE Appointments
	Add CONSTRAINT FK_Clinics
		Foreign Key (AppointmentClinicID) References Clinics(ClinicID);

--Creating Views
DROP VIEW IF EXISTS vClinics;
GO
CREATE VIEW vClinics
		As
            SELECT  ClinicID,
                    ClinicName,
                    ClinicPhoneNumber,
                    ClinicAddress,
                    ClinicCity,
                    ClinicState,
                    ClinicZipCode

            FROM PatientAppointmentsDB_AKrinsky.dbo.Clinics
GO

DROP VIEW IF EXISTS vPatients;
GO
CREATE VIEW vPatients
		As
            SELECT  PatientID,
                    PatientFirstName,
                    PatientLastName,
                    PatientPhoneNumber,
                    PatientAddress,
                    PatientCity,
                    PatientState,
                    PatientZipCode

            FROM PatientAppointmentsDB_AKrinsky.dbo.Patients
GO


DROP VIEW IF EXISTS vDoctors;
GO
CREATE VIEW vDoctors
		As
            SELECT  DoctorID,
                    DoctorFirstName,
                    DoctorLastName,
                    DoctorPhoneNumber,
                    DoctorAddress,
                    DoctorCity,
                    DoctorState,
                    DoctorZipCode

            FROM PatientAppointmentsDB_AKrinsky.dbo.Doctors
GO

DROP VIEW IF EXISTS vAppointments;
GO
CREATE VIEW vAppointments
		As
            SELECT  AppointmentID,
                    AppointmentDateTime,
                    AppointmentPatientID,
                    AppointmentDoctorID,
                    AppointmentClinicID

            FROM PatientAppointmentsDB_AKrinsky.dbo.Appointments
GO

--reporting view

DROP VIEW IF EXISTS vAppointmentsByPatientsDoctorsAndClinics;
GO
CREATE VIEW vAppointmentsByPatientsDoctorsAndClinics
		As
            SELECT  AppointmentID,
            		Format(AppointmentDateTime, 'MM/dd/yyyy') as AppointmentDate,
                    CONVERT(DATETIME, AppointmentDateTime, 0) as AppointmentTime, --this might be wrong
                    P.PatientID,
                    CONCAT(PatientFirstName, ' ', PatientLastName) as PatientName, 
                    PatientPhoneNumber,
                    PatientAddress,
                    PatientCity,
                    PatientState,
                    PatientZipCode,
                    D.DoctorID,
                    CONCAT(DoctorFirstName, ' ', DoctorLastName) as DoctorName, 
                    DoctorPhoneNumber,
                    DoctorAddress,
                    DoctorCity,
                    DoctorState,
                    DoctorZipCode,
                    C.ClinicID,
                    ClinicName,
                    ClinicPhoneNumber,
                    ClinicAddress,
                    ClinicCity,
                    ClinicState,
                    ClinicZipCode
            FROM PatientAppointmentsDB_AKrinsky.dbo.Appointments as A
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Patients as P
                ON P.PatientID = A.AppointmentPatientID
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Clinics as C
                ON C.ClinicID = A.AppointmentClinicID
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Doctors as D
                ON D.DoctorID = A.AppointmentDoctorID
GO

--Create Stored Procedures

--Clinics
GO
CREATE PROC pInsClinics (
	@ClinicName NVARCHAR(100),
    @ClinicPhoneNumber NVARCHAR(100),
    @ClinicAddress NVARCHAR(100),
    @ClinicCity NVARCHAR(100),
    @ClinicState NCHAR(100),
    @ClinicZipCode NVARCHAR(100)
	)
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc Clinics
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Clinics (
        ClinicName,
        ClinicPhoneNumber,
        ClinicAddress,
        ClinicCity,
        ClinicState,
        ClinicZipCode
	)
      Values(
		@ClinicName,
        @ClinicPhoneNumber,
        @ClinicAddress,
        @ClinicCity,
        @ClinicState,
        @ClinicZipCode
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

GO
CREATE PROC pUpdClinics (
    @ClinicID int,
	@ClinicName NVARCHAR(100),
    @ClinicPhoneNumber NVARCHAR(100),
    @ClinicAddress NVARCHAR(100),
    @ClinicCity NVARCHAR(100),
    @ClinicState NCHAR(100),
    @ClinicZipCode NVARCHAR(100)
	)
AS
/* Author: <AKrinksy>
** Desc: Create Update Proc Clinics
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    UPDATE Clinics 
        SET ClinicName = @ClinicName,
        ClinicPhoneNumber = @ClinicPhoneNumber,
        ClinicAddress =@ClinicAddress,
        ClinicCity = @ClinicCity,
        ClinicState = @ClinicState,
        ClinicZipCode = @ClinicZipCode
	WHERE ClinicID = @ClinicID;
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

CREATE PROC pDelClinics (@ClinicID INT)
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
          FROM Clinics
            WHERE ClinicID = @ClinicID
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

--Patients
GO
CREATE PROC pInsPatients (
    @PatientFirstName NVARCHAR(100),
    @PatientLastName NVARCHAR(100),
    @PatientPhoneNumber NVARCHAR(100),
    @PatientAddress NVARCHAR(100),
    @PatientCity NVARCHAR(100),
    @PatientState NCHAR(100),
    @PatientZipCode NVARCHAR(100)
	)
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc Patients
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Patients (
        PatientFirstName,
        PatientLastName,
        PatientPhoneNumber,
        PatientAddress,
        PatientCity,
        PatientState,
        PatientZipCode
	)
      Values(
		@PatientFirstName,
        @PatientLastName,
        @PatientPhoneNumber,
        @PatientAddress,
        @PatientCity,
        @PatientState,
        @PatientZipCode
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

GO
CREATE PROC pUpdPatients (
    @PatientID int,
    @PatientFirstName NVARCHAR(100),
    @PatientLastName NVARCHAR(100),
    @PatientPhoneNumber NVARCHAR(100),
    @PatientAddress NVARCHAR(100),
    @PatientCity NVARCHAR(100),
    @PatientState NCHAR(100),
    @PatientZipCode NVARCHAR(100)
)
AS
/* Author: <AKrinksy>
** Desc: Create Update Proc Clinics
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    UPDATE Patients 
        SET PatientFirstName = @PatientFirstName,
        PatientLastName = @PatientLastName,
        PatientPhoneNumber = @PatientPhoneNumber,
        PatientAddress = @PatientAddress,
        PatientCity = @PatientCity,
        PatientState = @PatientCity,
        PatientZipCode = @PatientZipCode 
	WHERE PatientID = @PatientID;
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

CREATE PROC pDelPatients (@PatientID INT)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc Patients
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Patients
            WHERE PatientID = @PatientID
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

--Doctors
GO
CREATE PROC pInsDoctors (
    @DoctorFirstName NVARCHAR(100),
    @DoctorLastName NVARCHAR(100),
    @DoctorPhoneNumber NVARCHAR(100),
    @DoctorAddress NVARCHAR(100),
    @DoctorCity NVARCHAR(100),
    @DoctorState NVARCHAR(100),
    @DoctorZipCode NVARCHAR(100)
	)
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc Doctors
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Doctors (
        DoctorFirstName,
        DoctorLastName,
        DoctorPhoneNumber,
        DoctorAddress,
        DoctorCity,
        DoctorState,
        DoctorZipCode
	)
      Values(
		@DoctorFirstName,
        @DoctorLastName,
        @DoctorPhoneNumber,
        @DoctorAddress,
        @DoctorCity,
        @DoctorState,
        @DoctorZipCode
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

GO
CREATE PROC pUpdDoctors (
    @DoctorID int,
    @DoctorFirstName NVARCHAR(100),
    @DoctorLastName NVARCHAR(100),
    @DoctorPhoneNumber NVARCHAR(100),
    @DoctorAddress NVARCHAR(100),
    @DoctorCity NVARCHAR(100),
    @DoctorState NVARCHAR(100),
    @DoctorZipCode NVARCHAR(100)
)
AS
/* Author: <AKrinksy>
** Desc: Create Update Proc Doctors
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    UPDATE Doctors 
        SET DoctorFirstName = @DoctorFirstName,
        DoctorLastName = @DoctorLastName,
        DoctorPhoneNumber = @DoctorPhoneNumber,
        DoctorAddress = @DoctorAddress,
        DoctorCity = @DoctorCity,
        DoctorState = @DoctorState,
        DoctorZipCode = @DoctorZipCode
	WHERE DoctorID = @DoctorID;
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

CREATE PROC pDelDoctors (@DoctorID INT)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc Doctors
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Doctors
            WHERE DoctorID = @DoctorID
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

--Appointments
GO
CREATE PROC pInsAppointments (
    @AppointmentDateTime DATETIME,
    @AppointmentPatientID int,
    @AppointmentDoctorID int ,
    @AppointmentClinicID int
	)
AS
/* Author: <AKrinksy>
** Desc: Create Insert Proc Appointments
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    INSERT INTO dbo.Appointments (
        AppointmentDateTime,
        AppointmentPatientID,
        AppointmentDoctorID,
        AppointmentClinicID
	)
      Values(
		@AppointmentDateTime,
        @AppointmentPatientID,
        @AppointmentDoctorID,
        @AppointmentClinicID
    )
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

GO
CREATE PROC pUpdAppointments (
    @AppointmentID int,
    @AppointmentDateTime DATETIME,
    @AppointmentPatientID int,
    @AppointmentDoctorID int,
    @AppointmentClinicID int
)
AS
/* Author: <AKrinksy>
** Desc: Create Update Proc Appointments
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
 BEGIN
  DECLARE @RC int = 0;
  BEGIN Try
   BEGIN TRAN
    UPDATE Appointments 
        SET AppointmentDateTime =  @AppointmentDateTime,
            AppointmentPatientID = @AppointmentPatientID,
            AppointmentDoctorID = @AppointmentDoctorID,
            AppointmentClinicID = @AppointmentClinicID
	WHERE AppointmentID = @AppointmentID;
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

CREATE PROC pDelAppointment (@AppointmentID INT)
AS
/* Author: <AKrinksy>
** Desc: Create Delete Proc Patients
** Change Log: When,Who,What
** <2020-03-03>,<AKrinksy>,Created stored procedure.
*/
  BEGIN
    DECLARE @RC int = 0;
    BEGIN TRY
      BEGIN TRAN
        DELETE
          FROM Appointments
            WHERE AppointmentID = @AppointmentID
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

--Setting Permissions

--tables
Deny Select, Insert, Update, Delete On Clinics To PUBLIC; 
Deny Select, Insert, Update, Delete On Patients To PUBLIC; 
Deny Select, Insert, Update, Delete On Doctors To PUBLIC; 
Deny Select, Insert, Update, Delete On Appointments To PUBLIC;

--views
Grant Select On vClinics To webuser;
Grant Select On vDoctors To webuser;
Grant Select On vPatients To webuser;
Grant Select On vAppointments To webuser;
Grant Select On vAppointmentsByPatientsDoctorsAndClinics To webuser;

--sprocs
Grant Execute On pInsClinics To webuser;
Grant Execute On pUpdClinics To webuser;
Grant Execute On pDelClinics To webuser;
Grant Execute On pInsPatients To webuser;
Grant Execute On pUpdPatients To webuser;
Grant Execute On pDelPatients To webuser;
Grant Execute On pInsDoctors To webuser;
Grant Execute On pUpdDoctors To webuser;
Grant Execute On pDelDoctors To webuser;
Grant Execute On pInsAppointments To webuser;
Grant Execute On pUpdAppointments To webuser;
Grant Execute On pDelAppointment To webuser;

--Testing Sprocs and Views
GO
--Test Inserts
--clinics
DECLARE @Status int;
SELECT * FROM vClinics;
EXEC @Status = pInsClinics
        @ClinicName = 'Seattle Clinic',
        @ClinicPhoneNumber = '(206)-123-4567',
        @ClinicAddress = '123 Main St.',
        @ClinicCity = 'Seattle',
        @ClinicState = 'WA',
        @ClinicZipCode = '98105';
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vClinics Where ClinicID = @@IDENTITY;

--patients
SELECT * FROM vPatients;
EXEC @Status = pInsPatients
        @PatientFirstName = 'Emily',
        @PatientLastName = 'Johnson',
        @PatientPhoneNumber = '(206)-999-1111',
        @PatientAddress = '345 Second Street',
        @PatientCity = 'Seattle',
        @PatientState = 'WA',
        @PatientZipCode = '98105';
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vPatients Where PatientID = @@IDENTITY;

--doctors
SELECT * FROM vDoctors;
EXEC @Status = pInsDoctors
		@DoctorFirstName = 'Mike',
        @DoctorLastName = 'Bell',
        @DoctorPhoneNumber = '(206)-345-7987',
        @DoctorAddress = '875 Pine Ave',
        @DoctorCity = 'Seattle',
        @DoctorState = 'WA',
        @DoctorZipCode = '98103';
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vDoctors Where DoctorID = @@IDENTITY;

--appointments
SELECT * FROM vAppointments;
EXEC @Status = pInsAppointments
        @AppointmentDateTime = '20200305 11:30:00',
        @AppointmentPatientID = 1,
        @AppointmentDoctorID = 1 ,
        @AppointmentClinicID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Insert was sucessful!'
  WHEN -1 THEN 'Insert Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vAppointments Where AppointmentID = @@IDENTITY;

GO 
--test updates
--clinics
DECLARE @Status int;
SELECT * FROM vClinics;
EXEC @Status = pUpdClinics
        @ClinicID = @@IDENTITY,
        @ClinicName = 'Seattle Clinic',
        @ClinicPhoneNumber = '(206)-123-4567',
        @ClinicAddress = '124 Main St.',
        @ClinicCity = 'Seattle',
        @ClinicState = 'WA',
        @ClinicZipCode = '98105';
SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vClinics Where ClinicID = @@IDENTITY;

--patients
SELECT * FROM vPatients;
EXEC @Status = pUpdPatients
        @PatientID = @@IDENTITY,
        @PatientFirstName = 'Emily',
        @PatientLastName = 'Johnson',
        @PatientPhoneNumber = '(206)-999-1112',
        @PatientAddress = '345 Second Street',
        @PatientCity = 'Seattle',
        @PatientState = 'WA',
        @PatientZipCode = '98105';

SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vPatients Where PatientID = @@IDENTITY;

--doctor
SELECT * FROM vDoctors;
EXEC @Status = pUpdDoctors
        @DoctorID = @@IDENTITY,
		@DoctorFirstName = 'Mike',
        @DoctorLastName = 'Bell',
        @DoctorPhoneNumber = '(206)-345-7987',
        @DoctorAddress = '875 Pine Ave',
        @DoctorCity = 'Seattle',
        @DoctorState = 'WA',
        @DoctorZipCode = '98105';

SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vDoctors Where DoctorID = @@IDENTITY;

--appointment
SELECT * FROM vAppointments;
EXEC @Status = pUpdAppointments
        @AppointmentID = @@IDENTITY,
        @AppointmentDateTime = '20200305 1:30:00',
        @AppointmentPatientID = 1,
        @AppointmentDoctorID = 1 ,
        @AppointmentClinicID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Update was sucessful!'
  WHEN -1 THEN 'Update Failed! Common Issues: Duplicate Data'
  END AS [Status];
Select * From vAppointments Where AppointmentID = @@IDENTITY;

GO
--Test Deletes

--appointment
DECLARE @Status int;
SELECT * FROM vAppointments;
EXEC @Status = pDelAppointment
            @AppointmentID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed! Common Issues: Foriegn Key Violation'
  END AS [Status];
Select * From vAppointments Where AppointmentID = @@IDENTITY;

--clinics

SELECT * FROM vClinics;
EXEC @Status = pDelClinics
            @ClinicID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed! Common Issues: Foriegn Key Violation'
  END AS [Status];
Select * From vClinics Where ClinicID = @@IDENTITY;

--patients
SELECT * FROM vPatients;
EXEC @Status = pDelPatients
            @PatientID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed! Common Issues: Foriegn Key Violation'
  END AS [Status];
Select * From vPatients Where PatientID = @@IDENTITY;

--doctors
SELECT * FROM vDoctors;
EXEC @Status = pDelDoctors
            @DoctorID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was sucessful!'
  WHEN -1 THEN 'Delete Failed! Common Issues: Foriegn Key Violation'
  END AS [Status];
Select * From vDoctors Where DoctorID = @@IDENTITY;

GO

