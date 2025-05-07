SELECT * FROM mintclassics.warehouses;
DESC warehouses;
-- LEAST full WAREHOUSE IS 'C' WITH 50pct, MOST full warehouse is 'D' with 75pct. 'B' 67pct, and 'A' 72pct !!!!!!!!
-- Warehouse B got the most (distinct) PRODUCTS : 38, with warehouses A, C, D having consequetively 25, 24, 23 distinct products
-- total Units in Stock (not distinct Products) : B '219183' - A '131688' - C '124880', D '79380'
-- Warehouse Stock Turnover 'D' got the most turnover with '0.0102' then comes 'A', 'C', 'B' with '0.0067', '0.0067', '0.0061'
-- B (East) is the warehouse with the most revenue : 3853922.49. the other 3 are close to each other ARROUND the half of 'EAST' revenue with C (WEST) having the lowest : '1797559.63'
-- B (East) is the warehouse with the most Profit : 1526212.20. the other 3 are close to each other ARROUND the half of 'EAST' revenue with D (SOUTH) having the lowest : '727183.71'
-- (most selled) top 3 products : '1962 LanciaA Delta 16V','1998 Chrysler Plymouth Prowler','1952 Alpine Renault 1300'
-- (least selled) WORST 3 products : '1958 Chevy Corvette Limited Edition','1982 Lamborghini Diablo','1938 Cadillac V-16 Presidential Limousine'
-- Prods with the most Profit : (warehouse : B) '1992 Ferrari 360 Spider red', (B) '1952 Alpine Renault 1300', (B) '2001 Ferrari Enzo'
-- Products with the lowest Profit : (warehouse : C) '1939 Chevrolet Deluxe Coupe', (A) 'Boeing X-32A JSF', (A) '1982 Ducati 996 R', (C) '1936 Mercedes Benz 500k Roadster', (C) '1930 Buick Marquette Phaeton'
-- ProductLines with most Profit : (B) 'Classic Cars', (C) 'Vintage Cars', (A) 'Motorcycles'
-- ProductLines with Low Profit : (D) 'Trains', (D) 'Ships', (A) 'Planes' (D) 'Trucks and Buses'
-- Best Customers(on Profit) per warehouse : (B) 'Euro+ Shopping Channel', (B) 'Mini Gifts Distributors Ltd.', (D) 'Euro+ Shopping Channel'
-- Worst Customers(on Profit) per warehouse : (A) 'Dragon Souveniers, Ltd.', (C) 'Frau da Collezione', (C) 'Microscale Inc.', (D) 'Mini Gifts Distributors Ltd.'
-- Least sold Products : (B) '1957 Ford Thunderbird', (B) '1970 Chevy Chevelle SS 454', (C) '1936 Mercedes Benz 500k Roadster', (C) '1911 Ford Town Car', (B) '1999 Indy 500 Monte Carlo SS', (C) '1932 Alfa Romeo 8C2300 Spider Sport', (B) '1992 Porsche Cayenne Turbo Silver', (B) '1969 Chevrolet Camaro Z28', (B) '1952 Citroen-15CV', (C) '1928 Mercedes-Benz SSK', (C) '1903 Ford Model A', (C) '1937 Horch 930V Limousine'
-- pct of products sold : B '1985 Toyota Supra' [not sold at all] '100.00', B '1995 Honda Civic' '91.42', B '2002 Chevy Corvette' '91.35', A '1982 Ducati 996 R' '91.07', B '1976 Ford Gran Torino' '90.89', B '1965 Aston Martin DB5' '90.82', 
-- when DECIDING which warehouse to cut off, see if it has any of TOP products (by Profit) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!! THERE IS SOME PRODUCTS WHO COULD BE SOLD FOR MORE (add that to report) !!!!!!!!!!!!!!!!!!!! 

-- deliverytime is not stable

SELECT w.warehouseCode, o.orderNumber, w.warehouseName, c.country, o.shippedDate, o.requiredDate, DATEDIFF(o.shippedDate, o.orderDate) deliveryTimeDays
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
WHERE o.shippedDate IS NOT NULL
ORDER BY w.warehouseCode, c.country, deliveryTimeDays;
--     
SELECT DISTINCT w.warehouseCode, w.warehouseName, c.country, DATEDIFF(o.shippedDate, o.orderDate) deliveryTimeDays
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
WHERE o.shippedDate IS NOT NULL
ORDER BY w.warehouseCode, c.country, deliveryTimeDays;

-- Products Quantity in stock vs OrdersQuantity

