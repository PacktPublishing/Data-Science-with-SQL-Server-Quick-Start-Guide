-- Data Science with SQL Server Quick Start Guide
-- Chapter 08

USE AdventureWorksDW2017;
GO
-- Test set
SELECT TOP 30 PERCENT
  CustomerKey, CommuteDistance,
  TotalChildren, NumberChildrenAtHome, 
  Gender, HouseOwnerFlag,
  NumberCarsOwned, MaritalStatus,
  Age, Region,
  YearlyIncome AS Income,
  EnglishEducation AS Education,
  EnglishOccupation AS Occupation,
  BikeBuyer, 2 AS TrainTest
 INTO dbo.TMTest
FROM dbo.vTargetMail
ORDER BY CAST(CRYPT_GEN_RANDOM(4) AS INT);
-- 5546 rows

-- Training set
SELECT 
  CustomerKey, CommuteDistance,
  TotalChildren, NumberChildrenAtHome, 
  Gender, HouseOwnerFlag,
  NumberCarsOwned, MaritalStatus,
  Age, Region,
  YearlyIncome AS Income,
  EnglishEducation AS Education,
  EnglishOccupation AS Occupation,
  BikeBuyer, 1 AS TrainTest
INTO dbo.TMTrain
FROM dbo.vTargetMail AS v
WHERE NOT EXISTS
 (SELECT * FROM dbo.TMTest AS t
  WHERE v.CustomerKey = t.CustomerKey);
GO  
-- 12938 rows



-- Native predictions

-- Table for the models
-- Create a table to store models
	CREATE TABLE dbo.dsModels
	(Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	 ModelName NVARCHAR(50) NOT NULL,
	 Model VARBINARY(MAX) NOT NULL);
	GO

-- Decision Trees model for the PREDICT T-SQL function 
DECLARE @model VARBINARY(MAX);
EXECUTE sys.sp_execute_external_script
  @language = N'R'
 ,@script = N'
   rxDT <- rxDTree(BikeBuyer ~ NumberCarsOwned +
                   TotalChildren + Age + YearlyIncome,
                   data = TM);
   model <- rxSerializeModel(rxDT, realtimeScoringOnly = TRUE);'
 ,@input_data_1 = N'
     SELECT CustomerKey, NumberCarsOwned,
	  TotalChildren, Age, YearlyIncome,
	  BikeBuyer
     FROM dbo.vTargetMail;'
 ,@input_data_1_name =  N'TM'
 ,@params = N'@model VARBINARY(MAX) OUTPUT'
 ,@model = @model OUTPUT;
INSERT INTO dbo.dsModels (ModelName, Model)
VALUES('rxDT', @model);
GO

-- Check the models
SELECT *
FROM dbo.dsModels;
GO

-- Use the PREDICT function
DECLARE @model VARBINARY(MAX) = 
(
  SELECT Model
  FROM dbo.dsModels
  WHERE ModelName = 'rxDT'
);
SELECT d.CustomerKey, d.Age, d.NumberCarsOwned,
 d.BikeBuyer, p.BikeBuyer_Pred
FROM PREDICT(MODEL = @model, DATA = dbo.vTargetMail AS d)
WITH(BikeBuyer_Pred FLOAT) AS p
ORDER BY d.CustomerKey;
GO


-- Clean up
DROP TABLE IF EXISTS dbo.TMTrain;
DROP TABLE IF EXISTS dbo.TMTest;
DROP TABLE IF EXISTS dbo.dsModels;
GO
