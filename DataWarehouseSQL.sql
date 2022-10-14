drop view additional_person_info
select * from person_economic_info
select * from education_codes
select * from states

create view additional_person_info as
select s.us_state_terr, em.category_description, ed.education_level_achieved, p.*

from person_economic_info p
join states s on p.address_state=s.numeric_id
join employment_categories em on p.employment_category=em.employment_category
join education_codes ed on p.education =ed.code

--select count(*) from person_economic_info
select * from additional_person_info a

---2.Using a single aggregate query to select from the 
--additional_person_info view which
--shows states where there is no one who owns a 
--personal computer.

select us_state_terr
  from additional_person_info 
  group by us_state_terr having sum(own_computer)=0


-- 3.With one query, show each state’s aggregates (result should have four columns and one row for each state).  --Use a CUBE to show 
--subtotals by education level for each state (each state will be grouped together).
--a.	People responding
--b.	Number of people who own computer 
--c.	Average income 

--select own_computer from additional_person_info a
--select * from person_economic_info 

select us_state_terr, education_level_achieved, --own_computer, income
count(internet) people_reported,
avg(income) average_income,
sum(own_computer) #people_own_computer,
count(education) subtotal_educ_level
from additional_person_info
group by
rollup(us_state_terr, education_level_achieved)
order by us_state_terr desc

--4.Use the query above to show each state’s rank for (result should have four columns and one row for each state). 
--Order the result by the ranking of your choice.  There is no need to CUBE the results
--a.	People responding
--b.	Number of people who own computer
--c.	Average income

--select * from additional_person_info 

select us_state_terr, --own_computer, income
--avg(income) average_income,
RANK() OVER (ORDER BY avg(income)DESC ) as RANK_avg_income,
--sum(own_computer) #people_own_computer,
rank() over ( ORDER BY sum(own_computer) desc) as RANK_#people_own_computer,
rank() over ( ORDER BY count(internet) desc) as RANK_#people_responding
from additional_person_info
group by us_state_terr
order by RANK_avg_income desc


--5.We want to look at statistics of states where there is at least one person using a computer.  Using a single query select from the additional_person_info view: For each state, give the following summary information (result should have seven columns and one row for each state).  
--a.	Number of people reported
--b.	Number of people who use the internet – Hint:  review distinct values here, there will be a bit of transformation that you will need to do, look at case statements
--c.    Number of people who own a personal computer
--d.	Highest income (format as currency) 
--e.	Average income (format as currency)
--f.	This is the challenging part: Of the people who own a personal computer, calculate percentage of people who have a dedicated internet connection rather than dial-up (internet column).   

select us_state_terr, --internet, own_computer, high income, avg_income,
count(us_state_terr) people_reported,
sum(internet) internet,
sum(own_computer) own_computer,
format(max(income),'C') highest,
format (avg(income), 'C') average_income,
cast (sum(case when internet > 0 and own_computer > 0 then 1 else 0 end) as decimal)/sum(case when own_computer>=1 then 1 else 0 end) internet_pct
--cast(sum(internet) over (partition by own_computer) as decimal)/sum(own_computer) percent_own_comp
from additional_person_info a 
group by us_state_terr having sum(own_computer) >=1

--6.	For each state AND education level, give the same information (result should have seven columns and two rows for each state).   

select us_state_terr, education_level_achieved, --own_computer, income
count(us_state_terr) people_reported,
sum(internet) internet,
sum(own_computer) own_computer,
format(max(income),'C') highest,
format (avg(income), 'C') average_income,
case when sum(own_computer)=0 then 0 else cast (sum(case when internet > 0 and own_computer > 0 then 1 else 0 end) as decimal)/sum(case when own_computer>=1 then 1 else 0 end) end internet_pct
from additional_person_info a 
group by
rollup(us_state_terr, education_level_achieved)
order by us_state_terr desc

--7.	Extra credit (3 points): Implement a query using Lag/Lead or Pivot.  In a single sentence explain what you are trying to accomplish.
--select * from additional_person_info

select us_state_terr,age,income_category,
lag(age) over (order by income_category) as old_age,
lead(age) over (order by income_category) as next_age
from additional_person_info
