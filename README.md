# Walmart_TX_Sales-Analysis
![Cover Photo](Walmart_DA_Project_thumbnail.png)

## Overview

This project explores transactional sales data across 100 Walmart locations in the U.S. state of Texas from 2020-2023. The goal was uncover insights around branch performance, product category performance, customer behavior and revenue trends across the first four years of the 2020s decade. This project was completed via Python for data cleaning, and MySQL for analaysis.

## Dataset

- **Source:** [Kaggle](https://www.kaggle.com/datasets/najir0123/walmart-10k-sales-datasets)
- **Values:** 10,051 transactions in original dataset, 9,969 after cleaning.
- **Duration:** January 2020 - December 2023 *(2019 Q1 data is also present in dataset but excluded in analysis)
- **Scope:** 100 branches across 98 cities

| Column | Description |
|---|---|
| `invoice_id` | Unique transaction identifier |
| `Branch` | Branch code |
| `City` | City where the branch is located |
| `category` | Product category |
| `unit_price` | Price per unit |
| `quantity` | Number of units sold |
| `date` | Transaction date |
| `time` | Transaction time |
| `payment_method` | Ewallet, Cash, or Credit Card |
| `rating` | Customer rating (1–10) |
| `profit_margin` | Margin applied to the transaction |
| `total` | Total transaction value (unit_price × quantity) |

## Tools Used

- **Python** — pandas, SQLAlchemy, pymysql
- **MySQL** — Aggregations, CTEs, Window Functions (RANK, NTILE, LAG), CASE statements, date parsing
- **Jupyter Notebook** — Data exploration and cleaning workflow

## Data Cleaning (Python)

The following cleansing steps were taken before analysis:

- **Duplicate removal** — 51 duplicate rows were identified and dropped using `drop_duplicates()`
- **Null value handling** — 31 rows contained missing values in the `unit_price` and `quantity` columns. These were dropped using `dropna()` in the interest of time, though imputation could be explored as an alternative
- **Type conversion** — `unit_price` was stored as a string with a leading `$` character. The dollar sign was stripped and the column was cast to `float`
- **Feature engineering** — A `total` column was derived by multiplying `unit_price` by `quantity`, representing the gross transaction value

## Analysis (MySQL)

### 1. Payment Method Breakdown
Analyzed the number of transactions and total quantity sold per payment method to understand how customers prefer to pay.

```sql
SELECT 
    payment_method, 
    COUNT(*) AS number_of_transactions, 
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method
ORDER BY number_of_transactions DESC, total_quantity DESC;
```
| payment_method | number_of_transactions | total_quantity |
| -------------- | ---------------------- | -------------- |
| Credit card    | 4256                   | 9567           |
| Ewallet        | 3881                   | 8932           |
| Cash           | 1832                   | 4984           |
---

### 2. Highest-Rated Category per Branch
Used a window function with `RANK()` and `PARTITION BY` to identify the top-rated product category within each branch. Both a subquery and CTE approach were written to compare methods.

```sql
WITH ranked AS (
    SELECT 
        branch, city, category,
        ROUND(AVG(rating), 1) AS average_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS cat_rank
    FROM walmart
    GROUP BY branch, city, category
)
SELECT * FROM ranked
WHERE cat_rank = 1;
```
<details>
  <summary>Click to expand table</summary>

| branch  | city                 | category               | average_rating | cat_rank |
| ------- | -------------------- | ---------------------- | -------------- | -------- |
| WALM001 | Houston              | Electronic accessories | 7.4            | 1        |
| WALM002 | Dallas               | Food and beverages     | 8.2            | 1        |
| WALM003 | San Antonio          | Sports and travel      | 7.5            | 1        |
| WALM004 | Austin               | Food and beverages     | 9.3            | 1        |
| WALM005 | Fort Worth           | Health and beauty      | 8.4            | 1        |
| WALM006 | El Paso              | Fashion accessories    | 6.8            | 1        |
| WALM007 | Arlington            | Food and beverages     | 7.6            | 1        |
| WALM008 | Corpus Christi       | Food and beverages     | 7.4            | 1        |
| WALM009 | Plano                | Sports and travel      | 9.6            | 1        |
| WALM010 | Laredo               | Electronic accessories | 9              | 1        |
| WALM011 | Lubbock              | Food and beverages     | 7              | 1        |
| WALM012 | Garland              | Health and beauty      | 7.4            | 1        |
| WALM013 | Irving               | Health and beauty      | 7.6            | 1        |
| WALM014 | Amarillo             | Electronic accessories | 6.8            | 1        |
| WALM015 | Grand Prairie        | Home and lifestyle     | 6.2            | 1        |
| WALM016 | Brownsville          | Sports and travel      | 9.1            | 1        |
| WALM017 | McKinney             | Electronic accessories | 7              | 1        |
| WALM018 | Frisco               | Electronic accessories | 8.8            | 1        |
| WALM019 | Pasadena             | Electronic accessories | 8.4            | 1        |
| WALM020 | Killeen              | Food and beverages     | 8.3            | 1        |
| WALM021 | McAllen              | Sports and travel      | 7.2            | 1        |
| WALM022 | Mesquite             | Health and beauty      | 8.8            | 1        |
| WALM023 | Midland              | Health and beauty      | 8              | 1        |
| WALM024 | Carrollton           | Electronic accessories | 8.7            | 1        |
| WALM025 | Waco                 | Food and beverages     | 8.4            | 1        |
| WALM026 | Denton               | Health and beauty      | 6.8            | 1        |
| WALM027 | Abilene              | Health and beauty      | 9.7            | 1        |
| WALM028 | Odessa               | Food and beverages     | 8              | 1        |
| WALM029 | Round Rock           | Food and beverages     | 8.9            | 1        |
| WALM030 | Richardson           | Sports and travel      | 8.6            | 1        |
| WALM031 | Lewisville           | Electronic accessories | 7.6            | 1        |
| WALM032 | Tyler                | Fashion accessories    | 5.5            | 1        |
| WALM033 | Pearland             | Home and lifestyle     | 6.7            | 1        |
| WALM034 | College Station      | Health and beauty      | 10             | 1        |
| WALM035 | San Angelo           | Sports and travel      | 9.3            | 1        |
| WALM036 | Allen                | Fashion accessories    | 6.6            | 1        |
| WALM037 | League City          | Sports and travel      | 9.4            | 1        |
| WALM038 | Sugar Land           | Sports and travel      | 8.5            | 1        |
| WALM039 | Longview             | Food and beverages     | 9              | 1        |
| WALM040 | Edinburg             | Health and beauty      | 8.6            | 1        |
| WALM041 | Mission              | Food and beverages     | 8              | 1        |
| WALM042 | Bryan                | Sports and travel      | 7.2            | 1        |
| WALM043 | Baytown              | Sports and travel      | 6.4            | 1        |
| WALM044 | Pharr                | Health and beauty      | 9.2            | 1        |
| WALM045 | Missouri City        | Food and beverages     | 9.3            | 1        |
| WALM046 | Temple               | Food and beverages     | 7.3            | 1        |
| WALM047 | Flower Mound         | Health and beauty      | 8              | 1        |
| WALM048 | Harlingen            | Electronic accessories | 9.6            | 1        |
| WALM049 | North Richland Hills | Sports and travel      | 7.7            | 1        |
| WALM050 | Victoria             | Electronic accessories | 5.3            | 1        |
| WALM051 | New Braunfels        | Sports and travel      | 8.9            | 1        |
| WALM052 | Mansfield            | Electronic accessories | 7.8            | 1        |
| WALM053 | Conroe               | Sports and travel      | 8              | 1        |
| WALM054 | Sherman              | Health and beauty      | 5.6            | 1        |
| WALM055 | Waxahachie           | Food and beverages     | 7.5            | 1        |
| WALM056 | Rowlett              | Electronic accessories | 6              | 1        |
| WALM057 | Euless               | Food and beverages     | 6.8            | 1        |
| WALM058 | Port Arthur          | Health and beauty      | 6.3            | 1        |
| WALM059 | Pflugerville         | Electronic accessories | 7.9            | 1        |
| WALM060 | DeSoto               | Health and beauty      | 9.9            | 1        |
| WALM061 | Cedar Park           | Food and beverages     | 8.5            | 1        |
| WALM062 | Galveston            | Sports and travel      | 7.3            | 1        |
| WALM063 | Georgetown           | Electronic accessories | 8.3            | 1        |
| WALM064 | Bedford              | Health and beauty      | 8.2            | 1        |
| WALM065 | Texas City           | Health and beauty      | 6.5            | 1        |
| WALM066 | Grapevine            | Sports and travel      | 7.2            | 1        |
| WALM066 | Grapevine            | Health and beauty      | 7.2            | 1        |
| WALM067 | Haltom City          | Sports and travel      | 9.7            | 1        |
| WALM068 | Burleson             | Electronic accessories | 9.7            | 1        |
| WALM069 | Rockwall             | Sports and travel      | 7.8            | 1        |
| WALM070 | Hurst                | Food and beverages     | 9.1            | 1        |
| WALM071 | Lufkin               | Food and beverages     | 8.6            | 1        |
| WALM072 | Lancaster            | Sports and travel      | 8.1            | 1        |
| WALM073 | Seguin               | Food and beverages     | 9.6            | 1        |
| WALM074 | Weslaco              | Food and beverages     | 8.7            | 1        |
| WALM075 | San Marcos           | Sports and travel      | 7.9            | 1        |
| WALM076 | Huntsville           | Food and beverages     | 8.1            | 1        |
| WALM077 | Coppell              | Sports and travel      | 9.6            | 1        |
| WALM078 | Del Rio              | Food and beverages     | 9              | 1        |
| WALM079 | La Porte             | Sports and travel      | 7.2            | 1        |
| WALM080 | Nacogdoches          | Electronic accessories | 7.2            | 1        |
| WALM081 | Friendswood          | Food and beverages     | 9.1            | 1        |
| WALM082 | Weslaco              | Health and beauty      | 9.2            | 1        |
| WALM083 | Farmers Branch       | Electronic accessories | 6.6            | 1        |
| WALM084 | Schertz              | Sports and travel      | 5.5            | 1        |
| WALM085 | Kerrville            | Food and beverages     | 8.4            | 1        |
| WALM086 | Rosenberg            | Health and beauty      | 9.9            | 1        |
| WALM087 | Waxahachie           | Health and beauty      | 7.2            | 1        |
| WALM088 | Cleburne             | Sports and travel      | 7.7            | 1        |
| WALM089 | Southlake            | Sports and travel      | 8.9            | 1        |
| WALM090 | Brownwood            | Sports and travel      | 8.1            | 1        |
| WALM091 | Little Elm           | Electronic accessories | 6.2            | 1        |
| WALM092 | Lake Jackson         | Health and beauty      | 7.2            | 1        |
| WALM093 | Angleton             | Food and beverages     | 7.7            | 1        |
| WALM094 | Alamo                | Health and beauty      | 8              | 1        |
| WALM095 | Big Spring           | Health and beauty      | 7.7            | 1        |
| WALM096 | Eagle Pass           | Sports and travel      | 9.6            | 1        |
| WALM097 | Alice                | Food and beverages     | 7.7            | 1        |
| WALM098 | Mineral Wells        | Health and beauty      | 9.8            | 1        |
| WALM099 | Weatherford          | Electronic accessories | 6              | 1        |
| WALM100 | Canyon               | Health and beauty      | 6.9            | 1        |

</details>
---

### 3. Busiest Day of the Week per Branch
Identified the day with the most transactions for each branch using `DAYNAME()` and `RANK()` partitioned by branch.

```sql
WITH day_rank AS (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_of_week,
        COUNT(*) AS number_of_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS weekday_rank
    FROM walmart
    GROUP BY branch, day_of_week
)
SELECT * FROM day_rank
WHERE weekday_rank = 1;
```
<details>
  <summary>Click to expand table</summary>

| branch  | day_of_week | number_of_transactions | weekday_rank |
| ------- | ----------- | ---------------------- | ------------ |
| WALM001 | Thursday    | 16                     | 1            |
| WALM002 | Thursday    | 15                     | 1            |
| WALM003 | Tuesday     | 33                     | 1            |
| WALM004 | Sunday      | 14                     | 1            |
| WALM005 | Wednesday   | 19                     | 1            |
| WALM006 | Thursday    | 15                     | 1            |
| WALM007 | Friday      | 12                     | 1            |
| WALM007 | Sunday      | 12                     | 1            |
| WALM008 | Tuesday     | 17                     | 1            |
| WALM009 | Sunday      | 42                     | 1            |
| WALM010 | Wednesday   | 12                     | 1            |
| WALM011 | Tuesday     | 18                     | 1            |
| WALM012 | Sunday      | 20                     | 1            |
| WALM013 | Monday      | 13                     | 1            |
| WALM014 | Sunday      | 12                     | 1            |
| WALM015 | Friday      | 15                     | 1            |
| WALM016 | Tuesday     | 16                     | 1            |
| WALM017 | Thursday    | 17                     | 1            |
| WALM018 | Sunday      | 12                     | 1            |
| WALM019 | Thursday    | 13                     | 1            |
| WALM020 | Tuesday     | 16                     | 1            |
| WALM021 | Thursday    | 12                     | 1            |
| WALM022 | Friday      | 15                     | 1            |
| WALM023 | Tuesday     | 17                     | 1            |
| WALM024 | Sunday      | 14                     | 1            |
| WALM025 | Saturday    | 26                     | 1            |
| WALM025 | Thursday    | 26                     | 1            |
| WALM025 | Tuesday     | 26                     | 1            |
| WALM026 | Sunday      | 17                     | 1            |
| WALM027 | Thursday    | 14                     | 1            |
| WALM028 | Saturday    | 18                     | 1            |
| WALM029 | Thursday    | 36                     | 1            |
| WALM030 | Wednesday   | 40                     | 1            |
| WALM031 | Sunday      | 13                     | 1            |
| WALM032 | Tuesday     | 30                     | 1            |
| WALM033 | Saturday    | 10                     | 1            |
| WALM033 | Thursday    | 10                     | 1            |
| WALM034 | Wednesday   | 12                     | 1            |
| WALM035 | Saturday    | 32                     | 1            |
| WALM036 | Thursday    | 16                     | 1            |
| WALM037 | Tuesday     | 13                     | 1            |
| WALM038 | Sunday      | 37                     | 1            |
| WALM039 | Wednesday   | 15                     | 1            |
| WALM040 | Saturday    | 13                     | 1            |
| WALM041 | Friday      | 15                     | 1            |
| WALM042 | Wednesday   | 15                     | 1            |
| WALM043 | Tuesday     | 18                     | 1            |
| WALM044 | Sunday      | 18                     | 1            |
| WALM045 | Wednesday   | 13                     | 1            |
| WALM046 | Wednesday   | 35                     | 1            |
| WALM047 | Sunday      | 15                     | 1            |
| WALM048 | Monday      | 18                     | 1            |
| WALM049 | Wednesday   | 17                     | 1            |
| WALM050 | Sunday      | 32                     | 1            |
| WALM051 | Friday      | 11                     | 1            |
| WALM051 | Thursday    | 11                     | 1            |
| WALM051 | Tuesday     | 11                     | 1            |
| WALM051 | Monday      | 11                     | 1            |
| WALM052 | Tuesday     | 17                     | 1            |
| WALM053 | Thursday    | 17                     | 1            |
| WALM054 | Sunday      | 32                     | 1            |
| WALM055 | Wednesday   | 32                     | 1            |
| WALM056 | Saturday    | 29                     | 1            |
| WALM056 | Wednesday   | 29                     | 1            |
| WALM057 | Wednesday   | 18                     | 1            |
| WALM058 | Wednesday   | 45                     | 1            |
| WALM059 | Monday      | 15                     | 1            |
| WALM060 | Tuesday     | 14                     | 1            |
| WALM061 | Thursday    | 14                     | 1            |
| WALM062 | Tuesday     | 24                     | 1            |
| WALM063 | Sunday      | 17                     | 1            |
| WALM064 | Saturday    | 14                     | 1            |
| WALM065 | Tuesday     | 30                     | 1            |
| WALM065 | Friday      | 30                     | 1            |
| WALM066 | Wednesday   | 15                     | 1            |
| WALM067 | Sunday      | 14                     | 1            |
| WALM068 | Monday      | 11                     | 1            |
| WALM068 | Thursday    | 11                     | 1            |
| WALM069 | Thursday    | 42                     | 1            |
| WALM070 | Sunday      | 15                     | 1            |
| WALM071 | Sunday      | 16                     | 1            |
| WALM072 | Thursday    | 14                     | 1            |
| WALM073 | Thursday    | 30                     | 1            |
| WALM074 | Wednesday   | 41                     | 1            |
| WALM075 | Friday      | 35                     | 1            |
| WALM076 | Thursday    | 14                     | 1            |
| WALM077 | Saturday    | 12                     | 1            |
| WALM078 | Saturday    | 17                     | 1            |
| WALM079 | Sunday      | 12                     | 1            |
| WALM079 | Wednesday   | 12                     | 1            |
| WALM080 | Monday      | 16                     | 1            |
| WALM081 | Tuesday     | 11                     | 1            |
| WALM081 | Saturday    | 11                     | 1            |
| WALM082 | Thursday    | 40                     | 1            |
| WALM083 | Monday      | 17                     | 1            |
| WALM084 | Tuesday     | 35                     | 1            |
| WALM085 | Thursday    | 14                     | 1            |
| WALM085 | Tuesday     | 14                     | 1            |
| WALM086 | Tuesday     | 31                     | 1            |
| WALM087 | Saturday    | 35                     | 1            |
| WALM088 | Wednesday   | 16                     | 1            |
| WALM089 | Saturday    | 31                     | 1            |
| WALM089 | Monday      | 31                     | 1            |
| WALM090 | Wednesday   | 15                     | 1            |
| WALM091 | Wednesday   | 17                     | 1            |
| WALM092 | Thursday    | 11                     | 1            |
| WALM093 | Wednesday   | 12                     | 1            |
| WALM094 | Tuesday     | 17                     | 1            |
| WALM095 | Thursday    | 18                     | 1            |
| WALM096 | Tuesday     | 15                     | 1            |
| WALM097 | Friday      | 12                     | 1            |
| WALM098 | Monday      | 18                     | 1            |
| WALM099 | Sunday      | 30                     | 1            |
| WALM100 | Wednesday   | 14                     | 1            |

</details>
---

### 4. Category Ratings by City
Returned the average, minimum, and maximum customer rating for each product category in every city.

```sql
SELECT 
    city, category,
    ROUND(AVG(rating), 1) AS average_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category
ORDER BY city;
```

---

### 5. Total Profit by Category
Calculated total revenue and profit per category using the `profit_margin` column.

```sql
SELECT 
    category,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(SUM(total * profit_margin), 2) AS profit
FROM walmart
GROUP BY category;
```

---

### 6. Most Common Payment Method per Branch
Used `RANK()` partitioned by branch to find the most frequently used payment method at each location.

```sql
WITH payment_method_rank_branch AS (
    SELECT 
        branch, payment_method,
        COUNT(*) AS number_of_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS method_rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method
FROM payment_method_rank_branch
WHERE method_rank = 1;
```

---

### 7. Transaction Volume by Time of Day
Categorized each transaction into Morning, Afternoon, or Evening using a `CASE` statement on the `time` column, then counted transactions per shift per branch.

```sql
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
```

---

### 8. Largest Proportional Revenue Decrease (2022–2023)
Identified the 5 branches with the steepest proportional revenue decline from 2022 to 2023. Two approaches were written — one using nested subqueries and one using CTEs.

```sql
WITH 
revenue_22 AS (
    SELECT branch, SUM(total) AS revenue_2022
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_23 AS (
    SELECT branch, SUM(total) AS revenue_2023
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    revenue_22.branch, revenue_2022, revenue_2023,
    (revenue_2023 - revenue_2022) AS YoY_change, 
    ROUND((((revenue_2023 - revenue_2022) / revenue_2022) * 100), 2) AS proportion_of_change
FROM revenue_22
JOIN revenue_23 ON revenue_22.branch = revenue_23.branch
ORDER BY proportion_of_change ASC
LIMIT 5;
```

---

### 9. Profitability Analysis by Branch and Category
Calculated total profit, total revenue, and profit percentage for each branch/category combination. A CTE was then used to isolate combinations where `profit_pct` fell below 40%, flagging underperforming segments.

```sql
WITH profit_analysis AS (
    SELECT
        Branch, City, category,
        ROUND(SUM(total * profit_margin), 2) AS total_profit,
        ROUND(SUM(total), 2) AS total_revenue,
        ROUND(SUM(total * profit_margin) / SUM(total) * 100, 2) AS profit_pct
    FROM walmart
    GROUP BY Branch, City, category
)
SELECT * FROM profit_analysis
WHERE profit_pct < 40;
```

> **Note:** `profit_pct` differs from the raw `profit_margin` column because it reflects the weighted average of margins across transactions within each group. When a branch/category combination is dominated by low-margin (0.33) transactions, the resulting `profit_pct` will fall below 33%, making it a meaningful signal rather than a redundant column.

---

### 10. Month-over-Month Revenue Trend (2020–2023)
Used `LAG()` to compare each month's revenue to the prior month, producing a `month_over_month_change` column. Q1 2019 was excluded due to incomplete data.

```sql
WITH monthly_revenue AS (
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
```

---

### 11. Consistently Top-Performing Branches (2020–2023)
Used `NTILE(4)` to rank all branches into revenue quartiles within each year. Branches that remained in the top quartile across all 4 years were identified. A third CTE was added to validate the results by inspecting the year-by-year quartile ranking of each qualifying branch.

```sql
WITH 
annual_revenue AS (
    SELECT
        branch,
        YEAR(STR_TO_DATE(date,'%d/%m/%Y')) AS calendar_year,
        ROUND(SUM(total), 2) AS annual_revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date,'%d/%m/%Y')) != 2019
    GROUP BY branch, calendar_year
),
ranked_branches AS (
    SELECT
        branch, calendar_year, annual_revenue,
        NTILE(4) OVER (PARTITION BY calendar_year ORDER BY annual_revenue DESC) AS revenue_quartile
    FROM annual_revenue
),
consistent_top AS (
    SELECT branch
    FROM ranked_branches
    WHERE revenue_quartile = 1
    GROUP BY branch
    HAVING COUNT(DISTINCT calendar_year) = 4
)
SELECT rb.branch, rb.calendar_year, rb.annual_revenue, rb.revenue_quartile
FROM ranked_branches rb
JOIN consistent_top ct ON rb.branch = ct.branch
ORDER BY rb.branch, rb.calendar_year;
```

---

### 12. Highest Revenue Growth by Branch (2020–2023)
Used conditional aggregation with `CASE WHEN` inside `SUM()` to pivot 2020 and 2023 revenues into separate columns, then calculated both absolute and percentage growth per branch.

```sql
WITH annual_revenue AS (
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
    SUM(CASE WHEN calendar_year = 2020 THEN annual_revenue END) AS revenue_2020,
    SUM(CASE WHEN calendar_year = 2023 THEN annual_revenue END) AS revenue_2023,
    ROUND(SUM(CASE WHEN calendar_year = 2023 THEN annual_revenue END) - 
          SUM(CASE WHEN calendar_year = 2020 THEN annual_revenue END), 2) AS absolute_growth,
    ROUND((SUM(CASE WHEN calendar_year = 2023 THEN annual_revenue END) - 
           SUM(CASE WHEN calendar_year = 2020 THEN annual_revenue END)) / 
           SUM(CASE WHEN calendar_year = 2020 THEN annual_revenue END) * 100, 2) AS growth_pct
FROM annual_revenue
GROUP BY branch
ORDER BY growth_pct DESC;
```

---

### 13. High-Revenue, Low-Rating Branches
Ranked all branches independently by total revenue (descending) and average rating (ascending), then filtered for branches appearing in the bottom 25 of both rankings — revealing an inverse relationship between revenue and customer satisfaction.

```sql
WITH 
branch_metrics AS (
    SELECT
        branch,
        ROUND(SUM(total), 2) AS total_revenue,
        ROUND(AVG(rating), 2) AS avg_rating
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) != 2019
    GROUP BY branch
),
ranked AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        RANK() OVER (ORDER BY avg_rating ASC) AS rating_rank
    FROM branch_metrics
)
SELECT * FROM ranked
WHERE revenue_rank <= 25 AND rating_rank <= 25
ORDER BY revenue_rank;
```
