#------------FileProcessor.py ---------------#
#Desc:  Functions that reads and writes file data
#Dev:   RRoot
#Date:  12/12/2020
#ChangeLog:(When,Who,What)
#----------------------------------------#
if __name__ == "__main__":
    raise Exception("This file is not meant to ran by itself")

def ReadFileData(PathAndFileName):
  # NOTE: The file must be created first before this will work,
  objFile = open(PathAndFileName, "r")
  return objFile

def SaveFileData(PathAndFileName, Data):
  # NOTE: The file must be created first before this will work,
  objFile = open(PathAndFileName, "a")
  objFile.write(Data + '\n')
  objFile.close()