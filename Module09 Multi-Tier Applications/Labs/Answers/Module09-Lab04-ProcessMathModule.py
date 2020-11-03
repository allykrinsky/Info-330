if __name__ == "__main__":
    import MathProcessor
else:
    raise Exception("This file was not created to be imported")

# -- data code --
fltValue1 = None # first argument
fltValue2 = None # second argument
lstData = None   # row of processed data

# --processing code--
# Define the function
'''
def ProcessMath(value1 = 0, value2 = 0):
    fltSum = value1 + value2
    fltDiff = value1 - value2
    fltProd = value1 + value2
    fltQuot = value1 + value2
    lstResults = [value1, value2,fltSum,fltDiff,fltProd,fltQuot]
    return lstResults
'''


# --presentation (I/0) code--
# Call the function
fltValue1 = float(input("Enter 1st Number: "))
fltValue2 = float(input("Enter 2nd Number: "))
lstData = MathProcessor.ProcessMath(fltValue1,fltValue2)
print("The sum of " + str(lstData[1])
       + " and " + str(lstData[2])
       + " is: " + str(lstData[0]))
