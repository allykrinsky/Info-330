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

def insert_demo_data(con):
    try:
        csr = con.cursor()  # A cursor object allows you to submit commands
        csr.execute("INSERT INTO Demo (ID, Name) values (1, 'A'), (2, 'B');")  # Single quotes for strings!
        csr.execute("commit;")  # You need to add this when using PySQLite!
        csr.close()  # Always close the cursor when your done
    except Exception as e:
        raise e

def update_demo_data(con):
    try:
        csr = con.cursor()  # A cursor object allows you to submit commands
        csr.execute("Update Demo Set Name = 'AAA' Where ID = 1;")  # Single quotes for strings!
        csr.execute("commit;")  # You need to add this when using PySQLite!
        csr.close()  # Always close the cursor when your done
    except Exception as e:
        raise e

def delete_demo_data(con):
    try:
        csr = con.cursor()  # A cursor object allows you to submit commands
        csr.execute("Delete From Demo Where ID = 2;")
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

# Main body of the script ------------------------------------
db_con = None

try:  # Connecting
    db_con = create_connection('C:/DataFiles/test.db')
    print("Connected!")
except Exception as e:
    print(e)

try:  # Creating
    create_demo_table(db_con)
    print("Table created!")
except Exception as e:
    print(e)

try:  # Inserting
    insert_demo_data(db_con)
    print("Data inserted!")
except Exception as e:
    print(e)

try:  # Selecting
    rows = select_demo_data(db_con)
    for row in rows:
        print(row)
    print("Data selected!")
except Exception as e:
    print(e)

try:  # Updating
    update_demo_data(db_con)
    rows = select_demo_data(db_con)
    for row in rows:
        print(row)
    print("Data updated!")
except Exception as e:
    print(e)

try:  # Deleting
    delete_demo_data(db_con)
    rows = select_demo_data(db_con)
    for row in rows:
        print(row)
    print("Data deleted!")
except Exception as e:
    print(e)

db_con.close()  # Always close the connection when your done

