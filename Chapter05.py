# Data Science with SQL Server Quick Start Guide
# Chapter 05

# Imports
import numpy as np
import pandas as pd
import pyodbc
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns
import scipy as sc

# Handling NULLs
con = pyodbc.connect('DSN=AWDW;UID=RUser;PWD=Pa$$w0rd')
query = """SELECT c1, c2, c3
           FROM dbo.NULLTest;"""
NULLTest = pd.read_sql(query, con)
NULLTest

# Checking for NULLs
pd.isnull(NULLTest)

# Omitting
NULLTest.dropna(axis = 'rows')
NULLTest.dropna(axis = 'columns')


# Aggregate functions
NULLTest.c2.mean()
NULLTest.c2.mean(skipna = False)


# Reading the data from SQL Server
con = pyodbc.connect('DSN=AWDW;UID=RUser;PWD=Pa$$w0rd')
query = """SELECT CustomerKey, CommuteDistance,
            TotalChildren, NumberChildrenAtHome, 
            Gender, HouseOwnerFlag,
            NumberCarsOwned, MaritalStatus,
            Age, YearlyIncome, BikeBuyer,
            EnglishEducation AS Education,
            EnglishOccupation AS Occupation
          FROM dbo.vTargetMail"""
TM = pd.read_sql(query, con)

# check the Age
TM["Age"].describe()

# Generating dummies (indicators)
pd.get_dummies(TM.MaritalStatus)
pd.get_dummies(TM.MaritalStatus, prefix = 'TM')

# Create the dummies
TM1 = TM[['MaritalStatus']].join(pd.get_dummies(TM.MaritalStatus, prefix = 'TM'))
TM1.tail(3)

# Show the Age in 20 equal width bins
TM['AgeEWB'] = pd.cut(TM['Age'], 20)
TM['AgeEWB'].value_counts()
pd.crosstab(TM.AgeEWB,
            columns = 'Count') .plot(kind = 'bar',
                                    legend = False,
                                    title = 'AgeEWB20')
plt.show()

# Equal width binning - 5 bins
TM['AgeEWB'] = pd.cut(TM['Age'], 5)
TM['AgeEWB'].value_counts(sort = False)


# Equal height binning
TM['AgeEHB'] = pd.qcut(TM['Age'], 5)
TM['AgeEHB'].value_counts(sort = False)


# Custom binning
custombins = [16, 22, 29, 39, 54, 88]
TM['AgeCUB'] = pd.cut(TM['Age'], custombins)
TM['AgeCUB'].value_counts(sort = False)
pd.crosstab(TM.AgeCUB,
            columns = 'Count') .plot(kind = 'bar',
                                    legend = False,
                                    title = 'AgeCUB')
plt.show()


# Calculating the entropy
# Function that calculates the entropy
def f_entropy(indata):
    indataprob = indata.value_counts() / len(indata) 
    entropy=sc.stats.entropy(indataprob, base = 2) 
    return entropy

# Use the function on variables
f_entropy(TM.NumberCarsOwned), np.log2(5), f_entropy(TM.NumberCarsOwned) / np.log2(5)
f_entropy(TM.BikeBuyer), np.log2(2), f_entropy(TM.BikeBuyer) / np.log2(2)


# rx_data_step filtering variables
from revoscalepy import rx_data_step
TM4 = rx_data_step(input_data=TM.iloc[0:3,], 
                   vars_to_keep = {'CustomerKey', 'Age', 'AgeCUB'})
TM4


###########################
# More code as a bonus:-) #
###########################

# Projections
TM1 = TM[["CustomerKey", "MaritalStatus"]]
TM2 = TM[["CustomerKey", "Gender"]]

# Positional access
TM1.iloc[0:3, 0:2]
TM2.iloc[0:3, 0:2]

# Filter and projection
TM.loc[TM.Age > 85, ["CustomerKey", "Age", "Gender"]]

# Joining data frames
TM3 = pd.merge(TM1, TM2, on = "CustomerKey")
TM3.iloc[0:3, 0:3]

# Sort
TMSortedByAge = TM.sort_values(by = ["Age"], ascending = False)
TMSortedByAge.loc[TM.Age > 84, ["CustomerKey", "Age"]]

# Connecting and reading the data
con = pyodbc.connect('DSN=AWDW;UID=RUser;PWD=Pa$$w0rd')
query = """
SELECT g.EnglishCountryRegionName AS Country,
 c.EnglishEducation AS Education,
 c.YearlyIncome AS Income,
 c.NumberCarsOwned
FROM dbo.DimCustomer AS c
 INNER JOIN dbo.DimGeography AS g
  ON c.GeographyKey = g.GeographyKey;"""
TM = pd.read_sql(query, con)

# Group by
TM.groupby('Country')['Income'].count()
TM.groupby('Country')['Income'].median()
TM.groupby('Country')['Income'].describe()

# Aggregate
TM.groupby('Country').aggregate({'Income': 'std',
                                 'NumberCarsOwned':'mean'})
# Agg is an alias for aggregate
# Multiple functions on multiple columns
TM.groupby('Country').aggregate({'Income': ['max', 'mean'],
                                 'NumberCarsOwned':['sum', 'count']})

# Filtering aggregations
TMAGG = pd.DataFrame(TM.groupby('Country')['Income'].mean())
TMAGG.loc[TMAGG.Income > 50000]

# Plot
ax = TMAGG.plot(kind = 'bar',
           color = ('b', 'y', 'r', 'g', 'm', 'k'),
           fontsize = 14, legend = False, 
           use_index = True, rot = 1)
ax.set_xlabel('Country', fontsize = 16)
ax.set_ylabel('Income Mean', fontsize = 16)
plt.show()
