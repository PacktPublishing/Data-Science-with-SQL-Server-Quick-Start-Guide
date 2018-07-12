# Data Science with SQL Server Quick Start Guide
# Chapter 04

# Load RODBC library and read SQL Server data
library(RODBC)
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
TM <-
sqlQuery(con,
         "SELECT CustomerKey, CommuteDistance,
            TotalChildren, NumberChildrenAtHome, 
            Gender, HouseOwnerFlag,
            NumberCarsOwned, MaritalStatus,
            Age, YearlyIncome, BikeBuyer,
            EnglishEducation AS Education,
            EnglishOccupation AS Occupation
          FROM dbo.vTargetMail;")
close(con)
# View(TM)


# Basic distribution
table(TM$NumberCarsOwned)

# Attach a DF
attach(TM)

# Education is ordered by a custom order
Education = factor(Education, order = TRUE,
                   levels = c("Partial High School",
                            "High School", "Partial College",
                            "Bachelors", "Graduate Degree"))
# Plot
plot(Education, main = 'Education',
    xlab = 'Education', ylab = 'Number of Cases',
    col = "purple")

# Package descr
install.packages("descr")
library(descr)
freq(Education)


# A quick summary for Age
summary(Age)

# Details for Age

# Centers
mean(Age)
median(Age)

# Spread
min(Age)
max(Age)
range(Age)

quantile(Age, 1 / 4)
quantile(Age, 3 / 4)
IQR(Age)

var(Age)
sd(Age)
sd(Age) / mean(Age)

# Custom function for skewness and kurtosis
skewkurt <- function(p) {
    avg <- mean(p)
    cnt <- length(p)
    stdev <- sd(p)
    skew <- sum((p - avg) ^ 3 / stdev ^ 3) / cnt
    kurt <- sum((p - avg) ^ 4 / stdev ^ 4) / cnt - 3
    return(c(skewness = skew, kurtosis = kurt))
}
skewkurt(Age)


###########################
# More code as a bonus:-) #
###########################

# 2X2 grid graphs
# Generating a subset data frame
cols1 <- c("CustomerKey", "NumberCarsOwned", "TotalChildren")
TM1 <- TM[TM$CustomerKey < 11010, cols1]
names(TM1) <- c("CustomerKey1", "NumberCarsOwned1", "TotalChildren1")
attach(TM1)

# Generating a table from NumberCarsOwned and BikeBuyer
nofcases <- table(NumberCarsOwned, BikeBuyer)
nofcases

# Saving parameters
oldpar <- par(no.readonly = TRUE)

# Defining a 2x2 graph
par(mfrow = c(2, 2))

# Education and marital status
plot(Education, MaritalStatus,
     main = 'Education and marital status',
     xlab = 'Education', ylab = 'Marital Status',
     col = c("blue", "yellow"))


# Histogram with a title and axis labels and color
hist(NumberCarsOwned, main = 'Number of cars owned',
     xlab = 'Number of Cars Owned', ylab = 'Number of Cases',
     col = "blue")

# Plot with two lines, title, legend, and axis legends
plot_colors = c("blue", "red")
plot(TotalChildren1,
     type = "o", col = 'blue', lwd = 2,
     xlab = "Key", ylab = "Number")
lines(NumberCarsOwned1,
      type = "o", col = 'red', lwd = 2)
legend("topleft",
       c("TotalChildren", "NumberCarsOwned"),
       cex = 1.4, col = plot_colors, lty = 1:2, lwd = 1, bty = "n")
title(main = "Total children and number of cars owned line chart",
      col.main = "DarkGreen", font.main = 4)

# NumberCarsOwned and BikeBuyer grouped bars
barplot(nofcases,
        main = 'Number of cars owned and bike buyer gruped',
        xlab = 'BikeBuyer', ylab = 'NumberCarsOwned',
        col = c("black", "blue", "red", "orange", "yellow"),
        beside = TRUE)
legend("topright", legend = rownames(nofcases),
       fill = c("black", "blue", "red", "orange", "yellow"),
       ncol = 1, cex = 0.75)

# Restoring the default graphical parameters
par(oldpar)
# 2X2 grid graphs

# geometric and harmonic mean
# Package psych
install.packages("psych")
library(psych)
geometric.mean(Age)
harmonic.mean(Age)


# Drawing different distributions

# Normal distribution
n <- 10000;
x <- rnorm(n);
hist(x,
     xlim = c(min(x), max(x)), probability = T, nclass = 27,
     col = 'light yellow', xlab = ' ', ylab = ' ', axes = F,
     main = 'Normal Distribution');
lines(density(x), col = 'dark blue', lwd = 3);

# Positively skewed distribution
n <- 10000;
x <- rnbinom(n, 10, .5);
hist(x,
     xlim = c(min(x), max(x)), probability = T, nclass = max(x) - min(x) + 1,
     col = 'light yellow', xlab = ' ', ylab = ' ', axes = F,
     main = 'Positively Skewed Distribution');
lines(density(x, bw = 1), col = 'dark blue', lwd = 3);

# Peaked distribution
install.packages("SuppDists");
require(SuppDists);
parms <- JohnsonFit(c(0, 1, 0, 5), moment = "use");
x <- rJohnson(1000, parms);
hist(x, main = 'Tailed Distribution',
     xlim = c(min(x), max(x)), probability = T, nclass = 40,
     col = 'light yellow', xlab = ' ', ylab = ' ', axes = F);
lines(density(x, bw = 0.3), col = 'dark blue', lwd = 3);
