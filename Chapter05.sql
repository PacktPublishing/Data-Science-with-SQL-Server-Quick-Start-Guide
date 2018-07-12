-- Data Science with SQL Server Quick Start Guide
-- Chapter 05

USE AdventureWorksDW2017;
GO

-- Handling NULLs
DROP TABLE IF EXISTS dbo.NULLTest;
GO
CREATE TABLE dbo.NULLTest
(
 c1 INT NULL,
 c2 INT NULL,
 c3 INT NULL
);
GO

INSERT INTO dbo.NULLTest VALUES
(1, NULL, 3),
(4, 5, 6),
(NULL, 8, 9),
(10, 11, 12),
(13, NULL, NULL);
GO

-- Data
SELECT *
FROM dbo.NULLTest;

-- ISNULL and COALESCE
SELECT c1, ISNULL(c1, 0) AS c1NULL,
 c2, c3, COALESCE(c2, c3, 99) AS c2NULL
FROM dbo.NULLTest;

-- Aggregate functions
SELECT AVG(c2) AS c2AVG, SUM(c2) AS c2SUM, COUNT(*) AS n,
 SUM(1.0*c2)/COUNT(*) AS c2SumByCount
FROM dbo.NULLTest;
GO

-- Getting dummies
SELECT TOP 3 MaritalStatus,
 IIF(MaritalStatus = 'S', 1, 0)
  AS [TM_S],
 IIF(MaritalStatus = 'M', 1, 0)
  AS [TM_M]
FROM dbo.vTargetMail;
GO


-- Binning Age
-- Data overview
SELECT MIN(Age) AS minA,
 MAX(Age) AS maxA,
 MAX(Age) - MIN(Age) AS rngA,
 AVG(Age) AS avgA,
 1.0 * (MAX(Age) - MIN(Age)) / 5 AS binwidth
FROM dbo.vTargetMail;

-- Equal width binning
DECLARE @binwidth AS NUMERIC(5,2), 
 @minA AS INT, @maxA AS INT;
SELECT @minA = MIN(AGE),
 @maxa = MAX(Age),
 @binwidth = 1.0 * (MAX(Age) - MIN(Age)) / 5
FROM dbo.vTargetMail;
SELECT CustomerKey, Age,
 CASE 
  WHEN Age >= @minA + 0 * @binwidth AND Age < @minA + 1 * @binwidth
   THEN CAST((@minA + 0 * @binwidth) AS VARCHAR(5)) + ' - ' +
        CAST((@minA + 1 * @binwidth - 1) AS VARCHAR(5))
  WHEN Age >= @minA + 1 * @binwidth AND Age < @minA + 2 * @binwidth
   THEN CAST((@minA + 1 * @binwidth) AS VARCHAR(5)) + ' - ' +
        CAST((@minA + 2 * @binwidth - 1) AS VARCHAR(5))
  WHEN Age >= @minA + 2 * @binwidth AND Age < @minA + 3 * @binwidth
   THEN CAST((@minA + 2 * @binwidth) AS VARCHAR(5)) + ' - ' +
        CAST((@minA + 3 * @binwidth - 1) AS VARCHAR(5))
  WHEN Age >= @minA + 3 * @binwidth AND Age < @minA + 4 * @binwidth
   THEN CAST((@minA + 3 * @binwidth) AS VARCHAR(5)) + ' - ' +
        CAST((@minA + 4 * @binwidth - 1) AS VARCHAR(5))
  ELSE CAST((@minA + 4 * @binwidth) AS VARCHAR(5)) + ' + '
 END AS AgeEWB
FROM dbo.vTargetMail
ORDER BY NEWID();
GO

-- Equal height binning
SELECT CustomerKey, Age,
 CAST(NTILE(5) OVER(ORDER BY Age)
  AS CHAR(1)) AS AgeEHB
FROM dbo.vTargetMail
ORDER BY NEWID();
GO

-- Custom binning
SELECT CustomerKey, Age,
 CASE 
  WHEN Age >= 17 AND Age < 23
   THEN '17 - 22'
  WHEN Age >= 23 AND Age < 30
   THEN '23 - 29'
  WHEN Age >= 29 AND Age < 40
   THEN '30 - 39'
  WHEN Age >= 40 AND Age < 55
   THEN '40 - 54'
  ELSE '54 +'
 END AS AgeCUB 
FROM dbo.vTargetMail
ORDER BY NEWID();
GO

