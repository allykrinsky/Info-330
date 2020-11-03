import pypyodbc
#This needs to be downloaded and installed after installing Python

#Declare and Configure Variables
strConnection = "Driver={SQL Server Native Client 11.0};"\
                + "Server=localhost;"\
                + "Database=MyLabsDB_YourNameHere;"\
                + "UID=Randal;"\
                + "PWD=sql;"
#Semicolons are required and AutoCommit need for Transactions!
strSQLInsCommand = """ 
                    Exec pInsProducts 
                         @ProductID = null -- Ignoring this for now
                        ,@ProductName = ?
                        ,@ProductPrice = ?;
                    """
lstInsParameters = ['ProdTest', 1.99]
strSQLSelMaxCommand = "Select Max(ProductID) From vProducts;"
strSQLSelDataCommand = "Select ProductID, ProductName, ProductPrice From vProducts Where ProductID = ?;"

objCon = None #references a connection object
objCursor = None #references a cursor object
lstRow = []; #Will one row of data
intTestStatus = 0; #Will track the status of the SQL code

#Open a connection
try:
  objCon = pypyodbc.connect(strConnection)#Create a new Connection object
  print("Connection Succeeded")
except:
  print("Connection Failed")

#Issue a Command
try:
  objCursor = objCon.cursor() #Create a new Cursor object

  #Insert
  objCursor.execute(strSQLInsCommand, lstInsParameters)
  objCursor.commit()
  print("Command Succeeded: pInsProducts")

  #Get new ID
  objCursor.execute(strSQLSelMaxCommand)
  print("Command Succeeded: Select Max(ProductID) From vProducts;")
  lstRow = objCursor.fetchone() #one row

  #Get Current Row
  objCursor.execute(strSQLSelDataCommand, [lstRow[0]])
  print("Command Succeeded: Select * From vProducts Where ProductID = ?;")

  #Indicate that it all work in the Status flag
  intTestStatus = 1
except:
  objCursor.rollback()
  print("Command Failed")
  intTestStatus = -1

#Present the results
try:
  if (intTestStatus == 1):
    print("New ID: " + str(lstRow[0]))
    for row in objCursor:
      print(str(row[0]) + ',' + str(row[1]) + ',' + str(row[2]))
    print("Presentation Succeeded")
  else: raise  IndexError
except IndexError:
 print("No Data to Return")
except:
  print("Presentation Failed")

