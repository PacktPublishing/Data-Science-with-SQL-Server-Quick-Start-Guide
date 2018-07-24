# Data Science with SQL Server Quick Start Guide
# Chapter 07


# Association rules
# Install arules library only if needed
# install.packages("arules")
library(arules)

# Read the data
library(RODBC)
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
df_AR <- as.data.frame(sqlQuery(con,
  "SELECT OrderNumber, Model
   FROM dbo.vAssocSeqLineItems
   ORDER BY OrderNumber, Model;"
), stringsAsFactors = FALSE)
close(con)
# View(df_AR)

# Defining transactions 
trans <- as(split(df_AR[, "Model"],
                  df_AR[, "OrderNumber"]),
            "transactions")
# Transactions info
trans
inspect(trans[6:8])

# Association rules
AR <- apriori(trans,
              parameter = list
              (minlen = 2,
               supp = 0.03,
               conf = 0.05,
               target = "rules"))
inspect(AR, ruleSep = "---->", itemSep = " + ")

# Install arulesViz library only if needed
# install.packages("arulesViz")
library(arulesViz)
# Rules graph
plot(AR, method = "graph", control = list(type = "items"))


# Clustering
# Read SQL Server data
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
TM <-
  sqlQuery(con,
           "SELECT CustomerKey, CommuteDistance,
           TotalChildren, NumberChildrenAtHome, 
           Gender, HouseOwnerFlag,
           NumberCarsOwned, MaritalStatus,
           Age, BikeBuyer, Region,
           YearlyIncome AS Income,
           EnglishEducation AS Education,
           EnglishOccupation AS Occupation
           FROM dbo.vTargetMail")
close(con)
# View(TM)

# Order Education
TM$Education = factor(TM$Education, order = TRUE,
                      levels = c("Partial High School",
                                 "High School", "Partial College",
                                 "Bachelors", "Graduate Degree"))
# Create integer Education
TM$EducationInt = as.integer(TM$Education)
# View(TM)

# K-Means Clustering
library(RevoScaleR)
ThreeClust <- rxKmeans(formula = ~NumberCarsOwned + Income + Age +
                         NumberChildrenAtHome + BikeBuyer + EducationInt,
                       data = TM, numClusters = 3)
# summary(ThreeClust)


# Add cluster membership to the original data frame and rename the variable
TMClust <- cbind(TM, ThreeClust$cluster)
names(TMClust)[16] <- "ClusterID"
# View(TMClust)

# Attach the new data frame
attach(TMClust);
# Saving parameters
oldpar <- par(no.readonly = TRUE);
# Defining a 2x2 graph
par(mfrow = c(2, 2));
# Income and clusters
boxplot(Income ~ ClusterID,
        main = "Yearly Income in Clusters",
        notch = TRUE,
        varwidth = TRUE,
        col = "orange",
        ylab = "Yearly Income",
        xlab = "Cluster Id")
# BikeBuyer and clusters
nc <- table(BikeBuyer, ClusterID)
barplot(nc,
        main = 'Bike buyer and cluster ID',
        xlab = 'Cluster Id', ylab = 'BikeBuyer',
        legend = rownames(nc),
        col = c("blue", "yellow"),
        beside = TRUE)
# Education and clusters
nc <- table(Education, ClusterID)
barplot(nc,
        main = 'Education and cluster ID',
        xlab = 'Cluster Id', ylab = 'Total Children',
        col = c("black", "blue", "green", "red", "yellow"),
        beside = TRUE)
legend("topright", rownames(nc), cex = 0.6,
       fill = c("black", "blue", "green", "red", "yellow"))
# Age and clusters
boxplot(Age ~ ClusterID,
        main = "Age in Clusters",
        notch = TRUE,
        varwidth = TRUE,
        col = "Green",
        ylab = "Yearly Income",
        xlab = "Cluster Id")
# Clean up
par(oldpar)
detach(TMClust)


# Factor analysis
# Install package psych only if needed
# install.packages("psych")
library(psych)
# Extracting numerical data only
TMFA <- TM[, c("TotalChildren", "NumberChildrenAtHome",
               "HouseOwnerFlag", "NumberCarsOwned",
               "BikeBuyer", "Income", "Age")]


# EFA orthogonal rotation
efaTM_varimax <- fa(TMFA, nfactors = 2, rotate = "varimax")
efaTM_varimax

# EFA oblique rotation
efaTM_promax <- fa(TMFA, nfactors = 2, rotate = "promax")
efaTM_promax

# Showing an 1x2 graph
par(mfrow = c(1, 2))
fa.diagram(efaTM_varimax, simple = FALSE,
           main = "EFA Varimax", cex = 1.2,
           e.size = .07, rsize = .12)
fa.diagram(efaTM_promax, simple = FALSE,
           main = "EFA Promax", cex = 1.3,
           e.size = .07, rsize = .12)
par(oldpar)


###########################
# More code as a bonus:-) #
###########################

# More arules plots

# Basic plot
plot(AR)
# Rules matrix
plot(AR, method = "grouped")
