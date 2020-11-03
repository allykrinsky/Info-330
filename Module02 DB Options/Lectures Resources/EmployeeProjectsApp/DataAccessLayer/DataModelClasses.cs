using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data;
using System.Data.Entity.Core.Objects;

namespace DataAccessLayer
{
    public class Employee : IEmployeeRepository
    {
        IEnumerable<Employee> objEmployees;
        int intEmployeeID;
        string strEmployeeName;

        public IEnumerable<Employee> Employees
        {
            get
            {
                return objEmployees;
            }
            set
            {
              objEmployees = value ;
            }
        }

        public int EmployeeID
        {
            get
            {
                return intEmployeeID;
            }
            set
            {
              intEmployeeID = value ;
            }
        }

        public string EmployeeName
        {
            get
            {
                return strEmployeeName;
            }
            set
            {
              strEmployeeName = value ;
            }
        }

        public int InsEmployee(string EmployeeName, out int NewRowID)
        {
            return ADONetOption(EmployeeName, out NewRowID);
            //return EFOption(EmployeeName, out NewRowID);
        }

        #region Examples of using ADO.NET or EF
        private static int ADONetOption(string EmployeeName, out int NewRowID)
        {
            //Set up the variables
            int intRC = 0; //Used to trap the Stored Procedure's return code

            //Create a Connection object using my custom connection factory
            System.Data.SqlClient.SqlConnection objCon = new ADOConnectionFactory().Connection;

            //Set up the parameters using my custom parameter factory
            IParameterFactory objParams = new EmployeesParameterFactory(EmployeeName: EmployeeName);

            //Create and configure an ADO.NET command object 
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("", objCon);
            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeName"]);
            objCmd.Parameters.Add(objParams.Parmeters["NewRowID"]);
            objCmd.CommandType = CommandType.StoredProcedure;
            objCmd.CommandText = "pInsEmployees";

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();

                //Get the new row ID created by the table's Identity feature
                if (objParams.Parmeters["NewRowID"].Value is DBNull)
                { NewRowID = 0; } //if the insert has failed, then set this to an arbitrary number
                else { NewRowID = (int)objParams.Parmeters["NewRowID"].Value; } //else send it back as output

                //Trap or return the Stored Procedure's return code
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }

                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        private static int EFOption(string EmployeeName, out int NewRowID)
        {
            //Set up the variables
            int intRC = 0; //Used to trap the Stored Procedure's return code

            //Create a Connection object using Entity Framework (EF)
            IObjectContextAdapter Context = new EFDbContext();

            //Set up the parameters using my custom parameter factory
            IParameterFactory objParams = new EmployeesParameterFactory(EmployeeName: EmployeeName);
            //-- Change the RC parameter from ReturnValue to Output, since the EF does not support ReturnValue (Crazy!)
            objParams.Parmeters["RC"].Direction = ParameterDirection.Output;

            //Create and configure an ADO.NET command object 
            //-- Create a SQL command string
            string strSQLCode = @"Exec @RC = pInsEmployees" +
                                " @EmployeeName = '" + objParams.Parmeters["EmployeeName"] + "'" + // Don't forget the SINGLE Quotes!!!
                                ",@NewRowID = @NewRowID out;";
            //configure the command object and execute it
            try
            {
                Context.ObjectContext.ExecuteStoreCommand(strSQLCode
                                                            , objParams.Parmeters["RC"]
                                                            , objParams.Parmeters["EmployeeName"]
                                                            , objParams.Parmeters["NewRowID"]
                                                            );

                //Get the new row ID created by the table's Identity feature
                if (objParams.Parmeters["NewRowID"].Value is DBNull)
                { NewRowID = 0; } //if the insert has failed, then set this to an arbitrary number
                else { NewRowID = (int)objParams.Parmeters["NewRowID"].Value; } //else send it back as output

                //Trap or return the Stored Procedure's return code
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
            }
            catch (Exception)
            {

                throw;
            }

            return intRC;
        }
        #endregion

        public int UpdEmployee(int EmployeeID, string EmployeeName)
        {
            int intRC = 0; 
            IParameterFactory objParams = new EmployeesParameterFactory(EmployeeID: EmployeeID,EmployeeName: EmployeeName);
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pUpdEmployees", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeID"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeName"]);

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        public int DelEmployee(int EmployeeID)
        {
            int intRC = 0;
            IParameterFactory objParams = new EmployeesParameterFactory(EmployeeID: EmployeeID, EmployeeName: EmployeeName);
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pDelEmployees", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeID"]);

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        public IEnumerable<Employee> SelEmployee(int EmployeeID = -1)
        {
            int intRC = 0;
            objEmployees = new List<Employee>();

            IParameterFactory objParams = new EmployeesParameterFactory(EmployeeID: EmployeeID, EmployeeName: EmployeeName);
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pSelEmployees", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeID"]);

