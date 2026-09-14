-- =============================================
-- 05_indexes.sql
-- Demonstrates the performance impact of indexing
-- a foreign-key column that has no index by default.
--
-- Run each SELECT below with "Include Actual Execution
-- Plan" turned on in SSMS (Ctrl+M) to see the before/
-- after operation change from Clustered Index Scan
-- to Index Seek.
-- =============================================

USE SuperstoreDB;
GO

-- Before: no index on CustomerID -> Clustered Index Scan
SELECT 	*
FROM 	Orders
WHERE 	[CustomerID] = 'CG-12520';
GO

-- Create an index on CustomerID
CREATE INDEX 	IX_Orders_CustomerID ON Orders([CustomerID]);
GO

-- After: Index Seek
SELECT 		*
FROM 		Orders
WHERE 		[CustomerID] = 'CG-12520';
GO
