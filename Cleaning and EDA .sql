/****** Viewing All data ******/
SELECT *
FROM [Project Portfolio Solo].[dbo].[Financial Consumer Complaints]

-- Cleaning: create copy file -- 
SELECT * 
INTO [Cleaning Financial Consumer Complaints] 
FROM [Financial Consumer Complaints]
-----------------------------------------------------------------------------------------------

/* Duplicates? */
SELECT count(*), count(distinct [Complaint ID])
FROM [Project Portfolio Solo].[dbo].[Cleaning Financial Consumer Complaints] -- no
-----------------------------------------------------------------------------------------------

/* Convert date for [date submitted] */
-- currently m/d/y
SELECT [Date Submitted], convert(date,[Date Submitted]) FROM [Cleaning Financial Consumer Complaints]

-- add new column into table and fill with converted date
ALTER TABLE [Cleaning Financial Consumer Complaints]
Add [Date Submitted Clean] date

Update [Cleaning Financial Consumer Complaints]
set [Date Submitted Clean] = convert(date,[Date Submitted])

-- technique for rearranging the way the date order, if there was errors with convert
SELECT 
	CONCAT_WS('/',
	PARSENAME(replace([Date Submitted],'/','.'),1) , 
	PARSENAME(replace([Date Submitted],'/','.'),2) , 
	PARSENAME(replace([Date Submitted],'/','.'),3))
FROM [Cleaning Financial Consumer Complaints]
-----------------------------------------------------------------------------------------------

-- replacing [Sub-product] records where the name is: "" 
-- using CASE as I don't want to alter records which coincidentally contain "". Can't use replace here! 

SELECT distinct [Sub-product] from [Cleaning Financial Consumer Complaints]

SELECT
	product,
	[Sub-product],
	CASE
		WHEN [Sub-product] = '""' then Product
		ELSE [Sub-product]
	END as [Sub-product clean]
FROM [Cleaning Financial Consumer Complaints]

-- update and replace column in table
ALTER TABLE [Cleaning Financial Consumer Complaints]
Add [Sub-product clean] nvarchar(255)

Update [Cleaning Financial Consumer Complaints]
set [Sub-product clean] = CASE
		WHEN [Sub-product] = '""' then Product
		ELSE [Sub-product]
	END
FROM [Cleaning Financial Consumer Complaints]
-----------------------------------------------------------------------------------------------

/* Convert date for [date received] */
-- currently m/d/y
SELECT [Date Received], convert(date,[Date Received]) FROM [Cleaning Financial Consumer Complaints]

-- update and replace column in table
ALTER TABLE [Cleaning Financial Consumer Complaints]
Add [Date Received Clean] date

Update [Cleaning Financial Consumer Complaints]
set [Date Received Clean] = convert(date,[Date Received])

-----------------------------------------------------------------------------------------------
-- All Data Cleaned and ready for EDA; now to drop the redundant columns;
ALTER TABLE [Cleaning Financial Consumer Complaints]
DROP column [date submitted], tags, [Date Received], [Consumer consent provided?], [Sub-product]
-----------------------------------------------------------------------------------------------
 
 -- EDA --
 SELECT TOP 1000 * FROM [Cleaning Financial Consumer Complaints]

 SELECT distinct Product FROM [Cleaning Financial Consumer Complaints] -- [8 categories] (proportion analysis / drill down)
 SELECT distinct [Sub-product clean] FROM [Cleaning Financial Consumer Complaints] -- [45 categories] (sorted analysis)
 SELECT distinct Issue FROM [Cleaning Financial Consumer Complaints] -- [88 categories] analysis
 SELECT distinct [Submitted via] FROM [Cleaning Financial Consumer Complaints] -- [6 categories] (proportion analysis)
 SELECT distinct [Company response to consumer] FROM [Cleaning Financial Consumer Complaints] -- [8 categories] (proportion analysis)
 SELECT distinct [Timely response?] FROM [Cleaning Financial Consumer Complaints] -- [2 categories] (proportion analysis/drilldown?)
 SELECT distinct [Consumer disputed?] FROM [Cleaning Financial Consumer Complaints] -- [3 categories] (proportion analysis

 -----------------------------------------------------------------------------------------------

 -- Questions --
 -- Q1) How many total complaints were there?
SELECT count([Complaint ID]) as number_of_complaints from [Cleaning Financial Consumer Complaints]
 -----------------------------------------------------------------------------------------------

 -- Questions --
 -- Q2) Which product received the most complaints?
SELECT Product, count(*) number_of_complaints  FROM [Cleaning Financial Consumer Complaints] GROUP BY Product ORDER BY 2 DESC
 -----------------------------------------------------------------------------------------------

 -- Questions --
 -- Q3) By Product, find the highest volume of complaints for subproducts?
