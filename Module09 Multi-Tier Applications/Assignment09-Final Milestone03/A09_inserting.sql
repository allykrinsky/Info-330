USE PatientAppointmentsDB_AKrinsky;

--resetting @@Identity

TRUNCATE TABLE Appointments;

ALTER TABLE Appointments
DROP CONSTRAINT FK_Clinics;

ALTER TABLE Appointments
DROP CONSTRAINT FK_Doctors;

ALTER TABLE Appointments
DROP CONSTRAINT FK_Patients;

TRUNCATE TABLE Clinics;
TRUNCATE TABLE Doctors;
TRUNCATE TABLE Patients;

Alter TABLE Appointments
	Add CONSTRAINT FK_Clinics
		Foreign Key (AppointmentClinicID) References Clinics(ClinicID);

ALTER TABLE Appointments
	Add CONSTRAINT FK_Doctors
		Foreign Key (AppointmentDoctorID) References Doctors(DoctorID);

ALTER TABLE Appointments
	Add CONSTRAINT FK_Patients
		Foreign Key (AppointmentPatientID) References Patients(PatientID);


--Inserting CLinics
EXEC pInsClinics 
    @ClinicName = 'Lakin, Jerde and Barton', 
    @ClinicPhoneNumber = '(614)-379-0163', 
    @ClinicAddress = '473 Miller Drive' , 
    @ClinicCity = 'Karis', 
    @ClinicState = 'LA',
    @ClinicZipCode = '13258';

EXEC pInsClinics 
    @ClinicName = 'Beahan-Armstrong', 
    @ClinicPhoneNumber = '(737)-337-4586', 
    @ClinicAddress = '3 Eagan Lane', 
    @ClinicCity = 'Singaparna', 
    @ClinicState = 'WA',
    @ClinicZipCode = '23412' ;  

EXEC pInsClinics 
    @ClinicName = 'Homenick and Sons', 
    @ClinicPhoneNumber = '(328)-499-5142', 
    @ClinicAddress = '6 Roxbury Terrace', 
    @ClinicCity ='Sollebrunn', 
    @ClinicState = 'MO',
    @ClinicZipCode = '43543';  

EXEC pInsClinics 
    @ClinicName = 'Ortiz-Murazik', 
    @ClinicPhoneNumber = '(873)-883-9672', 
    @ClinicAddress = '5713 Chive Trail', 
    @ClinicCity ='København', 
    @ClinicState = 'KS',
    @ClinicZipCode = '45678';

EXEC pInsClinics 
    @ClinicName = 'Sporer-Adams', 
    @ClinicPhoneNumber = '(944)-465-4005', 
    @ClinicAddress = '866 Hagan Place', 
    @ClinicCity ='Shaffa', 
    @ClinicState = 'KS',
    @ClinicZipCode = '12345';


--Inserting Doctors

EXEC pInsDoctors
    @DoctorFirstName = 'Josephine', 
    @DoctorLastName = 'Blaycock', 
    @DoctorPhoneNumber = '(417)-466-3854', 
    @DoctorAddress = '65553 Heffernan Road', 
    @DoctorCity = 'Puerto Mayor Otaño', 
    @DoctorState = 'AZ',
    @DoctorZipCode = '12123';

EXEC pInsDoctors
    @DoctorFirstName = 'Robinson', 
    @DoctorLastName = 'Joannic', 
    @DoctorPhoneNumber = '(264)-369-0884', 
    @DoctorAddress = '6692 Schurz Trail', 
    @DoctorCity = 'Rawson', 
    @DoctorState = 'NV',
    @DoctorZipCode = '91032';

EXEC pInsDoctors
    @DoctorFirstName = 'Susanetta', 
    @DoctorLastName = 'McGrayle', 
    @DoctorPhoneNumber = '(603)-952-8061', 
    @DoctorAddress = '664 7th Court', 
    @DoctorCity = 'Portsmouth', 
    @DoctorState = 'NH',
    @DoctorZipCode = '03804';