CREATE TEMPORARY TABLE product_order_counts
SELECT p.productCode, p.productName, p.productLine, IFNULL(oc.order_count, 0)  total_ordered_quantity, quantityInStock
FROM products AS p
LEFT JOIN
(
SELECT productCode, productName, SUM(quantityOrdered) order_count
FROM orderdetails
LEFT JOIN products p
USING(productCode)
GROUP BY productCode, productName
ORDER BY order_count
) oc
USING(productCode)
;

-- Product percent SOLD
SELECT p.productCode, p.productName, p.p.warehouseCode,w.warehouseName,p.quantityInStock,IFNULL(oc.total_ordered_quantity, 0) total_ordered_quantity,
    ROUND(IFNULL(oc.total_ordered_quantity, 0) / (p.quantityInStock + IFNULL(oc.total_ordered_quantity, 0)) * 100, 2) percent_sold
FROM products p LEFT JOIN (
        SELECT productCode, SUM(quantityOrdered) total_ordered_quantity
        FROM orderdetails
        GROUP BY productCode) oc USING(productCode)
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
ORDER BY percent_sold ASC;

-- Warehouse Percent Sold (decide if to keep) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SELECT p.warehouseCode,w.warehouseName,ROUND(SUM(oc.total_ordered_quantity) / SUM(p.quantityInStock + IFNULL(oc.total_ordered_quantity, 0)) * 100,2) warehouse_percent_sold
FROM products p
LEFT JOIN 
    (SELECT productCode, SUM(quantityOrdered) total_ordered_quantity
        FROM orderdetails
        GROUP BY productCode) oc USING(productCode)
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY p.warehouseCode, w.warehouseName
ORDER BY warehouse_percent_sold ASC;

-- (DISTINCT)Product per Warehouse

select warehouseCode, productLine, count(distinct productCode) productCount
from products
group by warehouseCode, ProductLine
order by productCount desc;

-- total units in stock

SELECT warehouseCode, SUM(quantityInStock) totalstock
FROM products
GROUP BY warehouseCode
order by totalStock desc;

-- Stock Turnover Ratio

SELECT p.warehouseCode, SUM(od.quantityOrdered) / NULLIF(SUM(p.quantityInStock), 0) stockTurnover
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.warehouseCode
order by stockTurnover desc;


-- Revenue per Warehouse
with Revenue as (
select w.warehouseCode, od.priceEach, od.quantityOrdered
from warehouses w join products p on w.warehouseCode = p.warehouseCode
join orderdetails od on p.productCode = od.productCode 
)
select warehouseCode, sum(quantityOrdered * priceEach) TotalRevenue
from Revenue
group by warehouseCode
order by TotalRevenue DESC;

-- Profit (revenue - buyPrice) per warehouse

SELECT w.warehouseCode, ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)), 2) profit
FROM warehouses w
JOIN products p ON w.warehouseCode = p.warehouseCode
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY w.warehouseCode
ORDER BY profit DESC;

-- selling Price VS MSRP (to see if products that has potential tp be sold for more)

SELECT w.warehouseName, p.productName, o.orderDate, od.priceEach, p.MSRP, od.priceEach - p.MSRP diff
FROM warehouses w
JOIN products p ON w.warehouseCode = p.warehouseCode
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
where od.priceEach - p.MSRP is not null
ORDER BY diff ASC;


WITH PriceDiff AS (
    SELECT w.warehouseName, p.productName, o.orderDate, od.priceEach - p.MSRP diff
    FROM warehouses w
    JOIN products p ON w.warehouseCode = p.warehouseCode
    JOIN orderdetails od ON p.productCode = od.productCode
    JOIN orders o ON od.orderNumber = o.orderNumber
    WHERE od.priceEach - p.MSRP != 0
)
SELECT distinct *
FROM PriceDiff
order by diff asc;


-- Most selled Products per WareHouse

select distinct productName, buyPrice
from products
order by buyPrice desc;

-- Profit per Product

SELECT p.productName, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) totalProfit
FROM products p JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productName
ORDER BY totalProfit asc;

-- top Profit Prods per warehouse

SELECT p.productName, p.warehouseCode, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) totalProfit
FROM products p JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productName, p.warehouseCode
ORDER BY totalProfit desc;

-- Top Profit ProductLine with Warehouse

SELECT p.productLine, p.warehouseCode, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) totalProfit
FROM products p JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productLine, p.warehouseCode
ORDER BY totalProfit DESC;

-- Profit per Customer

