if __name__ == "__main__":
    import MathProcessor,FileProcessor
else:
    raise Exception("This file was not created to be imported")

# -- data code --
fltValue1 = None # first argument
fltValue2 = None # second argument
lstData = None   # row of processed data
strFilePath = "c:\\Python\\TestData.txt"

# --processing code--


# --presentation (I/0) code--
# Call the function
fltValue1 = float(input("Enter 1st Number: "))
fltValue2 = float(input("Enter 2nd Number: "))
lstData = MathProcessor.ProcessMath(fltValue1,fltValue2)
print("The sum of " + str(lstData[1])
       + " and " + str(lstData[2])
       + " is: " + str(lstData[0]))
FileProcessor.SaveFileData(strFilePath, str(lstData))