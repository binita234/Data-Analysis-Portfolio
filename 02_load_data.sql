-- =============================================
-- 02_load_data.sql
-- Loads the cleaned CSV into the flat Superstore
-- table, then verifies row counts, key values,
-- and the data integrity assumptions behind the
-- normalized schema.
--
-- NOTE: Update the file paths below to match your
-- local environment before running.
-- =============================================

USE SuperstoreDB;
GO

BULK INSERT 	dbo.Superstore
FROM 			'D:\PL-300\Files\Superstore\cleaned_superstore.csv'
WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = '|',
				ROWTERMINATOR = '\n',
				MAXERRORS = 10,
				ERRORFILE = 'D:\PL-300\Files\Superstore\bulkinsert_errors.txt'
);
GO

-- =============================================
-- Verify load: row count and value-level checks
-- =============================================
SELECT 		COUNT(*) AS RowCount
FROM 		dbo.Superstore;
GO

SELECT TOP 	5 *
FROM 		dbo.Superstore;
GO

-- Confirms leading zeros were preserved for Northeastern postal codes
SELECT TOP 5 	[RowID], [PostalCode], [State]
FROM 		 	dbo.Superstore
WHERE 			[State] = 'Massachusetts';
GO

-- =============================================
-- Data integrity checks before normalizing
-- =============================================

-- Should return 0 rows if CustomerID reliably maps to one Name/Segment
SELECT		[CustomerID],
			COUNT(DISTINCT [CustomerName]) AS name_count,
			COUNT(DISTINCT Segment) AS segment_count
FROM 		dbo.Superstore
GROUP BY 	[CustomerID]
HAVING 		COUNT(DISTINCT [CustomerName]) > 1 
OR 			COUNT(DISTINCT Segment) > 1;
GO

-- Should return 0 rows if ProductID reliably maps to one Name/Category/SubCategory
-- (this returns 30 rows in the source data - see README: Known Limitations)
SELECT		[ProductID],
			COUNT(DISTINCT [ProductName]) AS name_count,
			COUNT(DISTINCT Category) AS category_count,
			COUNT(DISTINCT [SubCategory]) AS subcategory_count
FROM 		dbo.Superstore
GROUP BY 	[ProductID]
HAVING 		COUNT(DISTINCT [ProductName]) > 1
    OR 		COUNT(DISTINCT Category) > 1
    OR 		COUNT(DISTINCT [SubCategory]) > 1;
GO

-- Example of the ProductID -> multiple ProductName conflict
SELECT 		[ProductID], 
			[ProductName], 
			COUNT(*) AS row_count
FROM 		dbo.Superstore
WHERE 		[ProductID] = 'FUR-BO-10002213'
GROUP BY 	[ProductID], [ProductName];
GO
