using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Data;
using DataAccessLayer;

public interface IEmployeeRepository
{
    //Table Data
    IEnumerable<Employee> Employees { get; set; }
    int EmployeeID { get; set; }
    string EmployeeName { get; set; }

    //Transaction Processing
    int InsEmployee(string EmployeeName, out int NewRowID);
    int UpdEmployee(int EmployeeID, string EmployeeName);
    int DelEmployee(int EmployeeID);

    //Query Processing
    IEnumerable<Employee> SelEmployee(int EmployeeID);
}

public interface IProjectRepository
{
    //Table Data
    IEnumerable<Project> Projects { get; set; }
    int ProjectID { get; set; }
    string ProjectName { get; set; }
    string ProjectDescription { get; set; }

    //Transaction Processing
    int InsProject(string ProjectName, string ProjectDescription, out int NewRowID);
    int UpdProject(int ProjectID, string ProjectName, string ProjectDescription);
    int DelProject(int ProjectID);

    //Query Processing
    IEnumerable<Project> SelProject(int ProjectID);
}

public interface IEmployeeProjectHourRepository
{
    //Table Data
    IEnumerable<EmployeeProjectHour> EmployeeProjectHours { get; set; }

    int EmployeeID { get; set; }
    DateTime Date { get; set; }
    int ProjectID { get; set; }
    decimal Hours { get; set; }

    string EmployeeName { get; set; }
    string ProjectName { get; set; }


    //Transaction Processing
    int InsEmployeeProjectHour(int EmployeeID, int ProjectID, DateTime Date, decimal Hours);
    int UpdEmployeeProjectHour(int EmployeeID, int ProjectID, DateTime Date, decimal Hours);
    int DelEmployeeProjectHour(int EmployeeID, int ProjectID, DateTime Date);

    //Query Processing
    IEnumerable<EmployeeProjectHour> SelEmployeeProjectHour(int EmployeeID, int ProjectID);
}

public interface IThisYearsDateRepository
{
    //Table Data
    IEnumerable<ThisYearsDate> ThisYearsDates { get; set; }
    int DateID { get; set; }
    string DateName { get; set; }
    
    //Transaction Processing
    //Not implemented

    //Query Processing
    IEnumerable<ThisYearsDate> SelThisYearsDates();
}

public interface IValidHourEntryRepository
{
    //Table Data
    IEnumerable<ValidHourEntry> ValidHourEntries { get; set; }
    int TimePeriodID { get; set; }
    string TimePeriod { get; set; }

    //Transaction Processing
    //Not implemented

    //Query Processing
    IEnumerable<ValidHourEntry> SelValidHourEntries();
}
//