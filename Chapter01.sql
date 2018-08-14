-- Data Science with SQL Server Quick Start Guide
-- Chapter 01

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

-- SELECT *
USE AdventureWorksDW2017;
GO
SELECT *
FROM dbo.DimEmployee;
-- 296 rows

-- Explicit columns
SELECT EmployeeKey, FirstName, LastName
FROM dbo.DimEmployee;
-- 296 rows

-- Delimited identifiers and column aliases
SELECT EmployeeKey, 
 FirstName + ' ' + LastName AS [Full Name]
INTO dbo.EmpFUll
FROM dbo.DimEmployee;
GO
SELECT EmployeeKey, [Full Name]
FROM dbo.EmpFUll;
GO

-- Filter
SELECT EmployeeKey, FirstName, LastName
FROM dbo.DimEmployee
WHERE SalesPersonFlag = 1;
-- 17 rows

-- Inner join, table aliases
SELECT e.EmployeeKey, e.FirstName, e.LastName,
 fr.SalesAmount
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey;
-- 60855 rows

-- How many rows in the fact table?
SELECT COUNT(*) AS ResellerSalesCount
FROM dbo.FactResellerSales;
-- 60855 rows


-- More inner joins
SELECT e.EmployeeKey, e.FirstName, e.LastName,
 r.ResellerKey, r.ResellerName,
 d.DateKey, d.CalendarYear, d.CalendarQuarter,
 p.ProductKey, p.EnglishProductName,
 ps.EnglishProductSubcategoryName,
 pc.EnglishProductCategoryName,
 fr.OrderQuantity, fr.SalesAmount
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey
 INNER JOIN dbo.DimReseller AS r
  ON r.ResellerKey = fr.ResellerKey
 INNER JOIN dbo.DimDate AS d
  ON fr.OrderDateKey = d.DateKey
 INNER JOIN dbo.DimProduct AS p
  ON fr.ProductKey = p.ProductKey
 INNER JOIN dbo.DimProductSubcategory AS ps
  ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
 INNER JOIN dbo.DimProductCategory AS pc
  ON ps.ProductCategoryKey = pc.ProductCategoryKey;
-- 60855 rows


-- Distinct EmployeeKey 
SELECT DISTINCT fr.EmployeeKey
FROM dbo.FactResellerSales AS fr;
-- 17 rows (sales people only)

-- Outer join
SELECT e.EmployeeKey, e.FirstName, e.LastName,
 fr.SalesAmount
FROM dbo.DimEmployee AS e
 LEFT OUTER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey;
-- 61134 rows

-- Distinct EmployeeKey after the outer join
SELECT DISTINCT e.EmployeeKey
FROM dbo.DimEmployee AS e
 LEFT OUTER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey;
-- 296 rows (all employees)

-- Outer join  - controlling the join order, 
-- using the right outer join
SELECT e.EmployeeKey, e.FirstName, e.LastName,
 r.ResellerKey, r.ResellerName,
 d.DateKey, d.CalendarYear, d.CalendarQuarter,
 p.ProductKey, p.EnglishProductName,
 ps.EnglishProductSubcategoryName,
 pc.EnglishProductCategoryName,
 fr.OrderQuantity, fr.SalesAmount
FROM (dbo.FactResellerSales AS fr
 INNER JOIN dbo.DimReseller AS r
  ON r.ResellerKey = fr.ResellerKey
 INNER JOIN dbo.DimDate AS d
  ON fr.OrderDateKey = d.DateKey
 INNER JOIN dbo.DimProduct AS p
  ON fr.ProductKey = p.ProductKey
 INNER JOIN dbo.DimProductSubcategory AS ps
  ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
 INNER JOIN dbo.DimProductCategory AS pc
  ON ps.ProductCategoryKey = pc.ProductCategoryKey)
 RIGHT OUTER JOIN dbo.DimEmployee AS e
  ON e.EmployeeKey = fr.EmployeeKey;
-- 61134 rows

-- Aggregating data
SELECT e.EmployeeKey, 
 MIN(e.LastName) AS LastName,
 SUM(fr.OrderQuantity) AS EmpTotalQuantity, 
 SUM(fr.SalesAmount) AS EmpTotalAmount
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey
GROUP BY e.EmployeeKey;
-- 17 rows

-- Filter aggregated data
SELECT e.EmployeeKey, 
 MIN(e.LastName) AS LastName,
 SUM(fr.OrderQuantity) AS EmpTotalQuantity, 
 SUM(fr.SalesAmount) AS EmpTotalAmount
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey
GROUP BY e.EmployeeKey
HAVING SUM(fr.OrderQuantity) < 10000;
-- 8 rows

-- Ordering rows
SELECT e.EmployeeKey, 
 MIN(e.LastName) AS LastName,
 SUM(fr.OrderQuantity) AS EmpTotalQuantity, 
 SUM(fr.SalesAmount) AS EmpTotalAmount
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey
GROUP BY e.EmployeeKey
HAVING SUM(fr.OrderQuantity) > 10000
ORDER BY EmpTotalQuantity DESC;
-- 9 rows

