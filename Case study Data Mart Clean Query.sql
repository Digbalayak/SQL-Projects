use case1;

select * from weekly_sales LIMIT 10;

-- A.	Data Cleansing Steps

-- 1.	Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 
-- 8th to 14th will be 2, etc. and more steps you can see  FROM SQL notes DATA CLEANSING.

CREATE TABLE clean_weekly_sales as
SELECT week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calender_year,
region,platform,
CASE WHEN segment=null THEN 'Unknown'
	ELSE segment
	END AS segment,
CASE 
	WHEN right(segment,1)='1' THEN 'Young Adults'
    WHEN RIGHT(segment,1)= '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
    ELSE 'Unknown'
    END AS age_band,
CASE 
	WHEN LEFT(segment,1) ='C' THEN 'Couples'
    WHEN LEFT(segment,1) ='F' THEN 'Families'
    ELSE 'Unknown'
    END AS demographic,customer_type,transactions,sales,
ROUND(sales/transactions,2) as 'avg_sales'
FROM weekly_sales;

SELECT * from clean_weekly_sales LIMIT 10;

-- B. Data Exploration
-- 1.Which week numbers are missing from the dataset? 
CREATE TABLE seq100(x int auto_increment primary key);
INSERT INTO seq100 values(),(),(),(),(),(),(),(),(),();
INSERT INTO seq100 values(),(),(),(),(),(),(),(),(),();
INSERT INTO seq100 values(),(),(),(),(),(),(),(),(),();
INSERT INTO seq100 values(),(),(),(),(),(),(),(),(),();
INSERT INTO seq100 values(),(),(),(),(),(),(),(),(),();

SELECT * FROM seq100;

INSERT INTO seq100 SELECT x+50 from seq100;

-- NOW CREATE A TABLE FOR SEQ 52 for in year there are 52 weeks
CREATE TABLE seq52 as(SELECT X FROM seq100 LIMIT 52);
SELECT *FROM seq52;

-- check which week numbers are not present in data 
SELECT x as week_day from seq52
WHERE x not in (SELECT week_number from clean_weekly_sales);

-- 2.	How many total transactions were there for each year in the dataset?
SELECT calender_year,sum(transactions) as 'Total Transaction' FROM clean_weekly_sales
GROUP BY calender_year;


-- 3.	What are the total sales for each region for each month?
SELECT region,month_number,sum(sales) as 'Total Sales' from clean_weekly_sales
GROUP BY month_number,region;

-- 4.What is the total count of transactions for each platform?

SELECT platform,SUM(transactions) as 'Total Transactions' FROM clean_weekly_sales
GROUP BY platform;

-- 5.What is the percentage of sales for Retail vs Shopify for each month?

WITH cte_each_month_sale as
(SELECT month_number,calender_year,platform,sum(sales) as monthly_sales 
from clean_weekly_sales
GROUP BY month_number,calender_year,platform)
select month_number,calender_year,
round(100*MAX(case when platform='Retail' 
	THEN monthly_sales else null end)/sum(monthly_sales),2) as retail_percentage,
round(100*MAX(CASE WHEN platform='Shopify'
	THEN monthly_sales else null end)/sum(monthly_sales),2) as shopify_percentage
FROM cte_each_month_sale GROUP BY month_number,calender_year;

-- 6.What is the percentage of sales by demographic for each year in the dataset?
SELECT * from clean_weekly_sales LIMIT 10;

SELECT calender_year,demographic,sum(sales) as yearly_sales,
round(100*sum(sales)/sum(sum(sales)) 
over (partition by demographic),2)as percentage
from clean_weekly_sales;

-- 7.	Which age_band and demographic values contribute the most to Retail sales?

SELECT age_band,demographic,sum(sales) as Total_sales from clean_weekly_sales
WHERE platform='Retail'
GROUP BY age_band,demographic
ORDER BY Total_sales;

