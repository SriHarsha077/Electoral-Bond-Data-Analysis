use `electoralbonddata`;
/*1. Find out how much donors spent on bonds*/

select d.purchaser as Company_Names, sum(b.denomination) as Total_spent
from donordata d
left join bonddata b
on d.Unique_key = b.Unique_key
group by 1 order by 2 desc;
---------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*2. Find out total fund politicians got*/

SELECT * FROM electoralbonddata.receiverdata;
select r.partyname, sum(b.denomination) as Total_Fund
from receiverdata r
left join bonddata b
on r.unique_key = b.unique_key
group by r.partyname
order by sum(b.denomination) desc;
------------------------------------------------------------------------------------------------------------------
/*3. Find out the total amount of unaccounted money received by parties*/

select * from receiverdata where unique_key is null;

select Unique_key, AccountNum, Denomination
from receiverdata;

describe bankdata;
describe receiverdata;

select * from receiverdata where accountnum is null;
SELECT *
FROM
    receiverdata r
        LEFT JOIN
    donordata d ON r.Unique_key = d.Unique_key
        LEFT JOIN
    bonddata b ON r.Unique_key = b.Unique_key
WHERE
    d.Unique_key IS NULL;
    
---------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*4. Find year wise how much money is spend on bonds*/   

select year(d.purchasedate) as Yearly , sum(Denomination) as Total_Money_Spent
from donordata d
left join bonddata b
on  d.unique_key = b.unique_key 
group by yearly
order by Total_Money_Spent desc;

---------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*5. In which month most amount is spent on bonds*/

WITH monthly_spending AS (
    SELECT MONTHNAME(d.JournalDate) AS Month_Name, SUM(b.Denomination) AS Total_Spent
    FROM donordata d
    INNER JOIN bonddata b ON d.Unique_key = b.Unique_key
    GROUP BY Month_Name), max_spending AS (
		SELECT MAX(Total_Spent) AS max_spent
		FROM monthly_spending
)
SELECT ms.Month_Name, ms.Total_Spent
FROM monthly_spending ms
JOIN max_spending m ON ms.Total_Spent = m.max_spent;

----------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*6. Find out which company bought the highest number of bonds.*/
select distinct(denomination) from bonddata order by 1;

with ctemax as (
select d.purchaser, count(b.denomination) as No_of_Bonds
from donordata as d
left join bonddata as b
on  d.unique_key = b.unique_key
group by d.purchaser
order by No_of_Bonds desc) select * from ctemax where No_of_Bonds=(select max(No_of_Bonds) from ctemax);
-------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*7. Find out which company spent the most on electoral bonds.*/

 with ctemax as(
 select d.purchaser, sum(b.denomination) as Highly_Spent
from donordata d
join bonddata b
on d.unique_key = b.unique_key
group by d.purchaser
order by  Highly_Spent desc) select * from ctemax where Highly_Spent =(select max(Highly_Spent) from ctemax);

----------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*8. List companies which paid the least to political parties.*/
with ctemin as(
select d.purchaser, r.partyname, sum(b.denomination) Least_Paid_Amount
from donordata as d
right join receiverdata as r
on d.unique_key = r.unique_key
right join bonddata as b
on d.unique_key = b.unique_key
group by 2,1
order by 3) 
select * from ctemin 
limit 5;
  
------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*9. Which political party received the highest cash?*/

with ctemax as (
select r.partyname, sum(b.denomination) as Highest_cash
from receiverdata as r
left join bonddata as b
on r.unique_key = b.unique_key
group by r.partyname
order by Highest_cash desc) select * from ctemax where Highest_cash =(select max(Highest_cash) from ctemax);

------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*10. Which political party received the highest number of electoral bonds?*/

with ctemax as(
select Partyname,count(denomination) Highest_Received_EB
from receiverdata as r
join bonddata as b
on r.unique_key = b.unique_key
group by Partyname 
order by Highest_Received_EB desc) select * from ctemax where Highest_Received_EB =(select max(Highest_Received_EB) from ctemax);

-------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*11. Which political party received the least cash?*/

WITH party_totals AS (
    SELECT r.Partyname, SUM(b.denomination) AS Total_Cash, RANK() OVER (ORDER BY SUM(b.denomination) ASC) AS rnk
    FROM receiverdata AS r
    LEFT JOIN bonddata AS b ON r.unique_key = b.unique_key
    GROUP BY 1) SELECT Partyname, Total_Cash FROM party_totals ;


--------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*12. Which political party received the least number of electoral bonds?*/

