
'*** Encrypting Column Data ***'
-----------------------------------------------------------------------------------------------------------------------
-- You much create a Master Key in the database before you 
-- can create a Certificate
Create Certificate demoCert with subject = 'demo1' -- You will get an error!
Go

Select * from sys.Symmetric_keys 
Go

Create Master Key Encryption By Password = 'P@ssw0rd'
Go

Select * from sys.Symmetric_keys 
Go

-- Now this will work
Create Certificate demoCert 
	with subject = 'demo1' 
Go

Select * From sys.certificates
Go

Create Symmetric Key DemoSKey 
	with Algorithm = DES
	Encryption By Certificate demoCert
Go

-- Now see if the Certificate was added.
Select * from sys.Symmetric_keys 
Go

-- You can get the GUID for the Key with this command
Select Key_Guid('DemoSKey')
Go 

-- Create a table to test this on.
-- Note: Only types nvarchar, char, varchar, binary, varbinary, or nchar 
-- can be encrypted with a key.
Create Table DemoTable 
(	Id int, 
	AccountNumber int,  
	strAccountNumber nvarchar(4000), 
	name varBINARY(4000))


-- Before using the Key you need to OPEN it using
-- the Certificate the Key was made with.
Open Symmetric Key DemoSKey Decryption by Certificate DemoCert
Go

Insert into DemoTable( Id , AccountNumber , strAccountNumber,name )
Values 
(	100,
	EncryptByKey( Key_Guid('DemoSKey'), '4455'), -- Even Int must be added as a string
	EncryptByKey( Key_Guid('DemoSKey'), '4455'),
	EncryptByKey( Key_Guid('DemoSKey'), 'Bob Smith')
)
Go

-- Note the the actual data cannot be seen now
Select * From DemoTable
Go

-- Before using the Key you need to OPEN it using 
-- the Certificate the Key was made with.
-- It is still open on this connection so it is not required to run this again
/* Open Symmetric Key DemoSKey Decryption by Certificate DemoCert */
Go

-- The DecryptByKey function return a varbinary data type
-- with a maximum size of 8,000 bytes. So, you must convert
-- the data back to the original data type as follows:
Select 
	Id , 
	Convert( varchar(10), DecryptByKey(AccountNumber) )as [AcctNo], '<- error'
	Convert( varchar(10), DecryptByKey(strAccountNumber) )as [str AcctNo], 
	Convert( varchar(50), DecryptByKey(Name))  as [Name]
From DemoTable

-- Even trying to convert the integer over to Varchar first will not 
-- fix this issue
Select 
	Id , 
	Convert( int, DecryptByKey(Cast(AccountNumber as varchar(10)))), 
	Convert( varchar(10), DecryptByKey(strAccountNumber) )as [str AcctNo], 
	Convert( varchar(50), DecryptByKey(Name))  
From DemoTable

