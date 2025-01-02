show databases;

use walmart_db;
-- Initial steps to go through the data.
show tables;
select * from walmart;


select count(*) from walmart;

select payment_method ,count(*) from walmart group by payment_method;

select count(*) from walmart group by payment_method;



select branch , count(*) from walmart group by Branch;

select payment_method,
count(*) as no_payments 
from walmart 
group by payment_method;

-- Business problems 

-- 1. Find the different payment methods , number of transactions and quantity sold by payment method

select payment_method, count(*) as no_payments, sum(quantity) as no_qty_sold
from walmart group by payment_method;


-- 2 Identify the highest rated category in each branch and display the branch , category and average rating
select branch , category , avg_rating
from ( 
select 
branch , category , avg(rating) as avg_rating,
RANK() over(partition by branch order by avg(rating) desc) as ranking 
from walmart 
group by branch , category) as ranked where ranking = 1;

-- 3.  Select the busiest day for each branch based on the number of transactions
Select branch , day_name , no_transactions
from (select 
branch , dayname(str_to_date(date , '%d/%m/%Y')) as day_name,
count(*) as no_transactions ,
rank() over(partition by branch order by count(*) desc) as ranking
from walmart 
group by branch , day_name) as ranked where ranking = 1;

-- 4. Calculate the total quantity of items sold per payment method

Select payment_method , sum(quantity) as total_qty_sold
from walmart group by payment_method;

-- 5. Determine the average , minimum and maximum rating of categories for each city 
Select city , category , 
min(rating) as min_rating ,
max(rating) as max_rating ,
avg(rating) as avg_rating from walmart
group by city , category ;

-- 6. Calculate the total profit of each category 

Select category , sum(unit_price * quantity * profit_margin) as total_profit
from walmart 
group by category 
order by total_profit desc;

-- 7. Determine the most common payment method for each branch 
WITH cte as (
select branch , payment_method , COUNT(*) as total_transactions,
rank() over(partition by branch order by count(*) desc) as ranking
from walmart 
group by branch , payment_method
)
select branch , payment_method as preferred_payment_method
from cte where ranking = 1;
-- or 
select branch , payment_method as preffferd_payment_method
from (
select branch , payment_method , count(*) as total_transactions , 
rank() over(partition by branch order by count(*) desc) as ranking
from walmart group by branch , payment_method) as ranked 
where ranking = 1;

-- 8. Categorize sales into Morning , Afternoon and evening shifts

select branch ,
case 
when hour(time(time)) < 12 then 'Morning'
when hour(time(time)) < 12 then 'Morning'
else 'Evening' 
END as shift ,
count(*) as num_invoices
from walmart 
group by branch , shift
order by branch , num_invoices desc ; 

-- 9. Identify the 5 branches with the highest revenue decrease ratio from last year to current year

with revenue_2022 as (
select 
branch , sum(total) as revenue 
from walmart where year(str_to_date(date, '%d/%m/%Y')) = 2022
group by branch
),
revenue_2023 as (select branch , sum(total) as revenue
from walmart where year(str_to_date(date, '%d/%m/%Y'))= 2023
group by branch)
select 
r2022.branch ,
r2022.revenue as last_year_revenue,
r2023.revenue as current_year_revenue,
Round(((r2022.revenue - r2023.revenue)/r2022.revenue)*100,2) as revenue_decrease_ratio
from revenue_2022 as r2022
join revenue_2023 as r2023
where r2022.revenue > r2023.revenue
order by revenue_decrease_ratio
limit 5;





