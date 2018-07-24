-- Data Science with SQL Server Quick Start Guide
-- Chapter 07

USE AdventureWorksDW2017;
GO

-- Install an R package in SQL Server ML Services
-- Check the installed packages
EXECUTE sys.sp_execute_external_script
@language=N'R',
@script =
N'str(OutputDataSet);
instpack <- installed.packages();
NameOnly <- instpack[,1];
OutputDataSet <- as.data.frame(NameOnly);'
WITH RESULT SETS (
 ( PackageName nvarchar(20) ) 
);
GO
-- 57 rows the first time
-- No dplyr package
-- Install the dplyr package with R.exe (run as admin)
-- Re-check the installed packages - dplyr should appear
-- 65 rows the second time
-- q() the R.exe


-- Install a Python package in SQL Server ML Services
-- Check the installed packages
EXECUTE sys.sp_execute_external_script 
  @language = N'Python', 
  @script = N'
import pip
import pandas as pd
instpack = pip.get_installed_distributions()
instpacksort = sorted(["%s==%s" % (i.key, i.version)
   for i in instpack])
dfPackages = pd.DataFrame(instpacksort)
OutputDataSet = dfPackages'
WITH RESULT SETS (
 ( PackageNameVersion nvarchar (150) )
);
GO
-- 128 rows the first time
-- No cntk package
-- Install the cntk package with VS 2017 - check the correct environment
-- Re-check the installed packages - cntk should appear
-- 129 rows the second time


-- Association rules
SELECT TOP 3 *
FROM dbo.vAssocSeqLineItems;

-- Frequency of itemsets with a single model
SELECT Model, COUNT(*) AS Support
FROM dbo.vAssocSeqLineItems
GROUP BY Model
ORDER BY Support DESC;
GO

-- Frequency of itemsets with two models
WITH Pairs_CTE AS
(
SELECT t1.OrderNumber,
 t1.Model AS Model1, 
 t2.Model2
FROM dbo.vAssocSeqLineItems AS t1
 CROSS APPLY 
  (SELECT Model AS Model2
   FROM dbo.vAssocSeqLineItems
   WHERE OrderNumber = t1.OrderNumber
     AND Model > t1.Model) AS t2
)
SELECT Model1, Model2, COUNT(*) AS Support
FROM Pairs_CTE
GROUP BY Model1, Model2
ORDER BY Support DESC;
GO

-- Frequency of itemsets with three models
WITH Pairs_CTE AS
(
SELECT t1.OrderNumber,
 t1.Model AS Model1, 
 t2.Model2
FROM dbo.vAssocSeqLineItems AS t1
 CROSS APPLY 
  (SELECT Model AS Model2
   FROM dbo.vAssocSeqLineItems
   WHERE OrderNumber = t1.OrderNumber
     AND Model > t1.Model) AS t2
),
Triples_CTE AS
(
SELECT t2.OrderNumber,
 t2.Model1, 
 t2.Model2,
 t3.Model3
FROM Pairs_CTE AS t2
 CROSS APPLY 
  (SELECT Model AS Model3
   FROM dbo.vAssocSeqLineItems
   WHERE OrderNumber = t2.OrderNumber
     AND Model > t2.Model1
	 AND Model > t2.Model2) AS t3
)
SELECT Model1, Model2, Model3, COUNT(*) AS Support
FROM Triples_CTE
GROUP BY Model1, Model2, Model3
ORDER BY Support DESC;
GO



-- Clustering 
-- Temp table
CREATE TABLE #tmp
 (CustomerKey             INT   NOT NULL,
  NumberChildrenAtHome    INT   NOT NULL,
  NumberCarsOwned         INT   NOT NULL, 
  Age                     INT   NOT NULL,
  BikeBuyer               INT   NOT NULL,
  Income                  INT   NOT NULL,
  ClusterID               INT   NOT NULL);
GO
-- Train the model and insert
INSERT INTO #tmp
EXECUTE sys.sp_execute_external_script
  @language = N'R'
 ,@script = N'
    library(RevoScaleR)
    ThreeClust <- rxKmeans(formula = ~NumberCarsOwned + Income + Age +
                                      NumberChildrenAtHome + BikeBuyer,
                           data = TM, numClusters = 3)
    TMClust <- cbind(TM, ThreeClust$cluster);
    names(TMClust)[7] <- "ClusterID";
   '
 ,@input_data_1 = N'
    SELECT CustomerKey, NumberChildrenAtHome, 
           NumberCarsOwned, Age, BikeBuyer, 
           YearlyIncome AS Income
           FROM dbo.vTargetMail;'
 ,@input_data_1_name =  N'TM'
 ,@output_data_1_name = N'TMClust';
GO
-- Analyze
SELECT ClusterID, AVG(1.0*Income) AS AvgIncome
FROM #tmp
GROUP BY ClusterID
ORDER BY ClusterID;
GO


