-- =============================================
-- 03_queries.sql
-- Core analytical queries against the normalized
-- schema: filtering, aggregation, JOINs, subqueries,
-- CTEs, and window functions.
-- =============================================

USE SuperstoreDB;
GO

-- =============================================
-- Section 1: Filtering, sorting, basic aggregation
-- =============================================

-- Orders from the West region with Sales > 500
SELECT 		[OrderID], 
			[OrderDate], 
			Sales, 
			Profit
FROM 		Orders
WHERE 		Region = 'West' 
AND 		Sales > 500;
GO

-- Top 10 orders by Profit (highest first)
SELECT TOP 10 	[OrderID], 
				Sales, 
				Profit, 
				[OrderDate]
FROM 			Orders
ORDER BY 		Profit DESC;
GO

-- Total Sales and total Profit across all orders
SELECT			SUM(Sales) AS TotalSales,
				SUM(Profit) AS TotalProfit
FROM 			Orders;
GO

-- Average Discount for orders shipped via Same Day
SELECT 			AVG(Discount) AS AverageDiscount
FROM 			Orders
WHERE 			[ShipMode] = 'Same Day';
GO

-- Distinct customers who placed at least one order
SELECT 			COUNT(DISTINCT [CustomerID]) AS CustomersWithOrders
FROM 			Orders;
GO

-- =============================================
-- Section 2: GROUP BY and HAVING
-- =============================================

-- Total Sales and Profit by Region
SELECT			Region,
				SUM(Sales) AS TotalSales,
				SUM(Profit) AS TotalProfit
FROM 			Orders
GROUP BY 		Region;
GO

-- Total Sales by State, sorted highest to lowest
SELECT			[State],
				SUM(Sales) AS TotalSales
FROM 			Orders
GROUP BY 		[State]
ORDER BY 		TotalSales DESC;
GO

-- Customers who placed more than 10 orders
SELECT			[CustomerID],
				COUNT(DISTINCT [OrderID]) AS OrderCount
FROM 			Orders
GROUP BY 		[CustomerID]
HAVING 			COUNT(DISTINCT [OrderID]) > 10;
GO

-- Total Sales by OrderYear and OrderMonth
SELECT			[OrderYear],
				[OrderMonth],
				SUM(Sales) AS TotalSales
FROM 			Orders
GROUP BY 		[OrderYear], [OrderMonth]
ORDER BY 		[OrderYear], [OrderMonth];
GO

-- =============================================
-- Section 3: JOINs
-- =============================================

-- Order details with customer name and segment
SELECT			o.[OrderID],
				o.[OrderDate],
				o.Sales,
				c.[CustomerName],
				c.Segment
FROM 			Orders AS o
INNER JOIN 		Customers AS c 
ON 				o.[CustomerID] = c.[CustomerID];
GO

-- Order details with product category and subcategory
SELECT			o.[OrderID],
				o.[ProductName],
				p.Category,
				p.[SubCategory],
				o.Sales
FROM 			Orders o
INNER JOIN 		Products p 
ON 				o.[ProductID] = p.[ProductID];
GO

-- Total Sales by product Category
SELECT			p.Category,
				SUM(o.Sales) AS TotalSales
FROM 			Orders o
INNER JOIN 		Products p 
ON 				o.[ProductID] = p.[ProductID]
GROUP BY 		p.Category;
GO

-- Orders that resulted in a loss (negative Profit)
SELECT			c.[CustomerName],
				o.[OrderID],
				o.Profit
FROM 			Orders o
INNER JOIN 		Customers c 
ON 				o.[CustomerID] = c.[CustomerID]
WHERE 			o.Profit < 0;
GO

-- Customers who have never placed an order (LEFT JOIN, expected to return 0 rows)
SELECT			c.[CustomerID],
				c.[CustomerName]
FROM 			Customers c
LEFT JOIN 		Orders o 
ON 				c.[CustomerID] = o.[CustomerID]
WHERE 			o.[CustomerID] IS NULL;
GO

-- =============================================
-- Section 4: Subqueries and CTEs
-- =============================================

-- Orders with Sales above the overall average (subquery)
SELECT 			[OrderID], 
				Sales
FROM 			Orders
WHERE 			Sales > (SELECT AVG(Sales) FROM Orders);
GO

-- Same result, rewritten with a CTE
WITH 	AvgSales AS (
						SELECT 	AVG(Sales) AS AverageSales
						FROM 	Orders
					 )
SELECT 			o.[OrderID], 
				o.Sales
FROM 			Orders o
CROSS JOIN 		AvgSales
WHERE 			o.Sales > AvgSales.AverageSales;
GO

-- Top 3 customers by total Sales
SELECT TOP 3 	o.[CustomerID],
				c.[CustomerName],
				SUM(o.Sales) AS TotalSales
FROM 			Orders o
INNER JOIN 		Customers c 
ON 				o.[CustomerID] = c.[CustomerID]
GROUP BY 		o.[CustomerID], c.[CustomerName]
ORDER BY 		TotalSales DESC;
GO

-- =============================================
-- Section 5: Window functions - running totals
-- =============================================

-- Running total of Sales, ordered chronologically with tiebreakers
-- (OrderDate alone is not unique; OrderID and RowID break ties deterministically)
SELECT		[RowID],
			[OrderID],
			[OrderDate],
			Sales,
			SUM(Sales) OVER (ORDER BY [OrderDate], [OrderID], [RowID]) AS RunningTotal
FROM 		Orders
ORDER BY 	[OrderDate], [OrderID], [RowID];
GO

-- Running total that resets separately for each Region
SELECT		[RowID],
			Region,
			[OrderDate],
			Sales,
			SUM(Sales) OVER (PARTITION BY Region ORDER BY [OrderDate], [OrderID], [RowID]) AS RunningTotalByRegion
FROM 		Orders
ORDER BY 	Region, [OrderDate], [OrderID], [RowID];
GO

-- =============================================
-- Section 6: Window functions - ranking
-- =============================================

-- Rank orders by Sales within each Region
SELECT		[RowID],
			Region,
			Sales,
			RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRank
FROM 		Orders;
GO

-- RANK() vs DENSE_RANK() vs ROW_NUMBER() on tied Sales values (West region)
SELECT		[RowID],
			Region,
			Sales,
			RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRank,
			DENSE_RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesDenseRank,
			ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRowNumber
FROM 		Orders
WHERE 		Region = 'West'
ORDER BY 	Sales DESC;
GO

-- =============================================
-- Section 7: Window functions - LAG and growth
-- =============================================

-- Month-over-month Sales with previous month comparison and growth %
WITH 	MonthlySales AS (
							SELECT		[OrderYear],
										[OrderMonth],
										SUM(Sales) AS TotalSales
							FROM 		Orders
							GROUP BY 	[OrderYear], [OrderMonth]
						)
SELECT		[OrderYear],
			[OrderMonth],
			TotalSales,
			LAG(TotalSales) OVER (ORDER BY [OrderYear], [OrderMonth]) AS PreviousMonthSales,
			(TotalSales - LAG(TotalSales) OVER (ORDER BY [OrderYear], [OrderMonth]))/ LAG(TotalSales) OVER (ORDER BY [OrderYear], [OrderMonth]) * 100 AS MoMGrowthPercent
FROM 		MonthlySales
ORDER BY 	[OrderYear], [OrderMonth];
GO
