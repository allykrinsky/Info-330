#------------MathProcessor.py ---------------#
#Desc:  Functions that perform math on data
#Dev:   RRoot
#Date:  12/12/2020
#ChangeLog:(When,Who,What)
#----------------------------------------#
if __name__ == "__main__":
    raise Exception("This file is not meant to ran by itself")

def ProcessMath(value1=0, value2=0):
  fltSum = value1 + value2
  fltDiff = value1 - value2
  fltProd = value1 * value2
  fltQuot = value1 / value2
  lstResults = [value1, value2, fltSum, fltDiff, fltProd, fltQuot]
  return lstResults