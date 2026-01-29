🍬US CANDY SALES: DATA ENGINEERING & ANALYSIS


📋 Project Overview
This project demonstrates a complete data workflow: from ingesting "messy" raw CSV data to performing advanced analytical queries in SQL. The analysis focuses on a candy distributor's sales performance across the US and Canada, identifying high-margin products, standardizing date formats for time-series analysis, and ranking regional performance.

🏗️ Data Architecture
The project utilizes a relational database structure with the following entities:

candy_sales: The core fact table containing over 15 columns including sales, profit, and cost metrics.

Candy_Products: A dimension table for product attributes and factory sourcing.

Candy_Factories: Geospatial data for manufacturing sites.

Candy_Targets: Performance benchmarks for the Chocolate, Sugar, and Other divisions.

🛠️ Technical Deep Dive
1. Advanced ETL & Data Standardization
One of the primary challenges was the inconsistent date formats in the raw source files. I developed a conditional update script using STR_TO_DATE and CASE logic to transform mixed formats into a standardized DATE type, enabling accurate time-period analysis.

SQL
UPDATE candy_sales 
SET order_date = CASE 
    WHEN order_date LIKE '____-__-__' THEN order_date
    WHEN order_date LIKE '__-__-____' THEN STR_TO_DATE(order_date, '%d-%m-%Y')
    ELSE order_date 
END;
2. Quarterly Performance Partitioning
Using Common Table Expressions (CTEs) and Window Functions, I ranked monthly sales totals into quartiles. This allows the business to identify which months are consistently in the top 25% of performance for each division.

SQL
WITH monthly AS (
    SELECT division, month(order_date) as month_num, sum(sales) as total_sales
    FROM candy_sales
    GROUP BY division, month_num
)
SELECT division, total_sales,
       NTILE(4) OVER (PARTITION BY division ORDER BY total_sales) as sales_quartile
FROM monthly;
3. Comprehensive Executive Reporting
I utilized UNION ALL to create a consolidated KPI report. This single view provides an instant snapshot of:

Total Revenue & Gross Profit

Operational Scale (Total unique orders and regions)

Product Breadth (Distinct product counts across US/Canada)

📈 Key Business Insights
Product Performance: Identified the Wonka Bar - Triple Dazzle Caramel and Scrumdiddlyumptious as significant revenue drivers.

Regional Footprint: The analysis spans 4 key regions (Atlantic, Gulf, Interior, Pacific) across two countries.

Factory Efficiency: Mapped production from sites like Lot's O' Nuts and Wicked Choccy's to specific product lines.

📂 Repository Structure
/data: Contains raw .csv data files.

/scripts: Includes candy_sql_script.sql with full cleaning and analysis code.

README.md: Project documentation and insights.

🚀 How to Run
Import the CSV files into your SQL environment (MySQL preferred).

Run the candy_sql_script.sql to perform the data cleaning.

Execute the analytical queries to generate the "Key Metrics Report."

Author: AKSHAY R  Project Type: SQL Portfolio Project 
