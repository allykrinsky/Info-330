#------------Main.py -----------------------------------#
#Desc:  Presentation code for working with a database
#Dev:   RRoot
#Date:  12/12/2020
#ChangeLog:(When,Who,What)
#----------------------------------------------------------------#

import DataProcessor as dp

# Main body of the script ------------------------------------
db_con = None

try:  # Connecting
    db_con = dp.create_connection('C:/DataFiles/test.db')
    print("Connected!")
except Exception as e:
    print(e)

try:  # Creating
    dp.create_demo_table(db_con)
    print("Table created!")
except Exception as e:
    print(e)

try:  # Inserting
    dp.insert_demo_data(db_con, 3, "CCC")
    print("Data inserted!")
except Exception as e:
    print(e)

try:  # Selecting
    rows = dp.select_demo_data(db_con)
    for row in rows:
        print(row)
    print("Data selected!")
except Exception as e:
    print(e)

try:  # Updating
    dp.update_demo_data(db_con, 3, "CC")
    rows = dp.select_demo_data(db_con)
    for row in rows:
        print(row)
    print("Data updated!")
except Exception as e:
    print(e)

try:  # Deleting
    dp.delete_demo_data(db_con, 3)
    rows = dp.select_demo_data(db_con)
    for row in rows:
        print(row)
    print("Data deleted!")
except Exception as e:
    print(e)

db_con.close()
