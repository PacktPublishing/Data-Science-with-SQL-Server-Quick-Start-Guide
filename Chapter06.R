# Data Science with SQL Server Quick Start Guide
# Chapter 06

# Load RODBC library and read SQL Server data
library(RODBC)
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

# Continuous variables

# Correlation
x <- TM[, c("Income", "Age")]
cov(x)
cor(x)

# Two matrices correlations
y <- TM[, c("NumberCarsOwned", "NumberChildrenAtHome")]
cor(y, x)

# Visualizing the correlations
z <- TM[, c("NumberCarsOwned", "NumberChildrenAtHome", "Age")]
# install.packages("corrgram")
library(corrgram)
corrgram(z, order = TRUE, lower.panel = panel.shade,
         upper.panel = panel.shade, text.panel = panel.txt,
         cor.method = "pearson", main = "Corrgram")


# Discrete variables

# Order CommuteDistance
TM$CommuteDistance = factor(TM$CommuteDistance, order = TRUE,
                     levels = c("0-1 Miles",
                                "1-2 Miles", "2-5 Miles",
                               "5-10 Miles", "10+ Miles"))
# Let's order the Occupation according to the Income
TM$Occupation = factor(TM$Occupation, order = TRUE,
                levels = c("Manual", 
                           "Clerical","Skilled Manual", 
                           "Professional", "Management"))

# Crosstabluation with xtabs
xtabs(~TM$Occupation + TM$CommuteDistance)

# Storing tables in objects
tEduGen <- xtabs(~TM$Education + TM$Gender)
tOccCdi <- xtabs(~TM$Occupation + TM$CommuteDistance)
# Test of independece
chisq.test(tEduGen)
chisq.test(tOccCdi)

# Showing with ggplot
# install.packages("ggplot2")
library(ggplot2)
ggplot(TM, aes(x = CommuteDistance, fill = Occupation)) +
 geom_bar(stat = "count") +
 scale_fill_manual(values = c("yellow", "blue", "red", "green", "black")) +
 theme(text = element_text(size = 15));


# Discrete and continuous variables

# One-way ANOVA
aggregate(TM$Income, by = list(TM$CommuteDistance), FUN = mean)
AssocTest <- aov(TM$Income ~ TM$CommuteDistance)
summary(AssocTest)

# Load gplots
# install.packages("gplots")
# gplots usually preinstalled
library(gplots)
plotmeans(TM$Income ~ TM$CommuteDistance,
          bars = TRUE, p = 0.99, barwidth = 3,
          col = "red", lwd = 3,
          main = "Yearly Income in Groups",
          ylab = "Yearly Income",
          xlab = "Commute Distance")


# Linear regression
# Age and Income ith ggplot an loess line
# First create a smaller sample
TMSample <- TM[sample(nrow(TM), 100), c("Income", "Age")];
ggplot(data = TMSample, aes(x = Age, y = Income)) +
  geom_point() +
  geom_smooth(method = "lm", color = "red") +
  geom_smooth(color = "blue")

# Polynomial  regression
lrPoly <- lm(TM$Income ~ TM$Age + I(TM$Age ^ 2));
summary(lrPoly);


###########################
# More code as a bonus:-) #
###########################

# Some scalable functions demo
# RevoScaleR
library(RevoScaleR)

# Info about the data frame and the variables
rxGetInfo(TM)
rxGetVarInfo(TM)

# Compute summary statistics 
sumOut <- rxSummary(
  formula = ~Income + CommuteDistance + F(BikeBuyer),
  data = TM)
sumOut

# Crosstabulation 
table(TM$Occupation, TM$CommuteDistance)

cTabs <- rxCrossTabs(formula = ~Occupation:CommuteDistance,
                     data = TM)
# Check the results
print(cTabs, output = "counts")
summary(cTabs, output = "counts")

# Crosstabulation in a different way
cCube <- rxCube(formula = ~
                Occupation:CommuteDistance,
                data = TM)
# Check the results
cCube


# Visualizing ANOVA with a boxplot
boxplot(TM$Income ~ TM$CommuteDistance,
        main = "Yearly Income in Groups",
        notch = TRUE,
        varwidth = TRUE,
        col = "orange",
        ylab = "Yearly Income",
        xlab = "Commute Distance")
