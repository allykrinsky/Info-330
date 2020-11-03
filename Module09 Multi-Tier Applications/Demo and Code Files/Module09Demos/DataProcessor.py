#------------DataProcessor.py -----------------------------------#
#Desc:  Functions that read and write data to a database
#Dev:   RRoot
#Date:  12/12/2020
#ChangeLog:(When,Who,What)
#----------------------------------------------------------------#

if __name__ == "__main__":
    raise Exception("This file is not meant to ran by itself")


import sqlite3

# Functions ----------------------------------------------------
def create_connection(db_file):
    try:
        con = sqlite3.connect(db_file)  # This opens OR creates the database
    except Exception as e:
        raise e
    return con


def create_demo_table(con):
    try:
        csr = con.cursor()  # A cursor object allows you to submit commands
        csr.execute("CREATE TABLE Demo (ID [integer], Name [text]);")  # Need semi-colon!
        csr.close()  # Always close the cursor when your done
    except Exception as e:
        raise e

def insert_demo_data(con, ID, Name):
    try:
        csr = con.cursor()  # A cursor object allows you to submit commands
        csr.execute("INSERT INTO Demo (ID, Name) values (?,?);", [ID, Name])  # ? is a parameter
        csr.execute("commit;")  # You need to add this when using PySQLite!
        csr.close()  # Always close the cursor when your done
    except Exception as e:
        raise e

def update_demo_data(con, ID, Name):
    try:
        csr = con.cursor()  # A cursor object allows you to submit commands
        csr.execute("Update Demo Set Name = ? Where ID = ?;", [ID, Name])  # ? is a parameter
        csr.execute("commit;")  # You need to add this when using PySQLite!
        csr.close()  # Always close the cursor when your done
    except Exception as e:
        raise e

def delete_demo_data(con, ID):
    try:
        csr = con.cursor()  # A cursor object allows you to submit commands
        csr.execute("Delete From Demo Where ID = ?;", [ID])  # ? is a parameter
        csr.execute("commit;")  # You need to add this when using PySQLite!
        csr.close()  # Always close the cursor when your done
    except Exception as e:
        raise e

def select_demo_data(con):
    try:
        csr = con.cursor()  # A cursor object allows you to submit commands
        csr.execute("SELECT ID, Name FROM Demo;")
        rows = csr.fetchall()  # fetchall puts all of the rows from the result into a list
        csr.close()  # Always close the cursor when your done
        return rows
    except Exception as e:
        raise e
