# Data Science with SQL Server Quick Start Guide
# Chapter 08

# Read SQL Server data
library(RODBC)
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
TM <-
  sqlQuery(con,
           "SELECT CustomerKey, CommuteDistance,
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
          FROM dbo.TMTEST")
close(con)
# View(TM)


# Define Education as ordinal
TM$Education = factor(TM$Education, order = TRUE,
                      levels = c("Partial High School",
                                 "High School", "Partial College",
                                 "Bachelors", "Graduate Degree"))
# Define CommuteDistance as ordinal
TM$CommuteDistance = factor(TM$CommuteDistance, order = TRUE,
                     levels = c("0-1 Miles",
                                "1-2 Miles", "2-5 Miles",
                               "5-10 Miles", "10+ Miles"))
# Define Occupation as ordinal
TM$Occupation = factor(TM$Occupation, order = TRUE,
                levels = c("Manual",
                           "Clerical", "Skilled Manual",
                           "Professional", "Management"))

# Make integers from ordinals
TM$EducationInt = as.integer(TM$Education)
TM$CommuteDistanceInt = as.integer(TM$CommuteDistance)
TM$OccupationInt = as.integer(TM$Occupation)

# Giving labels to BikeBuyer values
TM$BikeBuyer <- factor(TM$BikeBuyer,
                       levels = c(0, 1),
                       labels = c("No", "Yes"))

# Split the data to the training and test set
TMTrain <- TM[TM$TrainTest == 1,]
TMTest <- TM[TM$TrainTest == 2,]


# Logistic regression from the base installation

# Three input variables only
TMLogR <- glm(BikeBuyer ~
    Income + Age + NumberCarsOwned,
    data = TMTrain, family = binomial())
# Test the model
probLR <- predict(TMLogR, TMTest, type = "response")
predLR <- factor(probLR > 0.5,
                 levels = c(FALSE, TRUE),
                 labels = c("No", "Yes"))
perfLR <- table(TMTest$BikeBuyer, predLR,
                dnn = c("Actual", "Predicted"))
perfLR
# Not good

# More input variables 
TMLogR <- glm(BikeBuyer ~
    Income + Age + NumberCarsOwned +
    EducationInt + CommuteDistanceInt + OccupationInt,
    data = TMTrain, family = binomial())
# Test the model
probLR <- predict(TMLogR, TMTest, type = "response")
predLR <- factor(probLR > 0.5,
                 levels = c(FALSE, TRUE),
                 labels = c("No", "Yes"))
perfLR <- table(TMTest$BikeBuyer, predLR,
                dnn = c("Actual", "Predicted"))
perfLR
# Slightly better


# Decision tees from the base installation
TMRP <- rpart(BikeBuyer ~ MaritalStatus + Gender +
              Education + Occupation +
              + NumberCarsOwned + TotalChildren +
              CommuteDistance + Region,
              data = TMTrain)
# Test the model
predDT <- predict(TMRP, TMTest, type = "class")
perfDT <- table(TMTest$BikeBuyer, predDT,
                dnn = c("Actual", "Predicted"))
perfDT
# Better for true positives

# Plot the tree
# install.packages("rpart.plot")
library(rpart.plot)
prp(TMRP, type = 2, extra = 104, fallen.leaves = FALSE);


# Decision tees from rparty
# install.packages("party")
library(party)
TMDT <- ctree(BikeBuyer ~ MaritalStatus + Gender +
              Education + Occupation +
              NumberCarsOwned + TotalChildren +
              CommuteDistance + Region,
              data = TMTrain)
# Test the model
predDT <- predict(TMDT, TMTest, type = "response")
perfDT <- table(TMTest$BikeBuyer, predDT,
                dnn = c("Actual", "Predicted"))
perfDT
# Better for true negatives

# Model evaluation
# Adding predictions
TMTest$Predicted <- predict(TMDT, newdata = TMTest)
# Calculate the overall accuracy.
TMTest$CorrectP <- TMTest$Predicted == TMTest$BikeBuyer
print(paste("Correct predictions: ",
            100 * mean(TMTest$CorrectP), "%"))

# Prediction probabilities
TMTest$Probabilities <-
  1 - unlist(treeresponse(TMDT, newdata = TMTest),
             use.names = F)[seq(1, nrow(TMTest) * 2, 2)]
# View(TMTest)

# ROC curve
# install.packages("ROCR")
library(ROCR)
pred <- prediction(TMTest$Probabilities, TMTest$BikeBuyer)
perf <- performance(pred, "tpr", "fpr")
plot(perf, main = "ROC curve", colorize = T, cex.axis = 1.3, cex.lab = 1.4, lwd = 6)


# Scalable random forest and gradient boosted decision trees
library(RevoScaleR)
# Decision forest
rxDF <- rxDForest(BikeBuyer ~ CommuteDistance +
            NumberCarsOwned + Education,
            data = TMTrain, cp = 0.01)
# Test the model
predDF <- rxPredict(rxDF, data = TMTest, type = 'response')
TMDF <- cbind(TMTest['BikeBuyer'], predDF)
# View(predDF)
perfDF <- table(TMDF$BikeBuyer, TMDF$BikeBuyer_Pred,
                dnn = c("Actual", "Predicted"))
perfDF
# Not so bad for just a few variables


# Boosted trees
rxBT <- rxBTrees(BikeBuyer ~ CommuteDistance +
            TotalChildren + NumberChildrenAtHome +
            Gender + HouseOwnerFlag +
            NumberCarsOwned + MaritalStatus +
            Age + Region + Income +
            Education + Occupation,
            data = TMTrain, cp = 0.01)
# Test the model
predBT <- rxPredict(rxBT, data = TMTest, type = 'response')
predBT['BBPredicted'] <- as.integer(predBT['BikeBuyer_prob'] >= 0.5)
TMBT <- cbind(TMTest['BikeBuyer'], predBT)
# Giving labels to BikeBuyer values
TMBT$BBPredicted <- factor(TMBT$BBPredicted,
                           levels = c(0, 1),
                           labels = c("No", "Yes"))
# View(predBT)
perfBT <- table(TMBT$BikeBuyer, TMBT$BBPredicted,
                dnn = c("Actual", "Predicted"))
perfBT
# Better for true positives
