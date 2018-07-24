# Data Science with SQL Server Quick Start Guide
# Chapter 07

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


# Import PCA 
from sklearn.decomposition import PCA
# Feature matrix
X = TM[["TotalChildren", "HouseOwnerFlag", "Age", "Income",
        "NumberChildrenAtHome", "NumberCarsOwned", "BikeBuyer"]]

# TM reduce dimensionality
model = PCA(n_components = 2)
model.fit(X)
X_2D = model.transform(X)
# X_2D

# Adding PCAs to TM
TM['PCA1'] = X_2D[:, 0]
TM['PCA2'] = X_2D[:, 1]
# TM.head(10)

# Analyzing PCAs with a graph
ax = sns.lmplot('PCA1', 'PCA2', hue = 'NumberCarsOwned',
                data = TM, fit_reg = True, legend_out = False,
                palette = ("green", "red", "blue", "yellow", "black"), 
                x_bins = 15, scatter_kws={"s": 100})
ax.set_xlabels(fontsize=16)
ax.set_ylabels(fontsize=16)
ax.set_xticklabels(fontsize=12)
ax.set_yticklabels(fontsize=12)
plt.show()


# GMM clustering
from sklearn.mixture import GaussianMixture
# Define and train the model
X = TM[["PCA1", "PCA2"]]
model = GaussianMixture(n_components = 3, covariance_type = 'full')
model.fit(X)
# Get the clusters vector
y_gmm = model.predict(X)

# Adding cluster membership to the original
TM['cluster'] = y_gmm
TM.head()

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

# Seaborn countplot
sns.countplot(x="CommuteDistance", hue="cluster", data=TM);
plt.show()
# Seaborn countplot
sns.countplot(x="Occupation", hue="cluster", data=TM);
plt.show()
