
--****************** SQL Development *********************--
-- This file show some basic tools for Importing
-- and Exporting data.
--**********************************************************--

--  SQL Server supports the following methods of Moving data:
--      The BCP command (Windows console application)
--      SELECT INTO...(Transact-SQL)
--      INSERT INTO... SELECT * FROM AnotherTable (Transact-SQL)
--      Integration Services (SSIS)

'*** Importing data to tables with SELECT INTO ***'
-----------------------------------------------------------------------------------------------------------------------
USE MASTER;
Go
-- SELECT INTO creates a New table based on a query made on the Products table. 
CREATE -- DROP
DATABASE ImportingDemos;
Go
USE ImportingDemos;
Go
SELECT ProductName, UnitPrice AS Price, (UnitPrice * 0.1) AS Tax 
  INTO NEWPriceTable 
  FROM Northwind.dbo.Products; 
Go
SELECT * FROM NewPriceTable; 


-- You can also use SELECT INTO to create "TEMP" tables as shown here:
-- (Note that Temp Tables with a single # can only be used by one connection.)
SELECT ProductName, UnitPrice AS Price, (UnitPrice * 0.1) AS Tax 
  INTO #PriceTable 
  FROM Northwind.dbo.Products; 
Go
SELECT * FROM #PriceTable; 


-- However, Temp Tables with a double ## can only be used by many connections.
SELECT ProductName, UnitPrice AS Price, (UnitPrice * 0.1) AS Tax 
  INTO ##PriceTable 
  FROM Northwind.dbo.Products; 
Go
SELECT * FROM ##PriceTable -- TEST THIS IN A DIFFERENT QUERY WINDOW!

-- Often, Standard tables are created for reports or exporting data
-- using the SELECT INTO option.
SELECT DISTINCT CompanyName, Convert(Date, OrderDate) AS OrderDate
  INTO OrdersReport  -- New Demo table
  FROM Northwind.dbo.Orders INNER JOIN Northwind.dbo.Customers 
  ON Northwind.dbo.Orders.CustomerID = Northwind.dbo.Customers.CustomerID 

-- Notice that since we did not include a # sign since this was a regular table
SELECT Count(*) FROM OrdersReport
SELECT * FROM OrdersReport

-- SELECT INTO can be used to create an empty table as well
-- This is sometimes done to allow imports into a table
DROP TABLE OrdersReport
Go
SELECT DISTINCT CompanyName, OrderDate 
  INTO OrdersReport -- New Demo table
  FROM Northwind.dbo.Orders INNER JOIN Northwind.dbo.Customers 
  ON Northwind.dbo.Orders.CustomerID = Northwind.dbo.Customers.CustomerID 
  WHERE 5 = 4; -- NOTE: THIS WILL NEVER BE TRUE and so create an empty table!!!
Go
SELECT Count(*) FROM OrdersReport;
Go

'*** Importing data to tables with INSERT INTO ***'
-----------------------------------------------------------------------------------------------------------------------
-- INSERT INTO seems similar in some ways, 
-- but the table must already exsist before you can Insert data!
INSERT
  INTO OrdersReport  -- EXISTING Demo table
  SELECT DISTINCT CompanyName, OrderDate
  FROM Northwind.dbo.Orders INNER JOIN Northwind.dbo.Customers 
  ON Northwind.dbo.Orders.CustomerID = Northwind.dbo.Customers.CustomerID ;

-- See how there is now twice the data we had before?
SELECT Count(*) FROM OrdersReport;
SELECT * FROM OrdersReport;


'*** IMPORTING and EXPORTING with BCP  ***'
-----------------------------------------------------------------------------------------------------------------------
--  The BCP utility can both EXPORT and IMPORT data from data files and tables 
DROP TABLE TempDB.dbo.OrdersReport
Go
SELECT DISTINCT CompanyName, Convert(Date, OrderDate) AS OrderDate
  INTO TempDB.dbo.OrdersReport -- New Demo table
  FROM Northwind.dbo.Orders INNER JOIN Northwind.dbo.Customers 
  ON Northwind.dbo.Orders.CustomerID = Northwind.dbo.Customers.CustomerID 


-- Let first make a folder for our work using the SQL CMD Mode feature http://msdn.microsoft.com/en-us/library/ms174187.aspx
!! MD C:\_SQLDev

--  Exporting data from a table into a data file
!!BCP TempDB.dbo.OrdersReport OUT "C:\_SQLDev\ReportData.csv" -T -c -t "," -r "\n"

!!NOTEPAD.exe "C:\_SQLDev\ReportData.csv"
--  http://msdn.microsoft.com/en-us/library/ms162802.aspx

/* Here is syntax for the BCP command:  
    BCP {[[database_name.][owner].]{table_name | view_name} | "query"}
        {in | out | queryout | format} data_file
        [-m max_errors] [-f format_file] [-x] [-e err_file]
        [-F first_row] [-L last_row] [-b batch_size]
        [-n] [-c] [-w] [-N] [-V (60 | 65 | 70 | 80)] [-6] 
        [-q] [-C { ACP | OEM | RAW | code_page } ] [-tfield_term] 
        [-rrow_term] [-i input_file] [-o output_file] [-a packet_size]
        [-S server_name[\instance_name]] [-U login_id] [-P password]
        [-T] [-v] [-R] [-k] [-E] [-h "hint [,...n]"] "

-c Performs the operation using a character data type
-r Specifies the row terminator. The default is \n (newline character). 
-t Specifies the field terminator. The default is \t (tab character).
-T Specifies that the bcp utility connects to SQL Server with a trusted (Window's Securtity) connection.

*/

' Some Important options and facts about BCP'
--  1) You cannot export data out of a Single # table, but you can with ##'
--  2) Demo: 
		!! BCP ##pricetable out c:\_SQLDev\pricelist.txt -c -T  
		!! Explorer.exe C:\_SQLDev   

