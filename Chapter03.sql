-- Data Science with SQL Server Quick Start Guide
-- Chapter 03

-- Configure SQL Server to allow external scripts
USE master;
EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sys.sp_configure 'external scripts enabled', 1; 
RECONFIGURE WITH OVERRIDE;
GO
-- Restart SQL Server
-- Check the configuration
EXEC sys.sp_configure;
GO

-- Check whether Python code can run
EXECUTE sys.sp_execute_external_script 
@language =N'Python',
@script=N'
OutputDataSet = InputDataSet
print("Input data is: \n", InputDataSet)
', 
@input_data_1 = N'SELECT 1 as col';
GO

-- Check the installed R packages
EXECUTE sys.sp_execute_external_script
 @language=N'R'
,@script = 
 N'str(OutputDataSet)
   packagematrix <- installed.packages()
   NameOnly <- packagematrix[,1]
   OutputDataSet <- as.data.frame(NameOnly)'
,@input_data_1 = N'SELECT 1 AS col'
WITH RESULT SETS (( PackageName nvarchar(250) ));
GO
