
----------------ANALYZING THE DATA-------------------------------

SELECT *
FROM dbo.e_commerce_data


--1. Find the top 3 customers who have the maximum count of orders.

SELECT TOP 3 Cust_ID, Customer_Name, COUNT(Ord_ID) AS Count_Orders
FROM dbo.e_commerce_data
GROUP BY Cust_ID, Customer_Name
ORDER BY  Count_Orders DESC


--2. Find the customer whose order took the maximum time to get shipping.

SELECT TOP 1 Cust_ID, Customer_Name
FROM dbo.e_commerce_data
ORDER BY DaysTakenForShipping DESC


/*
3. Count the total number of unique customers in January and 
how many of them came back again in the each one months of 2011.
*/

SELECT COUNT(DISTINCT Cust_ID) 
FROM dbo.e_commerce_data
WHERE Order_Date BETWEEN '2011-01-01' AND '2011-01-31'


WITH CustomerReturns AS (
    SELECT
        Cust_ID,
        CASE
            WHEN MONTH(Order_Date) = 1 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS JanuaryVisit,
        CASE
            WHEN MONTH(Order_Date) = 2 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS FebruaryReturn,
        CASE
            WHEN MONTH(Order_Date) = 3 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS MarchReturn,
		CASE
            WHEN MONTH(Order_Date) = 4 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS AprilReturn,
		CASE
            WHEN MONTH(Order_Date) = 5 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS MayReturn,
		CASE
            WHEN MONTH(Order_Date) = 6 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS JuneReturn,
		CASE
            WHEN MONTH(Order_Date) = 7 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS JulyReturn,
		CASE
            WHEN MONTH(Order_Date) = 8 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS AugustReturn,
		CASE
            WHEN MONTH(Order_Date) = 9 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS SeptemberReturn,
		CASE
            WHEN MONTH(Order_Date) = 10 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS OctoberReturn,
		CASE
            WHEN MONTH(Order_Date) = 11 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS NovemberReturn,
		CASE
            WHEN MONTH(Order_Date) = 12 AND YEAR(Order_Date) = 2011 THEN 1
            ELSE 0
        END AS DecemberReturn
   
    FROM
        dbo.e_commerce_data
    WHERE
        YEAR(Order_Date) = 2011
)
SELECT
    COUNT(DISTINCT CASE WHEN JanuaryVisit = 1 THEN Cust_ID END) AS TotalCustomersInJanuary,
    SUM(FebruaryReturn) AS FebruaryReturnCount,
    SUM(MarchReturn) AS MarchReturnCount,
    SUM(AprilReturn) AS AprilReturnCount,
	SUM(MayReturn) AS MayhReturnCount,
	SUM(JuneReturn) AS JuneReturnCount,
	SUM(JulyReturn) AS JulyReturnCount,
	SUM(AugustReturn) AS AugustReturnCount,
	SUM(SeptemberReturn) AS SeptemberReturnCount,
	SUM(OctoberReturn) AS OctoberReturnCount,
	SUM(NovemberReturn) AS NovemberReturnCount,
	SUM(DecemberReturn) AS DecemberReturnCount
FROM
    CustomerReturns;

/*
4. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
in ascending order by Customer ID.
*/

WITH CustomerPurchases AS (
SELECT Cust_ID,Ord_ID,order_date,
		ROW_NUMBER() OVER (PARTITION BY Cust_ID ORDER BY order_date) AS PurchaseNumber
FROM dbo.e_commerce_data
)
SELECT
    Cust_ID,
    DATEDIFF(day, MIN(CASE WHEN PurchaseNumber = 1 THEN Order_Date END), MIN(CASE WHEN PurchaseNumber = 3 THEN Order_Date END)) AS TimeElapsed
FROM
    CustomerPurchases
WHERE
    PurchaseNumber IN (1, 3)
GROUP BY
    Cust_ID
ORDER BY
    Cust_ID;

/*
5. Write a query that returns customers who purchased both product 11 and product 14,
as well as the ratio of these products to the total number of products purchased by the customer.
*/

WITH T1 AS (
SELECT DISTINCT Cust_ID, Customer_Name,	
	SUM(CASE Prod_ID WHEN 'Prod_11' THEN 1 END) AS Prod_11,
	SUM(CASE Prod_ID WHEN 'Prod_14' THEN 1 END) AS Prod_14
FROM dbo.e_commerce_data
GROUP BY Cust_ID, Customer_Name
HAVING SUM(CASE Prod_ID WHEN 'Prod_11' THEN 1 END)  IS NOT NULL
AND
	   SUM(CASE Prod_ID WHEN 'Prod_14' THEN 1 END) IS NOT NULL
),
T2 AS (
SELECT Cust_ID, COUNT(Ord_ID) AS total_order
FROM dbo.e_commerce_data
GROUP BY Cust_ID
)
SELECT T1.Cust_ID, (T1.Prod_11+T1.Prod_14) AS Purchases, T2.total_order, FORMAT(1.0*(T1.Prod_11+T1.Prod_14)/T2.total_order,'N2') AS Ratio
FROM T1 
	 INNER JOIN 
	 T2 
	 ON T1.Cust_ID = T2.Cust_ID



