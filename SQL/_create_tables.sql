
/* Creating database SuperstoreDB */

CREATE DATABASE SuperstoreDB;

USE SuperstoreDB;

/*Creating table Superstore*/
CREATE	TABLE	Superstore (
							[RowID]					INT		PRIMARY KEY,
							[OrderID]				VARCHAR(14),
							[OrderDate]				DATE,
							[ShipDate]				DATE,
							[ShipMode]				VARCHAR(20),
							[CustomerID]			VARCHAR(8),
							[CustomerName]			VARCHAR(100),
							Segment					VARCHAR(11),
							Country					VARCHAR(50),
							City					VARCHAR(20),
							[State]					VARCHAR(20),
							[PostalCode]			VARCHAR(5),
							Region					VARCHAR(7),
							[ProductID]				VARCHAR(15),
							Category				VARCHAR(20),
							[SubCategory]			VARCHAR(200),
							[ProductName]			VARCHAR(200),
							Sales					DECIMAL(10,2),
							Quantity				INT,
							Discount				DECIMAL(3,2),
							Profit					DECIMAL(10,2),
							[OrderToShipDays]		INT,
							[OrderYear]				INT,
							[OrderMonth]			INT,
							[OrderQuarter]			INT,
							[ProfitMargin]			DECIMAL(10,2)

							);


-- normalizing into multiple tables 
-- creating customer,product and order table --

CREATE	TABLE	dbo.Customers (
								[CustomerID]		VARCHAR(8)		PRIMARY KEY,
								[CustomerName]		VARCHAR(100),
								Segment				VARCHAR(11)
								);
							 
CREATE	TABLE	dbo.Products (
								[ProductID]		VARCHAR(15)		PRIMARY KEY,
								[Category]			VARCHAR(20),
								[SubCategory]		VARCHAR(200)
								);
CREATE	TABLE	dbo.Orders (
								[RowID]					INT PRIMARY KEY,
								[OrderID]				VARCHAR(14),
								[OrderDate]				DATE,
								[ShipDate]				DATE,
								[ShipMode]				VARCHAR(20),
								[CustomerID]			VARCHAR(8) NOT NULL,
								Country					VARCHAR(50),
								City					VARCHAR(20),
								[State]					VARCHAR(20),
								[PostalCode]			VARCHAR(5),
								Region					VARCHAR(7),
								[ProductID]				VARCHAR(15) NOT NULL,
								[ProductName]			VARCHAR(200),
								Sales					DECIMAL(10,2),
								Quantity				INT,
								Discount				DECIMAL(3,2),
								Profit					DECIMAL(10,2),
								[OrderToShipDays]		INT,
								[OrderYear]				INT,
								[OrderMonth]			INT,
								[OrderQuarter]			INT,
								[ProfitMargin]			DECIMAL(10,2),
								--Defining foreign key
								FOREIGN KEY ([CustomerID]) REFERENCES Customers([CustomerID]),
								FOREIGN KEY ([ProductID]) REFERENCES Products([ProductID])
								);


/* Verifying all three tables exists*/

SELECT		TABLE_NAME 
FROM		INFORMATION_SCHEMA.TABLES 
WHERE		TABLE_SCHEMA = 'dbo';