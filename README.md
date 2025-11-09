# 🛒 Zepto Product Data Analysis using MySQL

![](https://github.com/Saqibahamed/Zepto_SQL_Project/blob/main/Zepto_logo.png)

## Overview
This project involves a comprehensive analysis of Zepto’s product data using MySQL.  
The goal is to perform **data cleaning, transformation, and analysis** to extract valuable insights related to pricing, discounts, product categories, and stock availability.  
The following README provides a detailed account of the project's objectives, SQL queries, findings, and conclusions.

## Objectives
- Clean and transform raw product data imported from a CSV file.
- Handle invalid or missing entries and standardize pricing.
- Analyze discounts, stock trends, and category-level performance.
- Generate insights to support product and pricing decisions.

## Dataset
The dataset was imported from a CSV file using MySQL’s import data wizard.  
It includes the following columns:  
`category`, `name`, `mrp`, `discountPercent`, `availableQuantity`, `discountedSellingPrice`, `weightInGms`, and `quantity`.

---

## Schema
This is done directly by importing the data from the .CSV file using the import data wizard.

```sql
CREATE DATABASE zepto_db;
USE zepto_db;

CREATE TABLE zepto_new(
    sku_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(200),
    name VARCHAR(200) NOT NULL,
    mrp DECIMAL(10,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(10,2),
    weightInGms INT,
    quantity INT,
    outofstock_bool BOOL
);
```

---

## Data Cleaning, Transformation and Exploration

### 1. Add a Boolean Column for Stock Status
```sql
ALTER TABLE zepto_new ADD COLUMN outofstock_bool BOOL;

UPDATE zepto_new SET outofstock_bool = TRUE WHERE availableQuantity = 0;
UPDATE zepto_new SET outofstock_bool = FALSE WHERE availableQuantity > 0;
```
**Objective:** Mark items as TRUE if out of stock and FALSE if in stock.

### 2. Remove Invalid Price Entries
```sql
DELETE FROM zepto_new
WHERE mrp = 0 OR discountedSellingPrice = 0;
```
**Objective:** Remove rows with zero or invalid price values to ensure accuracy.

### 3. Convert Price Units to Rupees
```sql
UPDATE zepto_new
SET mrp = mrp / 100, discountedSellingPrice = discountedSellingPrice / 100;
```
**Objective:** Standardize price units for meaningful analysis.

### 4. Drop Redundant Columns
```sql
ALTER TABLE zepto_new DROP COLUMN outOfStock;
```
**Objective:** Simplify the dataset by removing unnecessary columns.

### 5. Record Count and Sample Data
```sql
SELECT COUNT(*) FROM zepto_new;
SELECT * FROM zepto_new LIMIT 10;
```
**Objective:** Verify dataset size and preview records.

### 6. Check for Null Values
```sql
SELECT * FROM zepto_new
WHERE category IS NULL OR name IS NULL OR mrp IS NULL
 OR discountPercent IS NULL OR availableQuantity IS NULL
 OR discountedSellingPrice IS NULL OR weightInGms IS NULL
 OR quantity IS NULL OR outofstock_bool IS NULL;
```
**Objective:** Confirm data completeness — no null values found.

### 7. Unique Product Categories
```sql
SELECT DISTINCT category
FROM zepto_new
ORDER BY category;
```
**Objective:** Identify all unique categories available in the dataset.

### 8. Stock Availability Summary
```sql
SELECT outofstock_bool, IF(outofstock_bool = 1, 'OUT OF STOCK','IN STOCK') AS stock, COUNT(sku_id)
FROM zepto_new
GROUP BY outofstock_bool;
```
**Objective:** Display total products in stock vs out of stock.

### 9. Duplicate Product Names
```sql
SELECT name, COUNT(name)
FROM zepto_new
GROUP BY name
HAVING COUNT(name) > 1
ORDER BY COUNT(name) DESC;
```
**Objective:** Identify duplicate products for potential review or removal.

---

## Business Problems and Solutions

### 1. Find the Top 10 Best-Value Products by Discount
```sql
SELECT * FROM (
    SELECT name, mrp, discountPercent,
           ROW_NUMBER() OVER (PARTITION BY name ORDER BY discountPercent DESC) AS rk
    FROM zepto_new
) AS ranked
WHERE rk = 1
LIMIT 10;
```
**Objective:** Retrieve the top 10 products offering the highest discounts.

### 2. Identify High-MRP Products That Are Out of Stock
```sql
SELECT DISTINCT name, mrp, IF(outofstock_bool = TRUE, 'Not in stock', 'In Stock') AS 'In_Stock?'
FROM zepto_new
WHERE outofstock_bool = TRUE
ORDER BY mrp DESC
LIMIT 10;
```
**Objective:** Identify premium products that are currently unavailable.

### 3. Calculate Estimated Revenue by Category
```sql
SELECT category, SUM(discountedSellingPrice * availableQuantity) AS Revenue
FROM zepto_new
GROUP BY category
ORDER BY Revenue DESC;
```
**Objective:** Estimate total potential revenue for each category.

### 4. Find Products with High MRP and Low Discount
```sql
SELECT DISTINCT name, mrp, discountPercent
FROM zepto_new
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;
```
**Objective:** Identify premium products with minimal discounts.

### 5. Identify Top 5 Categories Offering the Highest Average Discount
```sql
SELECT category, AVG(discountPercent) AS avg_discount
FROM zepto_new
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;
```
**Objective:** Rank categories based on their average discount percentage.

### 6. Find Price per Gram for Products Above 100g
```sql
SELECT name, mrp, weightInGms, ROUND(discountedSellingPrice / weightInGms, 3) AS price_per_gram
FROM zepto_new
WHERE weightInGms > 100;
```
**Objective:** Evaluate cost efficiency using price-per-gram analysis.

### 7. Categorize Products by Weight Class
```sql
SELECT name,
       CASE
           WHEN weightInGms < 1000 THEN 'Low'
           WHEN weightInGms < 5000 THEN 'Medium'
           ELSE 'Bulk'
       END AS weight_category
FROM zepto_new;
```
**Objective:** Group products by weight for inventory categorization.

---

## Insights

- Most Zepto products are in stock, with only a few high-MRP items currently unavailable.  
- Snacks, Beverages, and Dairy categories contribute the most to total revenue.  
- Bulk items provide the best price-per-gram value, offering cost efficiency.  
- Discounts vary significantly across categories, revealing promotional opportunities.

---

## Outcome
This project demonstrates a complete SQL data analysis workflow, including:  
✅ Database creation and import  
✅ Data cleaning and transformation  
✅ Business query development  
✅ Revenue and stock trend analysis  

It highlights proficiency in **MySQL**, **data aggregation**, and **analytical problem-solving**, transforming raw data into meaningful, actionable business insights.
