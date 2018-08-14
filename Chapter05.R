# Data Science with SQL Server Quick Start Guide
# Chapter 05

# Handling NULLs
library(RODBC)
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
NULLTest <-
sqlQuery(con,
         "SELECT c1, c2, c3
          FROM dbo.NULLTest;")
close(con)
NULLTest

# Working with NULLs
na.omit(NULLTest)
is.na(NULLTest)

# Aggregate functions
mean(NULLTest$c2)
mean(NULLTest$c2, na.rm=TRUE)


# Data manipulation
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
TM <-
sqlQuery(con,
         "SELECT CustomerKey, CommuteDistance,
            TotalChildren, NumberChildrenAtHome, 
            Gender, HouseOwnerFlag, MaritalStatus,
            NumberCarsOwned, MaritalStatus,
            Age, YearlyIncome, BikeBuyer,
            EnglishEducation AS Education,
            EnglishOccupation AS Occupation
          FROM dbo.vTargetMail;")
close(con)
# View(TM)


# Get dummies in R
install.packages("dummies")
library(dummies)
# Create the dummies
TM1 <- cbind(TM, dummy(TM$MaritalStatus, sep = "_"))
tail(TM1[c("MaritalStatus", "TM_S", "TM_M")], 3)

# Equal width binning
TM["AgeEWB"] = cut(TM$Age, 5)
table(TM$AgeEWB)

# Equal height binning - a function
EHBinning <- function(data, nofbins) {
    bincases <- rep(length(data) %/% nofbins, nofbins)
    bincases <- bincases + ifelse(1:nofbins <= length(data) %% nofbins, 1, 0)
    bin <- rep(1:nofbins, bincases)
    bin <- bin[rank(data, ties.method = "last")]
    return(factor(bin, levels = 1:nofbins, ordered = TRUE))
}
TM["AgeEHB"] = EHBinning(TM$Age, 5)
table(TM$AgeEHB)

# Histogram from RevoScaleR
library("RevoScaleR")
rxHistogram(formula = ~AgeEHB,
            data = TM)

# Custom binning
TM["AgeCUB"] = cut(TM$Age, c(16, 22, 29, 39, 54, 88))
table(TM$AgeCUB)


# Entropy (install only if needed) from DescTools
install.packages("DescTools")
library("DescTools")
# Entropy
NCO = table(TM$NumberCarsOwned)
print(c(Entropy(NCO), log2(5), Entropy(NCO) / log2(5)))
BBT = table(TM$BikeBuyer)
print(c(Entropy(BBT), log2(2), Entropy(BBT) / log2(2)))



# Connecting and reading the data
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
TM <- as.data.frame(sqlQuery(con,
  "SELECT c.CustomerKey,
    g.EnglishCountryRegionName AS Country,
    c.EnglishEducation AS Education,
    c.YearlyIncome AS Income,
    c.NumberCarsOwned AS Cars,
    C.MaritalStatus,
    c.NumberChildrenAtHome
   FROM dbo.DimCustomer AS c
    INNER JOIN dbo.DimGeography AS g
     ON c.GeographyKey = g.GeographyKey;"),
  stringsAsFactors = TRUE)
close(con)

# Package dplyr
install.packages("dplyr")
library(dplyr)

# Projection
head(TM)
head(select(TM, Income:MaritalStatus))
head(select(TM, - Income))
head(select(TM, starts_with("C")))

# Filter
# All data frame has 18484 cases
count(TM)
# 2906 cases with more than 2 cars
count(filter(TM, Cars > 2))
# Check
table(TM$Cars)

# Sort
head(arrange(TM, desc(CustomerKey)))

# Pipe operator
TM %>%
select(starts_with("C")) %>%
filter(Cars > 2) %>%
count

# Projection, filter, sort
TM %>%
select(starts_with("C")) %>%
filter(Cars > 2) %>%
arrange(desc(CustomerKey)) %>%
head

# Adding a column
TM %>%
filter(Cars > 0) %>%
mutate(PartnerExists = as.integer(ifelse(MaritalStatus == 'S', 0, 1))) %>%
mutate(HouseHoldNumber = 1 + PartnerExists + NumberChildrenAtHome) %>%
select(CustomerKey, Country, HouseHoldNumber, Cars) %>%
arrange(desc(CustomerKey)) %>%
head

# Aggregating
TM %>%
filter(Cars > 0) %>%
mutate(PartnerExists = as.integer(ifelse(MaritalStatus == 'S', 0, 1))) %>%
mutate(HouseHoldNumber = 1 + PartnerExists + NumberChildrenAtHome) %>%
select(CustomerKey, Country, HouseHoldNumber, Cars) %>%
summarise(avgCars = mean(Cars),
    avgHouseHoldNumber = mean(HouseHoldNumber))

# Grouping and aggregating
TM %>%
filter(Cars > 0) %>%
mutate(PartnerExists = as.integer(ifelse(MaritalStatus == 'S', 0, 1))) %>%
mutate(HouseHoldNumber = 1 + PartnerExists + NumberChildrenAtHome) %>%
select(CustomerKey, Country, HouseHoldNumber, Cars) %>%
group_by(Country) %>%
summarise(avgCars = mean(Cars),
    avgHouseHoldNumber = mean(HouseHoldNumber)) %>%
arrange(desc(Country))

# Storing in a df
TM1 =
TM %>%
filter(Cars > 0) %>%
mutate(PartnerExists = as.integer(ifelse(MaritalStatus == 'S', 0, 1))) %>%
mutate(HouseHoldNumber = 1 + PartnerExists + NumberChildrenAtHome) %>%
select(CustomerKey, Country, HouseHoldNumber, Cars) %>%
group_by(Country) %>%
summarise(avgCars = mean(Cars),
    avgHouseHoldNumber = mean(HouseHoldNumber)) %>%
arrange(desc(Country))
TM1

# Basic scatterplot
plot(TM1$avgCars ~ TM1$avgHouseHoldNumber, cex = 2, lwd = 2)


# Package Car scatterplot
install.packages("car")
library(car)
scatterplot(avgCars ~ avgHouseHoldNumber | Country,
    data = TM1,
    xlab = "HouseHoldNumber Avg", ylab = "Cars Avg",
    main = "Enhanced Scatter Plot",
    cex = 3.5, lwd = 15,
    cex.lab = 1.3,
    xlim = c(2.2, 3.6), ylim = c(1.7, 2.2),
    col = c('red', 'blue', 'green', 'black', 'orange', 'magenta'),
    boxplot = 'xy')


###########################
# More code as a bonus:-) #
###########################

# Equal height binning explained - step by step
# Lower limit for the number of cases in a bin
length(TM$Age) %/% 5
# Create the vector of the bins with number of cases
rep(length(TM$Age) %/% 5, 5)
# How many bins need a case more
length(TM$Age) %% 5
# Array to add cases to the first 4 bins
ifelse(1:5 <= length(TM$Age) %% 5, 1, 0)

# Projections
cols1 <- c("CustomerKey", "MaritalStatus")
TM1 <- TM[cols1]
cols2 <- c("CustomerKey", "Gender")
TM2 <- TM[cols2]
TM1[1:3, 1:2]
TM2[1:3, 1:2]

# Merge datasets
TM3 <- merge(TM1, TM2, by = "CustomerKey")
TM3[1:3, 1:3]

# Binding datasets
TM4 <- cbind(TM1, TM2)
TM4[1:3, 1:4]

# Filtering and row binding data
TM1 <- TM[TM$CustomerKey < 11002, cols1]
TM2 <- TM[TM$CustomerKey > 29481, cols1]
TM5 <- rbind(TM1, TM2)
TM5

# Aggregations in groups
aggregate(TM$Income, by = list(TM$Country), FUN = sum)

# More grouping
aggregate(TM$Income,
    by = list(TM$Country, TM$Education),
    FUN = mean)

# Filtering aggregations
TMAGG <- aggregate(list(Income = TM$Income),
    by = list(Country = TM$Country), FUN = median)
TMAGG[TMAGG$Income > 60000,]

# Plot the income median over countries
barplot(TMAGG$Income,
    legend = TMAGG$Country,
    col = c('blue', 'yellow', 'red', 'green', 'magenta', 'black'))
