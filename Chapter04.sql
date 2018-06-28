-- Data Science with SQL Server Quick Start Guide
-- Chapter 04

USE AdventureWorksDW2017;
GO

-- Frequencies
WITH freqCTE AS
(
SELECT v.NumberCarsOwned,
 COUNT(v.NumberCarsOwned) AS AbsFreq,
 CAST(ROUND(100. * (COUNT(v.NumberCarsOwned)) /
       (SELECT COUNT(*) FROM vTargetMail), 0) AS INT) AS AbsPerc
FROM dbo.vTargetMail AS v
GROUP BY v.NumberCarsOwned
)
SELECT NumberCarsOwned,
 AbsFreq,
 SUM(AbsFreq) 
  OVER(ORDER BY NumberCarsOwned 
       ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW) AS CumFreq,
 AbsPerc,
 SUM(AbsPerc)
  OVER(ORDER BY NumberCarsOwned
       ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW) AS CumPerc,
 CAST(REPLICATE('*',AbsPerc) AS VARCHAR(50)) AS Histogram
FROM freqCTE
ORDER BY NumberCarsOwned;


-- Centers

/* Make customers  15 years younger
USE AdventureWorksDW2017;
GO

SELECT MIN(Age), MAX(Age)
FROM dbo.vTargetMail;

UPDATE dbo.DimCustomer
   SET BirthDate = DATEADD(year, 15, BirthDate)

SELECT MIN(Age), MAX(Age)
FROM dbo.vTargetMail;
GO
-- 16 TO 87
*/

-- Median
SELECT DISTINCT
 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Age) OVER () AS Median
FROM dbo.vTargetMail;

-- Arithmetic mean
SELECT AVG(1.0*Age) AS Mean
FROM dbo.vtargetMail;


-- Spread

-- Range
SELECT MAX(Age) - MIN(Age) AS Range
FROM dbo.vTargetMail;

-- IQR
SELECT DISTINCT
 PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY 1.0*Age) OVER () -
 PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY 1.0*Age) OVER () AS IQR
FROM dbo.vTargetMail;

-- Standard deviation, coefficient of variation
SELECT STDEV(1.0*Age) AS StDevAge,
 STDEV(1.0*YearlyIncome) AS StDevIncome,
 STDEV(1.0*Age) / AVG(1.0*Age) AS CVAge,
 STDEV(1.0*YearlyIncome) / AVG(1.0*YearlyIncome) AS CVIncome
FROM dbo.vTargetMail;
GO


-- Higher population moments

-- Skewness
WITH SkewCTE AS
(
SELECT SUM(1.0*Age) AS rx,
 SUM(POWER(1.0*Age,2)) AS rx2,
 SUM(POWER(1.0*Age,3)) AS rx3,
 COUNT(1.0*Age) AS rn,
 STDEV(1.0*Age) AS stdv,
 AVG(1.0*Age) AS av
FROM dbo.vTargetMail
)
SELECT
   (rx3 - 3*rx2*av + 3*rx*av*av - rn*av*av*av)
   / (stdv*stdv*stdv) * rn / (rn-1) / (rn-2) AS Skewness
FROM SkewCTE;

-- Kurtosis
WITH KurtCTE AS
(
SELECT SUM(1.0*Age) AS rx,
 SUM(POWER(1.0*Age,2)) AS rx2,
 SUM(POWER(1.0*Age,3)) AS rx3,
 SUM(POWER(1.0*Age,4)) AS rx4,
 COUNT(1.0*Age) AS rn,
 STDEV(1.0*Age) AS stdv,
 AVG(1.*Age) AS av
FROM dbo.vTargetMail
)
SELECT
   (rx4 - 4*rx3*av + 6*rx2*av*av - 4*rx*av*av*av + rn*av*av*av*av)
   / (stdv*stdv*stdv*stdv) * rn * (rn+1) / (rn-1) / (rn-2) / (rn-3)
   - 3.0 * (rn-1) * (rn-1) / (rn-2) / (rn-3) AS Kurtosis
FROM KurtCTE;
GO


/***************************/
/* More code as a bonus:-) */
/***************************/

-- Mode
SELECT TOP (1) WITH TIES Age, COUNT(*) AS Number
FROM dbo.vTargetMail
GROUP BY Age
ORDER BY COUNT(*) DESC;
-- Mode with RANK()
WITH AgeCTE AS
(
SELECT Age, COUNT(*) AS Number
FROM dbo.vTargetMail
GROUP BY Age
),
AgeRankCTE AS
(
SELECT Age, Number,
 RANK() OVER (ORDER BY Number DESC) AS AgeRank
FROM AgeCTE
)
SELECT Age, Number
FROM AgeRankCTE
WHERE AgeRank = 1;


-- Geometric mean
SELECT POWER(10.0000, SUM(LOG10(1.0*Age))/COUNT(*)) AS GeometricMean
FROM dbo.vtargetMail;

-- Harmonic mean
SELECT COUNT(*)/SUM(1.0/Age) AS HarmonicMean
FROM dbo.vtargetMail;
GO