with ctemin as(
select Partyname,count(PayBranchCode) least_Received_EB
from receiverdata
group by Partyname
order by least_Received_EB asc) select * from ctemin where least_Received_EB =(select min(least_Received_EB) from ctemin);


---------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*13. Find the 2nd highest donor in terms of amount he paid?*/

WITH donors AS (
    SELECT d.Purchaser, SUM(b.Denomination) as Total_Amount, RANK() OVER (ORDER BY SUM(b.Denomination) DESC) as rnk
    FROM donordata as d
    LEFT JOIN bonddata as b ON d.unique_key = b.unique_key
    GROUP BY d.Purchaser) SELECT Purchaser, Total_Amount FROM donors WHERE rnk = 2;
    
    
----------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*14. Find the party which received the second highest donations?*/

WITH party_donations AS (
    SELECT r.Partyname, SUM(b.denomination) as Total_Donations, DENSE_RANK() OVER (ORDER BY SUM(b.denomination) DESC) as dense_rnk
    FROM receiverdata as r
    LEFT JOIN bonddata as b ON r.unique_key = b.unique_key
    GROUP BY r.Partyname) SELECT Partyname, Total_Donations as Second_Highest_Cash FROM party_donations WHERE dense_rnk = 2;

-- --------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*15. Find the party which received the second highest number of bonds?*/

with cte_max  as (
select Partyname,count(PayBranchCode) highest_Received_EB
from receiverdata
group by Partyname
order by highest_Received_EB desc
)
select * from cte_max
where highest_Received_EB = (select max(highest_Received_EB) from cte_max  
where highest_Received_EB <(select max(highest_Received_EB)from cte_max));


-----------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*16. In which city were the most number of bonds purchased?*/ 

WITH city_bond_counts AS (
    SELECT b.City, COUNT(bd.denomination) AS Bond_Count
    FROM bankdata AS b
    LEFT JOIN receiverdata AS r ON b.branchcodeno = r.paybranchcode
    LEFT JOIN bonddata AS bd ON r.unique_key = bd.unique_key
    GROUP BY b.City
),
max_bond_count AS (
    SELECT MAX(Bond_Count) AS max_count
    FROM city_bond_counts
)
SELECT cbc.City, cbc.Bond_Count
FROM city_bond_counts cbc
WHERE cbc.Bond_Count = (SELECT max_count FROM max_bond_count);
--------------------------------------------
select city,count(*) counts from bankdata b
left join donordata d
on b.branchcodeno=d.paybranchcode
group by city
order by 2 desc;     



-----------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*17. In which city was the highest amount spent on electoral bonds?*/

WITH city_totals AS (
    SELECT b.City, SUM(bd.denomination) AS Total_Amount
    FROM bankdata AS b
    LEFT JOIN receiverdata AS r ON b.branchcodeno = r.paybranchcode
    LEFT JOIN bonddata AS bd ON r.unique_key = bd.unique_key
    GROUP BY b.City
),
max_total AS (
    SELECT MAX(Total_Amount) AS max_amount
    FROM City_totals
)
SELECT ct.City, ct.Total_Amount
FROM City_totals ct
JOIN max_total mt ON ct.Total_Amount = mt.max_amount;


------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*18. In which city were the least number of bonds purchased?*/

SELECT b.city, COUNT(bd.denomination) AS no_of_count
FROM bankdata AS b
LEFT JOIN receiverdata AS r 
ON b.branchcodeno = r.paybranchcode
LEFT JOIN bonddata AS bd 
ON r.unique_key = bd.unique_key
GROUP BY b.city
ORDER BY no_of_count ASC; 

------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*19. In which city were the most number of bonds enchased?*/

WITH city_bond_counts AS (
    SELECT b.city, COUNT(bd.denomination) AS bond_count, RANK() OVER (ORDER BY COUNT(bd.denomination) DESC) AS rnk
    FROM bankdata AS b
    LEFT JOIN receiverdata AS r ON b.branchcodeno = r.paybranchcode
    LEFT JOIN bonddata AS bd ON bd.unique_key = r.unique_key
    GROUP BY b.city) SELECT city, bond_count FROM city_bond_counts WHERE rnk = 1;


------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*20.In which city were the least number of bonds enchased?*/ 
with cte as (
SELECT b.city,count(unique_key) AS bond_count
FROM bankdata AS b
left JOIN donordata AS r 
ON b.branchcodeno = r.paybranchcode    
GROUP BY b.city
ORDER BY bond_count asc)
 select * from cte ;
