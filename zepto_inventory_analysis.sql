USE zepto;

CREATE TABLE zepto_inventory (
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(100),
    name VARCHAR(255),
    mrp DECIMAL(10,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(10,2),
    weightInGms DECIMAL(10,2),
    outOfStock BOOLEAN,
    quantity INT
);

DESCRIBE TABLE zepto_inventory;

-- data exploration
SELECT * FROM zepto_inventory;
-- count of rows
select count(*) from zepto_inventory;

-- null values
SELECT * FROM zepto_inventory
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

-- different product categories
SELECT DISTINCT category
FROM zepto_inventory
ORDER BY category;

-- products available and not available in stock
SELECT outOfStock, COUNT(sku_id)
FROM zepto_inventory
GROUP BY outOfStock;

-- product name present multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto_inventory
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) DESC;

-- data cleaning

-- products with price = 0
SELECT * FROM zepto_inventory
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- Normalize prices from paise to rupees
UPDATE zepto_inventory
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

SELECT mrp, discountedSellingPrice FROM zepto_inventory;

-- Analysis

-- top 10 best-value products based on the discount percentage.
SELECT DISTINCT name,mrp, discountPercent 
FROM zepto_inventory
ORDER BY discountPercent DESC
LIMIT 10;

-- Out of stock product with higher mrp
SELECT DISTINCT name, mrp, outOfStock
FROM zepto_inventory
WHERE outOfStock = 1
ORDER BY mrp DESC;

-- estimate revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto_inventory
GROUP BY category
ORDER BY total_revenue;

-- all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT name, mrp, discountPercent
FROM zepto_inventory
WHERE mrp > 500 AND discountPercent < 10;

--  top 5 categories offering the highest average discount percentage.

SELECT category,
AVG(discountPercent) AS avg_discount
FROM zepto_inventory
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- price per gram for products above 100g and sort by best value.
SELECT name, discountedSellingPrice, 
(discountedSellingPrice / weightInGms) AS price_per_gram
FROM zepto_inventory
WHERE weightInGms > 100
ORDER BY price_per_gram ASC;

-- Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'low'
     WHEN weightInGms < 5000 THEN 'medium'
ELSE 'bulk'
END AS weight_category
FROM zepto_inventory;

-- Total Inventory Weight Per Category 

SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto_inventory
GROUP BY category
ORDER BY total_weight;

-- products taking up a lot of weight but offering low value
SELECT name,
       discountedSellingPrice,
       weightInGms,
       (discountedSellingPrice / weightInGms) AS price_per_gram
FROM zepto_inventory
WHERE weightInGms > 0
ORDER BY price_per_gram ASC
LIMIT 10;









