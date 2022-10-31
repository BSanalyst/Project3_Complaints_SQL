# Project3_Complaints_SQL

In this project I used SQL to clean and analyse the following dataset:
*https://data.world/markbradbourne/rwfd-real-world-fake-data/workspace/file?filename=Financial+Consumer+Complaints.csv* ..

The data had over 75,000 records based on consumer complaints. Who doesn't love a good moan? 😄


**Cleaning process:** 
1. Creating a copy table of the dataset (replicating that I wouldn't alter the raw data)
2. Formatting datatypes
3. Formatted records by using REPLACE and PARSENAME
4. Checked for duplicates
5. Dropped columns that wouldn't be used during the analysis

**Analysis:** 
1. Identified columns to draw insights from 
2. Aggregated data where needed using group by 
3. Used common table expressions
4. Used the window functions: max() to identify group leaders 
5. Time series analysis looking at yearly data, monthly data by year, and data by day name 
6. Pivoting results using CASE
