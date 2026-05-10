# Walmart_TX_Sales-Analysis
![Cover Photo](Walmart_DA_Project_thumbnail.png)

## Overview

This project explores transactional sales data across 100 Walmart locations in the U.S. state of Texas from 2020-2023. The goal was uncover insights around branch performance, product category performance, customer behavior and revenue trends across the first four years of the 2020s decade. This project was completed via Python for data cleaning, and MySQL for analaysis.

## Dataset

- **Source:** Kaggle
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
| `total` | Total transaction value (unit_price × quantity) |[^1]: Not included in original dataset.