-- Subquery and cross join
SELECT e.EmployeeKey, e.LastName,
 fr.SalesAmount,
 (SELECT SUM(fr1.SalesAmount) 
  FROM dbo.FactResellerSales AS fr1
  WHERE fr1.EmployeeKey = e.EmployeeKey)
  AS TotalPerEmployee,
 frt.GrandTotal
FROM (dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey)
 CROSS JOIN
  (SELECT SUM(fr2.SalesAmount) AS GrandTotal
   FROM dbo.FactResellerSales AS fr2) AS frt
ORDER BY e.EmployeeKey;

-- Window aggregate functions
SELECT e.EmployeeKey, e.LastName,
 fr.SalesAmount,
 SUM(fr.SalesAmount) OVER(PARTITION BY e.EmployeeKey) 
  AS TotalPerEmployee,
 SUM(fr.SalesAmount) OVER()
 AS GrandTotal
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey
ORDER BY e.EmployeeKey;

-- Common table expression
WITH EmpTotalCTE AS
(
SELECT e.EmployeeKey,
 MIN(e.LastName) AS LastName,
 SUM(fr.SalesAmount) AS TotalPerEmployee
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey
GROUP BY e.EmployeeKey
)
SELECT EmployeeKey, LastName, 
 TotalPerEmployee
FROM EmpTotalCTE
ORDER BY EmployeeKey;

-- Running total and moving average over employees
WITH EmpTotalCTE AS
(
SELECT e.EmployeeKey,
 MIN(e.LastName) AS LastName,
 SUM(fr.SalesAmount) AS TotalPerEmployee
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey
GROUP BY e.EmployeeKey
)
SELECT EmployeeKey, LastName,
 TotalPerEmployee,
 SUM(TotalPerEmployee) 
  OVER(ORDER BY EmploYeeKey
       ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW)
  AS RunningTotal,
 AVG(TotalPerEmployee) 
  OVER(ORDER BY EmploYeeKey
       ROWS BETWEEN 2 PRECEDING
                AND CURRENT ROW)
  AS MovingAverage
FROM EmpTotalCTE
ORDER BY EmployeeKey;

-- Check the sum and the average of the first two lines
SELECT 1092123.8562 + 9293903.0055,
 (1092123.8562 + 9293903.0055) / 2
-- 10386026.8617, 5193013.4308

-- Ranking functions
WITH EmpResTotalCTE AS
(
SELECT e.EmployeeKey, r.ResellerKey,
 MIN(e.LastName) AS LastName,
 MIN(r.ResellerName) AS ResellerName,
 SUM(fr.SalesAmount) AS EmpResTotal
FROM dbo.DimEmployee AS e
 INNER JOIN dbo.FactResellerSales AS fr
  ON e.EmployeeKey = fr.EmployeeKey
 INNER JOIN dbo.DimReseller AS r
  ON r.ResellerKey = fr.ResellerKey
GROUP BY e.EmployeeKey, r.ResellerKey
)
SELECT EmployeeKey, LastName,
 ResellerName, EmpResTotal,
 ROW_NUMBER() 
  OVER(PARTITION BY EmployeeKey ORDER BY EmpResTotal DESC)
  AS PositionByEmployee
FROM EmpResTotalCTE
ORDER BY EmployeeKey, EmpResTotal DESC;

-- OFFSET...FETCXH
SELECT SalesOrderNumber, 
 SalesOrderLineNumber,
 SalesAmount
FROM dbo.FactResellerSales
ORDER BY SalesAmount DESC
OFFSET 0 ROWS FETCH NEXT 6 ROWS ONLY;

-- TOP with ties
SELECT TOP 6 WITH TIES
 SalesOrderNumber, SalesOrderLineNumber,
 SalesAmount
FROM dbo.FactResellerSales
ORDER BY SalesAmount DESC;
-- 7 rows

-- APPLY

-- 1. TOP 3 resellers for an employee
SELECT TOP 3
 fr.EmployeeKey, fr.ResellerKey,
 SUM(fr.SalesAmount) AS EmpResTotal
FROM dbo.FactResellerSales AS fr
WHERE fr.EmployeeKey = 272
GROUP BY fr.EmployeeKey, fr.ResellerKey
ORDER BY EmpResTotal DESC;

-- 2. TOP 3 resellers for each employee
SELECT e.EmployeeKey, e.LastName,
 fr1.ResellerKey, fr1.EmpResTotal
FROM dbo.DimEmployee AS e
 CROSS APPLY
 (SELECT TOP 3
   fr.EmployeeKey, fr.ResellerKey,
   SUM(fr.SalesAmount) AS EmpResTotal
  FROM dbo.FactResellerSales AS fr
  WHERE fr.EmployeeKey = e.EmployeeKey
  GROUP BY fr.EmployeeKey, fr.ResellerKey
  ORDER BY EmpResTotal DESC) AS fr1
ORDER BY e.EmployeeKey, fr1.EmpResTotal DESC;
GO
-- 51 rows

-- Clean up
DROP TABLE dbo.EmpFUll;
GO