------------CATEGORIZING CUSTOMERS----------------

/*
1. Create a “view” that keeps visit logs of customers on a monthly basis. 
(For each log, three field is kept: Cust_id, Year, Month)
*/

CREATE VIEW MonthlyVisitLog AS
SELECT DISTINCT 
    Cust_ID,
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month
FROM
    dbo.e_commerce_data


/*
2. Create a “view” that keeps the number of monthly visits by users. 
(Show separately all months from the beginning business)
*/

CREATE VIEW MonthlyVisitCounts AS
SELECT
    Cust_ID,
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    COUNT(*) AS VisitCount
FROM
    dbo.e_commerce_data
GROUP BY
    Cust_ID,
    YEAR(Order_Date),
    MONTH(Order_Date);

--3. For each visit of customers, create the previous or next month of the visit as a separate column.


SELECT *,
    LEAD(Month) OVER (PARTITION BY Cust_ID ORDER BY Year, Month) AS NextMonth,
	LEAD(Year) OVER (PARTITION BY Cust_ID ORDER BY Year, Month) AS NextYear
FROM MonthlyVisitCounts
    

--4. Calculate the monthly time gap between two consecutive visits by each customer.

WITH T1 AS (
			SELECT *,
				LEAD(Month) OVER (PARTITION BY Cust_ID ORDER BY Year, Month) AS NextMonth,
				LEAD(Year) OVER (PARTITION BY Cust_ID ORDER BY Year, Month) AS NextYear
			FROM MonthlyVisitCounts
)
SELECT Cust_ID, Year, Month, NextMonth, 
	   (NextMonth-Month) + (NextYear-Year)*12 AS MonthlyTimeGap
FROM T1

/*
5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
For example:
- Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
- Labeled as regular if the customer has made a purchase every month.
Etc.
*/


WITH T1 AS (
			SELECT *,
				LEAD(Month) OVER (PARTITION BY Cust_ID ORDER BY Year, Month) AS NextMonth,
				LEAD(Year) OVER (PARTITION BY Cust_ID ORDER BY Year, Month) AS NextYear
			FROM MonthlyVisitCounts
),
T2 AS (
		SELECT Cust_ID, Year, Month, NextMonth, 
			   (NextMonth-Month) + (NextYear-Year)*12 AS MonthlyTimeGap
		FROM T1
), T3 AS (
		SELECT DISTINCT Cust_ID, 
			   AVG(MonthlyTimeGap) OVER(PARTITION BY Cust_ID ORDER BY Cust_ID) Avg_Monthly_Time_Gap
		FROM T2
)
SELECT Cust_ID, Avg_Monthly_Time_Gap,
	CASE WHEN Avg_Monthly_Time_Gap IS NULL THEN 'Churn'
	     WHEN Avg_Monthly_Time_Gap <=6  THEN 'Regular'
		 WHEN Avg_Monthly_Time_Gap >6 THEN 'Occasional'
END AS Customer_Labels
FROM T3



---------------Month-Wise Retention Rate-------------

/*

Find month-by-month customer retention rate since the start of the business.

There are many different variations in the calculation of Retention Rate. 
But we will try to calculate the month-wise retention rate in this project.

So, we will be interested in how many of the customers in the previous month could be retained in the next month.

Proceed step by step by creating “views”. 
You can use the view you got at the end of the Customer Segmentation section as a source.

1. Find the number of customers retained month-wise. (You can use time gaps)
2. Calculate the month-wise retention rate.
Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Previous Month

*/

WITH T1 AS (
			SELECT *,
				LEAD(Month) OVER (PARTITION BY Cust_ID ORDER BY Year, Month) AS NextMonth,
				LEAD(Year) OVER (PARTITION BY Cust_ID ORDER BY Year, Month) AS NextYear
			FROM MonthlyVisitCounts
),
T2 AS (
		SELECT Cust_ID, Year, Month, NextMonth, 
			   (NextMonth-Month) + (NextYear-Year)*12 AS MonthlyTimeGap
		FROM T1
),
T3 AS (
		SELECT Year, Month, COUNT(DISTINCT Cust_ID) AS Customer_Retained 
		FROM T2 
		WHERE MonthlyTimeGap = 1
		GROUP BY Month, Year
),
T4 AS (
		SELECT Year, Month, COUNT(DISTINCT Cust_ID) AS Total_Customer
		FROM T2
		GROUP BY Month, Year
),
T5 AS (
SELECT T3.Year, T3.Month, 
	LAG(T3.Customer_Retained) OVER(ORDER BY T3.Year, T3.Month) AS Cust_Retained,
	T4.Total_Customer
FROM T3 
	INNER JOIN T4
	ON T3.Month = T4.Month 
	AND T3.Year = T4.Year

)
SELECT *, FORMAT((1.0*Cust_Retained)/Total_Customer,'N3') AS Month_wise_Retention_Rate
FROM T5