import sqlite3

# Functions ----------------------------------------------------
def create_connection(db_file):
    try:
        con = sqlite3.connect(db_file)
    except Exception as e:
        raise e
    return con

def insert_students_data(con, ID, FName, LName, Email):
    try:
        csr = con.cursor()
        csr.execute("INSERT INTO Students values (?,?,?,?);", [ID, FName, LName, Email])
        csr.execute("commit;")
        csr.close()
    except Exception as e:
        raise e

def update_students_data(con, FName, LName, Email, ID):
    try:
        csr = con.cursor()
        csr.execute("UPDATE Students SET StudentFirstName = ?, StudentLastName = ?, StudentEmail = ? WHERE StudentID = ?;"
                    , [FName, LName, Email, ID])
        csr.execute("commit;")
        csr.close()
    except Exception as e:
        raise e

def delete_students_data(con, ID):
    try:
        csr = con.cursor()
        csr.execute("DELETE FROM Students WHERE StudentID = ? ;", [ID])
        csr.execute("commit;")
        csr.close()
    except Exception as e:
        raise e


def select_students_data(con):
    try:
        csr = con.cursor()
        csr.execute("SELECT StudentID, StudentFirstName, StudentLastName, StudentEmail FROM Students;")
        rows = csr.fetchall()
        csr.close()
        return rows
    except Exception as e:
        raise e

# Main body of the script ------------------------------------
db_con = None

try:  # Connecting
    db_con = create_connection('C:/DataFiles/Enrollments.db')
    print("Connected!")
except Exception as e:
    print(e)

try:  # Inserting
    insert_students_data(db_con, 2, "Sue", "Jones", "SJones@MyCo.com")
    print("Data inserted!")
except Exception as e:
    print(e)

try:  # Selecting
    rows = select_students_data(db_con)
    for row in rows:
        print(row)
    print("Data selected!")
except Exception as e:
    print(e)

try:  # Updating
    update_students_data(db_con, "Susan", "Jones", "SJones@MyCo.com", 2)
    rows = select_students_data(db_con)
    for row in rows:
        print(row)
    print("Data updated!")
except Exception as e:
    print(e)

try:  # Deleting
    delete_students_data(db_con, 2)
    rows = select_students_data(db_con)
    for row in rows:
        print(row)
    print("Data deleted!")
except Exception as e:
    print(e)