
-- FETCH DATA --------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM walmart.walmart;
 
 -- TOTAL BRANCHES AND TOTAL CITITES---------------------------------------------------------------------------------------------------------------------------------------------
 
 SELECT 
COUNT(DISTINCT BRANCH) TPTAL_BRANCH_COUNT,
COUNT(DISTINCT CITY) AS TOTAL_CITIES_COUNT
FROM WALMART;
 
 -- MOST PREFERENCE PAYMENT MODE, TOTAL SALES & TOTAL QUANTITY---------------------------------------------------------------------------------------------------------------------
 
SELECT PAYMENT_METHOD ,
COUNT(*) AS TOTAL_NO_OF_PAYMENTS,
SUM(QUANTITY) AS TOTAL_ORDER_QTY,
ROUND(SUM(TOTAL),2) AS TOTAL_SALES
FROM WALMART
GROUP BY PAYMENT_METHOD
ORDER BY TOTAL_NO_OF_PAYMENTS DESC;


-- TOP 3 REVENUE GENERATING CITIES--------------------------------------------------------------------------------------------------------------------------------------------
 
SELECT CITY , ROUND(SUM(TOTAL),2) AS TOTAL_SALE_CITY_WISE
FROM WALMART
GROUP BY CITY
ORDER BY TOTAL_SALE_CITY_WISE DESC
LIMIT 3;


 --  HIGHEST AVG RATING CATEGORY BRACH WISE--------------------------------------------------------------------------------------------------------------------------------------------
 
SELECT BRANCH,CATEGORY,AVG_RATING_PER_CATEGORY
FROM 
(SELECT BRANCH ,CATEGORY , ROUND(AVG(RATING),2) AS AVG_RATING_PER_CATEGORY,
RANK() OVER (PARTITION BY BRANCH ORDER BY AVG(RATING)DESC) AS RANKING
FROM WALMART
GROUP BY 1 , 2) AS SUBQUERY
WHERE RANKING = 1
ORDER BY AVG_RATING_PER_CATEGORY DESC;


-- MOST ORDER WEEK DAY--------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT DAY_NAME , COUNT(DAY_NAME) AS TOTAL_ORDER_ON_DAY
FROM (SELECT *, 
       DATE_FORMAT(STR_TO_DATE(DATE, '%d/%m/%Y'), '%W') AS DAY_NAME
       FROM WALMART) AS SUBQUERY
GROUP BY DAY_NAME
ORDER BY TOTAL_ORDER_ON_DAY DESC ;


-- AVG , MIN ,MAX RATING OF EACH CATEGORY --------------------------------------------------------------------------------------------------------------------------------------------

SELECT CATEGORY , 
COUNT(INVOICE_ID) ORDER_COUNT,
ROUND(AVG(RATING),2) AS AVG_RATING_PER_CATEGORY,
MIN(RATING) AS MIN_RATING,
MAX(RATING) AS MAX_RATING
FROM WALMART 
GROUP BY CATEGORY
ORDER BY AVG_RATING_PER_CATEGORY DESC;


-- EACH CATEGORY TOTAL QUANTITY SALE ,TOTAL REVENUE AND PROFIT --------------------------------------------------------------------------------------------------------------------------------------------


SELECT CATEGORY , 
SUM(QUANTITY) AS TOTAL_ORDERED_QTY,
ROUND(SUM(TOTAL),2) AS TOTAL_REVENUE,
ROUND(SUM(UNIT_PRICE * QUANTITY * PROFIT_MARGIN),2) AS TOTAL_PROFIT,
ROUND((SUM(UNIT_PRICE * QUANTITY * PROFIT_MARGIN) / SUM(TOTAL)) * 100, 2) AS PROFIT_PERCENTAGE
FROM WALMART
GROUP BY CATEGORY
ORDER BY TOTAL_PROFIT DESC;



-- BRANCH AND THEIR PREFERED PAYMENT METHOD --------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM 
( SELECT BRANCH  , PAYMENT_METHOD , COUNT(*) AS TOTAL_TRANSACTIONS,
RANK() OVER (PARTITION BY BRANCH ORDER BY COUNT(*) DESC) AS RANKING
FROM WALMART
GROUP BY 1 , 2 ) AS SQ
WHERE RANKING = 1;


-- ANALYZE SALES SHIFTS THROUGHOUT THE DAY 
 --------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW SALES_TIME_PERIOD AS
SELECT * ,STR_TO_DATE(time,'%H:%i:%s') AS CONVERTED_TIME,
CASE
	WHEN TIME(STR_TO_DATE(time,'%H:%i:%s')) BETWEEN '06:00:00' AND '11:59:59' THEN 'MORNING'
    WHEN TIME(STR_TO_DATE(time,'%H:%i:%s')) BETWEEN '12:00:00' AND '17:59:59' THEN 'AFTERNOON'
    WHEN TIME(STR_TO_DATE(time,'%H:%i:%s')) BETWEEN '18:00:00' AND '23:59:59' THEN 'EVENING'
    ELSE 'NIGHT'
END AS SALE_PERIOD
FROM WALMART;

SELECT  SALE_PERIOD , 
COUNT(SALE_PERIOD) AS SALE_COUNT,
ROUND(SUM(TOTAL),2) AS TOTAL_REVENUE
FROM SALES_TIME_PERIOD
GROUP BY  SALE_PERIOD;



-- HIGHEST REVENUE GENERATING BRANCH WITH TOTAL QUANTITY SALE--------------------------------------------------------------------------------------------------------------------------------------------

SELECT BRANCH , 
ROUND(SUM(TOTAL),2) AS TOP_REVENUE_GENERATING_BRANCH,
SUM(QUANTITY) AS TOTAL_SALAES_QUANTITY
FROM WALMART
GROUP BY BRANCH
ORDER BY TOP_REVENUE_GENERATING_BRANCH DESC;

-- TOP SELLING CATEGORY OF EACH CITY ---------------------------------------------------

WITH CTE1 AS 
(SELECT CITY , CATEGORY, COUNT(CATEGORY) AS TOTAL_QUANTITY,
RANK() OVER (PARTITION BY CITY ORDER BY COUNT(CATEGORY)DESC) AS TOP_SELLING_CATEGORY_OF_CITY
FROM WALMART
GROUP BY CITY, CATEGORY)
SELECT CITY, CATEGORY ,TOTAL_QUANTITY
FROM CTE1 
WHERE TOP_SELLING_CATEGORY_OF_CITY = 1;

SELECT * FROM walmart.walmart;