            try
            {
                objCmd.Connection.Open();
                System.Data.SqlClient.SqlDataReader objDR = objCmd.ExecuteReader();
                while (objDR.Read())
                {   
                    Employee objE = new Employee();
                    objE.intEmployeeID = (int)objDR["EmployeeID"];
                    objE.strEmployeeName = (string)objDR["EmployeeName"];
                    ((List<Employee>)objEmployees).Add(objE);                  
                }
                objDR.Close(); //You cannot get the return value if the reader is not closed!
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return objEmployees;
        }
    }

    public class Project: IProjectRepository
    {
        IEnumerable<Project> objProjects;
        int intProjectID;
        string strProjectName;
        string strProjectDescription;

        public IEnumerable<Project> Projects
        {
            get
            {
                return objProjects;
            }
            set
            {
                objProjects = value;
            }
        }

        public int ProjectID
        {
            get
            {
                return intProjectID;
            }
            set
            {
                intProjectID = value;
            }
        }
        public string ProjectName
        {
            get
            {
                return strProjectName;
            }
            set
            {
                strProjectName = value;
            }
        }
        public string ProjectDescription
        {
            get { return strProjectDescription; }
            set { strProjectDescription = value; }
        }

        public int InsProject(string ProjectName, string ProjectDescription, out int NewRowID)
        {
            int intRC = 0; //Used to trap the Stored Procedure's return code

            //Create a Connection object using my custom connection factory
            System.Data.SqlClient.SqlConnection objCon = new ADOConnectionFactory().Connection;

            //Set up the parameters using my custom parameter factory
            IParameterFactory objParams = new ProjectsParameterFactory(ProjectName: ProjectName, ProjectDescription: ProjectDescription);

            //Create and configure an ADO.NET command object 
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pInsProjects", objCon);
            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectName"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectDescription"]);
            objCmd.Parameters.Add(objParams.Parmeters["NewRowID"]);
            objCmd.CommandType = CommandType.StoredProcedure;

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();

                //Get the new row ID created by the table's Identity feature
                if (objParams.Parmeters["NewRowID"].Value is DBNull)
                { NewRowID = 0; } //if the insert has failed, then set this to an arbitrary number
                else { NewRowID = (int)objParams.Parmeters["NewRowID"].Value; } //else send it back as output

                //Trap or return the Stored Procedure's return code
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }

                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        public int UpdProject(int ProjectID, string ProjectName, string ProjectDescription )
        {
            int intRC = 0;
            IParameterFactory objParams = new ProjectsParameterFactory(ProjectID: ProjectID, ProjectName: ProjectName, ProjectDescription: ProjectDescription);
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pUpdProjects", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectID"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectName"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectDescription"]);

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        public int DelProject(int ProjectID)
        {
            int intRC = 0;
            IParameterFactory objParams = new ProjectsParameterFactory(ProjectID: ProjectID, ProjectName: ProjectName);
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pDelProjects", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectID"]);

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        public IEnumerable<Project> SelProject(int ProjectID = -1)
        {
            int intRC = 0;
            objProjects = new List<Project>();

            IParameterFactory objParams = new ProjectsParameterFactory(ProjectID: ProjectID, ProjectName: ProjectName);
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pSelProjects", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectID"]);

            try
            {
                objCmd.Connection.Open();
                System.Data.SqlClient.SqlDataReader objDR = objCmd.ExecuteReader();
                while (objDR.Read())
                {
                    Project objP = new Project();
                    objP.intProjectID = (int)objDR["ProjectID"];
                    objP.strProjectName = (string)objDR["ProjectName"];
                    objP.strProjectDescription = (string)objDR["ProjectDescription"];
                    ((List<Project>)objProjects).Add(objP);
                }
                objDR.Close(); //You cannot get the return value if the reader is not closed!
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return objProjects;
        }
    } //end Project

    public class EmployeeProjectHour: IEmployeeProjectHourRepository
    {
        IEnumerable<EmployeeProjectHour> objEmployeeProjectHours;
        int intEmployeeID;
        int intProjectID;
        DateTime dtDate;
        decimal decHours;
        string strEmployeeName;
        string strProjectName;

        public IEnumerable<EmployeeProjectHour> EmployeeProjectHours
        {
            get
            {
                return objEmployeeProjectHours;
            }
            set
            {
                objEmployeeProjectHours = value;
            }
        }
        public int EmployeeID
        {
            get
            {
                return intEmployeeID ;
            }
            set
            {
               intEmployeeID = value;
            }
        }
        public int ProjectID
        {
            get
            {
                return intProjectID;
            }
            set
            {
               intProjectID  = value;
            }
        }
        public DateTime Date
        {
            get
            {
                return dtDate;
            }
            set
            {
                dtDate = value;
            }
        }
        public decimal Hours
        {
            get
            {
                return decHours;
            }
            set
            {
                decHours = value;
            }
        }
        public string EmployeeName
        {
            get
            {
                return strEmployeeName;
            }
            set
            {
                strEmployeeName = value;
            }
        }
        public string ProjectName
        {
            get
            {
                return strProjectName;
            }
            set
            {
                strProjectName = value;
            }
        }


        public int InsEmployeeProjectHour(int EmployeeID, int ProjectID, DateTime Date, decimal Hours)
        {
            int intRC = 0; //Used to trap the Stored Procedure's return code

            //Create a Connection object using my custom connection factory
            System.Data.SqlClient.SqlConnection objCon = new ADOConnectionFactory().Connection;

            //Set up the parameters using my custom parameter factory
            IParameterFactory objParams = new EmployeeProjectHourParameterFactory(EmployeeID: EmployeeID, ProjectID: ProjectID, Date: Date, Hours: Hours);

            //Create and configure an ADO.NET command object 
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pInsEmployeeProjectHours", objCon);
            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeID"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectID"]);
            objCmd.Parameters.Add(objParams.Parmeters["Date"]);
            objCmd.Parameters.Add(objParams.Parmeters["Hours"]);
            //objCmd.Parameters.Add(new SqlParameter("Hours", 1));
            objCmd.CommandType = CommandType.StoredProcedure;

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();
                //Trap or return the Stored Procedure's return code
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }

                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        public int UpdEmployeeProjectHour(int EmployeeID, int ProjectID, DateTime Date, decimal Hours)
        {
            int intRC = 0; //Used to trap the Stored Procedure's return code

            //Create a Connection object using my custom connection factory
            System.Data.SqlClient.SqlConnection objCon = new ADOConnectionFactory().Connection;

            //Set up the parameters using my custom parameter factory
            IParameterFactory objParams = new EmployeeProjectHourParameterFactory(EmployeeID: EmployeeID, ProjectID: ProjectID, Date: Date, Hours: Hours);

            //Create and configure an ADO.NET command object 
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pUpdEmployeeProjectHours", objCon);
            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeID"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectID"]);
            objCmd.Parameters.Add(objParams.Parmeters["Date"]);
            objCmd.Parameters.Add(objParams.Parmeters["Hours"]);
            objCmd.CommandType = CommandType.StoredProcedure;

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();
                //intRC = (int)objParams.Parmeters["RC"].Value;
                //if (intRC < 0)
                //{ throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        public int DelEmployeeProjectHour(int EmployeeID, int ProjectID, DateTime Date)
        {
            int intRC = 0; //Used to trap the Stored Procedure's return code

            //Create a Connection object using my custom connection factory
            System.Data.SqlClient.SqlConnection objCon = new ADOConnectionFactory().Connection;

            //Set up the parameters using my custom parameter factory
            IParameterFactory objParams = new EmployeeProjectHourParameterFactory(EmployeeID: EmployeeID, ProjectID: ProjectID, Date: Date);

            //Create and configure an ADO.NET command object 
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pDelEmployeeProjectHours", objCon);
            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeID"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectID"]);
            objCmd.Parameters.Add(objParams.Parmeters["Date"]);
            objCmd.CommandType = CommandType.StoredProcedure;

            try
            {
                objCmd.Connection.Open();
                objCmd.ExecuteNonQuery();
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return intRC;
        }

        public IEnumerable<EmployeeProjectHour> SelEmployeeProjectHour(int EmployeeID = -1, int ProjectID = -1)
        {
            int intRC = 0;
            objEmployeeProjectHours = new List<EmployeeProjectHour>();

            IParameterFactory objParams = new EmployeeProjectHourParameterFactory(EmployeeID: EmployeeID, ProjectID: ProjectID);
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pSelEmployeeProjectHours", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            objCmd.Parameters.Add(objParams.Parmeters["EmployeeID"]);
            //objCmd.Parameters.Add(objParams.Parmeters["EmployeeName"]);
            objCmd.Parameters.Add(objParams.Parmeters["ProjectID"]);
            //objCmd.Parameters.Add(objParams.Parmeters["ProjectName"]);

            try
            {
                objCmd.Connection.Open();
                System.Data.SqlClient.SqlDataReader objDR = objCmd.ExecuteReader();
                while (objDR.Read())
                {
                    EmployeeProjectHour objEPH = new EmployeeProjectHour();
                    objEPH.intEmployeeID = (int)objDR["ProjectID"];
                    objEPH.strEmployeeName = (string)objDR["EmployeeName"];
                    objEPH.strProjectName = (string)objDR["ProjectName"];
                    objEPH.intProjectID = (int)objDR["ProjectID"];
                    objEPH.Date = (System.DateTime)objDR["Date"];
                    objEPH.Hours = (decimal)objDR["Hours"];
                    ((List<EmployeeProjectHour>)objEmployeeProjectHours).Add(objEPH);
                }
                objDR.Close(); //You cannot get the return value if the reader is not closed!
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return objEmployeeProjectHours;
        }

    }//end EmployeeProjectHour

    public class ThisYearsDate: IThisYearsDateRepository
    {
        IEnumerable<ThisYearsDate> objThisYearsDates;
        int intDateID;
        string strDateName;

        public IEnumerable<ThisYearsDate> ThisYearsDates
        {
            get
            {
                return objThisYearsDates;
            }
            set
            {
                objThisYearsDates = value;
            }
        }

        public int DateID
        {
            get
            {
                return intDateID;
            }
            set
            {
                intDateID = value;
            }
        }

        public string DateName
        {
            get
            {
                return strDateName;
            }
            set
            {
               strDateName = value;
            }
        }

        public IEnumerable<ThisYearsDate> SelThisYearsDates()
        {
            int intRC = 0;
            objThisYearsDates = new List<ThisYearsDate>();

            IParameterFactory objParams = new ValidHourEntryParameterFactory();
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pSelThisYearsDates", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            try
            {
                objCmd.Connection.Open();
                System.Data.SqlClient.SqlDataReader objDR = objCmd.ExecuteReader();
                while (objDR.Read())
                {
                    ThisYearsDate objTYD = new ThisYearsDate();
                    objTYD.DateID = (int)objDR["DateID"];
                    objTYD.DateName = (string)objDR["DateName"];
                    ((List<ThisYearsDate>)objThisYearsDates).Add(objTYD);
                }

                objDR.Close(); //You cannot get the return value if the reader is not closed!
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return objThisYearsDates;
        }
    }

    public class ValidHourEntry : IValidHourEntryRepository
    {
        IEnumerable<ValidHourEntry> objValidHourEntries;
        int intTimePeriodID;
        string strTimePeriod;

        public IEnumerable<ValidHourEntry> ValidHourEntries
        {
            get
            {
                return objValidHourEntries;
            }
            set
            {
                objValidHourEntries = value;
            }
        }

        public int TimePeriodID
        {
            get
            {
                return intTimePeriodID;
            }
            set
            {
                intTimePeriodID = value;
            }
        }

        public string TimePeriod
        {
            get
            {
                return strTimePeriod;
            }
            set
            {
               strTimePeriod = value;
            }
        }

        public IEnumerable<ValidHourEntry> SelValidHourEntries()
        {
            int intRC = 0;
            objValidHourEntries = new List<ValidHourEntry>();

            IParameterFactory objParams = new ValidHourEntryParameterFactory();
            System.Data.SqlClient.SqlCommand objCmd = new SqlCommand("pSelValidHours", new ADOConnectionFactory().Connection);
            objCmd.CommandType = CommandType.StoredProcedure;

            objCmd.Parameters.Add(objParams.Parmeters["RC"]);
            try
            {
                objCmd.Connection.Open();
                System.Data.SqlClient.SqlDataReader objDR = objCmd.ExecuteReader();
                while (objDR.Read())
                {
                    ValidHourEntry objVHE = new ValidHourEntry();
                    objVHE.TimePeriodID = (int)objDR["TimePeriodID"];
                    objVHE.TimePeriod = (string)objDR["TimePeriod"];
                    ((List<ValidHourEntry>)objValidHourEntries).Add(objVHE);
                }

                objDR.Close(); //You cannot get the return value if the reader is not closed!
                intRC = (int)objParams.Parmeters["RC"].Value;
                if (intRC < 0)
                { throw new Exception("Error reported in Stored Procedure: " + objParams.Parmeters["RC"].Value.ToString()); }
                objCmd.Connection.Close();
            }
            catch (Exception) { throw; }
            return objValidHourEntries;
        }
    }
}
//
