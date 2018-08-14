# Data Science with SQL Server Quick Start Guide
# Chapter 02

# R version and contributors
R.version.string
contributors()

# Help options
help()          # Getting help on help
help.start()    # General help
help("options") # Help about global options
help("exp")     # Help on the function exp()
?"exp"          # Help on the function exp()
example("exp")  # Examples for the function exp()
help.search("constants") # Search
?? "constants"           # Search
RSiteSearch("exp")       # Online search

# Demonstrate graphics capabilities
demo("graphics")

# Pie chart example
pie.sales <- c(0.12, 0.3, 0.26, 0.16, 0.04, 0.12)
names(pie.sales) <- c("Blueberry", "Cherry", "Apple",
                      "Boston Cream", "Other", "Vanilla Cream")
pie(pie.sales,
    col = c("purple", "violetred1", "green3", "cornsilk", "cyan", "white"))
title(main = "January Pie Sales", cex.main = 1.8, font.main = 1)
title(xlab = "(Don't try this at home kids)", cex.lab = 0.8, font.lab = 3)

# Listing the objects
objects()
ls()
# Get working folder
getwd()

# Divert R output to a file
sink("C:\\DataScienceSQLServer\\Chapter02.txt")
getwd()
sink()

# Basic expressions
1 + 2
2 + 5 * 4
3 ^ 4
sqrt(81)
pi

# Check the built-in constants
?? "constants"

# Sequences
rep(1, 5)
4:8
seq(4, 8)
seq(4, 20, by = 3)

# Variables
x <- 2
y <- 3
z <- 4
x + y * z

# Names are case-sensitive
X + Y + Z

# Can use period
This.Year <- 2018
This.Year

# Equals as an assignment operator
x = 2
y = 3
z = 4
x + y * z
# Boolean equality test
x <- 2
x == 2

# Vectors
x <- c(2, 0, 0, 4)
assign("y", c(1, 9, 9, 9))
c(5, 4, 3, 2) -> z
q = c(1, 2, 3, 4)

# Vector operations
x + y
x * 4
sqrt(x)

# Vector elements operations
x <- c(2, 0, 0, 4)
x[1]          # Selects the first element
x[-1]         # Excludes the first element
x[1] <- 3     # Assigns a value to the first element
x             # Shows the vector
x[-1] = 5     # Assigns a value to all other elements
x             # Shows the vector

# Vector elements logical operations
y <- c(1, 9, 9, 9)
y < 8         # Compares each element, returns result as vector
y[4] = 1      # Assigns a value to the first element
y < 8         # Compares each element, returns result as vector
y[y < 8] = 2  # Edits elements marked as TRUE in index vector
y             # Shows the vector

# Check the installed packages
installed.packages()
# Library location
.libPaths()
library()

# Reading from SQL Server
# Install RODBC library
install.packages("RODBC")
# Load RODBC library
library(RODBC)
# Getting help about RODBC
help(package = "RODBC")

# Ad-hoc connection
con <- odbcDriverConnect('driver={SQL Server};server=SQL2017EIM;
    database=AdventureWorksDW2017;uid=RUser;pwd=Pa$$w0rd')

# DSN connection
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
# Read SQL Server data
sqlQuery(con,
         "SELECT CustomerKey,
            EnglishEducation AS Education,
            Age, NumberCarsOwned, BikeBuyer
          FROM dbo.vTargetMail;")
close(con)

# Matrix
x = c(1, 2, 3, 4, 5, 6); x
Y = array(x, dim = c(2, 3)); Y
Z = matrix(x, 2, 3, byrow = F); Z
U = matrix(x, 2, 3, byrow = T); U

# Using explicit names
rnames = c("rrr1", "rrr2")
cnames = c("ccc1", "ccc2", "ccc3")
V = matrix(x, 2, 3, byrow = T,
    dimnames = list(rnames, cnames))
V

# Elements of a matrix
U[1,]
U[1, c(2, 3)]
U[, c(2, 3)]
V[, c("ccc2", "ccc3")]

# Array
rnames = c("rrr1", "rrr2")
cnames = c("ccc1", "ccc2", "ccc3")
pnames = c("ppp1", "ppp2", "ppp3")
Y = array(1:18, dim = c(2, 3, 3),
    dimnames = list(rnames, cnames, pnames))
Y

# Factor
x = c("good", "moderate", "good", "bad", "bad", "good")
y = factor(x); y
z = factor(x, order = TRUE); z
w = factor(x, order = TRUE,
           levels = c("bad", "moderate", "good")); w

# List
L = list(name1 = "ABC", name2 = "DEF",
         no.children = 2, children.ages = c(3, 6))
L
L[[1]]
L[[4]]
L[[4]][2]

# Data frame
CategoryId = c(1, 2, 3, 4)
CategoryName = c("Bikes", "Components", "Clothing", "Accessories")
ProductCategories = data.frame(CategoryId, CategoryName)
ProductCategories

# Reading in a data frame from SQL Server
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
TM <-
sqlQuery(con,
         "SELECT CustomerKey,
            EnglishEducation AS Education,
            Age, NumberCarsOwned, BikeBuyer
          FROM dbo.vTargetMail;")
close(con)
TM[1:5, 1:5]

# Check the complete data frame
View(TM)

# Crosstabulation of BikeBuyer and NumberCarsOwned
table(TM$NumberCarsOwned, TM$BikeBuyer)
