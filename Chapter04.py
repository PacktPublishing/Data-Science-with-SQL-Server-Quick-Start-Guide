# Data Science with SQL Server Quick Start Guide
# Chapter 04

# Imports
import numpy as np
import pandas as pd
import pyodbc
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns


# Reading the data from SQL Server
con = pyodbc.connect('DSN=AWDW;UID=RUser;PWD=Pa$$w0rd')
query = """SELECT CustomerKey, 
            TotalChildren, NumberChildrenAtHome, 
            Gender, HouseOwnerFlag,
            NumberCarsOwned, MaritalStatus,
            Age, YearlyIncome, BikeBuyer,
            EnglishEducation AS Education,
            EnglishOccupation AS Occupation
          FROM dbo.vTargetMail"""
TM = pd.read_sql(query, con)

# N of rows and cols
print (TM.shape)
# First 10 rows
print (TM.head(10))

# Basic distribution
TM['Education'].value_counts()
TM['Education']
# dtype: object

# Define Education as categorical
TM['Education'] = TM['Education'].astype('category')
TM['Education']
# dtype: category, incorrect order

# Reorder
TM['Education'].cat.reorder_categories(
    ["Partial High School", 
     "High School","Partial College", 
     "Bachelors", "Graduate Degree"], inplace=True)
TM['Education']
# dtype: category, correct order

# Counts sorted correctly
TM['Education'].value_counts().sort_index()

# Pandas plot
edu = TM['Education'].value_counts().sort_index()
ax = edu.plot(kind = 'bar',
              color = ('b'),
              fontsize = 14, legend = False, 
              use_index = True, rot = 1)
ax.set_xlabel('Education', fontsize = 16)
ax.set_ylabel('Count', fontsize = 16)
plt.show()

# Seaborn countplot
sns.countplot(x="Education", hue="BikeBuyer", data=TM);
plt.show()


# Descriptive statistics - summary
TM.Age.describe()

# Details

# Centers
TM.Age.mean()
TM.Age.median()

# Spread
TM.Age.min()
TM.Age.max()
TM.Age.max() - TM.Age.min()

TM.Age.quantile(0.25)
TM.Age.quantile(0.75)
TM.Age.quantile(0.75) - TM.Age.quantile(0.25)

TM.Age.var()
TM.Age.std()
TM.Age.std() / TM.Age.mean()


# Skewness and kurtosis
TM.Age.skew()
TM.Age.kurt()


# Scatterplot
TM1 = TM.head(200)
plt.scatter(TM1['Age'], TM1['YearlyIncome'])
plt.xlabel("Age", fontsize = 16)
plt.ylabel("YearlyIncome", fontsize = 16)
plt.title("YearlyIncome over Age", fontsize = 16)
plt.show()


# Joint and marginal distributions together
with sns.axes_style('white'):
    sns.jointplot('Age', 'YearlyIncome', TM, kind = 'kde')
plt.show()


###########################
# More code as a bonus:-) #
###########################

# Seaborn trellis chart
sns.set(font_scale = 3)
grid = sns.FacetGrid(TM, row = 'HouseOwnerFlag', col = 'BikeBuyer', 
                     margin_titles = True, size = 10)
grid.map(plt.hist, 'YearlyIncome', 
         bins = np.linspace(0, np.max(TM['YearlyIncome']), 7))
plt.show()

# Geometric and harmonic mean
from scipy import stats
stats.gmean(TM.Age)
stats.hmean(TM.Age)

