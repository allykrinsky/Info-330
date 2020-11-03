//For EF and ADO.NET
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data;
using System.Data.Entity.Core.Objects;

namespace DataAccessLayer
{

    public class ADOConnectionFactory
    {
        System.Data.SqlClient.SqlConnection objConnection;
        public System.Data.SqlClient.SqlConnection Connection
        {
            get { return objConnection; }
            set { objConnection = value; }
        }
        
        public ADOConnectionFactory()
        {
            Connection = new System.Data.SqlClient.SqlConnection();
            /** Note: You must have a reference to the System.Configuration.dll **/
            Connection.ConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings["EmployeeProjectsDbContext"].ConnectionString;
        }
    }//end class    
    
   
    public class EFDbContext : DbContext
    {
        //Set up the connection using the Constructor
        public EFDbContext()
            : base("name=EmployeeProjectsDbContext")
        {
            //Stop EF from automatically mapping to a missing "Customer" table
            DbModelBuilder objDBMB = new DbModelBuilder();
            objDBMB.Ignore<Employee>();
            objDBMB.Ignore<Project>();
            objDBMB.Ignore<EmployeeProjectHour>();
            objDBMB.Ignore<ValidHourEntry>();
            objDBMB.Ignore<ThisYearsDate>();
        }
    }//end class

}
//