EXEC pInsDoctors
    @DoctorFirstName = 'Bryanty', 
    @DoctorLastName = 'Petrovykh', 
    @DoctorPhoneNumber = '(401)-404-0144', 
    @DoctorAddress = '18064 Heath Road', 
    @DoctorCity = 'Providence', 
    @DoctorState = 'RI',
    @DoctorZipCode = '02905';

EXEC pInsDoctors
    @DoctorFirstName = 'Yank', 
    @DoctorLastName = 'Edinburough', 
    @DoctorPhoneNumber = '(706)-435-8200', 
    @DoctorAddress = '3201 Di Loreto Center', 
    @DoctorCity = 'Columbus', 
    @DoctorState = 'GA',
    @DoctorZipCode = '31904';

EXEC pInsDoctors
    @DoctorFirstName = 'Tatiania', 
    @DoctorLastName = 'Christoffersen', 
    @DoctorPhoneNumber = '(706)-435-8200', 
    @DoctorAddress = '054 Lawn Road', 
    @DoctorCity = 'San Jose', 
    @DoctorState = 'CA',
    @DoctorZipCode = '95128';


EXEC pInsDoctors
    @DoctorFirstName = 'Andra', 
    @DoctorLastName = 'Rudyard', 
    @DoctorPhoneNumber = '(915)-409-5810', 
    @DoctorAddress = '45799 Welch Circle', 
    @DoctorCity = 'El Paso', 
    @DoctorState = 'TX',
    @DoctorZipCode = '79955';

EXEC pInsDoctors
    @DoctorFirstName = 'Rivy', 
    @DoctorLastName = 'Di Iorio', 
    @DoctorPhoneNumber = '(850)-124-7128', 
    @DoctorAddress = '5 Mayer Point', 
    @DoctorCity = 'Pensacola', 
    @DoctorState = 'FL',
    @DoctorZipCode = '32575';

EXEC pInsDoctors
    @DoctorFirstName = 'Nina', 
    @DoctorLastName = 'Plak', 
    @DoctorPhoneNumber = '(860)-605-3671', 
    @DoctorAddress = '2604 Kings Circle', 
    @DoctorCity = 'Hartford', 
    @DoctorState = 'CI',
    @DoctorZipCode = '06183';


EXEC pInsDoctors
    @DoctorFirstName = 'Arabela', 
    @DoctorLastName = 'McGeaney', 
    @DoctorPhoneNumber = '(561)-113-2657', 
    @DoctorAddress = '0 Eagan Way', 
    @DoctorCity = 'Hartford', 
    @DoctorState = 'CI',
    @DoctorZipCode = '06183';

--Inserting Patients

EXEC pInsPatients
    @PatientFirstName = 'Kaja', 
    @PatientLastName = 'Conklin', 
    @PatientPhoneNumber = '(859)-694-3549', 
    @PatientAddress = '2176 Mendota Street', 
    @PatientCity = 'Lexington',
    @PatientState = 'KY',
    @PatientZipCode = '40591';

EXEC pInsPatients
    @PatientFirstName = 'Glenden', 
    @PatientLastName = 'Wilfing', 
    @PatientPhoneNumber = '(240)-185-8966', 
    @PatientAddress = '3 Thackeray Road', 
    @PatientCity = 'Silver Spring',
    @PatientState = 'MD',
    @PatientZipCode = '20910';

EXEC pInsPatients
    @PatientFirstName = 'Valeria', 
    @PatientLastName = 'Raff', 
    @PatientPhoneNumber = '(916)-513-1267', 
    @PatientAddress = '1 Bunker Hill Street', 
    @PatientCity = 'Sacramento',
    @PatientState = 'CA',
    @PatientZipCode = '94257';

EXEC pInsPatients
    @PatientFirstName = 'Olenolin', 
    @PatientLastName = 'Raynor', 
    @PatientPhoneNumber = '(205)-578-6152', 
    @PatientAddress = '1 7th Street', 
    @PatientCity = 'Birmingham',
    @PatientState = 'AL',
    @PatientZipCode = '35210';

EXEC pInsPatients
    @PatientFirstName = 'Darb', 
    @PatientLastName = 'Guidoni', 
    @PatientPhoneNumber = '(754)-762-1750', 
    @PatientAddress = '1 7th Street', 
    @PatientCity = 'Fort Lauderdale',
    @PatientState = 'FL',
    @PatientZipCode = '33345';