-- Check the bins
WITH AgeCTE AS
(
SELECT CustomerKey, Age,
 CASE 
  WHEN Age >= 17 AND Age < 23
   THEN '17 - 22'
  WHEN Age >= 23 AND Age < 30
   THEN '23 - 29'
  WHEN Age >= 29 AND Age < 40
   THEN '30 - 39'
  WHEN Age >= 40 AND Age < 55
   THEN '40 - 54'
  ELSE '54 +'
 END AS AgeCUB 
FROM dbo.vTargetMail
)
SELECT AgeCUB, COUNT(*)
FROM AgeCTE
GROUP BY AgeCUB
ORDER BY AgeCUB;
GO


-- Calculating the entropy
-- Maximal entropy for different number of distinct states
-- Logarithm equation for probability = 1/3 (3 states)
-- LOG(1/3) = LOG(1) - LOG(3) = -LOG(3)
-- Entropy = (-1) * ((1/3)*(-LOG(3)) + (1/3)*(-LOG(3)) + (1/3)*(-LOG(3))) = LOG(3)
-- Simplified calculation
SELECT LOG(2,2) AS TwoStatesMax,
 LOG(3,2) AS ThreeStatesMax,
 LOG(4,2) AS FourStatesMax,
 LOG(5,2) AS FiveStatesMax;
GO

SELECT CommuteDistance, COUNT(*)
FROM dbo.vTargetMail
GROUP BY CommuteDistance;


-- Entropy of the CommuteDistance
WITH ProbabilityCTE AS
(
SELECT CommuteDistance,
 COUNT(CommuteDistance) AS StateFreq
FROM dbo.vTargetMail
GROUP BY CommuteDistance
),
StateEntropyCTE AS
(
SELECT CommuteDistance,
 1.0*StateFreq / SUM(StateFreq) OVER () AS StateProbability
FROM ProbabilityCTE
)
SELECT 'CommuteDistance' AS Variable,
 (-1)*SUM(StateProbability * LOG(StateProbability,2)) AS TotalEntropy,
 LOG(COUNT(*),2) AS MaxPossibleEntropy,
 100 * ((-1)*SUM(StateProbability * LOG(StateProbability,2))) / 
 (LOG(COUNT(*),2)) AS PctOfMaxPossibleEntropy
FROM StateEntropyCTE;
GO

-- Grouping sets
-- Coeficient of variation
SELECT g.EnglishCountryRegionName AS Country,
 GROUPING(g.EnglishCountryRegionName) AS CountryGrouping,
 c.CommuteDistance,
 GROUPING(c.CommuteDistance) AS CommuteDistanceGrouping,
 STDEV(c.YearlyIncome) / AVG(c.YearlyIncome) 
  AS CVIncome
FROM dbo.DimCustomer AS c
 INNER JOIN dbo.DimGeography AS g
  ON c.GeographyKey = g.GeographyKey
GROUP BY GROUPING SETS
(
 (g.EnglishCountryRegionName, c.CommuteDistance),
 (g.EnglishCountryRegionName),
 (c.CommuteDistance),
 ()
)
ORDER BY NEWID();
GO


-- Using rx_data_step() in T_SQL
-- With pandas data frame
EXECUTE sys.sp_execute_external_script
@language =N'Python',
@script = N'
from revoscalepy import rx_data_step
import pandas as pd
OutputDataSet = rx_data_step(input_data=InputDataSet.iloc[0:3,],
                   vars_to_keep = {"CustomerKey", "Age"})
OutputDataSet = pd.DataFrame(OutputDataSet, columns=["CustomerKey", "Age"])
',
@input_data_1 = N'SELECT CustomerKey, Age, MaritalStatus FROM dbo.vTargetMail;'
WITH RESULT SETS (( CustomerKey INT, Age INT ));
GO


-- Clean up
DROP TABLE IF EXISTS dbo.NULLTest;
GO


/***************************/
/* More code as a bonus:-) */
/***************************/

-- Rollup
SELECT g.EnglishCountryRegionName AS Country,
 g.StateProvinceName AS StateProvince,
 SUM(c.YearlyIncome) AS SumIncome
FROM dbo.DimCustomer AS c
 INNER JOIN dbo.DimGeography AS g
  ON c.GeographyKey = g.GeographyKey
GROUP BY GROUPING SETS
(
 (g.EnglishCountryRegionName, g.StateProvinceName),
 (g.EnglishCountryRegionName),
 ()
);

-- Cube and Grouping ID
SELECT 
 GROUPING_ID(c.Gender, c.MaritalStatus) AS GroupingId,
 c.Gender,
 c.MaritalStatus,
 SUM(c.YearlyIncome) AS SumIncome
FROM dbo.DimCustomer AS c
 INNER JOIN dbo.DimGeography AS g
  ON c.GeographyKey = g.GeographyKey
GROUP BY CUBE
 (c.Gender, c.MaritalStatus);
GO
