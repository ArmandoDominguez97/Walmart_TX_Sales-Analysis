-- Number of transactions and total quantity sold per payment method
SELECT 
	payment_method, 
	COUNT(*) AS number_of_transactions, 
	SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method
ORDER BY number_of_transactions DESC, total_quantity DESC;

-- Highest-rated category in each branch.
SELECT * 			-- Subquery Method
FROM
(	SELECT			-- Subquery that ranks each category by it's average rating within each branch. 
		Branch,
		City,
		category,
		ROUND(AVG(rating), 1) AS Average_Rating,		 
		RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) as cat_rank -- Partition by used to rank every category within every branch by their respective average rating.
	FROM walmart
	GROUP BY Branch, City, Category
) AS top_category
WHERE cat_rank=1;

WITH ranked AS (	-- CTE Method, where the same subquery is put into a CTE
	SELECT 
		branch,
        city,
        category,
        ROUND(AVG(rating), 1) AS average_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as cat_rank
        FROM walmart
        GROUP BY branch, city, category
	)
SELECT * FROM ranked
WHERE cat_rank = 1;



-- Day with most total transactions for each branch

SELECT *		-- Subquery Method
FROM
(	SELECT
		branch,
		dayname(str_to_date(date, '%d/%m/%Y')) as day_of_week,
		COUNT(*) AS number_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS weekday_rank
	FROM walmart
	GROUP BY branch, day_of_week
) AS day_ranking
WHERE weekday_rank = 1;

WITH day_rank AS (		-- CTE Method
	SELECT
		branch,
		dayname(str_to_date(date, '%d/%m/%Y')) as day_of_week,
		COUNT(*) AS number_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS weekday_rank
	FROM walmart
	GROUP BY branch, day_of_week
    )
SELECT * FROM day_rank
WHERE weekday_rank = 1;

-- Average, minimum, and maximum rating of each category for each city.
-- city, average_rating, min_rating, and max_rating

SELECT 
	city,
    category,
    ROUND(AVG(rating), 1) AS average_rating,
    MIN(rating) AS min_rating,
    MAX(rating) as max_rating
FROM walmart
GROUP BY city, category
ORDER BY city;

-- total profit for each category

SELECT 
	category,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(SUM(total * profit_margin), 2) as profit
FROM walmart
GROUP BY category;


-- Most common payment method for each branch.

SELECT 				-- subquery method
	branch,
    payment_method
FROM 
(SELECT 
	branch,
    payment_method,
    COUNT(*) AS number_of_transactions,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS method_rank
FROM walmart
GROUP BY branch, payment_method
) AS payment_method_rank_by_branch
WHERE method_rank = 1;

WITH payment_method_rank_branch AS (	-- CTE Method
SELECT 
	branch,
    payment_method,
    COUNT(*) AS number_of_transactions,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS method_rank
FROM walmart
GROUP BY branch, payment_method
)
SELECT 
	branch,
    payment_method
FROM payment_method_rank_branch
WHERE method_rank = 1;

-- Categorize invoices between morning, afternoon, evening
-- Find out total transactions per shift

SELECT
branch,
CASE 
	WHEN HOUR(time) < 12 THEN 'Morning'
    WHEN HOUR(time) >= 12 AND HOUR(time) < 17 THEN 'Afternoon'
    ELSE 'Evening'
END AS shift,
COUNT(invoice_id) AS number_of_transactions
FROM walmart
GROUP BY branch, shift
ORDER BY branch, number_of_transactions DESC;

-- Branches with the highest proportional decrease in revenue from 2022 to 2023

SELECT 
	branch,
    sum(total) as revenue				-- query structure that I used for both of my subqueries.
FROM walmart
-- WHERE YEAR(str_to_date(date, '%d/%m/%Y')) = 202x  #this where clause extracts the year of each row by converting date values from strings to date and then extracting the year from the converted values
GROUP BY branch;

