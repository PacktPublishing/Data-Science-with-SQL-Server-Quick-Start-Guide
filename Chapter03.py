# Data Science with SQL Server Quick Start Guide
# Chapter 03

# This is a comment
print("Hello World!")
# This line is ignored - it is a comment again
print('Another string.')
print('O"Brien')   # In-line comment
print("O'Brien")

# Simple expressions
3 + 2
print("The result of 5 + 30 / 6 is:", 5 + 30 / 6)
10 * 3 - 6
11 % 4
print("Is 8 less or equal to 5?", 8 <= 5)
print("Is 8 greater than 5?", 8 > 5)

# Integer
a = 3
b = 4
a ** b
# Float
c = 6.0
d = float(7)
print(c, d)

# Formatted strings
# Variables in print()
e = "repeat"
f = 5
print("Let's %s string formatting %d times." % (e, f))
# String.format()
four_par = "String {} {} {} {}"
print(four_par.format(1, 2, 3, 4))
print(four_par.format('a', 'b', 'c', 'd'))

# More strings
print("""Three double quotes
are needed to delimit strings in multiple lines.
You can have as many lines as you wish.""")
a = "I am 5'11\" tall"
b = 'I am 5\'11" tall'
print("\t" + a + "\n\t" + b)

# Functions
def nopar():
    print("No parameters")
def add(a, b):
    return a + b

# Call without arguments
nopar()
# Call with variables and math
a = 10
b = 20
add(a / 5, b / 4)

# if..elif..else
a = 10
b = 20
c = 30
if a > b:
    print("a > b")
elif a > c:
    print("a > c")
elif (b < c):
    print("b < c")
    if a < c:
        print("a < c")
    if b in range(10, 30):
        print("b is between a and c")
else:
    print("a is less than b and less than c")

# List and loops
animals = ["bee", "whale", "cow"]
nums = []
for animal in animals:
    print("Animal: ", animal)
for i in range(2, 5):
    nums.append(i)
print(nums)
i = 1
while i <= 3:
    print(i)
    i = i + 1

# Dictionary
CtyCou = {
    "Paris": "France",
    "Tokyo": "Japan",
    "Lagos": "Nigeria"}
for city, country in CtyCou.items():
    print("{0} is in {1}.".format(city, country))


# Demo graphics
# Imports
import numpy as np
import pandas as pd
import pyodbc
import matplotlib.pyplot as plt

# Reading the data from SQL Server
con = pyodbc.connect('DSN=AWDW;UID=RUser;PWD=Pa$$w0rd')
query = """SELECT CustomerKey, 
             Age, YearlyIncome, 
             CommuteDistance, BikeBuyer
           FROM dbo.vTargetMail;"""
TM = pd.read_sql(query, con)

# Info about the data
TM.head(5)
TM.shape

# Define CommuteDistance as categorical
TM['CommuteDistance'] = TM['CommuteDistance'].astype('category')
# Reordering Education
TM['CommuteDistance'].cat.reorder_categories(
    ["0-1 Miles", 
     "1-2 Miles","2-5 Miles", 
     "5-10 Miles", "10+ Miles"], inplace=True)

# Crosstabulation
cdbb = pd.crosstab(TM.CommuteDistance, TM.BikeBuyer)
cdbb

cdbb.plot(kind = 'bar',
          fontsize = 14, legend = True, 
          use_index = True, rot = 1)
plt.show()

# Introducting numpy
np.__version__
np.array([1, 2, 3, 4])
np.array([1, 2, 3, 4], dtype = "float32")

# Arrays
np.zeros((3, 5), dtype = int)
np.ones((3, 5), dtype = int)
np.full((3, 5), 3.14)

# More arrays
np.arange(0, 20, 2)
np.random.random((1, 10))
np.random.normal(0, 1, (1, 10))
np.random.randint(0, 10, (3, 3))

# Operations on arrays
x = np.arange(0, 9).reshape((3, 3))
x
np.sin(x)

# Aggregate functions
x = np.arange(1,6)
x
np.sum(x), np.prod(x)
np.min(x), np.max(x)
np.mean(x), np.std(x)
# Running total
np.add.accumulate(x)


# Pandas Series
ser1 = pd.Series([1, 2, 3, 4])
ser1[1:3]

# Named index
ser1 = pd.Series([1, 2, 3, 4],
                 index = ['a', 'b', 'c', 'd'])
ser1['b':'c']

# Data frame descriptive statistics
TM.describe()
TM['YearlyIncome'].mean(), TM['YearlyIncome'].std()
TM['YearlyIncome'].skew(), TM['YearlyIncome'].kurt()

# Histogram and a kernel density plot
(TM['YearlyIncome']).hist(bins = 25, normed = True, 
                          color = 'lightblue')
(TM['YearlyIncome']).plot(kind='kde', 
                          style='r--', xlim = [0, 200000])
plt.show()
