USE PatientAppointmentsDB_AKrinsky;


--report view #1 Patients and their Doctors
DROP VIEW IF EXISTS vPatientsDoctors;
GO
CREATE VIEW vPatientsDoctors
		As
            SELECT  CONCAT(PatientFirstName, ' ', PatientLastName) as PatientName, 
            CONCAT(DoctorFirstName, ' ', DoctorLastName) as DoctorName
            FROM PatientAppointmentsDB_AKrinsky.dbo.Patients as P
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Appointments as A
                ON P.PatientID = A.AppointmentPatientID
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Doctors as D 
                ON D.DoctorID = A.AppointmentDoctorID
            
GO

select * from vPatientsDoctors;
go
--creating reporting view ClinicsDoctors
DROP VIEW IF EXISTS vPatientClinicLocations;
GO
CREATE VIEW vPatientClinicLocations
		As
            SELECT CONCAT(PatientFirstName, ' ', PatientLastName) as PatientName,
            CONCAT(PatientCity, ', ', PatientState) as PatientLocation,
            ClinicName,
            CONVERT(VARCHAR(100), AppointmentDateTime, 100) as AppointmentTime
            FROM PatientAppointmentsDB_AKrinsky.dbo.Clinics as C
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Appointments as A
                ON C.ClinicID = A.AppointmentClinicID
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Patients as P 
                ON P.PatientID = A.AppointmentDoctorID
            
            
GO

select * from vPatientClinicLocations;

--creating view AppointmentTimes
DROP VIEW IF EXISTS vAppointmentTimes;
GO
CREATE VIEW vAppointmentTimes
		As
            SELECT CONCAT(PatientFirstName, ' ', PatientLastName) as PatientName,
            ClinicName,
            SUBSTRING(CONVERT(VARCHAR(100), AppointmentDateTime, 100), 0, 4) as AppointmentMonth,
            CONCAT(DoctorFirstName, ' ', DoctorLastName) as DoctorName
            FROM PatientAppointmentsDB_AKrinsky.dbo.Clinics as C
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Appointments as A
                ON C.ClinicID = A.AppointmentClinicID
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Doctors as D 
                ON D.DoctorID = A.AppointmentDoctorID
            JOIN PatientAppointmentsDB_AKrinsky.dbo.Patients as P 
                ON P.PatientID = A.AppointmentPatientID
            
GO

SELECT * from vAppointmentTimes;