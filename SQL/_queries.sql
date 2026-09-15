
--Get all orders from the West region with Sales greater than 500, showing Order ID, Order Date, Sales, and Profit.--

SELECT		[OrderId],
			[OrderDate],
			Sales,
			Profit
FROM		Orders
WHERE		Region ='West'
AND			Sales > 500 ;

/*Sorting: Get the top 10 orders by Profit (highest first) — Order ID, Sales, Profit, Order Date.*/

SELECT	TOP 10	[OrderID],
				Sales,
				Profit,
				[OrderDate]
FROM			Orders
ORDER BY		Profit DESC;

/*Simple aggregation: What is the total Sales and total Profit across all orders? (single row result)*/

SELECT			SUM(Sales) AS [TotalSales],
				SUM(Profit) AS [TotalProfit]
FROM			Orders ;

 -- what is the average Discount given, but only for orders shipped via Same Day?--

 SELECT			AVG(Discount) [AverageDiscount]
 FROM			Orders
 WHERE			[ShipMode] = 'Same Day';

--Counting: How many distinct customers placed at least one order? 

 SELECT		COUNT(DISTINCT[CustomerID]) AS [CustomersWithOrders]
 FROM		Orders;

 
 SELECT	OrderID,CustomerID FROM	Orders
 
 SELECT	* FROM	Customers
 
 SELECT	* FROM	Products
 /*Task 3.2: GROUP BY + HAVING*/
 
 --Group + aggregate: Total Sales and Profit by Region (one row per region)--

 SELECT		Region,
			SUM(Sales) TotalSales,
			SUM(Profit) TotalProfit
 FROM		Orders
 GROUP BY	Region ;


 /* Sorted group: Total Sales by State, sorted highest to lowest */

 SELECT		State,
			SUM(Sales) TotalSales
 FROM		Orders
 GROUP BY	State
 ORDER BY	TotalSales DESC ;

/*GROUP BY with HAVING: Which CustomerIDs have placed more than 10 orders? Show CustomerID and their order count*/

SELECT		CustomerID,
			COUNT(DISTINCT OrderID) OrderCount
FROM		Orders
GROUP BY	CustomerID
HAVING		COUNT(DISTINCT OrderID) > 10 ;

/* Time-based grouping: Total Sales by OrderYear and OrderMonth */

SELECT		OrderYear,
			OrderMonth,
			SUM(Sales) TotalSales
FROM		Orders
GROUP BY	OrderYear,
			OrderMonth 
Order BY	OrderYear,
			OrderMonth ;


/* Basic JOIN: List each order's OrderID, OrderDate, Sales, and the customer's CustomerName and Segment.*/




SELECT		o.OrderID,
			o.OrderDate,
			o.Sales,
			c.CustomerName,
			c.Segment
FROM		Orders AS o
INNER JOIN	Customers as c
ON			o.CustomerID =c.CustomerID ;


/*List OrderID, ProductName, Category, SubCategory, and Sales for every order */

SELECT		o.OrderID,
			o.ProductName,
			p.Category,
			p.SubCategory,
			o.Sales
FROM		Orders o
INNER JOIN	Products p
ON			o.ProductID =p.ProductID ;

/*Total Sales by product Category*/

SELECT		p.Category,
			SUM(o.Sales) TotalSales
FROM		Orders o
INNER JOIN	Products p
ON			o.ProductID = p.ProductID
GROUP BY	p.Category ;

/*List CustomerName, OrderID, and Profit for all orders where Profit was negative (a loss) */

SELECT		c.CustomerName,
			o.OrderID,
			o.Profit
FROM		Orders o
INNER JOIN	Customers c
ON			o.CustomerID =c.CustomerID 
WHERE		o.Profit < 0;



/* Find any customers who have never placed an order*/

SELECT		c.CustomerID,
			c.CustomerName
FROM		Customers	c
LEFT JOIN	Orders     o
ON			c.CustomerID =o.CustomerID
WHERE		o.CustomerID IS NULL ;

/* Find all orders where Sales is above the overall average Sales across all orders */

SELECT		OrderID,
			Sales
FROM		Orders
WHERE		Sales >(
					SELECT         AVG(Sales) 
				    FROM			Orders
					);

/* Rewrite query 1 using a WITH CTE instead of a subquery */

WITH AvgSales AS				
				(
					SELECT 	AVG(Sales) AS AverageSales
				    FROM	Orders
				 )
				  
SELECT				o.OrderID,
					o.Sales
FROM				Orders o
CROSS JOIN			AvgSales
WHERE				o.Sales > AvgSales.AverageSales;

select top 5 *  from Orders
Select top 5  * from Customers
SELECT top 3 * FROM Products

/*top 3 customers by total Sales.*/

SELECT	TOP 3	o.CustomerID,
			    c.CustomerName,
				SUM(o.Sales)TotalSales
