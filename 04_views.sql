-- =============================================
-- 04_views.sql
-- Reusable SQL Views consumed directly by Power BI.
-- =============================================

USE SuperstoreDB;
GO

-- =============================================
-- vw_OrderDetails
-- Denormalized order-level view: joins Orders,
-- Customers, and Products for reporting.
-- =============================================
CREATE VIEW vw_OrderDetails AS
SELECT		o.[RowID],
			o.[OrderID],
			o.[OrderDate],
			o.Sales,
			o.Profit,
			o.Region,
			c.[CustomerName],
			c.Segment,
			p.Category,
			p.[SubCategory]
FROM 		Orders o
INNER JOIN 	Customers c 
ON 			o.[CustomerID] = c.[CustomerID]
INNER JOIN 	Products p 
ON 			o.[ProductID] = p.[ProductID];
GO

-- Verify
SELECT TOP 	10 * 
FROM 			vw_OrderDetails;
GO

-- =============================================
-- vw_MonthlySalesSummary
-- Pre-aggregated monthly Sales with month-over-month
-- growth. Not currently related to vw_OrderDetails in
-- the Power BI model - see README for why the
-- dashboard instead uses DAX time intelligence.
-- =============================================
CREATE VIEW vw_MonthlySalesSummary AS
WITH MonthlySales AS (
						SELECT	 [OrderYear],
								 [OrderMonth],
								 SUM(Sales) AS TotalSales
						FROM 	 Orders
						GROUP BY [OrderYear], [OrderMonth]
)
SELECT		[OrderYear],
			[OrderMonth],
			TotalSales,
			LAG(TotalSales) OVER (ORDER BY [OrderYear], [OrderMonth]) AS PreviousMonthSales,
			(TotalSales - LAG(TotalSales) OVER (ORDER BY [OrderYear], [OrderMonth]))/ LAG(TotalSales) OVER (ORDER BY [OrderYear], [OrderMonth]) * 100 AS MoMGrowthPercent
FROM 		MonthlySales;
GO

-- Verify
SELECT 		*
FROM 		vw_MonthlySalesSummary
ORDER BY 	[OrderYear], [OrderMonth];
GO