SELECT c.customerName, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) totalProfit
FROM customers c JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
GROUP BY c.customerName
ORDER BY totalProfit desc;

-- top 5 Customers using RANK

SET @rank := 0;

CREATE TEMPORARY TABLE top5_customers_ranked AS
SELECT customerNumber, customerName, totalProfit,
    @rank := @rank + 1 customerRank
FROM (
    SELECT c.customerNumber, c.customerName, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) AS totalProfit
    FROM customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN products p ON od.productCode = p.productCode
    GROUP BY c.customerNumber, c.customerName
    ORDER BY totalProfit DESC
    LIMIT 5
) ordered_top5;
SELECT tc.customerRank, tc.customerName, p.productName, p.warehouseCode, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) profitOnProduct
FROM top5_customers_ranked tc
JOIN orders o ON tc.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
GROUP BY tc.customerRank, tc.customerName, p.productName, p.warehouseCode
ORDER BY tc.customerRank, profitOnProduct desc;

SELECT tc.customerRank, tc.customerName, p.productName, p.productLine, p.warehouseCode, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) profitOnProduct
FROM top5_customers_ranked tc
JOIN orders o ON tc.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
where warehouseCode = 'd'
GROUP BY tc.customerRank, tc.customerName, p.productName,p.productLine, p.warehouseCode
ORDER BY tc.customerRank, profitOnProduct desc;

-- percentage of productLines purchased by one of top 3 customers 'Euro...' in warehouse D
SELECT p.productLine, ROUND(SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) /(
            SELECT SUM((od2.priceEach - p2.buyPrice) * od2.quantityOrdered)
            FROM orders o2
            JOIN orderdetails od2 ON o2.orderNumber = od2.orderNumber
            JOIN products p2 ON od2.productCode = p2.productCode
            WHERE o2.customerNumber = 141 AND p2.warehouseCode = 'D') * 100, 2
    ) percent_profit
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
WHERE o.customerNumber = 141 AND p.warehouseCode = 'D'
GROUP BY p.productLine
ORDER BY percent_profit DESC;
    
-- customer per warehouse

SELECT c.customerName, p.warehouseCode, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) totalProfit
FROM customers c JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
GROUP BY c.customerName, p.warehouseCode
ORDER BY totalProfit;

-- productlines per top 5 customers with their respective warehouses

WITH top_customers AS (
    SELECT c.customerNumber, c.customerName, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) AS totalProfit
    FROM customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN products p ON od.productCode = p.productCode
    GROUP BY c.customerNumber, c.customerName
    ORDER BY totalProfit DESC
    LIMIT 5
)
SELECT tc.customerName, pl.productLine, w.warehouseCode, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) AS profit
FROM top_customers tc
JOIN orders o ON tc.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
JOIN productlines pl ON p.productLine = pl.productLine
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY tc.customerName, pl.productLine, w.warehouseCode
ORDER BY tc.customerName, profit DESC;

-- Products per Warehouse

SELECT p.productName, w.warehouseCode
FROM products p
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
ORDER BY p.productName;
    
-- top 10 products in which warehouses --------------------------------------------------------------------------------------------------------

CREATE TEMPORARY TABLE top10_products AS
SELECT p.productCode, p.warehouseCode, p.productName, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) totalProfit
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName
ORDER BY totalProfit DESC
LIMIT 10;

SELECT t.productName, p.warehouseCode, w.warehousePctCap
FROM top10_products t
JOIN products p ON t.productCode = p.productCode
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
ORDER BY t.productName;
    
-- Slow moving Products (percentage)

SELECT p.productName, p.warehouseCode, w.warehouseName, p.quantityInStock, IFNULL(SUM(od.quantityOrdered), 0) totalSold, ROUND(100 * p.quantityInStock / (p.quantityInStock + IFNULL(SUM(od.quantityOrdered), 0)), 2) percentInStock
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY p.productCode, p.productName, p.warehouseCode, w.warehouseName, p.quantityInStock
ORDER BY percentInStock DESC;

-- average sales per Products for each warehouse

SELECT p.warehouseCode, w.warehouseName, COUNT(DISTINCT od.orderNumber) totalOrdersHandled, COUNT(DISTINCT p.productCode) totalProductsSold, ROUND(COUNT(DISTINCT od.orderNumber) / COUNT(DISTINCT p.productCode), 2) avgSalesPerProduct
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY p.warehouseCode, w.warehouseName
ORDER BY avgSalesPerProduct ASC;


