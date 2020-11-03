import sqlite3  # this imports code from the sqlite module of PySQLite!

# Functions -----------------------------------------------------
def create_connection(db_file):
    try:
        con = sqlite3.connect(db_file)  # This opens OR creates the database
        print('Connected! - SQLite Version is: ', sqlite3.version)
    except Exception as e:
        print(e.__str__())
    return con

# Main body of the script------------------------------------------
db_con = create_connection('C:/DataFiles/test.db')
db_con.close()  # Always close the connection when your done