--You can Import data in a similar way, but a table must exist before 
--you can fill it with data. 
--SELECT INTO can be used to create an empty table using 
--a false where condition. Here is an example:

SELECT DISTINCT CompanyName, OrderDate 
  INTO TempDB.dbo.NewOrdersReport -- New data table
  FROM Northwind.dbo.Orders INNER JOIN Northwind.dbo.Customers 
  ON Northwind.dbo.Orders.CustomerID = Northwind.dbo.Customers.CustomerID 
  WHERE 5 = 4; -- NOTE: THIS WILL NEVER BE TRUE and so create an empty table!!!

-- If you check the table will be empty:
SELECT * FROM TempDB.dbo.NewOrdersReport;

-- To import data, you use almost the same command. 
!! BCP TempDB.dbo.NewOrdersReport IN "C:\_SQLDev\ReportData.csv" -T -c -t "," -r "\n"

-- You can now check again and see if the data imported correctly:
SELECT * FROM TempDB.dbo.NewOrdersReport;


'Using Inserts'
--You often cannot import the data using BCP or another similar program 
--since you do not have administrator access to the computers command shell. 
--The work around is to import the data use one or more SQL Insert command. 

Insert Into TempDB.dbo.NewOrdersReport 
(CompanyName, OrderDate)
Values 
 ('Alfreds Futterkiste','1998-04-09')
,('Ana Trujillo Emparedados y helados','1996-09-18')




'*** Integration Services  ***'
-----------------------------------------------------------------------------------------------------------------------
-- Your instructor will demo how you can build an Integration Service 
-- packages using the Import/Export wizard

--  1) Create the package that Exports data FROM the OrdersReport 
--      table TO a file called "c:\_SQLDev\SSISDEMO.csv"
--  2) Use object explorer connect to Integration Services 
--     and view the package ICON in the tree
--  3) Export package to a file an show students the contents of the 
--	   Package using Visual Studio 2010


/**** LAB (5 Min) *****************************************************
1) Using the SSIS wizard, export the data in Pubs.dbo.titles table to a 
C:\_SQLDev\Titles.csv
**********************************************************************/