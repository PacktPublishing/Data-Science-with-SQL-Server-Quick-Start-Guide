-- Data Science with SQL Server Quick Start Guide
-- Chapter 06

USE AdventureWorksDW2017;
GO

-- Associations

-- Continuous variables

-- Covariance, correlation, coefficient of determination
WITH CoVarCTE AS
(
SELECT 1.0*NumberCarsOwned as val1,
 AVG(1.0*NumberCarsOwned) OVER () AS mean1,
 1.0*YearlyIncome AS val2,
 AVG(1.0*YearlyIncome) OVER() AS mean2
FROM dbo.vTargetMail
)
SELECT
 SUM((val1-mean1)*(val2-mean2)) / COUNT(*) AS Covar,
 (SUM((val1-mean1)*(val2-mean2)) / COUNT(*)) /
 (STDEVP(val1) * STDEVP(val2)) AS Correl,
 SQUARE((SUM((val1-mean1)*(val2-mean2)) / COUNT(*)) /
 (STDEVP(val1) * STDEVP(val2))) AS CD
FROM CoVarCTE;
GO


-- Discrete variables


-- Chi-squared
WITH
ObservedCombination_CTE AS
(
SELECT EnglishOccupation AS OnRows,
 Gender AS OnCols, 
 COUNT(*) AS ObservedCombination
FROM dbo.vTargetMail
GROUP BY EnglishOccupation, Gender
),
ExpectedCombination_CTE AS
(
SELECT OnRows, OnCols, ObservedCombination
 ,SUM(ObservedCombination) OVER (PARTITION BY OnRows) AS ObservedOnRows
 ,SUM(ObservedCombination) OVER (PARTITION BY OnCols) AS ObservedOnCols
 ,SUM(ObservedCombination) OVER () AS ObservedTotal
 ,CAST(ROUND(SUM(1.0 * ObservedCombination) OVER (PARTITION BY OnRows)
  * SUM(1.0 * ObservedCombination) OVER (PARTITION BY OnCols) 
  / SUM(1.0 * ObservedCombination) OVER (), 0) AS INT) AS ExpectedCombination
FROM ObservedCombination_CTE
)
SELECT SUM(SQUARE(ObservedCombination - ExpectedCombination)
  / ExpectedCombination) AS ChiSquared,
 (COUNT(DISTINCT OnRows) - 1) * (COUNT(DISTINCT OnCols) - 1) AS DegreesOfFreedom
FROM ExpectedCombination_CTE;
GO


-- Discrete and continuous variables

-- Is Occupation ordered?
SELECT EnglishOccupation, 
 AVG(YearlyIncome) AS Income
FROM dbo.vTargetMail
GROUP BY EnglishOccupation
ORDER BY Income;
GO

-- Anova
WITH Anova_CTE AS
(
SELECT EnglishOccupation, Age,
 COUNT(*) OVER (PARTITION BY EnglishOccupation) AS gr_CasesCount,
 DENSE_RANK() OVER (ORDER BY EnglishOccupation) AS gr_DenseRank,
 SQUARE(AVG(Age) OVER (PARTITION BY EnglishOccupation) -
        AVG(Age) OVER ()) AS between_gr_SS,
 SQUARE(Age - 
        AVG(Age) OVER (PARTITION BY EnglishOccupation)) 
		AS within_gr_SS
FROM dbo.vTargetMail
) 
SELECT N'Between groups' AS [Source of Variation],
 SUM(between_gr_SS) AS SS,
 (MAX(gr_DenseRank) - 1) AS df,
 SUM(between_gr_SS) / (MAX(gr_DenseRank) - 1) AS MS,
 (SUM(between_gr_SS) / (MAX(gr_DenseRank) - 1)) /
 (SUM(within_gr_SS) / (COUNT(*) - MAX(gr_DenseRank))) AS F
FROM Anova_CTE
UNION 
SELECT N'Within groups' AS [Source of Variation],
 SUM(within_gr_SS) AS SS,
 (COUNT(*) - MAX(gr_DenseRank)) AS df,
 SUM(within_gr_SS) / (COUNT(*) - MAX(gr_DenseRank)) AS MS,
 NULL AS F
FROM Anova_CTE;


-- Linear regression
WITH CoVarCTE AS
(
SELECT 1.0*NumberCarsOwned as val1,
 AVG(1.0*NumberCarsOwned) OVER () AS mean1,
 1.0*YearlyIncome AS val2,
 AVG(1.0*YearlyIncome) OVER() AS mean2
FROM dbo.vTargetMail
)
SELECT Slope1=
        SUM((val1 - mean1) * (val2 - mean2))
        /SUM(SQUARE((val1 - mean1))),
       Intercept1=
         MIN(mean2) - MIN(mean1) *
           (SUM((val1 - mean1)*(val2 - mean2))
            /SUM(SQUARE((val1 - mean1)))),
       Slope2=
        SUM((val1 - mean1) * (val2 - mean2))
        /SUM(SQUARE((val2 - mean2))),
       Intercept2=
         MIN(mean1) - MIN(mean2) *
           (SUM((val1 - mean1)*(val2 - mean2))
            /SUM(SQUARE((val2 - mean2))))
FROM CoVarCTE;
GO


/***************************/
/* More code as a bonus:-) */
/***************************/

-- One more chi-squared example
WITH
ObservedCombination_CTE AS
(
SELECT CommuteDistance AS OnRows,
 EnglishOccupation AS OnCols, 
 COUNT(*) AS ObservedCombination
FROM dbo.vTargetMail
GROUP BY CommuteDistance, EnglishOccupation
),
ExpectedCombination_CTE AS
(
SELECT OnRows, OnCols, ObservedCombination
 ,SUM(ObservedCombination) OVER (PARTITION BY OnRows) AS ObservedOnRows
 ,SUM(ObservedCombination) OVER (PARTITION BY OnCols) AS ObservedOnCols
 ,SUM(ObservedCombination) OVER () AS ObservedTotal
 ,CAST(ROUND(SUM(1.0 * ObservedCombination) OVER (PARTITION BY OnRows)
  * SUM(1.0 * ObservedCombination) OVER (PARTITION BY OnCols) 
  / SUM(1.0 * ObservedCombination) OVER (), 0) AS INT) AS ExpectedCombination
FROM ObservedCombination_CTE
)
SELECT SUM(SQUARE(ObservedCombination - ExpectedCombination)
  / ExpectedCombination) AS ChiSquared,
 (COUNT(DISTINCT OnRows) - 1) * (COUNT(DISTINCT OnCols) - 1) AS DegreesOfFreedom
FROM ExpectedCombination_CTE;
GO