--  where bond_count = (select min(bond_count) from cte);

-- 21 ans
select * from (
SELECT 
    city,count(b.unique_key) bond_count
FROM
    bankdata a
        LEFT JOIN
    donordata b ON a.branchcodeno = b.paybranchcode
    group by city 
    order by 2) as  A where bond_count=0;

-----------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*21. List the branches where no electoral bonds were bought; if none, mention it as null.*/
select * from bankdata;
SELECT bd.CITY as null_
FROM bankdata as bd
left join receiverdata as r
on bd.branchcodeno = r.paybranchcode
LEFT JOIN
    donordata d 
    ON r.Unique_key = d.Unique_key
LEFT JOIN
    bonddata b 
    ON r.Unique_key = b.Unique_key
WHERE
    d.Unique_key IS NULL
    group by bd.city;
-----------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*22. Break down how much money is spent on electoral bonds for each year.*/

select year(JournalDate) as Yearly , sum(Denomination) as Spend_On_EB
from donordata d
inner join bonddata b 
on d.Unique_key = b.Unique_key
group by year(JournalDate)
order by year(JournalDate);
-----------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*23. Break down how much money is spent on electoral bonds for each year and provide the year and the amount. Provide values
for the highest and least year and amount.*/

select year(PurchaseDate)AS YEARLY, sum(Denomination) 
from bonddata b
join donordata d
on b.Unique_key= d.Unique_key
group by year(PurchaseDate)
order by 1 desc;

  --- -- HIGEST VLUE
with cte as
(select year(PurchaseDate) , max(Denomination)  as maxmimum
from bonddata b
join donordata d
on b.Unique_key= d.Unique_key
group by 1 order by 2 desc)
select * from cte 
where  maxmimum = (select max(maxmimum)from cte);

---- -- LOWLEST
with cte as 
(select year(PurchaseDate)as Yearly  , min(Denomination)  as minimum
from bonddata b
join donordata d
on b.Unique_key= d.Unique_key
group by 1 order by 2 asc)
select * from cte 
where minimum = (select min(minimum)from cte);

with ywb as (
select year(PurchaseDate)AS YEARLY, sum(denomination) as total_denominationvalue 
from bonddata b
join donordata d
on b.Unique_key= d.Unique_key
group by year(PurchaseDate)
order by  2 desc),
rw as (select *,row_number() over() as rn from ywb),
hy as (select * from rw where rn=1),
ly as (select * from rw where rn=(select max(rn) from rw))
select concat('For year ',yearly) as foryear,total_denominationvalue  from rw
union all
select concat('Highest year ',yearly),total_denominationvalue from hy
union all 
select concat('Lowest year ',yearly),total_denominationvalue from ly;

------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*24. Find out how many donors bought the bonds but did not donate to any political party*/

select count(d.unique_key) as not_donated
from donordata as D
left join receiverdata as r
on D.unique_key = r.unique_key
where r.partyname is null;

------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*25. Find out the money that could have gone to the PM Office, assuming the above question assumption (Domain Knowledge)*/

with main_cte as (
SELECT 
	purchasedate as purchasedate_donor,
    DateEncashment as DateEncashment_party,
    DATEDIFF(DateEncashment, purchasedate),
    donordata.unique_key as donordatakey,
    receiverdata.unique_key as partykey
FROM
    donordata
        LEFT JOIN
    receiverdata ON donordata.unique_key = receiverdata.unique_key)
    , bonds as (select purchasedate_donor,donordatakey from main_cte where partykey is null),
    redirectedfund as (
    select unique_key,donordatakey,Denomination from main_cte join bonddata on main_cte.donordatakey=bonddata.unique_Key)
    select sum(denomination) as PM_OFF_fund ,count(unique_key) as noofbonds from redirectedfund;


----------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*26. Find out how many bonds don't have donors associated with them.*/
select count(a),sum(Denomination) from (
select a.unique_key as a ,b.unique_key as b ,Denomination from bonddata as a left join donordata as b 
on a.Unique_key=b.Unique_key where b.unique_key is null) as aaa;

SELECT COUNT(*) as without_donor
FROM bonddata AS b
WHERE NOT EXISTS (
    SELECT 1 
    FROM donordata AS d
    WHERE d.unique_key = b.unique_key
);
------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*27. Pay Teller is the employee ID who either created the bond or redeemed it. So find the employee ID who issued the highest
number of bonds.*/

