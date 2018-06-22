# Data Science with SQL Server Quick Start Guide
# Chapter 03

# Hash starts a comment
print("Hello World!")
# This line ignored
print('Printing again.')
print('O"Hara')   # In-line comment
print("O'Hara")

# Simple expressions
1 + 2
print("The result of 3 + 20 / 4 is:", 3 + 20 / 4)
10 * 2 - 7
10 % 4
print("Is 7 less or equal to 5?", 7 <= 5)
print("Is 7 greater than 5?", 7 > 5)

# Integer
a = 2
b = 3
a ** b
# Float
c = 7.0
d = float(5)
print(c, d)

# String
e = "String 1"
f = 10
print("Let's concatenate string %s and number %d." % (e, f))
four_cb = "String {} {} {} {}"
print(four_cb.format(1, 2, 3, 4))

# More strings
print("""Note three double quotes.
Allow you to print multiple lines.
As many as you wish.""")
a = "I am 5'11\" tall"
b = 'I am 5\'11" tall'
print("\t" + a + "\n\t" + b)

# Functions
def p_n():
    print("No args...")
def add(a, b):
    return a + b
# Call
p_n()
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
while i <= 10:
    print(i)
    i = i + 1

# Dictionary
states = {
    "Oregon": "OR",
    "Florida": "FL",
    "Michigan": "MI"}
for state, abbrev in list(states.items()):
    print("{} is abbreviated {}.".format(state, abbrev))

# Demo graphics
# Imports
import numpy as np
import pandas as pd
import pyodbc
import matplotlib.pyplot as plt

# Reading the data from SQL Server
con = pyodbc.connect('DSN=AWDW;UID=RUser;PWD=Pa$$w0rd')
query = """SELECT CustomerKey, Age,
             YearlyIncome, TotalChildren,
             NumberCarsOwned
           FROM dbo.vTargetMail;"""
TM = pd.read_sql(query, con)

# Info about the data
TM.head(5)
TM.shape

# Crosstabulation
obb = pd.crosstab(TM.NumberCarsOwned, TM.TotalChildren)
obb

obb.plot(kind = 'bar')
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
TM['Age'].mean(), TM['Age'].std()
TM['Age'].skew(), TM['Age'].kurt()

# Histogram and a kernel density plot
(TM['Age']).hist(bins = 25, normed = True, 
                      color = 'lightblue')
(TM['Age']).plot(kind='kde', style='r--', xlim = [0, 80])
plt.show()
