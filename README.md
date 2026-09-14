<div align="center">

# Retail Sales Performance Analysis
### End-to-End Data Pipeline: Python → SQL Server → Power BI

</div>

---

## Business Problem

Retail businesses generate large volumes of transactional data, but raw sales records alone don't reveal *where* a business is actually profitable. This project simulates a real-world analytics workflow for a national superstore, using four years of order-level sales data (2014–2017) to answer questions a business stakeholder would actually ask:

  - Which regions and product categories drive the most revenue, and which are most profitable?
  - Are there specific products or transactions actively losing the business money?
  - How does sales performance trend over time, and are there seasonal patterns worth planning around?
  - Who are the highest-value customers, and how concentrated is revenue among them?

**Key finding:** despite ~$2.3M in total sales, overall profit margin sits at just 12.5%, and Furniture emerges as a consistently low-margin category, including individual orders sold at a loss. This kind of gap between revenue and profitability is a common, high-stakes problem in retail.

---

## Dashboard Preview

![Sales Dashboard Screenshot](screenshots/dashboard.png)

---

## Tech Stack

| Layer | Tools |
|---|---|
| Data Cleaning & Feature Engineering | Python, pandas, Jupyter Notebook |
| Database & Querying | Microsoft SQL Server 2019, SQL Server Management Studio (SSMS), T-SQL |
| Visualization | Power BI Desktop, DAX |
| Version Control | Git, GitHub |

---

## Project Structure

```
├── python/
│   └── data_cleaning.ipynb        # Cleaning, feature engineering, export
├── sql/
│   ├── 01_create_tables.sql       # Schema design (Customers, Products, Orders)
│   ├── 02_load_data.sql           # BULK INSERT scripts and verification
│   ├── 03_queries.sql             # Core analytical queries
│   ├── 04_views.sql               # Reusable views for Power BI
│   └── 05_indexes.sql             # Indexing and execution plan demonstration
├── powerbi/
│   └── sales_dashboard.pbix
└── README.md
```

---

## What This Project Demonstrates

This is an end-to-end pipeline built entirely from scratch, including real data quality issues discovered and resolved along the way, not a clean, pre-packaged dataset.

  - **Python — Data Cleaning & Feature Engineering**
    - Loaded and explored raw data (nulls, duplicates, categorical consistency checks).
    - Diagnosed and fixed a real Excel-export data quality bug: postal codes lost leading zeros on load. Traced the issue back to the raw source file, identified the affected records (Northeastern states with 0-prefix ZIP codes), and restored them with a documented, justified fix.
    - Corrected date parsing and verified day/month interpretation against raw values.
    - Engineered new features: order-to-ship time, year/month/quarter, profit margin.
    - Identified and fixed floating-point precision artifacts in calculated columns before export.
    - Standardized column naming (PascalCase) at the source, after learning the cost of not doing this earlier in the pipeline.

  - **SQL Server — Schema Design & Advanced Querying**
    - Designed a normalized schema (`Customers`, `Products`, `Orders`) with appropriate data types, constraints, and foreign keys, built from a single flat table.
    - Investigated data relationships before normalizing, uncovering a real integrity issue (duplicate Product IDs mapped to different product names) and made a documented design decision to handle it.
    - Debugged a `BULK INSERT` limitation with quoted fields containing embedded commas; resolved it by switching to a pipe-delimited export.
    - Diagnosed and resolved invisible tab characters hidden in column names, using `ASCII()`/`LEN()` to detect them and dynamic SQL (`QUOTENAME`, `sp_executesql`) to rename columns without ever needing to type the problematic characters.
    - Wrote queries spanning filtering, aggregation, multi-table JOINs, subqueries, CTEs, and window functions (`SUM() OVER()`, `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `LAG()`), including hands-on discovery of tie-breaking behavior differences between ranking functions.
    - Built reusable SQL Views for downstream reporting.
    - Used execution plans to demonstrate the real performance impact of indexing (Scan → Seek).

  - **Power BI — Dashboard & DAX**
    - Connected Power BI directly to SQL Server; built a proper Date table for time-intelligence functions.
    - Wrote DAX measures for Total Sales, Total Profit, Profit Margin, and Month-over-Month Growth.
    - Debugged three separate real Power BI issues: incorrect chart granularity (daily vs. monthly), hierarchy drill-down collapsing dimensions unexpectedly, and a chart silently sorted by value instead of chronologically.
    - Caught and fixed a genuine ranking bug in a "Top 10 Customers" visual by cross-verifying Power BI's output against SQL; the visual was silently returning incorrect numbers before the fix.
    - Built an interactive dashboard: KPI cards, region/category breakdowns, a ranked customer table, and time-trend visuals, with working Date and Region slicers.

---

## Key Insights

  - **Furniture is a low-margin category.** Comparable in sales volume to Office Supplies, but with disproportionately thin profit, including at least one order sold at a significant loss.
  - **Technology drives the strongest combination of sales and profit** among the three categories.
  - **West is the top-performing region by sales**, followed by East, Central, and South.
  - **March shows a recurring uptick across multiple years**, suggesting a possible seasonal pattern worth further investigation.
  - **Revenue is meaningfully concentrated.** The top 10 customers account for a disproportionate share of total sales.

---

## Known Limitations & Honest Notes

  - Column names were standardized to PascalCase after loading into SQL Server rather than at the Python stage. In hindsight, renaming earlier in the pipeline would have avoided a real debugging detour (invisible tab characters in copy-pasted column names).
  - `Product Name` was intentionally kept in the `Orders` table rather than fully normalized into `Products`, due to a small number of Product IDs mapping to more than one product name in the source data. This is documented as a known data quality issue rather than silently resolved.
  - The dataset covers 2014–2017; trends and seasonal patterns are illustrative and specific to this historical window.

---

## How to Reproduce This Project

  1. Run the Python notebook (`python/data_cleaning.ipynb`) to clean the raw dataset and export `cleaned_superstore.csv`.
  2. Run the SQL scripts in order (`sql/01` through `sql/05`) against a SQL Server instance to build the schema, load data, create views, and add indexes.
  3. Open `powerbi/sales_dashboard.pbix` in Power BI Desktop and point the data source to your SQL Server instance.
  4. Refresh the data model.

---

## Author

*(Your name, LinkedIn, and/or portfolio link here)*
