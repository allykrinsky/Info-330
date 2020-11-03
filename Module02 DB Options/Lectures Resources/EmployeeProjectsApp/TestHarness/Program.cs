using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestHarness
{
    class Program
    {
        static void Main(string[] args)
        {
            int NewID = -1, RC;
            bool ShowEmployeesTest = true;
            bool ShowProjectsTest = true;
            bool ShowEmployeeProjectHoursTest = true;
            bool ShowThisYearsDatesTest = false;
            bool ShowValidHourEntriesTest = false;

            #region Employees Test
            if (ShowEmployeesTest)
            {
                DataAccessLayer.Employee objE = new DataAccessLayer.Employee();
                Console.WriteLine("++++ Testing: Employees ++++");

                RC = objE.InsEmployee("Emp1", out NewID);
                Console.WriteLine("Insert = RC: {0} and NewID: {1}", RC, NewID);
                SelectEmployees(objE);

                RC = objE.UpdEmployee(NewID, "Emp1A");
                Console.WriteLine("Update = RC: {0}", RC);
                SelectEmployees(objE);

                RC = objE.DelEmployee(NewID);
                Console.WriteLine("Del = RC: {0}", RC);
                SelectEmployees(objE); 
                Console.WriteLine("\n"); 
            }
            #endregion

            #region Projects Test
            if (ShowProjectsTest)
            {
                DataAccessLayer.Project objP = new DataAccessLayer.Project();
                Console.WriteLine("++++ Testing: Projects ++++");

                RC = objP.InsProject("Project1000", "DescA", out NewID);
                Console.WriteLine("Insert = RC: {0} and NewID: {1}", RC, NewID);
                SelectProjects(objP);

                RC = objP.UpdProject(NewID, "Project1100", "DescZ");
                Console.WriteLine("Update = RC: {0}", RC);
                SelectProjects(objP);

                RC = objP.DelProject(NewID);
                Console.WriteLine("Del = RC: {0}", RC);
                SelectProjects(objP);
                Console.WriteLine("\n"); 
            }
            #endregion
             
            #region EmployeeProjectHours Test
            if (ShowEmployeeProjectHoursTest)
            {
                DataAccessLayer.EmployeeProjectHour objEPH = new DataAccessLayer.EmployeeProjectHour();
                Console.WriteLine("++++ Testing: EmployeeProjectHours ++++");

                RC = objEPH.InsEmployeeProjectHour(2, 100, DateTime.Parse("2016/01/03"), 17);
                Console.WriteLine("Insert = RC: {0} and NewID: {1}", RC, NewID);
                SelectEmployeeProjectHours(objEPH);

                RC = objEPH.UpdEmployeeProjectHour(2, 100, DateTime.Parse("2016/01/03"), 7);
                Console.WriteLine("Update = RC: {0}", RC);
                SelectEmployeeProjectHours(objEPH);

                RC = objEPH.DelEmployeeProjectHour(2, 100, DateTime.Parse("2016/01/03"));
                Console.WriteLine("Del = RC: {0}", RC);
                SelectEmployeeProjectHours(objEPH);
                Console.WriteLine("\n"); 
            }
            #endregion

            #region ThisYearsDates Test
            if (ShowThisYearsDatesTest)
            {
                DataAccessLayer.ThisYearsDate objTYD = new DataAccessLayer.ThisYearsDate();
                Console.WriteLine("++++ Testing: ValidHourEntries ++++");
                SelectThisYearsDates(objTYD);
                Console.ReadLine(); 
            }
            #endregion

            #region ValidHourEntries Test
            if (ShowValidHourEntriesTest)
            {
                DataAccessLayer.ValidHourEntry objVHE = new DataAccessLayer.ValidHourEntry();
                Console.WriteLine("++++ Testing: ValidHourEntries ++++");
                SelectValidHourEntries(objVHE);
            }
            #endregion

            Console.WriteLine("Press any key to quit");
            Console.ReadLine(); 
        }

        private static void SelectEmployees(DataAccessLayer.Employee objE)
        {
            Console.WriteLine("Current Data in Employees");
            foreach (DataAccessLayer.Employee Row in objE.SelEmployee())
            {
                Console.WriteLine("  EmployeeID:{0},EmployeeName:{1}", Row.EmployeeID, Row.EmployeeName);
            }
            Console.WriteLine("---------------------------");
        }

        private static void SelectProjects(DataAccessLayer.Project objP)
        {
            Console.WriteLine("Current Data in Projects");
            foreach (DataAccessLayer.Project Row in objP.SelProject())
            {
                Console.WriteLine("  ProjectID:{0}\n  ProjectName:{1}\n  ProjectDescription:{2} \n", Row.ProjectID, Row.ProjectName, Row.ProjectDescription);
            }
            Console.WriteLine("---------------------------");
        }

        private static void SelectEmployeeProjectHours(DataAccessLayer.EmployeeProjectHour objEPH)
        {
            Console.WriteLine("Current Data in Projects");
            foreach (DataAccessLayer.EmployeeProjectHour Row in objEPH.SelEmployeeProjectHour())
            {
                Console.WriteLine("  EmployeeID:{0}\n  EmployeeName:{1}\n  ProjectID:{2}\n  ProjectName:{3}\n  Date:{4}\n  Hours:{5} \n", Row.EmployeeID, Row.EmployeeName, Row.ProjectID , Row.ProjectName, Row.Date, Row.Hours );
            }
            Console.WriteLine("---------------------------");
        }

        private static void SelectThisYearsDates(DataAccessLayer.ThisYearsDate objTYD)
        {
            Console.WriteLine("Current Data in Projects");
            foreach (DataAccessLayer.ThisYearsDate Row in objTYD.SelThisYearsDates())
            {
                Console.WriteLine("  DateID:{0}\n  DateName:{1}\n", Row.DateID, Row.DateName);
            }
            Console.WriteLine("---------------------------");
        }

        private static void SelectValidHourEntries(DataAccessLayer.ValidHourEntry objVHE)
        {
            Console.WriteLine("Current Data in Projects");
            foreach (DataAccessLayer.ValidHourEntry Row in objVHE.SelValidHourEntries())
            {
                Console.WriteLine("  TimePeriodID:{0}\n  TimePeriod:{1}\n", Row.TimePeriodID, Row.TimePeriod);
            }
            Console.WriteLine("---------------------------");
        }

    }
}
