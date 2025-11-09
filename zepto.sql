-- creating a database zepto_db:

CREATE DATABASE zepto_db;

-- using the database zepto_db:

USE zepto_db;

-- importing the table directly from a CSV file using the data wizard

-- viweing the table content

SELECT * FROM zepto;

DESC zepto;

-- adding a new column as boolean outofstock_bool

alter table zepto
ADD COLUMN outofstock_bool bool;

DESC zepto;


-- now copying all these in a new table with a new column sku_id setting it as a primary key with auto increment:

CREATE TABLE zepto_new(
	sku_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(200),
    name VARCHAR(200) NOT NULL,
    mrp decimal(10,2),
    discountPercent decimal(5,2),
    availableQuantity int,
    discountedSellingPrice decimal(10,2),
    weightInGms int,
    outOfStock varchar(20),
    quantity int,
    outofstock_bool bool
    
) ;

--  inserting the zepto table values in the new zepto_new table:


INSERT INTO zepto_new (category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice
	,weightInGms,outOfStock,quantity, outofstock_bool)
SELECT category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice
	,weightInGms,outOfStock,quantity, outofstock_bool FROM zepto;


DESC zepto_new;

-- setting outofstock_bool as if available quantity is 0 or >0

update zepto_new
SET outofstock_bool = TRUE 
WHERE availableQuantity = 0 ;

update zepto_new
SET outofstock_bool = FALSE 
WHERE availableQuantity > 0 ;

-- DATA EXPLORATION:

SELECT COUNT(*) FROM zepto_new;

SELECT * FROM zepto_new LIMIT 10;

-- checkingg if table has null values:

SELECT * FROM zepto_new
WHERE  category IS NULL OR
name IS NULL
 OR mrp IS NULL
 OR discountPercent IS NULL
 OR availableQuantity IS NULL
 OR discountedSellingPrice IS NULL
 OR weightInGms IS NULL
 OR outOfStock IS NULL
 OR quantity IS NULL
 OR outofstock_bool IS NULL;
 
 -- there were no null values
 
 -- checking different product category

SELECT DISTINCT category
FROM zepto_new
ORDER BY category;

-- checking number of products which are in stock and out of stock:

SELECT outofstock_bool, IF(outofstock_bool = 1, 'OUT OF STOCK','IN STOCK') as stock, COUNT(sku_id)
FROM zepto_new
GROUP BY outofstock_bool;

-- product names and count of it 

SELECT name, count(name)
FROM zepto_new
GROUP BY name
ORDER BY count(name) DESC;

-- product names present multiple times:

SELECT name, count(name)
FROM zepto_new
GROUP BY name
HAVING count(name) > 1
ORDER BY count(name) DESC;

-- DATA CLEANING:

-- products with price = 0:

SELECT * 
FROM zepto_new
WHERE mrp = 0 or discountedSellingPrice = 0;

-- removing such products

DELETE FROM zepto_new
WHERE mrp = 0;

SELECT *
FROM zepto_new;

--  changing the price to rupeers
UPDATE zepto_new
SET mrp = mrp/100, discountedsellingprice =discountedsellingprice/100;

-- removing the extra outofstock column

ALTER TABLE zepto_new
DROP COLUMN outofstock;

SELECT *
FROM zepto_new;

-- BUSINESS INSIGHT QUERIES

-- 1. FIND the top 10 best-value products based on discount percentage.

SELECT * FROM (

SELECT name,mrp,discountpercent,
row_number() OVER (PARTITION BY name ORDER BY discountpercent DESC) as rk
FROM zepto_new
ORDER BY discountpercent DESC

) as rnk

WHERE rk =1 
LIMIT 10;

-- same thing using a view

CREATE VIEW RNK AS (

SELECT name,mrp, discountpercent,
row_number() OVER (PARTITION BY name ORDER BY discountpercent DESC) as rk
FROM zepto_new
ORDER BY discountpercent DESC

);

SELECT * FROM RNK
WHERE Rk =1
LIMIT 10 ;

-- 2. What are te products with high MRP but out of stock

SELECT distinct name, mrp,IF(outofstock_bool = TRUE, 'Not in stock','In Stock') as 'In_stock?'
FROM zepto_new
WHERE outofstock_bool = TRUE
ORDER BY mrp DESC
LIMIT 10;

-- same using window function:

SELECT name,mrp,'in_stock?' FROM(
SELECT name, mrp, IF(outofstock_bool = TRUE, 'No','Yes') as 'In_stock?',
row_number() OVER (partition by name ORDER BY mrp DESC) as r
FROM zepto_new
WHERE outofstock_bool = TRUE 
ORDER BY  mrp DESC) as rn
WHERE r = 1
LIMIT 10;


-- 3.Calculate estimated Revenue for each category:

SELECT category, sum(discountedsellingprice * availablequantity) AS Revenue
FROM zepto_new
GROUP BY category
ORDER BY Revenue DESC;


--  4.Find all products where MRP is greater than 500rs and discount is less than 10%:

SELECT distinct name,mrp,discountpercent 
FROM zepto_new
WHERE mrp > 500 AND discountpercent < 10
order by mrp DESC,discountpercent DESC;

-- 5.Identify the top 5 categories offering the highest average discount percentage:

SELECT category,avg(discountpercent) as ag
FROM zepto_new
GROUP BY category
order by ag  DESC
LIMIT 5;

-- OR


SELECT * FROM (
SELECT category,avg(discountpercent) as ag
FROM zepto_new
GROUP BY category
) as t

WHERE ag > (SELECT avg(ag) FROM(
			SELECT category,avg(discountpercent) as ag
			FROM zepto_new
			GROUP BY category
			) as g)
            
ORDER BY ag DESC;


-- 6. Find the price per gram for products above 100g and sort by best value.

SELECT *
FROM zepto_new;

SELECT name, mrp, weightingms, ROUND(discountedsellingprice/weightingms,3) as price_per_gram
FROM zepto_new
WHERE weightingms > 100;


-- 7. Group the products into categories like low, mdeium,bulk

SELECT name, CASE 
					WHEN weightingms < 1000 THEN 'Low'
                    WHEN weightingms < 5000 THEN 'Medium'
                    ELSE 'Bulk'
                    END as weight_category
FROM zepto_new;