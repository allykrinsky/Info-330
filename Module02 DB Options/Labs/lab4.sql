/* sample code in the assignment */

Create Database AKrinsky_Mod2_Lab4;
GO
Use AKrinsky_Mod2_Lab4;
Go

If exists (Select Name from SysDatabaes Where name = 'AKrinsky_Mod2_Lab4')
Go
Create TABLE Employees(
    EmployeeID int Constraint pkEmployees primary key Identity(1,1),
    EmployeeName varchar(100)
)
Go
