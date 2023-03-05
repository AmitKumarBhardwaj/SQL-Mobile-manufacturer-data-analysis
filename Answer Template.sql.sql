use database db_SQLCaseStudies



--Q1.List all the states in which we have customers who have bought cellphones from 2005 till today. 
SELECT DISTINCT STATE
FROM DIM_LOCATION AS L
INNER JOIN 	FACT_TRANSACTIONS AS T ON L.IDLOCATION = T.IDLOCATION
WHERE YEAR(DATE) >= 2005




--Q2.What state in the US is buying the most 'Samsung' cell phones?
SELECT TOP 1 * FROM(
SELECT State, COUNT(DIM_LOCATION.IDLocation) AS CELL_PHONES FROM DIM_LOCATION
LEFT JOIN FACT_TRANSACTIONS ON DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
LEFT JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDMODEL
LEFT JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
WHERE Country = 'US' AND Manufacturer_Name = 'Samsung'
GROUP BY State
) AS T1



--Q3.Show the number of transactions for each model per zip code per state.   
SELECT DIM_MODEL.IDModel,Manufacturer_Name, ZipCode, State, COUNT(DIM_LOCATION.IDLocation) AS NUMBER_OF_TRANSACTION FROM DIM_LOCATION
LEFT JOIN FACT_TRANSACTIONS ON DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
LEFT JOIN DIM_MODEL ON DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
LEFT JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
GROUP BY DIM_MODEL.IDModel, ZipCode, State, Manufacturer_Name



--Q4.Show the cheapest cellphone (Output should contain the price also)SELECT TOP 1 Model_Name, MIN(Unit_price) AS UNIT_PRICE FROM DIM_MODEL
GROUP BY Model_Name




--Q5.Show the cheapest cellphone (Output should contain the price also)SELECT FACT_TRANSACTIONS.IDModel, DIM_MODEL.IDManufacturer, AVG(TotalPrice) AS AVG_PRICE
FROM FACT_TRANSACTIONS
INNER JOIN DIM_MODEL on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
WHERE DIM_MODEL.IDManufacturer IN (
select TOP 5 
DIM_MODEL.IDMANUFACTURER
FROM DIM_MODEL left join FACT_TRANSACTIONS on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
left join DIM_MANUFACTURER on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDModel
group by DIM_MODEL.IDMANUFACTURER 
order by SUM(Quantity) DESC)
GROUP BY FACT_TRANSACTIONS.IDModel, DIM_MODEL.IDManufacturer



--Q6.List the names of the customers and the average amount spent in 2009, 
where the average is higher than 500  
SELECT Customer_Name, AVG(TOTALPRICE) AS AMOUNT_SPENT FROM DIM_CUSTOMER
INNER JOIN FACT_TRANSACTIONS ON DIM_CUSTOMER.IDCustomer = FACT_TRANSACTIONS.IDCustomer
WHERE YEAR(DATE) = 2009 
GROUP BY Customer_Name
HAVING AVG(TOTALPRICE) >500



--Q7.List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010.
SELECT DIM_MODEL.* FROM (
SELECT * FROM (
SELECT top 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR(DATE) = 2008
GROUP BY IDModel
ORDER BY SUM(QUANTITY) DESC ) AS A
INTERSECT
SELECT * FROM (
SELECT top 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR(DATE) = 2009
GROUP BY IDModel
ORDER BY SUM(QUANTITY) DESC ) AS B
INTERSECT
SELECT * FROM (
SELECT top 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR(DATE) = 2010
GROUP BY IDModel
ORDER BY SUM(QUANTITY) DESC ) AS C
) AS ABC INNER JOIN DIM_MODEL ON ABC.IDModel = DIM_MODEL.IDModel



--Q8.Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010. 
SELECT Year, Manufacturer_Name from (
SELECT YEAR(Date) as Year, Manufacturer_Name, ROW_NUMBER() OVER (ORDER BY SUM(TOTALPRICE) DESC) AS RNUM
FROM FACT_TRANSACTIONS INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
WHERE YEAR(DATE) = 2009
GROUP BY Manufacturer_Name, YEAR(Date)
) AS TBL1 where RNUM = 2
union all
SELECT Year, Manufacturer_Name from (
SELECT YEAR(Date) as Year, Manufacturer_Name, ROW_NUMBER() OVER (ORDER BY SUM(TOTALPRICE) DESC) AS RNUM
FROM FACT_TRANSACTIONS INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
WHERE YEAR(DATE) = 2010
GROUP BY Manufacturer_Name, YEAR(Date)
) AS TBL1 where RNUM = 2



--Q9.Show the manufacturers that sold cellphones in 2010 but did not in 2009.
select Manufacturer_Name
from FACT_TRANSACTIONS 
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
left join DIM_MANUFACTURER on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
where YEAR(date) = 2010 and Manufacturer_Name not in (
select Manufacturer_Name from FACT_TRANSACTIONS 
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
left join DIM_MANUFACTURER on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
where YEAR(date) = 2009)



--Q10.Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend. 
select top 100 Customer_Name, AVG_Qty, Year, AVG_Price,  difference_value/Previous_Value*100 as [% change] from 
(
select
Customer_Name, AVG(totalprice) as AVG_Price, AVG(Quantity) as AVG_Qty, YEAR(date) as Year,
lag(avg(totalprice)) over (partition by Customer_Name order by YEAR(date) ) as Previous_Value,
 avg(totalprice) - (lag(avg(totalprice)) over (partition by Customer_Name order by YEAR(date) )) as difference_value
from DIM_CUSTOMER
inner join FACT_TRANSACTIONS on DIM_CUSTOMER.IDCustomer = FACT_TRANSACTIONS.IDCustomer
group by Customer_Name, YEAR(date)
) as TBL1
order by 2 desc, 4 desc
