SELECT * 
From orders$

--1. KPIs for Total Revenue, Profit, # of Orders, Profit Margin

SELECT 
		SUM(revenue) as total_revenue,
		SUM(profit) as total_profit, 
		COUNT(*) as total_orders, 
		SUM(profit)/SUM(revenue) * 100.0 as profit_margin
FROM 
		orders$

--2. Total Revenue, Profit, # of Orders, Profit Margin for each sport

SELECT 
		sport,
		ROUND(SUM(revenue),2) as total_revenue,
		ROUND(SUM(profit),2) as total_profit, 
		COUNT(*) as total_orders, 
		SUM(profit)/SUM(revenue) * 100.0 as profit_margin
FROM 
		orders$
WHERE sport IS NOT NULL 
GROUP BY 
		sport 
ORDER BY 
		profit_margin DESC 


--3. Number of customer ratings and the average rating 

SELECT
	(select count(*) 
	from orders$ 
	where rating IS NOT NULL) AS number_of_reviews,
	ROUND(avg(rating),2) AS average_rating
FROM
	orders$ 

--4. Number of people for each rating and its revenue, profit, profit margin

SELECT 
	rating,
	SUM(revenue) AS total_revenue, 
	SUM(profit) AS total_profit, 
	SUM(profit)/SUM(revenue) * 100.0 AS profit_margin
FROM 
	orders$
WHERE 
	rating IS NOT NULL
GROUP BY 
	rating
ORDER BY 
	rating DESC

--5. State revenue, profit, and profit margin

SELECT 
	a.state,
	ROW_NUMBER() OVER (ORDER BY SUM(b.revenue) DESC) AS revenue_rank,
	SUM(b.revenue) AS total_revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(b.profit) DESC) AS profit_rank,
	SUM(b.profit) AS total_profit, 
	ROW_NUMBER() OVER (ORDER BY SUM(b.profit)/SUM(b.revenue) * 100.0 DESC) AS margin_rank,
	SUM(b.profit)/SUM(b.revenue) * 100.0 AS profit_margin
FROM
	orders$ b 
JOIN
	customers$ a
ON 
	b.customer_id = a.customer_id 
GROUP BY 
	a.state
ORDER BY 
	margin_rank 

--6. Monthly Profits

WITH monthly_profit AS (SELECT	
	MONTH(DATE) AS month, 
	SUM(profit) AS total_profit
FROM 
	orders$
WHERE date IS NOT NULL 
GROUP BY 
	MONTH(date) ) 
SELECT 
	month, 
	total_profit,
	LAG(total_profit) OVER (ORDER BY month) AS previous_month_profit, 
	total_profit - LAG(total_profit) OVER (ORDER BY month) AS profit_difference
FROM
	monthly_profit
ORDER BY
	month 