-- Query I came up with on my own. As you can see it is unneccesarily complex
SELECT 							
	revenue_22.branch, 
    revenue_2022, 
    revenue_2023, 
    (revenue_2023 - revenue_2022) AS YoY_change, 
    ROUND((((revenue_2023 - revenue_2022)/ revenue_2022) * 100), 2) AS proportion_of_change		-- Round([value or column], [# of decminal places]). This clause used to round proportion_of_change to two decimal places
FROM
(SELECT 
	branch,
    sum(total) AS revenue_2022
FROM walmart							-- Subquery that returns total revenue for each branch in 2022
WHERE YEAR(str_to_date(date, '%d/%m/%Y')) = 2022
GROUP BY branch
) AS revenue_22
JOIN										-- Inner Join
(SELECT 
	branch,
	SUM(total) AS revenue_2023
FROM walmart								-- subquery that returns total revenue for each branch in 2023
WHERE YEAR(str_to_date(date, '%d/%m/%Y')) = 2023
GROUP BY branch
) AS revenue_23
ON revenue_22.branch = revenue_23.branch		-- join clause. Joined both subqueries on their branch columns.
ORDER BY proportion_of_change ASC LIMIT 5;		-- Ordered  % change from smallest to largest. The smallest in this case are the values of the largest negative number, which denotes the largest proportional decrease.

-- second query. created using CTEs with help from internet.

SELECT 
branch,
SUM(total) AS revenue			-- Query structure for CTEs
FROM walmart
-- WHERE YEAR(str_to_date(date, '%d/%m/%Y')) = 202x
GROUP BY branch;

WITH 
revenue_22		-- CTE with 2022 revenue values
AS
(
SELECT 
branch,
SUM(total) AS revenue_2022
FROM walmart
WHERE YEAR(str_to_date(date, '%d/%m/%Y')) = 2022
GROUP BY branch
),
revenue_23		-- CTE with 2023 revenue values
AS
(
SELECT 
branch,
SUM(total) AS revenue_2023
FROM walmart
WHERE YEAR(str_to_date(date, '%d/%m/%Y')) = 2023
GROUP BY branch
)

SELECT 					-- Query that returns values we are looking for.
	revenue_22.branch,
    revenue_2022,
    revenue_2023,
	(revenue_2023 - revenue_2022) AS YoY_change, 
    ROUND((((revenue_2023 - revenue_2022)/ revenue_2022) * 100), 2) AS proportion_of_change
FROM revenue_22
JOIN -- Both CTEs are inner joined on their respective branch columns
revenue_23
ON revenue_22.branch = revenue_23.branch
ORDER BY proportion_of_change ASC LIMIT 5;	-- Ordered values from smallest to largest. Smallest values are the ones with the largest negative numbers, denoting the highest proportional decrease in revenue.

-- Category with the highest total profit across all branches.

SELECT 
	category,
    ROUND(SUM(total * profit_margin), 2) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- city with highest average profit margin

SELECT
	city,
    ROUND(AVG(profit_margin), 2) AS average_profit_margin
FROM walmart
GROUP BY city
ORDER BY average_profit_margin DESC;

-- Comparing each city's average profit margin with it's total profit and revenue.

SELECT
    City,
    ROUND(AVG(profit_margin), 2) AS avg_profit_margin,
    ROUND(SUM(total * profit_margin), 2) AS total_profit,
    ROUND(SUM(total), 2) AS total_revenue
FROM walmart
GROUP BY City
ORDER BY total_profit DESC, avg_profit_margin DESC;

-- total profit and profit percentage for each categroy within ever branch.

SELECT
    Branch,
    City,
    category,
    ROUND(SUM(total * profit_margin), 2) AS total_profit,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(SUM(total * profit_margin) / SUM(total) * 100, 2) AS profit_pct
FROM walmart
GROUP BY Branch, City, category
ORDER BY total_profit DESC, profit_pct DESC;

-- most categories had at least a 40% profit_percentage at most branches. Looking for combinations of the two with abnormally small profit_pct values (less than 40%)

WITH profit_analysis
AS
(
SELECT
    Branch,
    City,
    category,
    ROUND(SUM(total * profit_margin), 2) AS total_profit,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(SUM(total * profit_margin) / SUM(total) * 100, 2) AS profit_pct
FROM walmart
GROUP BY Branch, City, category
)

SELECT * FROM profit_analysis
WHERE profit_pct < 40;

-- Month-to-month revenue 2020-2023

SELECT 
    YEAR(STR_TO_DATE(date, '%d/%m/%Y')) AS calendar_year,
    MONTH(STR_TO_DATE(date, '%d/%m/%Y')) AS calendar_month,
    MONTHNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS month_name,
    ROUND(SUM(total), 2) AS total_revenue
FROM walmart
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) != 2019
GROUP BY calendar_year, calendar_month, month_name
ORDER BY calendar_year, calendar_month;

-- Month-over-Month Revenue

WITH monthly_revenue AS 
(
SELECT 
    YEAR(STR_TO_DATE(date, '%d/%m/%Y')) AS calendar_year,
    MONTH(STR_TO_DATE(date, '%d/%m/%Y')) AS calendar_month,
    MONTHNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS month_name,
    ROUND(SUM(total), 2) AS total_revenue
FROM walmart
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) != 2019
GROUP BY calendar_year, calendar_month, month_name
)
SELECT 
	*,
    LAG(total_revenue, 1) OVER (ORDER BY calendar_year, calendar_month) AS prev_month_revenue,
    ROUND(total_revenue - LAG(total_revenue, 1) OVER (ORDER BY calendar_year, calendar_month), 2) AS month_over_month_change
