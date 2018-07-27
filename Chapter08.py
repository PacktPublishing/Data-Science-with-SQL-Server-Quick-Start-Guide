# Data Science with SQL Server Quick Start Guide
# Chapter 08

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
            Age, Region, Income,
            Education, Occupation,
            BikeBuyer, TrainTest
          FROM dbo.TMTrain
          UNION
          SELECT CustomerKey, CommuteDistance,
            TotalChildren, NumberChildrenAtHome, 
            Gender, HouseOwnerFlag,
            NumberCarsOwned, MaritalStatus,
            Age, Region, Income,
            Education, Occupation,
            BikeBuyer, TrainTest
          FROM dbo.TMTEST
          """
TM = pd.read_sql(query, con)


# Define Education as ordinal
TM['Education'] = TM['Education'].astype('category')
TM['Education'].cat.reorder_categories(
    ["Partial High School", 
     "High School","Partial College", 
     "Bachelors", "Graduate Degree"], inplace=True)
TM['Education']
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

# Make integers from ordinals
TM['EducationInt'] = TM['Education'].cat.codes
TM['CommuteDistanceInt'] = TM['CommuteDistance'].cat.codes
TM['OccupationInt'] = TM['Occupation'].cat.codes
# Check the distribution
# TM['OccupationInt'].value_counts().sort_index()
# TM['Occupation'].value_counts().sort_index()


# Create a linear model
from revoscalepy import rx_lin_mod, rx_predict
linmod = rx_lin_mod(
    """NumberCarsOwned ~ TotalChildren + OccupationInt + NumberChildrenAtHome +
    EducationInt + CommuteDistanceInt + BikeBuyer""", 
    data = TM)
TMPredict = rx_predict(linmod, data = TM, output_data = TM)
TMPredict[["NumberCarsOwned", "NumberCarsOwned_Pred"]].head(5)
TMPredict[["NumberCarsOwned", "NumberCarsOwned_Pred"]].head(20).plot(kind = "area",
                                                                     color = ('green','orange'))
plt.show()


# Naive Bayes
from sklearn.metrics import accuracy_score
from sklearn.naive_bayes import GaussianNB

# Arrange the data - feature matrix and target vector
# Split the data
Xtrain = TM.loc[TM.TrainTest == 1,
               ['TotalChildren', 'NumberChildrenAtHome',
                'HouseOwnerFlag', 'NumberCarsOwned',
                'EducationInt', 'OccupationInt',
                'CommuteDistanceInt']]
ytrain = TM.loc[TM.TrainTest == 1, ['BikeBuyer']]
Xtest = TM.loc[TM.TrainTest == 2,
               ['TotalChildren', 'NumberChildrenAtHome',
                'HouseOwnerFlag', 'NumberCarsOwned',
                'EducationInt', 'OccupationInt',
                'CommuteDistanceInt']]
ytest = TM.loc[TM.TrainTest == 2, ['BikeBuyer']]

# Fit the model 
model = GaussianNB()
model.fit(Xtrain, ytrain)

# Make predictions and check the accuracy
ymodel = model.predict(Xtest)
accuracy_score(ytest, ymodel)

# Output data
Xtest['BikeBuyer'] = ytest
Xtest['Predicted'] = ymodel
# Xtest.head(15)

# Analyze the results

# Actual vs predicted
cdbb = pd.crosstab(Xtest.BikeBuyer, Xtest.Predicted)
cdbb
cdbb.plot(kind = 'bar',
          fontsize = 14, legend = True, 
          use_index = True, rot = 1)
plt.show()

# Distribution of input variables in actual and predicted
sns.boxplot(x = 'Predicted', y = 'TotalChildren',  
            hue = 'BikeBuyer', data = Xtest,
            palette = ('red', 'lightgreen'))
plt.show()
sns.barplot(x="Predicted", y="NumberCarsOwned", 
            hue="BikeBuyer", data=Xtest,
            palette = ('yellow', 'blue'))
plt.show()


