-- =============================================
-- 01_create_tables.sql
-- Creates the SuperstoreDB database, the original
-- flat Superstore table, and the normalized schema
-- (Customers, Products, Orders).
-- =============================================

-- Create database
CREATE DATABASE SuperstoreDB;
GO

USE SuperstoreDB;
GO

-- =============================================
-- Flat table (matches the cleaned CSV structure)
-- =============================================
CREATE TABLE Superstore (
							[RowID]             INT             PRIMARY KEY,
							[OrderID]           VARCHAR(14),
							[OrderDate]         DATE,
							[ShipDate]          DATE,
							[ShipMode]          VARCHAR(20),
							[CustomerID]        VARCHAR(8),
							[CustomerName]      VARCHAR(100),
							Segment             VARCHAR(11),
							Country             VARCHAR(50),
							City                VARCHAR(20),
							[State]             VARCHAR(20),
							[PostalCode]        VARCHAR(5),
							Region              VARCHAR(7),
							[ProductID]         VARCHAR(15),
							Category            VARCHAR(20),
							[SubCategory]       VARCHAR(200),
							[ProductName]       VARCHAR(200),
							Sales               DECIMAL(10,2),
							Quantity            INT,
							Discount            DECIMAL(3,2),
							Profit              DECIMAL(10,2),
							[OrderToShipDays]   INT,
							[OrderYear]         INT,
							[OrderMonth]        INT,
							[OrderQuarter]      INT,
							[ProfitMargin]      DECIMAL(10,2)
						);
GO

-- =============================================
-- Normalized schema: Customers, Products, Orders
-- =============================================
CREATE TABLE 	dbo.Customers (
								[CustomerID]    VARCHAR(8)      PRIMARY KEY,
								[CustomerName]  VARCHAR(100),
								Segment         VARCHAR(11)
							   );
GO

CREATE TABLE 	dbo.Products (
								[ProductID]     VARCHAR(15)     PRIMARY KEY,
								Category        VARCHAR(20),
								[SubCategory]   VARCHAR(200)
							  );
GO

-- Note: ProductName is intentionally kept in Orders rather than
-- Products, since a small number of ProductIDs map to more than
-- one ProductName in the source data (see README: Known Limitations).
CREATE TABLE 	dbo.Orders (
								[RowID]             INT             PRIMARY KEY,
								[OrderID]           VARCHAR(14),
								[OrderDate]         DATE,
								[ShipDate]          DATE,
								[ShipMode]          VARCHAR(20),
								[CustomerID]        VARCHAR(8)      NOT NULL,
								Country             VARCHAR(50),
								City                VARCHAR(20),
								[State]             VARCHAR(20),
								[PostalCode]        VARCHAR(5),
								Region              VARCHAR(7),
								[ProductID]         VARCHAR(15)     NOT NULL,
								[ProductName]       VARCHAR(200),
								Sales               DECIMAL(10,2),
								Quantity            INT,
								Discount            DECIMAL(3,2),
								Profit              DECIMAL(10,2),
								[OrderToShipDays]   INT,
								[OrderYear]         INT,
								[OrderMonth]        INT,
								[OrderQuarter]      INT,
								[ProfitMargin]      DECIMAL(10,2),
								FOREIGN KEY 		([CustomerID]) REFERENCES Customers([CustomerID]),
								FOREIGN KEY 		([ProductID]) REFERENCES Products([ProductID])
);
GO

-- =============================================
-- Verify all tables were created
-- =============================================
SELECT 		TABLE_NAME
FROM 		INFORMATION_SCHEMA.TABLES
WHERE 		TABLE_SCHEMA = 'dbo';
GO
