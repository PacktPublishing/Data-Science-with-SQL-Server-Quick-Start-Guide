# Data Science with SQL Server Quick Start Guide
# Chapter 06

# Imports
import numpy as np
import pandas as pd
import pyodbc
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns


# Reading the data from SQL Server
con = pyodbc.connect('DSN=AWDW;UID=RUser;PWD=Pa$$w0rd')
query = """SELECT CustomerKey, CommuteDistance,
            TotalChildren, NumberChildrenAtHome, 
            Gender, HouseOwnerFlag,
            NumberCarsOwned, MaritalStatus,
            Age, BikeBuyer, Region,
            YearlyIncome AS Income,
            EnglishEducation AS Education,
            EnglishOccupation AS Occupation
          FROM dbo.vTargetMail"""
TM = pd.read_sql(query, con)


# Continuous variables

# Covariance and correlation
np.cov(TM.Age, TM.Income)
np.corrcoef(TM.Age, TM.Income)

# Selecting only one value
np.cov(TM.Age, TM.Income)[0][1]
np.corrcoef(TM.Age, TM.Income)[0][1]


# Discrete variables

# Define CommuteDistance as ordinal
TM['CommuteDistance'] = TM['CommuteDistance'].astype('category')
TM['CommuteDistance'].cat.reorder_categories(
    ["0-1 Miles", 
     "1-2 Miles","2-5 Miles", 
     "5-10 Miles", "10+ Miles"], inplace=True)
# Define Occupation as ordinal
TM['Occupation'] = TM['Occupation'].astype('category')
TM['Occupation'].cat.reorder_categories(
    ["Manual", 
     "Clerical","Skilled Manual", 
     "Professional", "Management"], inplace=True)

# Crosstabulation
cdo = pd.crosstab(TM.Occupation, TM.CommuteDistance)
cdo

# Chi squared
from scipy.stats import chi2_contingency
chi2, p, dof, expected = chi2_contingency(cdo)
chi2
dof
p


# Discrete and continuous variables

# Anova / boxplot
sns.boxplot(x = 'Occupation', y = 'Income',  
            data = TM)
plt.show()

# A violinplot
sns.violinplot(x = 'Occupation', y = 'Age',  
               data = TM, kind = 'box', size = 8)
plt.show()


# Import linear regression 
from sklearn.linear_model import LinearRegression
# Hyperparameters
model = LinearRegression(fit_intercept = True)
# Arrange the data - feature matrix and target vector (y is already vector)
X = TM[['Income']]
y = TM.NumberCarsOwned
# Fit the model to the data
model.fit(X, y)
# Slope and intercept
model.coef_; model.intercept_

# Predictions
ypred = TM[['Income']]
yfit = model.predict(ypred)
TM['CarsPredicted'] = yfit
# Results
TM[['CustomerKey', 'NumberCarsOwned', 'CarsPredicted']].sample(5)


###########################
# More code as a bonus:-) #
###########################

# Factorplot
sns.factorplot(x = 'Occupation', y = 'Age', hue = 'BikeBuyer',
               col="MaritalStatus", data=TM)
plt.show()