SELECT product, [Sub-product clean], count(*) as number_of_complaints  FROM [Cleaning Financial Consumer Complaints] GROUP BY product, [Sub-product clean]
 ORDER BY 1,3 DESC

  -- Questions --
 -- Q3.1) By Product, find the biggest contributor of complaints for sub-products?
 with cte1 as (
		SELECT product, [Sub-product clean], count(*) as number_of_complaints  FROM [Cleaning Financial Consumer Complaints] GROUP BY product, [Sub-product clean]
 ),
	cte2 as(
		SELECT *, max(number_of_complaints) over (partition by product) maxnum FROM cte1
 )
		SELECT product, [Sub-product clean], number_of_complaints FROM CTE2 WHERE number_of_complaints = maxnum
-----------------------------------------------------------------------------------------------

-- Questions --
 -- Q4) Top 10 issues that received the most complaints?
SELECT top 10  issue, count(*) complaints FROM [Cleaning Financial Consumer Complaints] group by issue order by 2 desc
-----------------------------------------------------------------------------------------------

-- Questions --
 -- Q5) Which medium is used most for complaints?
 SELECT [Submitted via], count(*) as number_of_complaints FROM [Cleaning Financial Consumer Complaints] group by [Submitted via]

 -- Q5.1) Using proportions, show whether there was a timely response or not for each medium
 -- step 1
 SELECT [Submitted via], [Timely response?], count(*) as number_of_complaints FROM [Cleaning Financial Consumer Complaints] group by [Submitted via], [Timely response?] order by 1,2

 --step 2
 with cte1 as
 (
	SELECT [Submitted via], [Timely response?], count(*) as number_of_complaints FROM [Cleaning Financial Consumer Complaints] group by [Submitted via], [Timely response?]
 ),
	cte2 as
 (
	SELECT [Submitted via], [Timely response?], number_of_complaints, sum(number_of_complaints) OVER (partition by [Submitted via]) totals FROM cte1 
 )
	SELECT [submitted via], [Timely response?], number_of_complaints, cast(number_of_complaints as numeric)/totals*100 as response_proportion FROM cte2 order by 1,4 ;
-----------------------------------------------------------------------------------------------

-- Questions --
 -- Q6) Which medium has the highest average time between submitting the complaint and it being received?

with cte1 as
(
	SELECT 
		[Submitted via],
		DATEDIFF(day,[Date Submitted Clean],[Date Received Clean]) as days_waited 
	FROM [Cleaning Financial Consumer Complaints]
) SELECT [Submitted via], avg(days_waited) as [Average days waited] FROM cte1 GROUP BY [Submitted via]
-----------------------------------------------------------------------------------------------

-- Questions --
 -- Q7) Look at the number of complaints by day of the week
SELECT
	 DATENAME(WEEKDAY,[Date Submitted Clean]) as day_of_week, 
	 count([Complaint ID]) as complaints
FROM  [Cleaning Financial Consumer Complaints] 
GROUP BY DATENAME(WEEKDAY,[Date Submitted Clean]) 
ORDER BY 2 DESC
-----------------------------------------------------------------------------------------------
-- Questions --
 -- Q8) Time series of yearly complaints
 SELECT
	 YEAR([Date Submitted Clean]) [Year], 
	 COUNT(*) complaints
FROM  [Cleaning Financial Consumer Complaints] 
GROUP BY YEAR([Date Submitted Clean])
ORDER BY 1

-----------------------------------------------------------------------------------------------

-- Questions --
 -- Q9) Time series of monthly complaints across the years
 SELECT
	 YEAR([Date Submitted Clean]) [Year], 
	 MONTH([Date Submitted Clean]) [Month] ,
	 COUNT(*) complaints
FROM  [Cleaning Financial Consumer Complaints] 
GROUP BY YEAR([Date Submitted Clean]), MONTH([Date Submitted Clean])
ORDER BY 1,2


-- PIVOTING results using CASE for readability 
with cte1 as(
SELECT
	 YEAR([Date Submitted Clean]) [Year], 
	 MONTH([Date Submitted Clean]) [Month] ,
	 COUNT(*) complaints
FROM  [Cleaning Financial Consumer Complaints] 
GROUP BY YEAR([Date Submitted Clean]), MONTH([Date Submitted Clean])
)
SELECT 
	[Month],
	SUM(CASE WHEN [Year] = 2011 THEN complaints else null end) as [complaints in 2011],
	SUM(CASE WHEN [Year] = 2012 THEN complaints else null end) as [complaints in 2012],
	SUM(CASE WHEN [Year] = 2013 THEN complaints else null end) as [complaints in 2013],
	SUM(CASE WHEN [Year] = 2014 THEN complaints else null end) as [complaints in 2014],
	SUM(CASE WHEN [Year] = 2015 THEN complaints else null end) as [complaints in 2015],
	SUM(CASE WHEN [Year] = 2016 THEN complaints else null end) as [complaints in 2016],
	SUM(CASE WHEN [Year] = 2017 THEN complaints else null end) as [complaints in 2017],
	SUM(CASE WHEN [Year] = 2018 THEN complaints else null end) as [complaints in 2018],
	SUM(CASE WHEN [Year] = 2019 THEN complaints else null end) as [complaints in 2019],
	SUM(CASE WHEN [Year] = 2020 THEN complaints else null end) as [complaints in 2020]
FROM cte1
GROUP BY month
;