FROM monthly_revenue
ORDER BY calendar_year, calendar_month;

-- branches that are in the top 25% in total revenue across all years

WITH 
annual_revenue
AS
(
SELECT				-- CTE that selects for each branches annual revenue
	branch,
    YEAR(STR_TO_DATE(date,'%d/%m/%Y')) AS calendar_year,
    ROUND(SUM(total), 2) AS annual_revenue
FROM walmart
WHERE YEAR(STR_TO_DATE(date,'%d/%m/%Y')) != 2019
GROUP BY branch, calendar_year
),
ranked_branches
AS 
(
SELECT				-- CTE that ranks groups each branch into a 4 quartiles. NOTE that CTE 2 references CTE 1
	branch,
    calendar_year,
    annual_revenue,
    NTILE(4) OVER (PARTITION BY calendar_year ORDER BY annual_revenue DESC) AS revenue_quartile
FROM annual_revenue
)
SELECT		-- 
	branch,
    COUNT(DISTINCT calendar_year) AS years_in_top_25
FROM ranked_branches
WHERE revenue_quartile = 1
GROUP BY branch
HAVING COUNT(DISTINCT calendar_year) = 4
ORDER BY years_in_top_25 DESC;

WITH annual_revenue AS (	-- Second query to double-check validity of first output. involves a third CTE
    SELECT
        Branch,
        YEAR(STR_TO_DATE(date, '%d/%m/%Y')) AS calendar_year,
        ROUND(SUM(total), 2) AS annual_revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) != 2019
    GROUP BY Branch, calendar_year
),
ranked_branches AS (		-- rank each branch into a quartile
    SELECT
        Branch,
        calendar_year,
        annual_revenue,
        NTILE(4) OVER (PARTITION BY calendar_year ORDER BY annual_revenue DESC) AS revenue_quartile
    FROM annual_revenue
),
consistent_top AS (		-- the aggregation of the first query is now a third CTE
    SELECT Branch
    FROM ranked_branches
    WHERE revenue_quartile = 1
    GROUP BY Branch
    HAVING COUNT(DISTINCT calendar_year) = 4
)
SELECT
    rb.Branch,
    rb.calendar_year,
    rb.annual_revenue,
    rb.revenue_quartile
FROM ranked_branches rb
JOIN consistent_top ct ON rb.Branch = ct.Branch		-- join statement combining 2nd and third CTEs
ORDER BY rb.Branch, rb.calendar_year;

-- Branches with the highest revenue growth growth from 2019 to 2023

WITH 
annual_revenue
AS
(
SELECT
	branch,
    YEAR(STR_TO_DATE(date, '%d/%m/%Y')) AS calendar_year,
    ROUND(SUM(total), 2) AS annual_revenue
FROM walmart
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) != 2019
GROUP BY branch, calendar_year
)
SELECT
	branch,
    SUM(CASE WHEN calendar_year = 2020 THEN annual_revenue END) AS revenue_2020,	-- CASE statement that sums up all transaction totals from year 2020.
    SUM(CASE WHEN calendar_year = 2023 THEN annual_revenue END) AS revenue_2023,	-- CASE statement that sums up all transaction totals from year 2023.
	ROUND(SUM(CASE WHEN calendar_year = 2023 THEN annual_revenue END) - SUM(CASE WHEN calendar_year = 2020 THEN annual_revenue END), 2) AS absolute_growth,
    ROUND((SUM(CASE WHEN calendar_year = 2023 THEN annual_revenue END) - SUM(CASE WHEN calendar_year = 2020 THEN annual_revenue END))/SUM(CASE WHEN calendar_year = 2020 THEN annual_revenue END)*100, 2) AS growth_pct
FROM annual_revenue
GROUP BY branch
ORDER BY growth_pct DESC;

-- Branches that have high revenue but low ratings

WITH 
branch_metrics
AS
(
SELECT
	branch,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmart
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) != 2019
GROUP BY branch
),
ranked
AS 
(
SELECT 
	*,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,	-- ranking each branch by revenue in descending order
    RANK() OVER (ORDER BY avg_rating ASC) AS rating_rank		-- ranking each branche's average rating in ascending order to make filtering easier. So lower number means worse rating.
FROM branch_metrics
)
SELECT * FROM ranked
WHERE revenue_rank <= 25 and rating_rank <=25
ORDER BY revenue_rank;		-- output of query shows an inverse correlation between revenue and rating. removing the where clause better demonstrates this. 