WITH counts AS (
    SELECT PayTeller, COUNT(unique_key) as no_of_bonds_issued, ROW_NUMBER() OVER (ORDER BY COUNT(unique_key) DESC, PayTeller ASC) as rnk
    FROM donordata 
    GROUP BY PayTeller) SELECT PayTeller, no_of_bonds_issued FROM counts where no_of_bonds_Issued=(select max(no_of_bonds_issued) from counts);
    
    
------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*28. Find the employee ID who issued the least number of bonds.*/

WITH teller_counts AS (
    SELECT PayTeller, COUNT(unique_key) as employee_id, ROW_NUMBER() OVER (ORDER BY COUNT(unique_key) ASC, PayTeller ASC) as rn
    FROM donordata
    GROUP BY PayTeller) SELECT PayTeller, employee_id FROM teller_counts WHERE rn = 1;

------------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*29. Find the employee ID who assisted in redeeming or enchasing bonds the most.*/

WITH teller_totals AS (
    SELECT PayTeller, SUM(b.Denomination) as total_amount, RANK() OVER (ORDER BY SUM(b.Denomination) DESC) as rnk
    FROM donordata as o
    INNER JOIN bonddata as b ON o.Unique_key = b.Unique_key
    GROUP BY PayTeller) SELECT PayTeller, total_amount FROM teller_totals WHERE rnk = 1;
    
--------------------------------------------------------------------------------------------------------------------------------------------
use `electoralbonddata`;
/*30. Find the employee ID who assisted in redeeming or enchasing bonds the least*/

SELECT payTeller, SUM(Denomination) AS least_encashed_bonds
FROM donordata AS o
JOIN bonddata AS b ON o.Unique_key = b.Unique_key
GROUP BY payTeller
HAVING SUM(Denomination) = (
    SELECT MIN(total_bonds)
    FROM (
        SELECT SUM(Denomination) AS total_bonds
        FROM donordata AS o
        JOIN bonddata AS b ON o.Unique_key = b.Unique_key
        GROUP BY payTeller
    ) AS min_bonds
);

-----------------------------------------------------------------------------------------------------------------------------------------
 
 

 
/*1. Tell me total how many bonds are created?*/

select count(*) Total_cereated_bonds
from bonddata;

/*2. Find the count of Unique Denominations provided by SBI?*/
select count(distinct Denomination) as SBI from bonddata;

/*3. List all the unique denominations that are available?*/
 select distinct Denomination as unique_denominations
 from bonddata
 order by  unique_denominations asc;

/*4. Total money received by the bank for selling bonds*/
select sum(denomination) as selling_denominations
from bonddata as b
order by selling_denominations asc;


/*5. Find the count of bonds for each denominations that are created.*/
select distinct denomination ,count(denomination) no_of_bonds
from bonddata
group by denomination
order by denomination asc;

/*6. Find the count and Amount or Valuation of electoral bonds for each denominations.*/
select distinct denomination ,count(denomination) no_of_bonds,sum(denomination) as Valuation
from bonddata
group by denomination
order by denomination asc;

/*7. Number of unique bank branches where we can buy electoral bond?*/
select count(distinct CITY)  total_cites from bankdata;

/*8. How many companies bought electoral bonds*/
select concat('Total companies that bonds bought   ',count( distinct  Unique_key)) total_companies from donordata;

/*9. How many companies made political donations*/
select count(distinct  Purchaser) from donordata;

/*10. How many number of parties received donations*/
select count(distinct PartyName) from receiverdata;

/*11. List all the political parties that received donations*/
select distinct PartyName from receiverdata;

/*12. What is the average amount that each political party received*/
select distinct partyName,  round(avg(Denomination),1 )from receiverdata r
join bonddata b
on r.Unique_key = b.Unique_key
group by partyName;

/*13. What is the average bond value produced by bank*/
select  avg(Denomination) from bonddata b
join donordata d
on b. Unique_key = d. Unique_key;
#avg bonds value by bank
select  paybranchcode,avg(Denomination) from bonddata b
join donordata d
on b. Unique_key = d. Unique_key group by paybranchcode order by 2 desc;

/*14. List the political parties which have enchased bonds in different cities?*/
select distinct partyName ,city
from receiverdata r
join bonddata b
on r.Unique_key = b.Unique_key
join bankdata bs
on b.Unique_key = r.Unique_key
group by partyName , CITY ;

/*15. List the political parties which have enchased bonds in different cities and list the cities in which the bonds have enchased as well?*/
select distinct bd.CITY, partyname 
from receIVerdata r
left join bankdata bd
on bd.branchCodeNo = r.PayBranchCode;









