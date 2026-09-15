/* Creating VIEW statement called vw_OrderDetails that selects
From Orders: RowID, OrderID, OrderDate, Sales, Profit, Region
From Customers (joined in): CustomerName, Segment
From Products (joined in): Category, SubCategory*/

CREATE	VIEW  vw_OrderDetails  AS
SELECT		  o.RowID,
			  o.OrderID,
			  o.OrderDate,
			  o.Sales,
			  o.Profit,
			  o.Region,
			  c.CustomerName,
			  c.Segment,
			  p.Category,
			  p.SubCategory
FROM		  Orders o
INNER JOIN	  Customers c
ON			  o.CustomerID =c.CustomerID
INNER JOIN	  Products p
ON			  o.ProductID = p.ProductID

SELECT TOP		10 * 
FROM			vw_OrderDetails;


/* Creating view for month-over-month comparison and growth calculation */

CREATE	VIEW  vw_MonthlySalesSummary  AS
WITH		  MonthlySales AS (
								SELECT		OrderYear,
											OrderMonth, 
											SUM(Sales) AS TotalSales
								FROM		Orders
								GROUP BY	OrderYear, 
											OrderMonth
)
SELECT			OrderYear, 
				OrderMonth, 
				TotalSales,
				LAG(TotalSales) OVER (ORDER BY OrderYear, OrderMonth) AS PreviousMonthSales,
				(TotalSales - LAG(TotalSales) OVER (ORDER BY OrderYear, OrderMonth)) / LAG(TotalSales) OVER (ORDER BY OrderYear, OrderMonth) * 100 AS MoMGrowthPercent
FROM			 MonthlySales;

SELECT			* 
FROM			vw_MonthlySalesSummary 
ORDER BY		OrderYear, 
				OrderMonth;
	
SELECT			* 
FROM			Orders 
WHERE			CustomerID = 'CG-12520';

CREATE INDEX IX_Orders_CustomerID ON Orders(CustomerID);

SELECT * FROM Orders WHERE CustomerID = 'CG-12520';