EXEC pInsPatients
    @PatientFirstName = 'Fleurette', 
    @PatientLastName = 'Wayvill', 
    @PatientPhoneNumber = '(212)-378-1837', 
    @PatientAddress = '10678 Melody Junction', 
    @PatientCity = 'Jamaica',
    @PatientState = 'NY',
    @PatientZipCode = '11431';

EXEC pInsPatients
    @PatientFirstName = 'Nilson', 
    @PatientLastName = 'McInnes', 
    @PatientPhoneNumber = '(405)-652-7537', 
    @PatientAddress = '8134 Larry Hill', 
    @PatientCity = 'Oklahoma City',
    @PatientState = 'OK',
    @PatientZipCode = '73152';

EXEC pInsPatients
    @PatientFirstName = 'Jacob', 
    @PatientLastName = 'Tommasetti', 
    @PatientPhoneNumber = '(404)-220-4880', 
    @PatientAddress = '65074 Acker Junction', 
    @PatientCity = 'Atlanta',
    @PatientState = 'GA',
    @PatientZipCode = '30343';

EXEC pInsPatients
    @PatientFirstName = 'De', 
    @PatientLastName = 'Sirman', 
    @PatientPhoneNumber = '(217)-748-0628', 
    @PatientAddress = '622 Susan Trail', 
    @PatientCity = 'Springfield',
    @PatientState = 'IL',
    @PatientZipCode = '62705';

EXEC pInsPatients
    @PatientFirstName = 'Shandeigh', 
    @PatientLastName = 'Flett', 
    @PatientPhoneNumber = '(913)-245-2188', 
    @PatientAddress = '49 Nelson Road', 
    @PatientCity = 'Shawnee Mission',
    @PatientState = 'KS',
    @PatientZipCode = '66220';


--Insertting Appointments

EXEC pInsAppointments
    @AppointmentDateTime = '07/04/2019 8:30',  
    @AppointmentClinicID = '1', 
    @AppointmentDoctorID = '1', 
    @AppointmentPatientID = '1';

EXEC pInsAppointments
    @AppointmentDateTime = '10/04/2019 11:50',  
    @AppointmentClinicID = '1', 
    @AppointmentDoctorID = '2', 
    @AppointmentPatientID = '2';

EXEC pInsAppointments
    @AppointmentDateTime = '08/06/2019 8:20',  
    @AppointmentPatientID = '3', 
    @AppointmentDoctorID = '3', 
    @AppointmentClinicID = '2';

EXEC pInsAppointments
    @AppointmentDateTime = '04/12/2019 6:50',  
    @AppointmentPatientID = '4', 
    @AppointmentDoctorID = '4', 
    @AppointmentClinicID = '2';

EXEC pInsAppointments
    @AppointmentDateTime = '01/13/2020 16:10',  
    @AppointmentPatientID = '5', 
    @AppointmentDoctorID = '5', 
    @AppointmentClinicID = '3';

EXEC pInsAppointments
    @AppointmentDateTime = '08/02/2019 8:50',  
    @AppointmentPatientID = '6', 
    @AppointmentDoctorID = '6', 
    @AppointmentClinicID = '3';

EXEC pInsAppointments
    @AppointmentDateTime = '11/14/2019 16:20',  
    @AppointmentPatientID = '7', 
    @AppointmentDoctorID = '7', 
    @AppointmentClinicID = '4';

EXEC pInsAppointments
    @AppointmentDateTime = '01/05/2020 4:15',  
    @AppointmentPatientID = '8', 
    @AppointmentDoctorID = '8', 
    @AppointmentClinicID = '4';

EXEC pInsAppointments
    @AppointmentDateTime = '10/12/2019 3:20',  
    @AppointmentPatientID = '9', 
    @AppointmentDoctorID = '9', 
    @AppointmentClinicID = '5';

EXEC pInsAppointments
    @AppointmentDateTime = '05/01/2019 10:45',  
    @AppointmentPatientID = '10', 
    @AppointmentDoctorID = '10', 
    @AppointmentClinicID = '5';




