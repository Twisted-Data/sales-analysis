-- creating database
CREATE DATABASE retail_project;

-- creating table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR (15),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

SELECT *
FROM retail_sales
LIMIT 10;

SELECT COUNT(*)
FROM retail_sales;

-- DATA CLEANING

-- checking for null values
SELECT *
FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	customer_id IS NULL
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;


-- Deleting null values
DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	customer_id IS NULL
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

-- EXPLORATORY DATA ANALYSIS

-- Number of sales
SELECT COUNT(*) AS total_sales
FROM retail_sales;

-- Number of unique customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM retail_sales;

-- Number of unique categories
SELECT DISTINCT category
FROM retail_sales;

-- ANSWERING BUSINESS QUESTIONS

--  All sales made on 2022-1-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Retrieve all transactions where the category is clothing and the quantity sold is more than 4 in the month of November 2022
SELECT *
FROM retail_sales
WHERE category ILIKE 'clothing'
	AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND
	quantity >= 4;

-- Find the total orders and net value for each category
SELECT 
	category,
	SUM(total_sale) AS net_sales,
	COUNT(total_sale) AS total_orders
FROM retail_sales
GROUP BY category;

-- Find the average age of customers who purchased items from the beauty category
SELECT
	ROUND(AVG(age), 2) AS average_age
FROM retail_sales
WHERE category = 'Beauty';

-- Find all sales where the total sales is greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Total number of transactions made by each gender in each category
SELECT 
	category,
	gender,
	COUNT(*) AS total_transations
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Calculate the average sale for each month and find out the best selling in each year
WITH cte AS
(SELECT 
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	AVG(total_sale) AS average_sale,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
FROM retail_sales
GROUP BY year, month)
SELECT *
FROM cte
WHERE rank = 1;

-- Find the top 5 customers based on the highest total sales
SELECT 
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY  customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Find the number of unique customers that purchased from each category
SELECT 
	category,
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Create a shift for each order using the guideline(Morning: before noon, Afternoon: Between 12 & 17, Evening: After 17)
WITH hourly_sale AS
(SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS Shift
FROM retail_sales)
SELECT
	Shift,
	COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;