FROM			Orders o
INNER JOIN		Customers c
ON				o.CustomerID = c.customerID
GROUP BY		o.CustomerID,
				c.CustomerName
ORDER BY	    TotalSales DESC;

SELECT
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER (ORDER BY OrderDate) AS RunningTotal
FROM Orders;

SELECT
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER (ORDER BY OrderDate) AS RunningTotal
FROM Orders
ORDER BY OrderDate;
SELECT
    RowID,
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER (ORDER BY OrderDate, OrderID, RowID) AS RunningTotal
FROM Orders
ORDER BY OrderDate, OrderID, RowID;

/* Write a query that shows RowID, Region, OrderDate, Sales, and 
a RunningTotalByRegion column — a running total of Sales that resets separately for each Region, 
ordered chronologically (with your OrderID, RowID tiebreakers included).*/

SELECT		RowID,
			Region,
			OrderDate,
			Sales,
			SUM(Sales)OVER(PARTITION BY	Region ORDER BY OrderDate,OrderID,ROWID) AS RunningTotalByRegion
FROM		Orders

--Verifying
SELECT TOP 20	RowID, 
				Region, 
				OrderDate, 
				Sales,
				SUM(Sales) OVER (PARTITION BY Region ORDER BY OrderDate, OrderID, RowID) AS RunningTotalByRegion
FROM			Orders
ORDER BY		Region, OrderDate, OrderID, RowID;

SELECT			RowID, 
				Region, 
				OrderDate,
				Sales,
				RunningTotalByRegion
FROM			(
				SELECT		RowID, 
							Region,		
							OrderDate, 
							Sales,
							SUM(Sales) OVER (PARTITION BY Region ORDER BY OrderDate, OrderID, RowID) AS RunningTotalByRegion
				FROM		Orders
				) sub
WHERE			Region IN ('Central', 'East')
ORDER BY		Region, OrderDate;

/* Rank orders by Sales within each Region*/

SELECT			RowID,
				Region,
				Sales,
				RANK()OVER(PARTITION BY Region ORDER BY Sales DESC) AS SalesRank
FROM			Orders

/* Verifying rank for each region specifically */


SELECT		* 
FROM		(
				SELECT		RowID, 
							Region, 
							Sales,
							RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRank
				FROM	    Orders
			) sub
WHERE SalesRank = 1;

/* Checking whether 2 orders in the same region have the exact same sales value in the table*/

SELECT			Region, 
				Sales, 
				COUNT(*) AS tie_count
FROM			Orders
GROUP BY		Region, 
				Sales
HAVING			COUNT(*) > 1
ORDER BY		tie_count DESC;

/* Query that filters down to just west group and shows the ranking in context*/

SELECT RowID, Region, Sales, SalesRank
FROM (
    SELECT RowID, Region, Sales,
           RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRank
    FROM Orders
) sub
WHERE Region = 'West'
ORDER BY Sales DESC;

-- comparing RANK() and DENSE_RANK()

SELECT			RowID, 
				Region, 
				Sales,
				RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRank,
				DENSE_RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesDenseRank
FROM			Orders
WHERE			Region = 'West'
ORDER BY		Sales DESC;

/* Using ROW_NUMBER*/


SELECT			RowID, 
				Region, 
				Sales,
				RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRank,
				DENSE_RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesDenseRank,
				ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRowNumber
FROM			Orders
WHERE			Region = 'West'
ORDER BY		Sales DESC;

/* Month-over-month sales comparison*/
/* using OrderYear/OrderMonth to calculate total Sales per month, then add a column showing the previous month's total right next to it — the first step toward calculating growth.*/

WITH MonthlySales AS 
					(
						SELECT			OrderYear,
										OrderMonth,
										SUM(Sales) AS TotalSales
						FROM			Orders
						GROUP BY		OrderYear,
										OrderMonth
					  )

SELECT		OrderYear,
			OrderMonth,
			TotalSales,
			LAG(TotalSales)OVER(ORDER BY OrderYear,OrderMonth) AS PreviousMonthSales
FROM        MonthlySales
ORDER BY	OrderYear,
			OrderMonth

/* Adding month-over-month growth calculation*/


WITH MonthlySales AS 
					(
						SELECT			OrderYear,
										OrderMonth,
										SUM(Sales) AS TotalSales
						FROM			Orders
						GROUP BY		OrderYear,
										OrderMonth
					  )

SELECT		OrderYear,
			OrderMonth,
			TotalSales,
			LAG(TotalSales)OVER(ORDER BY OrderYear,OrderMonth) AS PreviousMonthSales,
			(TotalSales-LAG(TotalSales)OVER(ORDER BY OrderYear,OrderMonth))/LAG(TotalSales)OVER(ORDER BY OrderYear,OrderMonth) * 100 AS MoMGrowthPercent  
FROM        MonthlySales
ORDER BY	OrderYear,
			OrderMonth