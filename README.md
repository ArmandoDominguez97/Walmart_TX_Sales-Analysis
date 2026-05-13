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

- **Python** — pandas, SQLAlchemy, pymysql, csv2md
- **MySQL** — Aggregations, CTEs, Window Functions (RANK, NTILE, LAG), CASE statements, date parsing
- **Jupyter Notebook** — Data exploration and cleaning workflow

## Data Cleaning (Python)

The following [cleansing](https://github.com/ArmandoDominguez97/Walmart_TX_Sales-Analysis/blob/fe65b3b3892a38fd845bd1ade7241a01402926d6/walmart_summary_and_cleanse.ipynb) steps were taken before analysis:

- **Duplicate removal** — 51 duplicate rows were identified and dropped using `drop_duplicates()`
- **Null value handling** — 31 rows contained missing values in the `unit_price` and `quantity` columns. These were dropped using `dropna()` in the interest of time, though imputation could be explored as an alternative
- **Type conversion** — `unit_price` was stored as a string with a leading `$` character. The dollar sign was stripped and the column was cast to `float`
- **Feature engineering** — A `total` column was derived by multiplying `unit_price` by `quantity`, representing the gross transaction value
- **CSV to markdown conversion** - installed the [csv2md](https://github.com/lzakharov/csv2md) python package used to convert the outputs of each query from csv files to their respective markdown formats. The resulting markdown tables were then pasted with their respective query. [Click here for file demonstrating my use of csv2md package](https://github.com/ArmandoDominguez97/Walmart_TX_Sales-Analysis/blob/fe65b3b3892a38fd845bd1ade7241a01402926d6/csv_to_markdown_table_converter_file.ipynb)

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
<details>
  <summary>Click to expand</summary>

| city                 | category               | average_rating | min_rating | max_rating |
| -------------------- | ---------------------- | -------------- | ---------- | ---------- |
| Abilene              | Electronic accessories | 8              | 7.1        | 8.8        |
| Abilene              | Fashion accessories    | 6.2            | 4          | 9          |
| Abilene              | Food and beverages     | 7              | 6          | 8.9        |
| Abilene              | Health and beauty      | 9.7            | 9.7        | 9.7        |
| Abilene              | Home and lifestyle     | 6.1            | 4          | 9          |
| Alamo                | Fashion accessories    | 6.9            | 3          | 9          |
| Alamo                | Food and beverages     | 5.2            | 5.2        | 5.2        |
| Alamo                | Health and beauty      | 8              | 7.7        | 8.2        |
| Alamo                | Home and lifestyle     | 6.3            | 3          | 9          |
| Alamo                | Sports and travel      | 7.3            | 5          | 10         |
| Alice                | Electronic accessories | 7.3            | 7.3        | 7.3        |
| Alice                | Fashion accessories    | 5.9            | 3          | 9          |
| Alice                | Food and beverages     | 7.7            | 5          | 9.2        |
| Alice                | Home and lifestyle     | 6              | 4          | 9          |
| Alice                | Sports and travel      | 6.9            | 6.5        | 7.9        |
| Allen                | Electronic accessories | 6.4            | 6.4        | 6.4        |
| Allen                | Fashion accessories    | 6.6            | 3          | 9          |
| Allen                | Food and beverages     | 5.6            | 5.6        | 5.6        |
| Allen                | Health and beauty      | 5.9            | 4.4        | 7.2        |
| Allen                | Home and lifestyle     | 6.2            | 4          | 9          |
| Allen                | Sports and travel      | 5.5            | 5.5        | 5.5        |
| Amarillo             | Electronic accessories | 6.8            | 5.2        | 7.8        |
| Amarillo             | Fashion accessories    | 6.7            | 3          | 9          |
| Amarillo             | Health and beauty      | 5.1            | 5.1        | 5.1        |
| Amarillo             | Home and lifestyle     | 6.4            | 3          | 9          |
| Angleton             | Electronic accessories | 7.6            | 5.1        | 10         |
| Angleton             | Fashion accessories    | 6.1            | 4          | 8          |
| Angleton             | Food and beverages     | 7.7            | 6.9        | 8.5        |
| Angleton             | Health and beauty      | 5.1            | 5.1        | 5.1        |
| Angleton             | Home and lifestyle     | 6.4            | 3          | 9.8        |
| Angleton             | Sports and travel      | 6.7            | 4.4        | 9.7        |
| Arlington            | Electronic accessories | 5.2            | 4.7        | 5.5        |
| Arlington            | Fashion accessories    | 6.2            | 3          | 9          |
| Arlington            | Food and beverages     | 7.6            | 5.5        | 9.6        |
| Arlington            | Home and lifestyle     | 6.3            | 3          | 9          |
| Arlington            | Sports and travel      | 5.4            | 4.6        | 6.2        |
| Austin               | Electronic accessories | 5.5            | 5.5        | 5.5        |
| Austin               | Fashion accessories    | 7.2            | 4          | 9          |
| Austin               | Food and beverages     | 9.3            | 9.3        | 9.3        |
| Austin               | Health and beauty      | 6.6            | 6.6        | 6.6        |
| Austin               | Home and lifestyle     | 6.8            | 4          | 9          |
| Baytown              | Fashion accessories    | 6.1            | 3          | 9.5        |
| Baytown              | Health and beauty      | 5              | 5          | 5          |
| Baytown              | Home and lifestyle     | 6.4            | 4          | 9          |
| Baytown              | Sports and travel      | 6.4            | 4          | 8.9        |
| Bedford              | Electronic accessories | 6              | 6          | 6          |
| Bedford              | Fashion accessories    | 5.9            | 3          | 9          |
| Bedford              | Food and beverages     | 5              | 4.5        | 5.6        |
| Bedford              | Health and beauty      | 8.2            | 6.1        | 9.3        |
| Bedford              | Home and lifestyle     | 6.8            | 4          | 9          |
| Big Spring           | Electronic accessories | 6.2            | 5.1        | 8          |
| Big Spring           | Fashion accessories    | 6.5            | 4          | 9          |
| Big Spring           | Health and beauty      | 7.7            | 6          | 8.4        |
| Big Spring           | Home and lifestyle     | 6.2            | 3          | 9          |
| Big Spring           | Sports and travel      | 7.3            | 6.8        | 8          |
| Brownsville          | Electronic accessories | 7.1            | 5          | 9.5        |
| Brownsville          | Fashion accessories    | 6.5            | 3          | 9          |
| Brownsville          | Health and beauty      | 7.3            | 6.2        | 8.4        |
| Brownsville          | Home and lifestyle     | 6.4            | 3          | 9          |
| Brownsville          | Sports and travel      | 9.1            | 9          | 9.2        |
| Brownwood            | Fashion accessories    | 6.3            | 3          | 9          |
| Brownwood            | Food and beverages     | 7.8            | 6.4        | 9.2        |
| Brownwood            | Home and lifestyle     | 6.3            | 4          | 9          |
| Brownwood            | Sports and travel      | 8.1            | 5.1        | 9.9        |
| Bryan                | Electronic accessories | 7.2            | 6.1        | 8.2        |
| Bryan                | Fashion accessories    | 6.8            | 4          | 9.9        |
| Bryan                | Food and beverages     | 6.6            | 4.5        | 9.1        |
| Bryan                | Health and beauty      | 6.8            | 5.8        | 7.9        |
| Bryan                | Home and lifestyle     | 6.4            | 4          | 9.1        |
| Bryan                | Sports and travel      | 7.2            | 4.5        | 10         |
| Burleson             | Electronic accessories | 9.7            | 9.7        | 9.7        |
| Burleson             | Fashion accessories    | 6.3            | 3          | 9          |
| Burleson             | Food and beverages     | 4.8            | 4.8        | 4.8        |
| Burleson             | Health and beauty      | 4.9            | 4.9        | 4.9        |
| Burleson             | Home and lifestyle     | 6.2            | 3          | 9          |
| Burleson             | Sports and travel      | 7.4            | 6.6        | 8.3        |
| Canyon               | Electronic accessories | 6.2            | 5          | 6.9        |
| Canyon               | Fashion accessories    | 6.1            | 3          | 9          |
| Canyon               | Health and beauty      | 6.9            | 5.8        | 8.9        |
| Canyon               | Home and lifestyle     | 6.2            | 3          | 9          |
| Canyon               | Sports and travel      | 6.3            | 5.2        | 7          |
| Carrollton           | Electronic accessories | 8.7            | 8.7        | 8.7        |
| Carrollton           | Fashion accessories    | 6.4            | 3          | 9          |
| Carrollton           | Health and beauty      | 5.7            | 5.7        | 5.7        |
| Carrollton           | Home and lifestyle     | 6.1            | 4          | 9          |
| Carrollton           | Sports and travel      | 7.2            | 7.2        | 7.2        |
| Cedar Park           | Electronic accessories | 6.6            | 5          | 8          |
| Cedar Park           | Fashion accessories    | 6.6            | 4          | 9.6        |
| Cedar Park           | Food and beverages     | 8.5            | 6.6        | 9.9        |
| Cedar Park           | Health and beauty      | 5.5            | 5.5        | 5.5        |
| Cedar Park           | Home and lifestyle     | 6.4            | 3          | 9          |
| Cedar Park           | Sports and travel      | 6.8            | 6.6        | 6.9        |
| Cleburne             | Electronic accessories | 7.2            | 5.8        | 7.8        |
| Cleburne             | Fashion accessories    | 6              | 3          | 9          |
| Cleburne             | Health and beauty      | 4.9            | 4.2        | 5.6        |
| Cleburne             | Home and lifestyle     | 7              | 3          | 9          |
| Cleburne             | Sports and travel      | 7.7            | 6.4        | 9.6        |
| College Station      | Electronic accessories | 8.4            | 7.2        | 9.7        |
| College Station      | Fashion accessories    | 6.7            | 4          | 9          |
| College Station      | Food and beverages     | 7.2            | 6.5        | 7.9        |
| College Station      | Health and beauty      | 10             | 10         | 10         |
| College Station      | Home and lifestyle     | 6.3            | 4          | 9          |
| Conroe               | Electronic accessories | 6.4            | 4.3        | 8.5        |
| Conroe               | Fashion accessories    | 6.4            | 4          | 9          |
| Conroe               | Food and beverages     | 6.9            | 4          | 8.6        |
| Conroe               | Health and beauty      | 7              | 4.9        | 9.2        |
| Conroe               | Home and lifestyle     | 6.3            | 3          | 8          |
| Conroe               | Sports and travel      | 8              | 8          | 8          |
| Coppell              | Electronic accessories | 6.4            | 4.9        | 7.6        |
| Coppell              | Fashion accessories    | 6.4            | 3          | 9          |
| Coppell              | Health and beauty      | 5.5            | 4          | 7          |
| Coppell              | Home and lifestyle     | 6.8            | 4          | 9          |
| Coppell              | Sports and travel      | 9.6            | 9.6        | 9.6        |
| Corpus Christi       | Electronic accessories | 4.2            | 4.2        | 4.2        |
| Corpus Christi       | Fashion accessories    | 6              | 3          | 9          |
| Corpus Christi       | Food and beverages     | 7.4            | 7.4        | 7.4        |
| Corpus Christi       | Health and beauty      | 6.8            | 5.3        | 8.4        |
| Corpus Christi       | Home and lifestyle     | 6.6            | 3          | 9.7        |
| Corpus Christi       | Sports and travel      | 4.5            | 4.5        | 4.5        |
| Dallas               | Electronic accessories | 8.1            | 6.1        | 9          |
| Dallas               | Fashion accessories    | 6              | 3          | 9.7        |
| Dallas               | Food and beverages     | 8.2            | 8          | 8.5        |
| Dallas               | Home and lifestyle     | 6              | 3          | 9          |
| Dallas               | Sports and travel      | 5.6            | 5.6        | 5.6        |
| Del Rio              | Fashion accessories    | 6.4            | 4          | 9          |
| Del Rio              | Food and beverages     | 9              | 8.4        | 9.6        |
| Del Rio              | Health and beauty      | 8              | 8          | 8          |
| Del Rio              | Home and lifestyle     | 5.8            | 3          | 9.9        |
| Del Rio              | Sports and travel      | 6.7            | 4.1        | 9.3        |
| Denton               | Electronic accessories | 6.7            | 4.1        | 9          |
| Denton               | Fashion accessories    | 6.7            | 3          | 9.2        |
| Denton               | Food and beverages     | 4.2            | 4.2        | 4.2        |
| Denton               | Health and beauty      | 6.8            | 5          | 8.7        |
| Denton               | Home and lifestyle     | 6.7            | 3          | 9          |
| Denton               | Sports and travel      | 6.7            | 5.4        | 8.6        |
| DeSoto               | Fashion accessories    | 6.4            | 3          | 9          |
| DeSoto               | Food and beverages     | 6.8            | 6.3        | 7.4        |
| DeSoto               | Health and beauty      | 9.9            | 9.9        | 9.9        |
| DeSoto               | Home and lifestyle     | 6              | 3          | 9          |
| DeSoto               | Sports and travel      | 6.6            | 6.6        | 6.6        |
| Eagle Pass           | Electronic accessories | 5.7            | 4.1        | 7.3        |
| Eagle Pass           | Fashion accessories    | 6              | 3          | 9          |
| Eagle Pass           | Food and beverages     | 6.5            | 4          | 9          |
| Eagle Pass           | Health and beauty      | 5.1            | 5.1        | 5.1        |
| Eagle Pass           | Home and lifestyle     | 6.4            | 4          | 9.6        |
| Eagle Pass           | Sports and travel      | 9.6            | 9.6        | 9.6        |
| Edinburg             | Electronic accessories | 7              | 4.3        | 9.8        |
| Edinburg             | Fashion accessories    | 6.7            | 3          | 9          |
| Edinburg             | Health and beauty      | 8.6            | 8.6        | 8.6        |
| Edinburg             | Home and lifestyle     | 6              | 3          | 9          |
| Edinburg             | Sports and travel      | 6.5            | 5.1        | 7.8        |
| El Paso              | Fashion accessories    | 6.8            | 3          | 9.1        |
| El Paso              | Food and beverages     | 6              | 6          | 6          |
| El Paso              | Home and lifestyle     | 5.9            | 3          | 9.8        |
| El Paso              | Sports and travel      | 6.5            | 6.3        | 6.7        |
| Euless               | Electronic accessories | 5.8            | 5          | 6.7        |
| Euless               | Fashion accessories    | 6              | 3          | 9          |
| Euless               | Food and beverages     | 6.8            | 4.5        | 8.8        |
| Euless               | Health and beauty      | 6.6            | 6.6        | 6.6        |
| Euless               | Home and lifestyle     | 6.6            | 4          | 9          |
| Euless               | Sports and travel      | 5.7            | 4.2        | 6.7        |
| Farmers Branch       | Electronic accessories | 6.6            | 5          | 8.7        |
| Farmers Branch       | Fashion accessories    | 6.2            | 3          | 9          |
| Farmers Branch       | Food and beverages     | 6              | 4.6        | 7.5        |
| Farmers Branch       | Home and lifestyle     | 6.3            | 3          | 9          |
| Flower Mound         | Electronic accessories | 7.3            | 5.9        | 9.8        |
| Flower Mound         | Fashion accessories    | 6.6            | 4          | 9          |
| Flower Mound         | Food and beverages     | 5.5            | 5.5        | 5.5        |
| Flower Mound         | Health and beauty      | 8              | 6.4        | 9.5        |
| Flower Mound         | Home and lifestyle     | 6.3            | 4          | 9.6        |
| Flower Mound         | Sports and travel      | 6              | 4.5        | 7.5        |
| Fort Worth           | Electronic accessories | 6.8            | 5.1        | 9.9        |
| Fort Worth           | Fashion accessories    | 6.3            | 3          | 9          |
| Fort Worth           | Food and beverages     | 7.2            | 5.8        | 8.7        |
| Fort Worth           | Health and beauty      | 8.4            | 7.8        | 9          |
| Fort Worth           | Home and lifestyle     | 6.6            | 4          | 9          |
| Friendswood          | Electronic accessories | 5.5            | 5.5        | 5.5        |
| Friendswood          | Fashion accessories    | 6.3            | 3          | 9          |
| Friendswood          | Food and beverages     | 9.1            | 8.5        | 9.5        |
| Friendswood          | Health and beauty      | 7.1            | 4.4        | 9.3        |
| Friendswood          | Home and lifestyle     | 5.9            | 4          | 9          |
| Friendswood          | Sports and travel      | 5.6            | 5.6        | 5.6        |
| Frisco               | Electronic accessories | 8.8            | 7.8        | 9.7        |
| Frisco               | Fashion accessories    | 6.4            | 3          | 9          |
| Frisco               | Home and lifestyle     | 6.6            | 3          | 9          |
| Frisco               | Sports and travel      | 6.2            | 5.1        | 7.2        |
| Galveston            | Electronic accessories | 6              | 5.5        | 6.4        |
| Galveston            | Fashion accessories    | 6              | 3          | 9.5        |
| Galveston            | Food and beverages     | 5.1            | 5.1        | 5.1        |
| Galveston            | Health and beauty      | 6              | 4.3        | 8.3        |
| Galveston            | Home and lifestyle     | 6.4            | 3          | 9          |
| Galveston            | Sports and travel      | 7.3            | 7.3        | 7.3        |
| Garland              | Fashion accessories    | 6.4            | 3          | 9.5        |
| Garland              | Food and beverages     | 6.9            | 4.2        | 9.9        |
| Garland              | Health and beauty      | 7.4            | 6          | 9.5        |
| Garland              | Home and lifestyle     | 6.2            | 4          | 9          |
| Georgetown           | Electronic accessories | 8.3            | 7.6        | 9.4        |
| Georgetown           | Fashion accessories    | 6.2            | 3          | 9          |
| Georgetown           | Food and beverages     | 7.3            | 6.6        | 8.1        |
| Georgetown           | Health and beauty      | 5.3            | 5.3        | 5.3        |
| Georgetown           | Home and lifestyle     | 6.2            | 4          | 9.8        |
| Georgetown           | Sports and travel      | 4.9            | 4.9        | 4.9        |
| Grand Prairie        | Electronic accessories | 4.3            | 4.3        | 4.3        |
| Grand Prairie        | Fashion accessories    | 5.9            | 3          | 9          |
| Grand Prairie        | Food and beverages     | 5.6            | 4.1        | 7.1        |
| Grand Prairie        | Home and lifestyle     | 6.2            | 3          | 9          |
| Grand Prairie        | Sports and travel      | 5              | 5          | 5          |
| Grapevine            | Electronic accessories | 6.2            | 6.2        | 6.2        |
| Grapevine            | Fashion accessories    | 6.5            | 3          | 9          |
| Grapevine            | Food and beverages     | 6.7            | 6          | 7.6        |
| Grapevine            | Health and beauty      | 7.2            | 7.2        | 7.2        |
| Grapevine            | Home and lifestyle     | 6.1            | 3          | 9          |
| Grapevine            | Sports and travel      | 7.2            | 7.2        | 7.2        |
| Haltom City          | Electronic accessories | 8              | 4.5        | 9.9        |
| Haltom City          | Fashion accessories    | 6.3            | 3          | 9          |
| Haltom City          | Food and beverages     | 5.9            | 5.9        | 5.9        |
| Haltom City          | Home and lifestyle     | 6.2            | 3          | 9.5        |
| Haltom City          | Sports and travel      | 9.7            | 9.7        | 9.7        |
| Harlingen            | Electronic accessories | 9.6            | 9.6        | 9.6        |
| Harlingen            | Fashion accessories    | 6.6            | 4          | 9.2        |
| Harlingen            | Health and beauty      | 6.6            | 4.7        | 8.1        |
| Harlingen            | Home and lifestyle     | 6.1            | 3          | 9          |
| Harlingen            | Sports and travel      | 8.1            | 5.9        | 9.5        |
| Houston              | Electronic accessories | 7.4            | 5.4        | 9.5        |
| Houston              | Fashion accessories    | 6.4            | 3          | 9.5        |
| Houston              | Home and lifestyle     | 6.2            | 3          | 9          |
| Houston              | Sports and travel      | 6.5            | 4.3        | 9.3        |
| Huntsville           | Electronic accessories | 5.8            | 5.8        | 5.8        |
| Huntsville           | Fashion accessories    | 6.8            | 4          | 9.7        |
| Huntsville           | Food and beverages     | 8.1            | 6.4        | 9.1        |
| Huntsville           | Home and lifestyle     | 6.7            | 4          | 9          |
| Hurst                | Electronic accessories | 5.6            | 4.7        | 6.5        |
| Hurst                | Fashion accessories    | 6.1            | 3          | 9          |
| Hurst                | Food and beverages     | 9.1            | 9.1        | 9.1        |
| Hurst                | Health and beauty      | 7.5            | 6.6        | 8.1        |
| Hurst                | Home and lifestyle     | 6.6            | 3          | 9          |
| Hurst                | Sports and travel      | 6.3            | 5.3        | 7.3        |
| Irving               | Electronic accessories | 7.2            | 5          | 8.6        |
| Irving               | Fashion accessories    | 6.2            | 3          | 9.8        |
| Irving               | Health and beauty      | 7.6            | 7.6        | 7.6        |
| Irving               | Home and lifestyle     | 6.3            | 4          | 9.7        |
| Irving               | Sports and travel      | 5.3            | 5.3        | 5.3        |
| Kerrville            | Electronic accessories | 6.5            | 6.5        | 6.5        |
| Kerrville            | Fashion accessories    | 6.8            | 3          | 9          |
| Kerrville            | Food and beverages     | 8.4            | 8.4        | 8.4        |
| Kerrville            | Health and beauty      | 8.3            | 7.9        | 8.7        |
| Kerrville            | Home and lifestyle     | 6.2            | 4          | 9          |
| Kerrville            | Sports and travel      | 5.2            | 4.2        | 6.5        |
| Killeen              | Electronic accessories | 6.6            | 4.4        | 9.4        |
| Killeen              | Fashion accessories    | 6              | 3          | 9          |
| Killeen              | Food and beverages     | 8.3            | 7          | 9.1        |
| Killeen              | Health and beauty      | 8.2            | 6.7        | 9.8        |
| Killeen              | Home and lifestyle     | 6.9            | 4          | 9.1        |
| Killeen              | Sports and travel      | 6.4            | 5.3        | 7.4        |
| La Porte             | Fashion accessories    | 6.6            | 3          | 9.1        |
| La Porte             | Health and beauty      | 7              | 4.9        | 9.1        |
| La Porte             | Home and lifestyle     | 5.8            | 4          | 9          |
| La Porte             | Sports and travel      | 7.2            | 5.6        | 9.5        |
| Lake Jackson         | Fashion accessories    | 6.9            | 4          | 9          |
| Lake Jackson         | Health and beauty      | 7.2            | 7.2        | 7.2        |
| Lake Jackson         | Home and lifestyle     | 6.2            | 4          | 9          |
| Lake Jackson         | Sports and travel      | 6.4            | 4.2        | 8.6        |
| Lancaster            | Electronic accessories | 7.7            | 5.6        | 9          |
| Lancaster            | Fashion accessories    | 5.8            | 4          | 9          |
| Lancaster            | Food and beverages     | 7.6            | 5          | 9.8        |
| Lancaster            | Home and lifestyle     | 5.9            | 3          | 9.4        |
| Lancaster            | Sports and travel      | 8.1            | 8.1        | 8.1        |
| Laredo               | Electronic accessories | 9              | 9          | 9          |
| Laredo               | Fashion accessories    | 6.9            | 3          | 9.6        |
| Laredo               | Food and beverages     | 6.6            | 5.7        | 7.4        |
| Laredo               | Health and beauty      | 6.3            | 6.3        | 6.3        |
| Laredo               | Home and lifestyle     | 6.3            | 3          | 9          |
| League City          | Electronic accessories | 6.9            | 6.5        | 7.3        |
| League City          | Fashion accessories    | 5.8            | 4          | 9          |
| League City          | Food and beverages     | 7.1            | 7.1        | 7.1        |
| League City          | Health and beauty      | 8.8            | 7.7        | 9.8        |
| League City          | Home and lifestyle     | 6.2            | 3          | 9          |
| League City          | Sports and travel      | 9.4            | 8.7        | 10         |
| Lewisville           | Electronic accessories | 7.6            | 5.8        | 9.3        |
| Lewisville           | Fashion accessories    | 6.8            | 4          | 9          |
| Lewisville           | Food and beverages     | 4.4            | 4.4        | 4.4        |
| Lewisville           | Health and beauty      | 5.6            | 5.5        | 5.7        |
| Lewisville           | Home and lifestyle     | 5.5            | 3          | 9          |
| Lewisville           | Sports and travel      | 6.1            | 6.1        | 6.1        |
| Little Elm           | Electronic accessories | 6.2            | 4.9        | 7.6        |
| Little Elm           | Fashion accessories    | 6.1            | 4          | 9.6        |
| Little Elm           | Food and beverages     | 5.2            | 4.2        | 6.4        |
| Little Elm           | Home and lifestyle     | 5.8            | 3          | 8          |
| Little Elm           | Sports and travel      | 5              | 5          | 5          |
| Longview             | Electronic accessories | 6.9            | 6.3        | 7.5        |
| Longview             | Fashion accessories    | 6.4            | 4          | 9          |
| Longview             | Food and beverages     | 9              | 8          | 9.9        |
| Longview             | Health and beauty      | 8              | 8          | 8          |
| Longview             | Home and lifestyle     | 6.1            | 4          | 9          |
| Lubbock              | Electronic accessories | 4.3            | 4.3        | 4.3        |
| Lubbock              | Fashion accessories    | 6.2            | 3          | 9          |
| Lubbock              | Food and beverages     | 7              | 7          | 7          |
| Lubbock              | Health and beauty      | 6.3            | 4.2        | 9.5        |
| Lubbock              | Home and lifestyle     | 6.1            | 3          | 9          |
| Lubbock              | Sports and travel      | 6.2            | 5.7        | 6.6        |
| Lufkin               | Electronic accessories | 8.4            | 8.4        | 8.4        |
| Lufkin               | Fashion accessories    | 6              | 3          | 9.9        |
| Lufkin               | Food and beverages     | 8.6            | 7.2        | 9.9        |
| Lufkin               | Health and beauty      | 6.7            | 4.3        | 9.8        |
| Lufkin               | Home and lifestyle     | 6.2            | 3          | 9          |
| Lufkin               | Sports and travel      | 7.8            | 5.9        | 9.6        |
| Mansfield            | Electronic accessories | 7.8            | 6.6        | 8.9        |
| Mansfield            | Fashion accessories    | 6              | 3          | 9          |
| Mansfield            | Food and beverages     | 6.6            | 5.8        | 8.1        |
| Mansfield            | Health and beauty      | 6.9            | 4          | 9.1        |
| Mansfield            | Home and lifestyle     | 6.7            | 4          | 9          |
| McAllen              | Fashion accessories    | 5.8            | 3          | 9          |
| McAllen              | Food and beverages     | 6.3            | 6.2        | 6.4        |
| McAllen              | Health and beauty      | 6              | 6          | 6          |
| McAllen              | Home and lifestyle     | 6.1            | 4          | 9          |
| McAllen              | Sports and travel      | 7.2            | 5.1        | 9.3        |
| McKinney             | Electronic accessories | 7              | 7          | 7          |
| McKinney             | Fashion accessories    | 6.3            | 3          | 9          |
| McKinney             | Food and beverages     | 4              | 4          | 4          |
| McKinney             | Health and beauty      | 7              | 5.6        | 8.3        |
| McKinney             | Home and lifestyle     | 5.9            | 3          | 9          |
| McKinney             | Sports and travel      | 5.2            | 5.2        | 5.2        |
| Mesquite             | Electronic accessories | 8.7            | 7          | 9.8        |
| Mesquite             | Fashion accessories    | 6.1            | 4          | 9          |
| Mesquite             | Food and beverages     | 7.5            | 7.5        | 7.5        |
| Mesquite             | Health and beauty      | 8.8            | 8.8        | 8.8        |
| Mesquite             | Home and lifestyle     | 6              | 3          | 9          |
| Mesquite             | Sports and travel      | 7.8            | 7.8        | 7.8        |
| Midland              | Electronic accessories | 5.7            | 4.9        | 6.3        |
| Midland              | Fashion accessories    | 6.4            | 3          | 9          |
| Midland              | Food and beverages     | 6              | 6          | 6          |
| Midland              | Health and beauty      | 8              | 5.9        | 9.7        |
| Midland              | Home and lifestyle     | 6.4            | 4          | 9          |
| Midland              | Sports and travel      | 5.7            | 5.4        | 6          |
| Mineral Wells        | Electronic accessories | 6.9            | 4.4        | 8.2        |
| Mineral Wells        | Fashion accessories    | 6.2            | 3          | 9          |
| Mineral Wells        | Food and beverages     | 6.2            | 6.2        | 6.2        |
| Mineral Wells        | Health and beauty      | 9.8            | 9.8        | 9.8        |
| Mineral Wells        | Home and lifestyle     | 6.4            | 3          | 9          |
| Mineral Wells        | Sports and travel      | 4.8            | 4.5        | 5.1        |
| Mission              | Fashion accessories    | 6.6            | 4          | 9          |
| Mission              | Food and beverages     | 8              | 7.7        | 8.3        |
| Mission              | Home and lifestyle     | 5.7            | 3          | 9          |
| Mission              | Sports and travel      | 7              | 7          | 7          |
| Missouri City        | Electronic accessories | 6.3            | 4          | 8.6        |
| Missouri City        | Fashion accessories    | 5.7            | 4          | 9          |
| Missouri City        | Food and beverages     | 9.3            | 9.3        | 9.3        |
| Missouri City        | Health and beauty      | 7.9            | 7.3        | 8.9        |
| Missouri City        | Home and lifestyle     | 6.4            | 3          | 9          |
| Missouri City        | Sports and travel      | 9              | 9          | 9          |
| Nacogdoches          | Electronic accessories | 7.2            | 6.4        | 8          |
| Nacogdoches          | Fashion accessories    | 6.3            | 3          | 9          |
| Nacogdoches          | Food and beverages     | 6              | 4.4        | 9.1        |
| Nacogdoches          | Home and lifestyle     | 6.4            | 4          | 9          |
| Nacogdoches          | Sports and travel      | 6.8            | 5          | 8.5        |
| New Braunfels        | Electronic accessories | 5.9            | 5.9        | 5.9        |
| New Braunfels        | Fashion accessories    | 6.1            | 3          | 9          |
| New Braunfels        | Food and beverages     | 6.6            | 4.3        | 8.9        |
| New Braunfels        | Health and beauty      | 4.2            | 4.2        | 4.2        |
| New Braunfels        | Home and lifestyle     | 6.4            | 3          | 9          |
| New Braunfels        | Sports and travel      | 8.9            | 8.2        | 9.6        |
| North Richland Hills | Electronic accessories | 6.6            | 5.3        | 7.9        |
| North Richland Hills | Fashion accessories    | 5.7            | 3          | 9          |
| North Richland Hills | Food and beverages     | 5.9            | 5          | 6.3        |
| North Richland Hills | Home and lifestyle     | 6.3            | 4          | 9.3        |
| North Richland Hills | Sports and travel      | 7.7            | 7.4        | 8.2        |
| Odessa               | Electronic accessories | 4.6            | 4.1        | 5          |
| Odessa               | Fashion accessories    | 6.3            | 4          | 9.3        |
| Odessa               | Food and beverages     | 8              | 7.7        | 8.3        |
| Odessa               | Home and lifestyle     | 6.2            | 3          | 9          |
| Odessa               | Sports and travel      | 4.8            | 4.8        | 4.8        |
| Pasadena             | Electronic accessories | 8.4            | 8          | 8.8        |
| Pasadena             | Fashion accessories    | 5.9            | 3          | 9          |
| Pasadena             | Home and lifestyle     | 7              | 4          | 9          |
| Pasadena             | Sports and travel      | 6.9            | 5.5        | 9.3        |
| Pearland             | Electronic accessories | 4.7            | 4.7        | 4.7        |
| Pearland             | Fashion accessories    | 6              | 4          | 9          |
| Pearland             | Food and beverages     | 6.4            | 6.4        | 6.4        |
| Pearland             | Home and lifestyle     | 6.7            | 3          | 9          |
| Pearland             | Sports and travel      | 6              | 4.3        | 7.7        |
| Pflugerville         | Electronic accessories | 7.9            | 7.7        | 8.1        |
| Pflugerville         | Fashion accessories    | 6.6            | 3          | 9          |
| Pflugerville         | Food and beverages     | 6.6            | 4.3        | 7.7        |
| Pflugerville         | Health and beauty      | 6.8            | 4          | 8.4        |
| Pflugerville         | Home and lifestyle     | 6.8            | 4          | 9          |
| Pflugerville         | Sports and travel      | 6.9            | 4.2        | 9.9        |
| Pharr                | Electronic accessories | 4.8            | 4.8        | 4.8        |
| Pharr                | Fashion accessories    | 6.1            | 3          | 9          |
| Pharr                | Food and beverages     | 7.3            | 4.2        | 9.9        |
| Pharr                | Health and beauty      | 9.2            | 9.2        | 9.2        |
| Pharr                | Home and lifestyle     | 6              | 4          | 9          |
| Pharr                | Sports and travel      | 9              | 9          | 9          |
| Plano                | Electronic accessories | 6              | 4          | 8          |
| Plano                | Fashion accessories    | 5.3            | 3          | 9.4        |
| Plano                | Food and beverages     | 7              | 5.6        | 7.8        |
| Plano                | Home and lifestyle     | 5.2            | 3          | 9          |
| Plano                | Sports and travel      | 9.6            | 9.6        | 9.6        |
| Port Arthur          | Electronic accessories | 4.5            | 3          | 7          |
| Port Arthur          | Fashion accessories    | 5.4            | 3          | 9.2        |
| Port Arthur          | Health and beauty      | 6.3            | 4.2        | 8.4        |
| Port Arthur          | Home and lifestyle     | 5.2            | 3          | 9          |
| Port Arthur          | Sports and travel      | 6.1            | 6.1        | 6.1        |
| Richardson           | Electronic accessories | 5.2            | 4          | 7          |
| Richardson           | Fashion accessories    | 5.3            | 3          | 9.6        |
| Richardson           | Food and beverages     | 4.6            | 4          | 5.2        |
| Richardson           | Health and beauty      | 7.5            | 5          | 8.9        |
| Richardson           | Home and lifestyle     | 5.4            | 3          | 9.8        |
| Richardson           | Sports and travel      | 8.6            | 8.6        | 8.6        |
| Rockwall             | Electronic accessories | 5.4            | 3          | 7          |
| Rockwall             | Fashion accessories    | 5.5            | 3          | 9          |
| Rockwall             | Food and beverages     | 5.6            | 4.8        | 6.5        |
| Rockwall             | Health and beauty      | 5.4            | 4.1        | 6.5        |
| Rockwall             | Home and lifestyle     | 5.1            | 3          | 9          |
| Rockwall             | Sports and travel      | 7.8            | 6.3        | 9.7        |
| Rosenberg            | Electronic accessories | 5.8            | 3          | 9.8        |
| Rosenberg            | Fashion accessories    | 5.1            | 3          | 9          |
| Rosenberg            | Food and beverages     | 7.2            | 6          | 8.7        |
| Rosenberg            | Health and beauty      | 9.9            | 9.9        | 9.9        |
| Rosenberg            | Home and lifestyle     | 5              | 3          | 9.4        |
| Rosenberg            | Sports and travel      | 6.5            | 6.5        | 6.5        |
| Round Rock           | Electronic accessories | 5.8            | 4          | 7          |
| Round Rock           | Fashion accessories    | 5.1            | 3          | 9.9        |
| Round Rock           | Food and beverages     | 8.9            | 8.9        | 8.9        |
| Round Rock           | Health and beauty      | 6.6            | 4.6        | 8.7        |
| Round Rock           | Home and lifestyle     | 5.2            | 3          | 9.3        |
| Round Rock           | Sports and travel      | 8.2            | 8.2        | 8.2        |
| Rowlett              | Electronic accessories | 6              | 3          | 9.5        |
| Rowlett              | Fashion accessories    | 5.1            | 3          | 9.8        |
| Rowlett              | Food and beverages     | 5.8            | 5.4        | 6.1        |
| Rowlett              | Home and lifestyle     | 4.7            | 3          | 9          |
| San Angelo           | Electronic accessories | 5.8            | 3          | 7          |
| San Angelo           | Fashion accessories    | 4.9            | 3          | 9          |
| San Angelo           | Food and beverages     | 8.4            | 8.2        | 8.5        |
| San Angelo           | Health and beauty      | 6.5            | 4.3        | 8.7        |
| San Angelo           | Home and lifestyle     | 5.4            | 3          | 8.7        |
| San Angelo           | Sports and travel      | 9.3            | 9.3        | 9.3        |
| San Antonio          | Electronic accessories | 5.5            | 3          | 9.9        |
| San Antonio          | Fashion accessories    | 5.1            | 3          | 9          |
| San Antonio          | Food and beverages     | 6.5            | 5.6        | 7.6        |
| San Antonio          | Health and beauty      | 7              | 5          | 9.1        |
| San Antonio          | Home and lifestyle     | 5.5            | 3          | 9.5        |
| San Antonio          | Sports and travel      | 7.5            | 7          | 8          |
| San Marcos           | Electronic accessories | 4.8            | 3          | 8.9        |
| San Marcos           | Fashion accessories    | 5              | 3          | 7          |
| San Marcos           | Food and beverages     | 6.3            | 4.6        | 8          |
| San Marcos           | Health and beauty      | 6.6            | 5          | 7.4        |
| San Marcos           | Home and lifestyle     | 4.9            | 3          | 7          |
| San Marcos           | Sports and travel      | 7.9            | 6.3        | 8.7        |
| Schertz              | Electronic accessories | 4.7            | 3          | 7          |
| Schertz              | Fashion accessories    | 5.3            | 3          | 9.5        |
| Schertz              | Health and beauty      | 5.4            | 4.2        | 6.6        |
| Schertz              | Home and lifestyle     | 5.4            | 3          | 9.8        |
| Schertz              | Sports and travel      | 5.5            | 4.1        | 6.5        |
| Seguin               | Electronic accessories | 5.1            | 3          | 7          |
| Seguin               | Fashion accessories    | 5.2            | 3          | 8          |
| Seguin               | Food and beverages     | 9.6            | 9.6        | 9.6        |
| Seguin               | Health and beauty      | 7.4            | 7          | 7.7        |
| Seguin               | Home and lifestyle     | 5.3            | 3          | 9          |
| Seguin               | Sports and travel      | 8.9            | 8.9        | 8.9        |
| Sherman              | Electronic accessories | 4.7            | 3          | 7.6        |
| Sherman              | Fashion accessories    | 5.2            | 3          | 9.2        |
| Sherman              | Health and beauty      | 5.6            | 5.6        | 5.6        |
| Sherman              | Home and lifestyle     | 5              | 3          | 7          |
| Southlake            | Electronic accessories | 5.6            | 3          | 7          |
| Southlake            | Fashion accessories    | 5.2            | 3          | 9          |
| Southlake            | Food and beverages     | 7.4            | 5.2        | 9.5        |
| Southlake            | Home and lifestyle     | 5.2            | 3          | 8.7        |
| Southlake            | Sports and travel      | 8.9            | 8.5        | 9.7        |
| Sugar Land           | Electronic accessories | 5.4            | 4          | 7          |
| Sugar Land           | Fashion accessories    | 5.2            | 3          | 7.9        |
| Sugar Land           | Food and beverages     | 7.2            | 5.1        | 9.2        |
| Sugar Land           | Health and beauty      | 7.6            | 6          | 9.2        |
| Sugar Land           | Home and lifestyle     | 5.2            | 3          | 9          |
| Sugar Land           | Sports and travel      | 8.5            | 8.5        | 8.5        |
| Temple               | Electronic accessories | 5.5            | 3          | 9.8        |
| Temple               | Fashion accessories    | 5.2            | 3          | 9          |
| Temple               | Food and beverages     | 7.3            | 7.3        | 7.3        |
| Temple               | Home and lifestyle     | 5.2            | 3          | 9          |
| Temple               | Sports and travel      | 6.5            | 4.1        | 9.8        |
| Texas City           | Electronic accessories | 4.6            | 3          | 7          |
| Texas City           | Fashion accessories    | 5.1            | 3          | 7          |
| Texas City           | Food and beverages     | 5.7            | 5.5        | 5.9        |
| Texas City           | Health and beauty      | 6.5            | 4.9        | 8.6        |
| Texas City           | Home and lifestyle     | 4.9            | 3          | 7          |
| Texas City           | Sports and travel      | 5.5            | 4.5        | 6.5        |
| Tyler                | Electronic accessories | 5.3            | 3          | 9.1        |
| Tyler                | Fashion accessories    | 5.5            | 3          | 9.4        |
| Tyler                | Home and lifestyle     | 5              | 3          | 8          |
| Victoria             | Electronic accessories | 5.3            | 3          | 7.3        |
| Victoria             | Fashion accessories    | 5.2            | 3          | 9.5        |
| Victoria             | Home and lifestyle     | 5              | 3          | 7          |
| Waco                 | Electronic accessories | 5.4            | 3          | 9          |
| Waco                 | Fashion accessories    | 5.5            | 3          | 9          |
| Waco                 | Food and beverages     | 8.4            | 8.4        | 8.4        |
| Waco                 | Health and beauty      | 7.6            | 5.3        | 9.3        |
| Waco                 | Home and lifestyle     | 5.2            | 3          | 9          |
| Waco                 | Sports and travel      | 5.6            | 5.6        | 5.6        |
| Waxahachie           | Electronic accessories | 5.9            | 3          | 9          |
| Waxahachie           | Fashion accessories    | 5.1            | 3          | 9.2        |
| Waxahachie           | Food and beverages     | 7.5            | 7.5        | 7.5        |
| Waxahachie           | Health and beauty      | 7.2            | 4.8        | 9.5        |
| Waxahachie           | Home and lifestyle     | 5.1            | 3          | 9          |
| Waxahachie           | Sports and travel      | 6.2            | 5.2        | 7.4        |
| Weatherford          | Electronic accessories | 6              | 5          | 7          |
| Weatherford          | Fashion accessories    | 5              | 3          | 7.4        |
| Weatherford          | Home and lifestyle     | 5.1            | 3          | 9          |
| Weatherford          | Sports and travel      | 5.2            | 4.2        | 6.2        |
| Weslaco              | Electronic accessories | 5.1            | 3          | 8.4        |
| Weslaco              | Fashion accessories    | 5              | 3          | 9.5        |
| Weslaco              | Food and beverages     | 8.7            | 7.1        | 9.8        |
| Weslaco              | Health and beauty      | 6.8            | 4.3        | 9.2        |
| Weslaco              | Home and lifestyle     | 5.2            | 3          | 9.2        |
| Weslaco              | Sports and travel      | 5.6            | 4.1        | 7.1        |

</details>
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
| category               | total_revenue | profit    |
| ---------------------- | ------------- | --------- |
| Health and beauty      | 46851.18      | 18671.73  |
| Electronic accessories | 78175.03      | 30772.49  |
| Home and lifestyle     | 489250.06     | 192213.64 |
| Sports and travel      | 52497.93      | 20613.81  |
| Food and beverages     | 53471.28      | 21552.86  |
| Fashion accessories    | 489480.9      | 192314.89 |
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
<details>
  <summary>Click to expand</summary>

| branch  | payment_method |
| ------- | -------------- |
| WALM001 | Ewallet        |
| WALM002 | Ewallet        |
| WALM003 | Credit card    |
| WALM004 | Ewallet        |
| WALM005 | Ewallet        |
| WALM006 | Ewallet        |
| WALM007 | Ewallet        |
| WALM008 | Ewallet        |
| WALM009 | Credit card    |
| WALM010 | Ewallet        |
| WALM011 | Ewallet        |
| WALM012 | Ewallet        |
| WALM013 | Ewallet        |
| WALM014 | Ewallet        |
| WALM015 | Ewallet        |
| WALM016 | Ewallet        |
| WALM017 | Ewallet        |
| WALM018 | Ewallet        |
| WALM019 | Ewallet        |
| WALM020 | Ewallet        |
| WALM021 | Ewallet        |
| WALM022 | Ewallet        |
| WALM023 | Ewallet        |
| WALM024 | Ewallet        |
| WALM025 | Credit card    |
| WALM026 | Ewallet        |
| WALM027 | Ewallet        |
| WALM028 | Ewallet        |
| WALM029 | Credit card    |
| WALM030 | Credit card    |
| WALM031 | Ewallet        |
| WALM032 | Credit card    |
| WALM033 | Ewallet        |
| WALM034 | Ewallet        |
| WALM035 | Credit card    |
| WALM036 | Ewallet        |
| WALM037 | Ewallet        |
| WALM038 | Credit card    |
| WALM039 | Ewallet        |
| WALM040 | Ewallet        |
| WALM041 | Ewallet        |
| WALM042 | Ewallet        |
| WALM043 | Ewallet        |
| WALM044 | Ewallet        |
| WALM045 | Credit card    |
| WALM046 | Credit card    |
| WALM047 | Ewallet        |
| WALM048 | Ewallet        |
| WALM049 | Ewallet        |
| WALM050 | Ewallet        |
| WALM051 | Ewallet        |
| WALM052 | Ewallet        |
| WALM053 | Ewallet        |
| WALM054 | Credit card    |
| WALM055 | Credit card    |
| WALM056 | Credit card    |
| WALM057 | Ewallet        |
| WALM058 | Credit card    |
| WALM059 | Ewallet        |
| WALM060 | Ewallet        |
| WALM061 | Ewallet        |
| WALM062 | Ewallet        |
| WALM063 | Ewallet        |
| WALM064 | Ewallet        |
| WALM065 | Credit card    |
| WALM066 | Ewallet        |
| WALM067 | Ewallet        |
| WALM068 | Ewallet        |
| WALM069 | Credit card    |
| WALM070 | Ewallet        |
| WALM071 | Ewallet        |
| WALM072 | Ewallet        |
| WALM073 | Credit card    |
| WALM074 | Cash           |
| WALM075 | Credit card    |
| WALM076 | Ewallet        |
| WALM077 | Ewallet        |
| WALM078 | Ewallet        |
| WALM079 | Ewallet        |
| WALM080 | Ewallet        |
| WALM081 | Ewallet        |
| WALM082 | Cash           |
| WALM083 | Ewallet        |
| WALM084 | Credit card    |
| WALM085 | Ewallet        |
| WALM086 | Credit card    |
| WALM087 | Credit card    |
| WALM088 | Ewallet        |
| WALM089 | Credit card    |
| WALM090 | Ewallet        |
| WALM091 | Ewallet        |
| WALM092 | Ewallet        |
| WALM093 | Ewallet        |
| WALM094 | Ewallet        |
| WALM095 | Ewallet        |
| WALM096 | Ewallet        |
| WALM097 | Ewallet        |
| WALM098 | Ewallet        |
| WALM099 | Credit card    |
| WALM100 | Ewallet        |

</details>
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
<details>
  <summary>Click to expand</summary>
    
| branch  | shift     | number_of_transactions |
| ------- | --------- | ---------------------- |
| WALM001 | Evening   | 39                     |
| WALM001 | Afternoon | 27                     |
| WALM001 | Morning   | 8                      |
| WALM002 | Evening   | 27                     |
| WALM002 | Afternoon | 23                     |
| WALM002 | Morning   | 15                     |
| WALM003 | Afternoon | 71                     |
| WALM003 | Evening   | 65                     |
| WALM003 | Morning   | 50                     |
| WALM004 | Evening   | 26                     |
| WALM004 | Afternoon | 25                     |
| WALM004 | Morning   | 9                      |
| WALM005 | Evening   | 49                     |
| WALM005 | Afternoon | 20                     |
| WALM005 | Morning   | 15                     |
| WALM006 | Evening   | 38                     |
| WALM006 | Afternoon | 26                     |
| WALM006 | Morning   | 7                      |
| WALM007 | Evening   | 40                     |
| WALM007 | Afternoon | 20                     |
| WALM007 | Morning   | 10                     |
| WALM008 | Evening   | 36                     |
| WALM008 | Afternoon | 23                     |
| WALM008 | Morning   | 9                      |
| WALM009 | Evening   | 103                    |
| WALM009 | Afternoon | 83                     |
| WALM009 | Morning   | 49                     |
| WALM010 | Evening   | 33                     |
| WALM010 | Afternoon | 26                     |
| WALM010 | Morning   | 7                      |
| WALM011 | Afternoon | 30                     |
| WALM011 | Evening   | 29                     |
| WALM011 | Morning   | 9                      |
| WALM012 | Evening   | 43                     |
| WALM012 | Afternoon | 26                     |
| WALM012 | Morning   | 11                     |
| WALM013 | Evening   | 23                     |
| WALM013 | Afternoon | 21                     |
| WALM013 | Morning   | 13                     |
| WALM014 | Evening   | 29                     |
| WALM014 | Afternoon | 14                     |
| WALM014 | Morning   | 9                      |
| WALM015 | Evening   | 41                     |
| WALM015 | Afternoon | 24                     |
| WALM015 | Morning   | 22                     |
| WALM016 | Evening   | 33                     |
| WALM016 | Afternoon | 30                     |
| WALM016 | Morning   | 7                      |
| WALM017 | Evening   | 37                     |
| WALM017 | Afternoon | 25                     |
| WALM017 | Morning   | 14                     |
| WALM018 | Evening   | 31                     |
| WALM018 | Afternoon | 22                     |
| WALM018 | Morning   | 11                     |
| WALM019 | Afternoon | 31                     |
| WALM019 | Evening   | 31                     |
| WALM019 | Morning   | 9                      |
| WALM020 | Evening   | 37                     |
| WALM020 | Afternoon | 29                     |
| WALM020 | Morning   | 10                     |
| WALM021 | Evening   | 32                     |
| WALM021 | Afternoon | 22                     |
| WALM021 | Morning   | 11                     |
| WALM022 | Evening   | 36                     |
| WALM022 | Afternoon | 29                     |
| WALM022 | Morning   | 10                     |
| WALM023 | Evening   | 38                     |
| WALM023 | Afternoon | 22                     |
| WALM023 | Morning   | 10                     |
| WALM024 | Evening   | 29                     |
| WALM024 | Afternoon | 22                     |
| WALM024 | Morning   | 14                     |
| WALM025 | Afternoon | 64                     |
| WALM025 | Evening   | 51                     |
| WALM025 | Morning   | 45                     |
| WALM026 | Evening   | 32                     |
| WALM026 | Afternoon | 28                     |
| WALM026 | Morning   | 13                     |
| WALM027 | Evening   | 41                     |
| WALM027 | Afternoon | 18                     |
| WALM027 | Morning   | 13                     |
| WALM028 | Evening   | 43                     |
| WALM028 | Afternoon | 16                     |
| WALM028 | Morning   | 11                     |
| WALM029 | Afternoon | 81                     |
| WALM029 | Evening   | 63                     |
| WALM029 | Morning   | 52                     |
| WALM030 | Evening   | 106                    |
| WALM030 | Afternoon | 75                     |
| WALM030 | Morning   | 48                     |
| WALM031 | Evening   | 32                     |
| WALM031 | Afternoon | 15                     |
| WALM031 | Morning   | 9                      |
| WALM032 | Evening   | 70                     |
| WALM032 | Afternoon | 55                     |
| WALM032 | Morning   | 45                     |
| WALM033 | Evening   | 30                     |
| WALM033 | Afternoon | 14                     |
| WALM033 | Morning   | 13                     |
| WALM034 | Evening   | 33                     |
| WALM034 | Afternoon | 13                     |
| WALM034 | Morning   | 10                     |
| WALM035 | Afternoon | 68                     |
| WALM035 | Evening   | 65                     |
| WALM035 | Morning   | 40                     |
| WALM036 | Evening   | 35                     |
| WALM036 | Afternoon | 23                     |
| WALM036 | Morning   | 15                     |
| WALM037 | Evening   | 34                     |
| WALM037 | Afternoon | 20                     |
| WALM037 | Morning   | 12                     |
| WALM038 | Afternoon | 83                     |
| WALM038 | Evening   | 59                     |
| WALM038 | Morning   | 47                     |
| WALM039 | Evening   | 30                     |
| WALM039 | Afternoon | 22                     |
| WALM039 | Morning   | 7                      |
| WALM040 | Evening   | 30                     |
| WALM040 | Afternoon | 23                     |
| WALM040 | Morning   | 16                     |
| WALM041 | Evening   | 33                     |
| WALM041 | Afternoon | 26                     |
| WALM041 | Morning   | 8                      |
| WALM042 | Evening   | 32                     |
| WALM042 | Afternoon | 18                     |
| WALM042 | Morning   | 14                     |
| WALM043 | Evening   | 40                     |
| WALM043 | Afternoon | 24                     |
| WALM043 | Morning   | 16                     |
| WALM044 | Evening   | 31                     |
| WALM044 | Afternoon | 24                     |
| WALM044 | Morning   | 15                     |
| WALM045 | Afternoon | 36                     |
| WALM045 | Evening   | 23                     |
| WALM045 | Morning   | 7                      |
| WALM046 | Afternoon | 76                     |
| WALM046 | Evening   | 74                     |
| WALM046 | Morning   | 41                     |
| WALM047 | Evening   | 39                     |
| WALM047 | Afternoon | 24                     |
| WALM047 | Morning   | 18                     |
| WALM048 | Evening   | 44                     |
| WALM048 | Afternoon | 23                     |
| WALM048 | Morning   | 12                     |
| WALM049 | Evening   | 36                     |
| WALM049 | Afternoon | 21                     |
| WALM049 | Morning   | 14                     |
| WALM050 | Afternoon | 63                     |
| WALM050 | Evening   | 50                     |
| WALM050 | Morning   | 38                     |
| WALM051 | Evening   | 41                     |
| WALM051 | Afternoon | 22                     |
| WALM051 | Morning   | 5                      |
| WALM052 | Evening   | 36                     |
| WALM052 | Afternoon | 29                     |
| WALM052 | Morning   | 14                     |
| WALM053 | Evening   | 37                     |
| WALM053 | Afternoon | 22                     |
| WALM053 | Morning   | 15                     |
| WALM054 | Afternoon | 62                     |
| WALM054 | Evening   | 58                     |
| WALM054 | Morning   | 55                     |
| WALM055 | Evening   | 74                     |
| WALM055 | Afternoon | 68                     |
| WALM055 | Morning   | 44                     |
| WALM056 | Evening   | 61                     |
| WALM056 | Afternoon | 59                     |
| WALM056 | Morning   | 49                     |
| WALM057 | Evening   | 33                     |
| WALM057 | Afternoon | 22                     |
| WALM057 | Morning   | 16                     |
| WALM058 | Afternoon | 95                     |
| WALM058 | Evening   | 90                     |
| WALM058 | Morning   | 54                     |
| WALM059 | Evening   | 37                     |
| WALM059 | Afternoon | 25                     |
| WALM059 | Morning   | 17                     |
| WALM060 | Evening   | 42                     |
| WALM060 | Afternoon | 23                     |
| WALM060 | Morning   | 14                     |
| WALM061 | Evening   | 34                     |
| WALM061 | Afternoon | 25                     |
| WALM061 | Morning   | 10                     |
| WALM062 | Evening   | 36                     |
| WALM062 | Afternoon | 27                     |
| WALM062 | Morning   | 12                     |
| WALM063 | Evening   | 29                     |
| WALM063 | Afternoon | 28                     |
| WALM063 | Morning   | 24                     |
| WALM064 | Evening   | 31                     |
| WALM064 | Afternoon | 20                     |
| WALM064 | Morning   | 13                     |
| WALM065 | Afternoon | 68                     |
| WALM065 | Evening   | 61                     |
| WALM065 | Morning   | 47                     |
| WALM066 | Evening   | 40                     |
| WALM066 | Afternoon | 26                     |
| WALM066 | Morning   | 9                      |
| WALM067 | Evening   | 33                     |
| WALM067 | Afternoon | 25                     |
| WALM067 | Morning   | 15                     |
| WALM068 | Evening   | 26                     |
| WALM068 | Afternoon | 24                     |
| WALM068 | Morning   | 9                      |
| WALM069 | Evening   | 97                     |
| WALM069 | Afternoon | 77                     |
| WALM069 | Morning   | 48                     |
| WALM070 | Evening   | 30                     |
| WALM070 | Afternoon | 27                     |
| WALM070 | Morning   | 11                     |
| WALM071 | Evening   | 31                     |
| WALM071 | Afternoon | 24                     |
| WALM071 | Morning   | 14                     |
| WALM072 | Evening   | 27                     |
| WALM072 | Afternoon | 27                     |
| WALM072 | Morning   | 9                      |
| WALM073 | Evening   | 68                     |
| WALM073 | Afternoon | 59                     |
| WALM073 | Morning   | 36                     |
| WALM074 | Afternoon | 80                     |
| WALM074 | Evening   | 72                     |
| WALM074 | Morning   | 58                     |
| WALM075 | Afternoon | 88                     |
| WALM075 | Evening   | 57                     |
| WALM075 | Morning   | 43                     |
| WALM076 | Evening   | 43                     |
| WALM076 | Afternoon | 20                     |
| WALM076 | Morning   | 11                     |
| WALM077 | Evening   | 31                     |
| WALM077 | Afternoon | 21                     |
| WALM077 | Morning   | 13                     |
| WALM078 | Evening   | 32                     |
| WALM078 | Afternoon | 31                     |
| WALM078 | Morning   | 15                     |
| WALM079 | Afternoon | 28                     |
| WALM079 | Evening   | 25                     |
| WALM079 | Morning   | 12                     |
| WALM080 | Evening   | 37                     |
| WALM080 | Afternoon | 24                     |
| WALM080 | Morning   | 14                     |
| WALM081 | Afternoon | 30                     |
| WALM081 | Evening   | 26                     |
| WALM081 | Morning   | 12                     |
| WALM082 | Afternoon | 76                     |
| WALM082 | Evening   | 65                     |
| WALM082 | Morning   | 45                     |
| WALM083 | Evening   | 33                     |
| WALM083 | Afternoon | 31                     |
| WALM083 | Morning   | 8                      |
| WALM084 | Evening   | 79                     |
| WALM084 | Afternoon | 78                     |
| WALM084 | Morning   | 48                     |
| WALM085 | Evening   | 39                     |
| WALM085 | Afternoon | 23                     |
| WALM085 | Morning   | 13                     |
| WALM086 | Afternoon | 66                     |
| WALM086 | Evening   | 63                     |
| WALM086 | Morning   | 48                     |
| WALM087 | Afternoon | 77                     |
| WALM087 | Evening   | 69                     |
| WALM087 | Morning   | 46                     |
| WALM088 | Evening   | 38                     |
| WALM088 | Afternoon | 25                     |
| WALM088 | Morning   | 16                     |
| WALM089 | Afternoon | 70                     |
| WALM089 | Morning   | 56                     |
| WALM089 | Evening   | 56                     |
| WALM090 | Evening   | 43                     |
| WALM090 | Afternoon | 21                     |
| WALM090 | Morning   | 12                     |
| WALM091 | Evening   | 36                     |
| WALM091 | Afternoon | 25                     |
| WALM091 | Morning   | 15                     |
| WALM092 | Afternoon | 25                     |
| WALM092 | Evening   | 18                     |
| WALM092 | Morning   | 8                      |
| WALM093 | Evening   | 30                     |
| WALM093 | Afternoon | 26                     |
| WALM093 | Morning   | 11                     |
| WALM094 | Evening   | 31                     |
| WALM094 | Afternoon | 26                     |
| WALM094 | Morning   | 11                     |
| WALM095 | Evening   | 41                     |
| WALM095 | Afternoon | 27                     |
| WALM095 | Morning   | 15                     |
| WALM096 | Afternoon | 31                     |
| WALM096 | Evening   | 30                     |
| WALM096 | Morning   | 18                     |
| WALM097 | Evening   | 35                     |
| WALM097 | Afternoon | 18                     |
| WALM097 | Morning   | 14                     |
| WALM098 | Evening   | 42                     |
| WALM098 | Afternoon | 15                     |
| WALM098 | Morning   | 8                      |
| WALM099 | Afternoon | 83                     |
| WALM099 | Evening   | 42                     |
| WALM099 | Morning   | 40                     |
| WALM100 | Evening   | 27                     |
| WALM100 | Morning   | 19                     |
| WALM100 | Afternoon | 16                     |
    
</details>
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
| branch  | revenue_2022 | revenue_2023 | YoY_change | proportion_of_change |
| ------- | ------------ | ------------ | ---------- | -------------------- |
| WALM045 | 1731         | 647          | -1084      | -62.62               |
| WALM047 | 2581         | 1069         | -1512      | -58.58               |
| WALM098 | 2446         | 1030         | -1416      | -57.89               |
| WALM033 | 2099         | 931          | -1168      | -55.65               |
| WALM081 | 1723         | 850          | -873       | -50.67               |
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

<details>
  <summary>Click to expand</summary>

| Branch  | City           | category               | total_profit | total_revenue | profit_pct |
| ------- | -------------- | ---------------------- | ------------ | ------------- | ---------- |
| WALM067 | Haltom City    | Home and lifestyle     | 1680.04      | 5091.04       | 33         |
| WALM064 | Bedford        | Health and beauty      | 674.16       | 2042.92       | 33         |
| WALM088 | Cleburne       | Electronic accessories | 697.76       | 2114.41       | 33         |
| WALM100 | Canyon         | Home and lifestyle     | 658.19       | 3656.6        | 18         |
| WALM066 | Grapevine      | Health and beauty      | 23.93        | 72.52         | 33         |
| WALM065 | Texas City     | Food and beverages     | 122.39       | 370.89        | 33         |
| WALM061 | Cedar Park     | Sports and travel      | 169.35       | 513.18        | 33         |
| WALM088 | Cleburne       | Health and beauty      | 482.24       | 1461.33       | 33         |
| WALM083 | Farmers Branch | Home and lifestyle     | 1233.34      | 3737.4        | 33         |
| WALM067 | Haltom City    | Electronic accessories | 316.57       | 959.31        | 33         |
| WALM001 | Houston        | Home and lifestyle     | 1734.87      | 4819.08       | 36         |
| WALM072 | Lancaster      | Fashion accessories    | 1229.86      | 3726.84       | 33         |
| WALM075 | San Marcos     | Health and beauty      | 315.26       | 955.33        | 33         |
| WALM076 | Huntsville     | Fashion accessories    | 1324.49      | 4013.61       | 33         |
| WALM098 | Mineral Wells  | Sports and travel      | 174.67       | 970.41        | 18         |
| WALM096 | Eagle Pass     | Health and beauty      | 34.77        | 193.16        | 18         |
| WALM095 | Big Spring     | Sports and travel      | 420.24       | 1273.46       | 33         |
| WALM070 | Hurst          | Electronic accessories | 280.08       | 848.72        | 33         |
| WALM070 | Hurst          | Health and beauty      | 445.05       | 1348.63       | 33         |
| WALM088 | Cleburne       | Home and lifestyle     | 957.34       | 2901.02       | 33         |
| WALM079 | La Porte       | Sports and travel      | 467.34       | 1416.17       | 33         |
| WALM056 | Rowlett        | Electronic accessories | 636.42       | 1928.54       | 33         |
| WALM058 | Port Arthur    | Health and beauty      | 191.65       | 580.77        | 33         |
| WALM063 | Georgetown     | Electronic accessories | 208.04       | 630.42        | 33         |
| WALM089 | Southlake      | Food and beverages     | 338.28       | 1025.08       | 33         |
| WALM093 | Angleton       | Food and beverages     | 161.38       | 489.03        | 33         |
| WALM066 | Grapevine      | Home and lifestyle     | 2427.55      | 7356.22       | 33         |
| WALM078 | Del Rio        | Home and lifestyle     | 1535.4       | 4652.72       | 33         |
| WALM069 | Rockwall       | Sports and travel      | 410.55       | 1244.09       | 33         |
| WALM087 | Waxahachie     | Health and beauty      | 525.71       | 1593.07       | 33         |
| WALM096 | Eagle Pass     | Food and beverages     | 178.53       | 991.86        | 18         |
| WALM083 | Farmers Branch | Electronic accessories | 520.45       | 1577.11       | 33         |
| WALM072 | Lancaster      | Home and lifestyle     | 945.84       | 2866.19       | 33         |
| WALM058 | Port Arthur    | Fashion accessories    | 3958.11      | 11994.28      | 33         |
| WALM094 | Alamo          | Fashion accessories    | 815.13       | 2470.09       | 33         |
| WALM063 | Georgetown     | Food and beverages     | 335.06       | 1015.33       | 33         |
| WALM071 | Lufkin         | Health and beauty      | 333.95       | 1011.96       | 33         |
| WALM061 | Cedar Park     | Health and beauty      | 196.4        | 595.14        | 33         |
| WALM090 | Brownwood      | Food and beverages     | 541.65       | 1641.36       | 33         |
| WALM061 | Cedar Park     | Food and beverages     | 225.12       | 682.19        | 33         |
| WALM097 | Alice          | Sports and travel      | 83.92        | 466.25        | 18         |
| WALM095 | Big Spring     | Home and lifestyle     | 1441.88      | 4369.32       | 33         |
| WALM065 | Texas City     | Health and beauty      | 507.75       | 1538.64       | 33         |
| WALM096 | Eagle Pass     | Electronic accessories | 26.4         | 146.65        | 18         |
| WALM075 | San Marcos     | Fashion accessories    | 2850.92      | 8639.15       | 33         |
| WALM057 | Euless         | Fashion accessories    | 1687.53      | 5113.72       | 33         |
| WALM078 | Del Rio        | Health and beauty      | 70.11        | 212.45        | 33         |
| WALM055 | Waxahachie     | Electronic accessories | 709.61       | 2150.32       | 33         |
| WALM087 | Waxahachie     | Fashion accessories    | 2255.9       | 6836.06       | 33         |
| WALM071 | Lufkin         | Fashion accessories    | 1127.04      | 3415.28       | 33         |
| WALM071 | Lufkin         | Home and lifestyle     | 779.63       | 2362.52       | 33         |
| WALM085 | Kerrville      | Sports and travel      | 593.74       | 1799.2        | 33         |
| WALM061 | Cedar Park     | Home and lifestyle     | 1619.34      | 4907.08       | 33         |
| WALM088 | Cleburne       | Fashion accessories    | 1465.78      | 4441.76       | 33         |
| WALM068 | Burleson       | Sports and travel      | 526.64       | 1595.88       | 33         |
| WALM055 | Waxahachie     | Sports and travel      | 85.35        | 258.65        | 33         |
| WALM002 | Dallas         | Electronic accessories | 387.52       | 1076.44       | 36         |
| WALM062 | Galveston      | Health and beauty      | 326.61       | 989.74        | 33         |
| WALM098 | Mineral Wells  | Fashion accessories    | 692.27       | 3845.97       | 18         |
| WALM093 | Angleton       | Home and lifestyle     | 1150.88      | 3487.52       | 33         |
| WALM097 | Alice          | Food and beverages     | 111.15       | 617.48        | 18         |
| WALM054 | Sherman        | Health and beauty      | 55.56        | 264.56        | 21         |
| WALM070 | Hurst          | Sports and travel      | 175.67       | 532.32        | 33         |
| WALM099 | Weatherford    | Fashion accessories    | 1411.25      | 7840.3        | 18         |
| WALM071 | Lufkin         | Food and beverages     | 92           | 278.78        | 33         |
| WALM078 | Del Rio        | Sports and travel      | 245.04       | 742.56        | 33         |
| WALM074 | Weslaco        | Food and beverages     | 418.68       | 1268.73       | 33         |
| WALM100 | Canyon         | Health and beauty      | 246.01       | 1366.71       | 18         |
| WALM094 | Alamo          | Sports and travel      | 260.63       | 789.78        | 33         |
| WALM084 | Schertz        | Sports and travel      | 136.92       | 414.9         | 33         |
| WALM057 | Euless         | Food and beverages     | 651.59       | 1974.52       | 33         |
| WALM069 | Rockwall       | Food and beverages     | 288.93       | 875.56        | 33         |
| WALM089 | Southlake      | Sports and travel      | 320.93       | 972.51        | 33         |
| WALM060 | DeSoto         | Home and lifestyle     | 1401.73      | 4247.67       | 33         |
| WALM073 | Seguin         | Food and beverages     | 58.53        | 177.36        | 33         |
| WALM059 | Pflugerville   | Fashion accessories    | 1538.94      | 4663.46       | 33         |
| WALM086 | Rosenberg      | Health and beauty      | 85.93        | 260.4         | 33         |
| WALM073 | Seguin         | Fashion accessories    | 2456.46      | 7443.82       | 33         |
| WALM072 | Lancaster      | Food and beverages     | 237.03       | 718.28        | 33         |
| WALM084 | Schertz        | Home and lifestyle     | 3752.35      | 11370.76      | 33         |
| WALM059 | Pflugerville   | Home and lifestyle     | 988.39       | 2995.12       | 33         |
| WALM062 | Galveston      | Fashion accessories    | 1552.2       | 4703.64       | 33         |
| WALM066 | Grapevine      | Fashion accessories    | 1290.09      | 3909.36       | 33         |
| WALM079 | La Porte       | Health and beauty      | 91.77        | 278.08        | 33         |
| WALM002 | Dallas         | Home and lifestyle     | 1118.91      | 3108.09       | 36         |
| WALM094 | Alamo          | Health and beauty      | 140.6        | 426.05        | 33         |
| WALM100 | Canyon         | Sports and travel      | 89.53        | 497.41        | 18         |
| WALM086 | Rosenberg      | Electronic accessories | 593.34       | 1797.99       | 33         |
| WALM065 | Texas City     | Home and lifestyle     | 2852.14      | 8642.85       | 33         |
| WALM085 | Kerrville      | Health and beauty      | 135.24       | 409.83        | 33         |
| WALM055 | Waxahachie     | Home and lifestyle     | 2749.82      | 8332.78       | 33         |
| WALM093 | Angleton       | Sports and travel      | 279.84       | 848.01        | 33         |
| WALM065 | Texas City     | Sports and travel      | 194.51       | 589.43        | 33         |
| WALM081 | Friendswood    | Electronic accessories | 93.69        | 283.92        | 33         |
| WALM056 | Rowlett        | Food and beverages     | 322.79       | 978.16        | 33         |
| WALM067 | Haltom City    | Sports and travel      | 57.53        | 174.32        | 33         |
| WALM059 | Pflugerville   | Health and beauty      | 513.95       | 1557.42       | 33         |
| WALM068 | Burleson       | Electronic accessories | 48.92        | 148.24        | 33         |
| WALM087 | Waxahachie     | Home and lifestyle     | 3249.17      | 9845.98       | 33         |
| WALM069 | Rockwall       | Health and beauty      | 196.42       | 595.2         | 33         |
| WALM068 | Burleson       | Health and beauty      | 28.73        | 87.05         | 33         |
| WALM085 | Kerrville      | Fashion accessories    | 1201.43      | 3640.69       | 33         |
| WALM077 | Coppell        | Fashion accessories    | 1219.48      | 3695.39       | 33         |
| WALM070 | Hurst          | Home and lifestyle     | 1197.4       | 3628.48       | 33         |
| WALM055 | Waxahachie     | Fashion accessories    | 3058.7       | 9268.8        | 33         |
| WALM078 | Del Rio        | Fashion accessories    | 1352.4       | 4098.18       | 33         |
| WALM066 | Grapevine      | Sports and travel      | 9.5          | 28.78         | 33         |
| WALM100 | Canyon         | Electronic accessories | 82.98        | 460.98        | 18         |
| WALM074 | Weslaco        | Electronic accessories | 752.14       | 2279.21       | 33         |
| WALM099 | Weatherford    | Sports and travel      | 134.1        | 745           | 18         |
| WALM075 | San Marcos     | Sports and travel      | 374.62       | 1135.22       | 33         |
| WALM081 | Friendswood    | Food and beverages     | 487.16       | 1476.24       | 33         |
| WALM094 | Alamo          | Home and lifestyle     | 1156.93      | 3505.86       | 33         |
| WALM056 | Rowlett        | Fashion accessories    | 2659.03      | 8057.67       | 33         |
| WALM091 | Little Elm     | Fashion accessories    | 1316.82      | 3990.36       | 33         |
| WALM073 | Seguin         | Home and lifestyle     | 2705.23      | 8197.68       | 33         |
| WALM094 | Alamo          | Food and beverages     | 112.06       | 339.57        | 33         |
| WALM074 | Weslaco        | Home and lifestyle     | 3840.5       | 11637.88      | 33         |
| WALM085 | Kerrville      | Home and lifestyle     | 1123.08      | 3403.28       | 33         |
| WALM100 | Canyon         | Fashion accessories    | 409.08       | 2272.64       | 18         |
| WALM053 | Conroe         | Electronic accessories | 132.69       | 631.84        | 21         |
| WALM088 | Cleburne       | Sports and travel      | 284.38       | 861.75        | 33         |
| WALM075 | San Marcos     | Electronic accessories | 861.37       | 2610.2        | 33         |
| WALM091 | Little Elm     | Electronic accessories | 277.08       | 839.65        | 33         |
| WALM086 | Rosenberg      | Home and lifestyle     | 2386.49      | 7231.78       | 33         |
| WALM076 | Huntsville     | Food and beverages     | 158.37       | 479.9         | 33         |
| WALM070 | Hurst          | Fashion accessories    | 928.65       | 2814.1        | 33         |
| WALM095 | Big Spring     | Electronic accessories | 370.58       | 1122.97       | 33         |
| WALM082 | Weslaco        | Electronic accessories | 533.23       | 1615.84       | 33         |
| WALM081 | Friendswood    | Sports and travel      | 24.74        | 74.97         | 33         |
| WALM070 | Hurst          | Food and beverages     | 249.4        | 755.76        | 33         |
| WALM002 | Dallas         | Food and beverages     | 103.58       | 287.73        | 36         |
| WALM089 | Southlake      | Home and lifestyle     | 3004.69      | 9105.11       | 33         |
| WALM079 | La Porte       | Fashion accessories    | 1390.11      | 4212.46       | 33         |
| WALM072 | Lancaster      | Electronic accessories | 210.26       | 637.14        | 33         |
| WALM096 | Eagle Pass     | Home and lifestyle     | 1255.88      | 4758.42       | 26.39      |
| WALM091 | Little Elm     | Food and beverages     | 173.52       | 525.82        | 33         |
| WALM074 | Weslaco        | Fashion accessories    | 3261.4       | 9883.03       | 33         |
| WALM066 | Grapevine      | Food and beverages     | 166.84       | 505.58        | 33         |
| WALM002 | Dallas         | Fashion accessories    | 1083.06      | 3008.5        | 36         |
| WALM075 | San Marcos     | Food and beverages     | 251.33       | 761.61        | 33         |
| WALM092 | Lake Jackson   | Home and lifestyle     | 668.72       | 2026.42       | 33         |
| WALM098 | Mineral Wells  | Electronic accessories | 120.08       | 667.09        | 18         |
| WALM055 | Waxahachie     | Food and beverages     | 38.21        | 115.8         | 33         |
| WALM084 | Schertz        | Fashion accessories    | 3202.85      | 9705.6        | 33         |
| WALM062 | Galveston      | Electronic accessories | 236.24       | 715.88        | 33         |
| WALM001 | Houston        | Sports and travel      | 545.86       | 1516.29       | 36         |
| WALM063 | Georgetown     | Health and beauty      | 8.93         | 27.07         | 33         |
| WALM077 | Coppell        | Sports and travel      | 12.91        | 39.12         | 33         |
| WALM099 | Weatherford    | Electronic accessories | 131.81       | 732.26        | 18         |
| WALM077 | Coppell        | Electronic accessories | 250.97       | 760.53        | 33         |
| WALM068 | Burleson       | Food and beverages     | 104.96       | 318.05        | 33         |
| WALM080 | Nacogdoches    | Food and beverages     | 683.87       | 2072.32       | 33         |
| WALM064 | Bedford        | Food and beverages     | 129.06       | 391.1         | 33         |
| WALM086 | Rosenberg      | Food and beverages     | 574.83       | 1741.9        | 33         |
| WALM071 | Lufkin         | Electronic accessories | 32.62        | 98.84         | 33         |
| WALM059 | Pflugerville   | Sports and travel      | 344.64       | 1044.36       | 33         |
| WALM057 | Euless         | Electronic accessories | 45.41        | 137.6         | 33         |
| WALM078 | Del Rio        | Food and beverages     | 263.6        | 798.8         | 33         |
| WALM066 | Grapevine      | Electronic accessories | 108.24       | 328           | 33         |
| WALM080 | Nacogdoches    | Home and lifestyle     | 1142.06      | 3460.8        | 33         |
| WALM003 | San Antonio    | Sports and travel      | 179.81       | 499.46        | 36         |
| WALM060 | DeSoto         | Sports and travel      | 65.33        | 197.96        | 33         |
| WALM080 | Nacogdoches    | Fashion accessories    | 1392.98      | 4221.14       | 33         |
| WALM063 | Georgetown     | Home and lifestyle     | 1638.52      | 4965.2        | 33         |
| WALM081 | Friendswood    | Fashion accessories    | 1039.76      | 3150.78       | 33         |
| WALM098 | Mineral Wells  | Food and beverages     | 97.46        | 541.44        | 18         |
| WALM073 | Seguin         | Sports and travel      | 32.38        | 98.13         | 33         |
| WALM071 | Lufkin         | Sports and travel      | 182.1        | 551.81        | 33         |
| WALM087 | Waxahachie     | Sports and travel      | 94.15        | 285.29        | 33         |
| WALM059 | Pflugerville   | Food and beverages     | 255.58       | 774.48        | 33         |
| WALM077 | Coppell        | Health and beauty      | 173.8        | 526.68        | 33         |
| WALM057 | Euless         | Sports and travel      | 503.11       | 1524.59       | 33         |
| WALM059 | Pflugerville   | Electronic accessories | 198.14       | 600.41        | 33         |
| WALM097 | Alice          | Home and lifestyle     | 570.24       | 3168.02       | 18         |
| WALM074 | Weslaco        | Sports and travel      | 150.83       | 457.05        | 33         |
| WALM095 | Big Spring     | Fashion accessories    | 1455.04      | 4409.22       | 33         |
| WALM073 | Seguin         | Health and beauty      | 264.52       | 801.57        | 33         |
| WALM082 | Weslaco        | Fashion accessories    | 2882.67      | 8735.36       | 33         |
| WALM085 | Kerrville      | Food and beverages     | 48.44        | 146.79        | 33         |
| WALM082 | Weslaco        | Home and lifestyle     | 3245.88      | 9836.01       | 33         |
| WALM063 | Georgetown     | Fashion accessories    | 1220.86      | 3699.58       | 33         |
| WALM062 | Galveston      | Food and beverages     | 173.21       | 524.88        | 33         |
| WALM091 | Little Elm     | Sports and travel      | 26.64        | 80.72         | 33         |
| WALM096 | Eagle Pass     | Fashion accessories    | 913.09       | 5072.7        | 18         |
| WALM061 | Cedar Park     | Electronic accessories | 156.5        | 474.24        | 33         |
| WALM089 | Southlake      | Electronic accessories | 397.44       | 1204.36       | 33         |
| WALM090 | Brownwood      | Sports and travel      | 379.2        | 1149.08       | 33         |
| WALM083 | Farmers Branch | Fashion accessories    | 1360.38      | 4122.36       | 33         |
| WALM082 | Weslaco        | Sports and travel      | 170.89       | 517.86        | 33         |
| WALM092 | Lake Jackson   | Sports and travel      | 203.01       | 615.18        | 33         |
| WALM095 | Big Spring     | Health and beauty      | 766.48       | 2322.68       | 33         |
| WALM001 | Houston        | Fashion accessories    | 1051.44      | 2920.68       | 36         |
| WALM081 | Friendswood    | Health and beauty      | 245.87       | 745.06        | 33         |
| WALM080 | Nacogdoches    | Electronic accessories | 51.18        | 155.08        | 33         |
| WALM064 | Bedford        | Fashion accessories    | 1009.14      | 3057.99       | 33         |
| WALM069 | Rockwall       | Fashion accessories    | 3411.94      | 10339.21      | 33         |
| WALM001 | Houston        | Electronic accessories | 349.07       | 969.63        | 36         |
| WALM058 | Port Arthur    | Home and lifestyle     | 3658.56      | 11086.56      | 33         |
| WALM098 | Mineral Wells  | Home and lifestyle     | 610.6        | 3392.24       | 18         |
| WALM060 | DeSoto         | Health and beauty      | 110.5        | 334.86        | 33         |
| WALM073 | Seguin         | Electronic accessories | 479.18       | 1452.07       | 33         |
| WALM054 | Sherman        | Fashion accessories    | 2135.82      | 9397.41       | 22.73      |
| WALM093 | Angleton       | Fashion accessories    | 882.93       | 2675.56       | 33         |
| WALM062 | Galveston      | Sports and travel      | 148.02       | 448.56        | 33         |
| WALM085 | Kerrville      | Electronic accessories | 13.03        | 39.48         | 33         |
| WALM063 | Georgetown     | Sports and travel      | 45.7         | 138.48        | 33         |
| WALM058 | Port Arthur    | Sports and travel      | 48.1         | 145.76        | 33         |
| WALM083 | Farmers Branch | Food and beverages     | 170.5        | 516.66        | 33         |
| WALM079 | La Porte       | Home and lifestyle     | 1029.85      | 3120.76       | 33         |
| WALM061 | Cedar Park     | Fashion accessories    | 1047.51      | 3174.28       | 33         |
| WALM057 | Euless         | Health and beauty      | 58.87        | 178.4         | 33         |
| WALM060 | DeSoto         | Food and beverages     | 48.11        | 145.78        | 33         |
| WALM084 | Schertz        | Health and beauty      | 226.11       | 685.17        | 33         |
| WALM064 | Bedford        | Electronic accessories | 241.72       | 732.48        | 33         |
| WALM002 | Dallas         | Sports and travel      | 91.21        | 253.36        | 36         |
| WALM060 | DeSoto         | Fashion accessories    | 1279.23      | 3876.46       | 33         |
| WALM069 | Rockwall       | Electronic accessories | 571.44       | 1731.64       | 33         |
| WALM096 | Eagle Pass     | Sports and travel      | 30.82        | 93.38         | 33         |
| WALM087 | Waxahachie     | Electronic accessories | 665.47       | 2016.58       | 33         |
| WALM072 | Lancaster      | Sports and travel      | 80.82        | 244.9         | 33         |
| WALM098 | Mineral Wells  | Health and beauty      | 16.7         | 92.78         | 18         |
| WALM080 | Nacogdoches    | Sports and travel      | 87.55        | 265.3         | 33         |
| WALM086 | Rosenberg      | Sports and travel      | 107.2        | 324.85        | 33         |
| WALM082 | Weslaco        | Health and beauty      | 30.13        | 91.3          | 33         |
| WALM076 | Huntsville     | Electronic accessories | 184.37       | 558.7         | 33         |
| WALM093 | Angleton       | Electronic accessories | 182.61       | 553.35        | 33         |
| WALM093 | Angleton       | Health and beauty      | 114.03       | 345.54        | 33         |
| WALM092 | Lake Jackson   | Health and beauty      | 138.04       | 418.3         | 33         |
| WALM099 | Weatherford    | Home and lifestyle     | 1576.27      | 8757.04       | 18         |
| WALM057 | Euless         | Home and lifestyle     | 765.57       | 2319.91       | 33         |
| WALM077 | Coppell        | Home and lifestyle     | 628.72       | 1905.22       | 33         |
| WALM054 | Sherman        | Electronic accessories | 733.01       | 2221.25       | 33         |
| WALM062 | Galveston      | Home and lifestyle     | 1603.64      | 4859.52       | 33         |
| WALM067 | Haltom City    | Food and beverages     | 113.43       | 343.74        | 33         |
| WALM097 | Alice          | Electronic accessories | 118.29       | 657.16        | 18         |
| WALM074 | Weslaco        | Health and beauty      | 9.74         | 29.52         | 33         |
| WALM090 | Brownwood      | Home and lifestyle     | 1267.53      | 3841          | 33         |
| WALM068 | Burleson       | Fashion accessories    | 992.64       | 3008          | 33         |
| WALM053 | Conroe         | Fashion accessories    | 1278.99      | 4299          | 29.75      |
| WALM081 | Friendswood    | Home and lifestyle     | 811.14       | 2458          | 33         |
| WALM091 | Little Elm     | Home and lifestyle     | 1222.98      | 3706          | 33         |
| WALM068 | Burleson       | Home and lifestyle     | 853.38       | 2586          | 33         |
| WALM086 | Rosenberg      | Fashion accessories    | 2719.86      | 8242          | 33         |
| WALM065 | Texas City     | Fashion accessories    | 2740.65      | 8305          | 33         |
| WALM075 | San Marcos     | Home and lifestyle     | 2647.59      | 8023          | 33         |
| WALM090 | Brownwood      | Fashion accessories    | 967.23       | 2931          | 33         |
| WALM097 | Alice          | Fashion accessories    | 444.24       | 2468          | 18         |
| WALM092 | Lake Jackson   | Fashion accessories    | 653.07       | 1979          | 33         |
| WALM056 | Rowlett        | Home and lifestyle     | 2521.2       | 7640          | 33         |
| WALM069 | Rockwall       | Home and lifestyle     | 3066.36      | 9292          | 33         |
| WALM089 | Southlake      | Fashion accessories    | 2956.8       | 8960          | 33         |
| WALM064 | Bedford        | Home and lifestyle     | 711.15       | 2155          | 33         |
| WALM076 | Huntsville     | Home and lifestyle     | 1026.63      | 3111          | 33         |
| WALM067 | Haltom City    | Fashion accessories    | 1209.12      | 3664          | 33         |
| WALM054 | Sherman        | Home and lifestyle     | 1575.42      | 7502          | 21         |
| WALM065 | Texas City     | Electronic accessories | 190.74       | 578           | 33         |
| WALM058 | Port Arthur    | Electronic accessories | 236.61       | 717           | 33         |
| WALM084 | Schertz        | Electronic accessories | 303.27       | 919           | 33         |

</details>

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
<details>
  <summary>Click to expand</summary>

| Branch  | calendar_year | annual_revenue | revenue_quartile |
| ------- | ------------- | -------------- | ---------------- |
| WALM003 | 2020          | 4822           | 1                |
| WALM003 | 2021          | 4178           | 1                |
| WALM003 | 2022          | 4436           | 1                |
| WALM003 | 2023          | 4741           | 1                |
| WALM009 | 2020          | 4909           | 1                |
| WALM009 | 2021          | 6557           | 1                |
| WALM009 | 2022          | 4876           | 1                |
| WALM009 | 2023          | 5933           | 1                |
| WALM025 | 2020          | 3946           | 1                |
| WALM025 | 2021          | 3015           | 1                |
| WALM025 | 2022          | 3262           | 1                |
| WALM025 | 2023          | 3028           | 1                |
| WALM029 | 2020          | 5031           | 1                |
| WALM029 | 2021          | 5169           | 1                |
| WALM029 | 2022          | 5400           | 1                |
| WALM029 | 2023          | 3750           | 1                |
| WALM030 | 2020          | 4567           | 1                |
| WALM030 | 2021          | 6432           | 1                |
| WALM030 | 2022          | 5622           | 1                |
| WALM030 | 2023          | 4130           | 1                |
| WALM032 | 2020          | 3800           | 1                |
| WALM032 | 2021          | 5520           | 1                |
| WALM032 | 2022          | 3860           | 1                |
| WALM032 | 2023          | 3833           | 1                |
| WALM035 | 2020          | 3316           | 1                |
| WALM035 | 2021          | 4097           | 1                |
| WALM035 | 2022          | 3986           | 1                |
| WALM035 | 2023          | 5262           | 1                |
| WALM038 | 2020          | 4647           | 1                |
| WALM038 | 2021          | 3770           | 1                |
| WALM038 | 2022          | 3864           | 1                |
| WALM038 | 2023          | 5900           | 1                |
| WALM046 | 2020          | 5730           | 1                |
| WALM046 | 2021          | 4161           | 1                |
| WALM046 | 2022          | 5074           | 1                |
| WALM046 | 2023          | 3528           | 1                |
| WALM050 | 2020          | 4208           | 1                |
| WALM050 | 2021          | 3518           | 1                |
| WALM050 | 2022          | 3318           | 1                |
| WALM050 | 2023          | 4499           | 1                |
| WALM054 | 2020          | 5585           | 1                |
| WALM054 | 2021          | 4165           | 1                |
| WALM054 | 2022          | 3484           | 1                |
| WALM054 | 2023          | 4631           | 1                |
| WALM055 | 2020          | 4666           | 1                |
| WALM055 | 2021          | 4008           | 1                |
| WALM055 | 2022          | 4022           | 1                |
| WALM055 | 2023          | 4860           | 1                |
| WALM056 | 2020          | 3474           | 1                |
| WALM056 | 2021          | 4666           | 1                |
| WALM056 | 2022          | 3736           | 1                |
| WALM056 | 2023          | 3730           | 1                |
| WALM058 | 2020          | 5885           | 1                |
| WALM058 | 2021          | 6097           | 1                |
| WALM058 | 2022          | 5227           | 1                |
| WALM058 | 2023          | 5405           | 1                |
| WALM065 | 2020          | 4134           | 1                |
| WALM065 | 2021          | 3656           | 1                |
| WALM065 | 2022          | 4966           | 1                |
| WALM065 | 2023          | 4681           | 1                |
| WALM069 | 2020          | 5433           | 1                |
| WALM069 | 2021          | 4410           | 1                |
| WALM069 | 2022          | 4439           | 1                |
| WALM069 | 2023          | 5414           | 1                |
| WALM073 | 2020          | 4287           | 1                |
| WALM073 | 2021          | 3527           | 1                |
| WALM073 | 2022          | 4446           | 1                |
| WALM073 | 2023          | 3777           | 1                |
| WALM074 | 2020          | 4658           | 1                |
| WALM074 | 2021          | 5540           | 1                |
| WALM074 | 2022          | 4257           | 1                |
| WALM074 | 2023          | 5125           | 1                |
| WALM075 | 2020          | 5179           | 1                |
| WALM075 | 2021          | 4937           | 1                |
| WALM075 | 2022          | 3391           | 1                |
| WALM075 | 2023          | 4411           | 1                |
| WALM082 | 2020          | 3704           | 1                |
| WALM082 | 2021          | 5008           | 1                |
| WALM082 | 2022          | 4299           | 1                |
| WALM082 | 2023          | 4974           | 1                |
| WALM084 | 2020          | 4739           | 1                |
| WALM084 | 2021          | 5649           | 1                |
| WALM084 | 2022          | 6067           | 1                |
| WALM084 | 2023          | 4011           | 1                |
| WALM086 | 2020          | 4010           | 1                |
| WALM086 | 2021          | 4488           | 1                |
| WALM086 | 2022          | 4091           | 1                |
| WALM086 | 2023          | 3427           | 1                |
| WALM087 | 2020          | 4318           | 1                |
| WALM087 | 2021          | 4453           | 1                |
| WALM087 | 2022          | 4056           | 1                |
| WALM087 | 2023          | 4005           | 1                |
| WALM089 | 2020          | 5291           | 1                |
| WALM089 | 2021          | 4142           | 1                |
| WALM089 | 2022          | 3326           | 1                |
| WALM089 | 2023          | 4744           | 1                |
| WALM099 | 2020          | 3283           | 1                |
| WALM099 | 2021          | 3898           | 1                |
| WALM099 | 2022          | 4662           | 1                |
| WALM099 | 2023          | 3712           | 1                |

</details>
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
<details>
  <summary>Click to expand</summary>

| branch  | revenue_2020 | revenue_2023 | absolute_growth | growth_pct |
| ------- | ------------ | ------------ | --------------- | ---------- |
| WALM014 | 418          | 2017         | 1599            | 382.54     |
| WALM092 | 213          | 1026         | 813             | 381.69     |
| WALM039 | 367          | 1685         | 1318            | 359.13     |
| WALM027 | 718          | 2873         | 2155            | 300.14     |
| WALM063 | 737          | 2194         | 1457            | 197.69     |
| WALM007 | 979          | 2547         | 1568            | 160.16     |
| WALM049 | 990          | 2129         | 1139            | 115.05     |
| WALM033 | 436          | 931          | 495             | 113.53     |
| WALM068 | 820          | 1696         | 876             | 106.83     |
| WALM093 | 622          | 1263         | 641             | 103.05     |
| WALM060 | 1260         | 2548         | 1288            | 102.22     |
| WALM071 | 716          | 1399         | 683             | 95.39      |
| WALM026 | 1111         | 2027         | 916             | 82.45      |
| WALM016 | 921          | 1667         | 746             | 81         |
| WALM018 | 773          | 1376         | 603             | 78.01      |
| WALM002 | 937          | 1572         | 635             | 67.77      |
| WALM021 | 962          | 1610         | 648             | 67.36      |
| WALM012 | 1350         | 2194         | 844             | 62.52      |
| WALM077 | 1160         | 1884         | 724             | 62.41      |
| WALM008 | 1510         | 2445         | 935             | 61.92      |
| WALM035 | 3316         | 5262         | 1946            | 58.69      |
| WALM072 | 1207         | 1785         | 578             | 47.89      |
| WALM015 | 1825         | 2600         | 775             | 42.47      |
| WALM010 | 1498         | 2114         | 616             | 41.12      |
| WALM028 | 1277         | 1799         | 522             | 40.88      |
| WALM096 | 1606         | 2255         | 649             | 40.41      |
| WALM017 | 1679         | 2332         | 653             | 38.89      |
| WALM070 | 1033         | 1413         | 380             | 36.79      |
| WALM057 | 1147         | 1557         | 410             | 35.75      |
| WALM082 | 3704         | 4974         | 1270            | 34.29      |
| WALM011 | 1187         | 1557         | 370             | 31.17      |
| WALM037 | 974          | 1255         | 281             | 28.85      |
| WALM005 | 1683         | 2152         | 469             | 27.87      |
| WALM038 | 4647         | 5900         | 1253            | 26.96      |
| WALM079 | 1395         | 1770         | 375             | 26.88      |
| WALM040 | 1414         | 1786         | 372             | 26.31      |
| WALM052 | 1447         | 1815         | 368             | 25.43      |
| WALM090 | 1747         | 2181         | 434             | 24.84      |
| WALM009 | 4909         | 5933         | 1024            | 20.86      |
| WALM023 | 1133         | 1366         | 233             | 20.56      |
| WALM034 | 973          | 1131         | 158             | 16.24      |
| WALM022 | 1658         | 1890         | 232             | 13.99      |
| WALM095 | 1495         | 1699         | 204             | 13.65      |
| WALM065 | 4134         | 4681         | 547             | 13.23      |
| WALM099 | 3283         | 3712         | 429             | 13.07      |
| WALM024 | 1202         | 1349         | 147             | 12.23      |
| WALM006 | 1882         | 2088         | 206             | 10.95      |
| WALM074 | 4658         | 5125         | 467             | 10.03      |
| WALM056 | 3474         | 3730         | 256             | 7.37       |
| WALM050 | 4208         | 4499         | 291             | 6.92       |
| WALM013 | 1034         | 1094         | 60              | 5.8        |
| WALM067 | 1964         | 2046         | 82              | 4.18       |
| WALM055 | 4666         | 4860         | 194             | 4.16       |
| WALM091 | 2303         | 2394         | 91              | 3.95       |
| WALM032 | 3800         | 3833         | 33              | 0.87       |
| WALM069 | 5433         | 5414         | -19             | -0.35      |
| WALM019 | 1532         | 1522         | -10             | -0.65      |
| WALM003 | 4822         | 4741         | -81             | -1.68      |
| WALM100 | 1604         | 1566         | -38             | -2.37      |
| WALM098 | 1057         | 1030         | -27             | -2.55      |
| WALM048 | 1592         | 1546         | -46             | -2.89      |
| WALM031 | 1021         | 983          | -38             | -3.72      |
| WALM044 | 1714         | 1629         | -85             | -4.96      |
| WALM051 | 1634         | 1536         | -98             | -6         |
| WALM087 | 4318         | 4005         | -313            | -7.25      |
| WALM058 | 5885         | 5405         | -480            | -8.16      |
| WALM030 | 4567         | 4130         | -437            | -9.57      |
| WALM061 | 1758         | 1585         | -173            | -9.84      |
| WALM053 | 1470         | 1319         | -151            | -10.27     |
| WALM089 | 5291         | 4744         | -547            | -10.34     |
| WALM083 | 1837         | 1645         | -192            | -10.45     |
| WALM073 | 4287         | 3777         | -510            | -11.9      |
| WALM086 | 4010         | 3427         | -583            | -14.54     |
| WALM075 | 5179         | 4411         | -768            | -14.83     |
| WALM084 | 4739         | 4011         | -728            | -15.36     |
| WALM094 | 1575         | 1323         | -252            | -16        |
| WALM076 | 1827         | 1520         | -307            | -16.8      |
| WALM054 | 5585         | 4631         | -954            | -17.08     |
| WALM001 | 1814         | 1463         | -351            | -19.35     |
| WALM080 | 2067         | 1641         | -426            | -20.61     |
| WALM066 | 2321         | 1836         | -485            | -20.9      |
| WALM025 | 3946         | 3028         | -918            | -23.26     |
| WALM064 | 1279         | 980          | -299            | -23.38     |
| WALM029 | 5031         | 3750         | -1281           | -25.46     |
| WALM042 | 1792         | 1328         | -464            | -25.89     |
| WALM078 | 1951         | 1421         | -530            | -27.17     |
| WALM062 | 1930         | 1396         | -534            | -27.67     |
| WALM036 | 2042         | 1419         | -623            | -30.51     |
| WALM047 | 1659         | 1069         | -590            | -35.56     |
| WALM020 | 1747         | 1083         | -664            | -38.01     |
| WALM046 | 5730         | 3528         | -2202           | -38.43     |
| WALM085 | 1929         | 1179         | -750            | -38.88     |
| WALM045 | 1061         | 647          | -414            | -39.02     |
| WALM088 | 1905         | 1126         | -779            | -40.89     |
| WALM043 | 2553         | 1470         | -1083           | -42.42     |
| WALM059 | 1984         | 1123         | -861            | -43.4      |
| WALM097 | 1460         | 814          | -646            | -44.25     |
| WALM041 | 2212         | 1231         | -981            | -44.35     |
| WALM004 | 1814         | 958          | -856            | -47.19     |
| WALM081 | 1897         | 850          | -1047           | -55.19     |

</details>
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
<details>
  <summary>Click to expand</summary>

| branch  | total_revenue | avg_rating | revenue_rank | rating_rank |
| ------- | ------------- | ---------- | ------------ | ----------- |
| WALM058 | 22614         | 5.25       | 1            | 21          |
| WALM009 | 22275         | 5.26       | 2            | 22          |
| WALM030 | 20751         | 5.3        | 3            | 25          |
| WALM084 | 20466         | 5.26       | 4            | 22          |
| WALM069 | 19696         | 5.28       | 5            | 24          |
| WALM074 | 19580         | 4.99       | 6            | 3           |
| WALM029 | 19350         | 5.11       | 7            | 12          |
| WALM046 | 18493         | 5.16       | 8            | 14          |
| WALM038 | 18181         | 5.18       | 9            | 15          |
| WALM003 | 18177         | 5.22       | 10           | 17          |
| WALM082 | 17985         | 5.1        | 11           | 11          |
| WALM075 | 17918         | 4.92       | 12           | 2           |
| WALM054 | 17865         | 5.01       | 13           | 5           |
| WALM055 | 17556         | 5.05       | 14           | 7           |
| WALM089 | 17503         | 5.2        | 15           | 16          |
| WALM065 | 17437         | 5          | 16           | 4           |
| WALM032 | 17013         | 5.22       | 17           | 17          |
| WALM087 | 16832         | 5.07       | 18           | 9           |
| WALM035 | 16661         | 5.11       | 19           | 12          |
| WALM073 | 16037         | 5.23       | 20           | 20          |
| WALM086 | 16016         | 5.05       | 21           | 7           |
| WALM056 | 15606         | 4.86       | 22           | 1           |
| WALM099 | 15555         | 5.04       | 23           | 6           |
| WALM050 | 15543         | 5.07       | 24           | 9           |
| WALM025 | 13251         | 5.22       | 25           | 17          |

</details>
