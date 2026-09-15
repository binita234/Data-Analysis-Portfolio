/*Loading cleaned CSV into the Superstore table*/
BULK INSERT dbo.Superstore
FROM		'D:\PL-300\Files\Superstore\cleaned_superstore.csv'
WITH		(
			 FIRSTROW = 2,
			 FIELDTERMINATOR = '|',
			 ROWTERMINATOR = '\n',
			 MAXERRORS   = 10,
			 ERRORFILE = 'D:\PL-300\Files\Superstore\bulkinsert_errors.txt'
			 )

/*Data loaded and verified correct at both row-count and actual-value level*/
SELECT	COUNT(*) 
FROM	dbo.Superstore;

SELECT TOP 5 * FROM dbo.Superstore;
SELECT TOP 5 [RowID], [PostalCode], [State]
FROM dbo.Superstore
WHERE [State] = 'Massachusetts';

-- Should return 0 rows if Customer ID reliably maps to one Name/Segment
SELECT		[CustomerID], COUNT(DISTINCT [CustomerName]) AS name_count, COUNT(DISTINCT Segment) AS segment_count
FROM		dbo.Superstore
GROUP BY	[CustomerID]
HAVING		COUNT(DISTINCT [CustomerName]) > 1 OR COUNT(DISTINCT Segment) > 1;

-- Should return 0 rows if Product ID reliably maps to one Name/Category/Subcategory 
SELECT		[ProductID],
			COUNT(DISTINCT[ProductName])	AS		name_count,
			COUNT(DISTINCT[Category])		AS		category_count,
			COUNT(DISTINCT[SubCategory])	AS		subcategory_count
FROM		dbo.Superstore
GROUP BY	[ProductID]
HAVING		COUNT(DISTINCT[ProductName]) > 1 
OR			COUNT(DISTINCT[Category]) > 1
OR			COUNT(DISTINCT[SubCategory]) > 1 ;

SELECT [ProductID], [ProductName], COUNT(*) AS row_count
FROM dbo.Superstore
WHERE [ProductID] = 'FUR-BO-10002213'
GROUP BY [ProductID], [ProductName];
