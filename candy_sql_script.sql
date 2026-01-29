use us_candy;
show tables;
desc candy_sales;

select order_date,
ship_date
from candy_sales;

alter table candy_sales
modify column order_date date;
UPDATE candy_sales 
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y');

SET SQL_SAFE_UPDATES = 0;

UPDATE candy_sales 
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y');

SET SQL_SAFE_UPDATES = 1;



SET SQL_SAFE_UPDATES = 0;

UPDATE candy_sales 
SET order_date = CASE 
    -- If it's already YYYY-MM-DD (has a dash at index 5), keep it
    WHEN order_date LIKE '____-__-__' THEN order_date
    -- If it's DD-MM-YYYY, convert it
    WHEN order_date LIKE '__-__-____' THEN STR_TO_DATE(order_date, '%d-%m-%Y')
    -- Otherwise, keep as is (handles NULLs or unexpected formats)
    ELSE order_date 
END;

SET SQL_SAFE_UPDATES = 1;

desc candy_sales;

SELECT order_date FROM candy_sales LIMIT 10;
ALTER TABLE candy_sales MODIFY COLUMN order_date DATE;

-- 1. Disable safe mode for this session
SET SQL_SAFE_UPDATES = 0;

-- 2. Standardize the format to YYYY-MM-DD
UPDATE candy_sales 
SET ship_date = CASE 
    WHEN ship_date LIKE '____-__-__' THEN ship_date
    WHEN ship_date LIKE '__-__-____' THEN STR_TO_DATE(ship_date, '%d-%m-%Y')
    ELSE ship_date 
END;

-- 3. Change the data type to DATE
ALTER TABLE candy_sales 
MODIFY COLUMN ship_date DATE;

-- 4. Re-enable safe mode
SET SQL_SAFE_UPDATES = 1;




use us_candy;
show tables;
-- exploring tables
select * from candy_factories;
select * from candy_products;
select * from candy_sales;
select * from candy_targets;

-- data quality and validation
-- finding duplicates
select * from candy_factories
where null;
select * from candy_products
where null;
select * from candy_sales
where null;
select * from candy_targets
where null;

-- duplicate order ids

select order_id,count(order_id)as dulpicates,
row_number() over(order by count(order_id)) as numbers
from candy_sales
group by order_id
having dulpicates >1;

-- orders with negative sales

select * from candy_sales
where sales <= 0;

-- orders with negative profit
select * from candy_sales
where gross_profit <= 0;

-- orders where order date is greater than ship date

select order_date,ship_date
from candy_sales
where ship_date < order_date;

-- data understanding
-- date range of orders

select min(order_date) as first_date,
max(order_date) as latest_date,
timestampdiff(day,min(order_date),max(order_date)) as days
from candy_sales;

-- total orders

select count(order_id) as total_orders
from candy_sales;

-- total unique orders
select count(distinct order_id) as total_orders
from candy_sales;

-- total products

select count(distinct product_id ) as total_products
from candy_sales;

ALTER TABLE candy_products 
RENAME COLUMN Division TO division;

-- division

select distinct division from candy_products;

-- regions

select distinct region from candy_sales;

-- factories

select distinct factory from candy_factories;

-- sales distributon by division

select division,sum(sales) as total_sales
from candy_sales
group by division
order by total_sales desc;
-- chocolate have the highest sales in division wise

-- sales distribution by region

select region,sum(sales) as total_sales
from candy_sales
group by region
order by total_sales desc;
-- pacific have highest sales

-- derived matrics
-- cost per unit (1.2)
select sum(cost) as total_cost,sum(units) as total_units,
 sum(cost)/sum(units) as cost_per_unit
 from candy_sales;
 
 -- profit margin (.65)
 select sum(gross_profit) as total_profit,
 sum(sales) as total_sales,
  sum(gross_profit)/sum(sales) as profit_margin
 from candy_sales;
 
 -- revenue per unit (3.66)
 select sum(sales) as total_sales,
 sum(units)as total_units,
 sum(sales)/ sum(units) as revenu_per_unit
 from candy_sales;
 
 -- shipping delays
 
 select order_date,ship_date,
 timestampdiff(day,order_date,ship_date) as delays
 from candy_sales;
 
 -- sales perfromance analysis
 -- total sales by divison
 
 select division,sum(sales) as total_sales
from candy_sales
group by division
order by total_sales desc;

-- total sales by product
select product_name,sum(sales) as sales
from candy_sales
group by product_name
order by sales desc;

-- total sales by region

select region,sum(sales) as total_sales
from candy_sales
group by region
order by total_sales desc;

-- total sales by factory
select f.factory,sum(s.sales) as sales
from candy_factories f 
left join candy_products p
on (f.factory = p.factory)
left join candy_sales s
on (p.product_id= s.product_id)
group by f.factory
order by sales desc;

-- monthly sales trend
SELECT 
    MONTHNAME(order_date) AS month_name, 
    SUM(Sales) AS total_sales 
FROM candy_sales 
GROUP BY MONTH(order_date), month_name
ORDER BY MONTH(order_date);

-- top 5 products based on sales

select 
product_name,
sum(sales) as total_sales
from candy_sales
group by product_name
order by total_sales desc
limit 5;

-- bottom 5 products based on sales

select 
product_name,
sum(sales) as total_sales
from candy_sales
group by product_name
order by total_sales asc
limit 5;

-- profitabilty analysis

-- products with high revenue and low margin

select product_name,
sum(sales) as total_sales,
sum(gross_profit) as total_profit,
sum(gross_profit)/sum(sales) as profit_margin
from candy_sales
group by product_name
order by total_sales desc,
profit_margin;

-- most profitable products
select product_name,
sum(gross_profit) as total_profit
from candy_sales
group by product_name
order by total_profit desc
limit 5;

-- least profitable products
	
select product_name,
sum(gross_profit) as total_profit
from candy_sales
group by product_name
order by total_profit asc
limit 5;

-- profit contribution by factory

select f.factory,sum(s.gross_profit) as total_profit,
  sum(s.gross_profit)  over() as gross_profit2 
from candy_factories f 
left join candy_products p
on (f.factory = p.factory)
left join candy_sales s
on (p.product_id= s.product_id)
group by f.factory
order by total_profit desc;



SELECT 
    f.factory,
    SUM(s.gross_profit) AS total_profit,
    -- Wrap the SUM in the OVER() function
    SUM(SUM(s.gross_profit)) OVER() AS grand_total_profit,
    SUM(s.gross_profit)/   SUM(SUM(s.gross_profit)) OVER() *100 as contribution
FROM candy_factories f 
LEFT JOIN candy_products p ON f.factory = p.factory 
LEFT JOIN candy_sales s ON p.product_id = s.product_id 
GROUP BY f.factory 
ORDER BY total_profit DESC;

-- profitabilty by division
select division,
sum(gross_profit) as total_profit
from candy_sales
group by division
order by total_profit desc;

-- target vs actual perfromance

SELECT 
    s.division, 
    SUM(s.sales) AS actual_sales, 
    t.target AS target_sales 
FROM candy_sales s  
LEFT JOIN candy_targets t ON s.division = t.division 
GROUP BY s.division, t.target; 

-- division missing and exceeding targets

SELECT 
    s.division, 
    SUM(s.sales) AS actual_sales, 
    t.target AS target_sales ,
     t.target-SUM(s.sales) as difference
FROM candy_sales s  
LEFT JOIN candy_targets t ON s.division = t.division 
GROUP BY s.division, t.target; 

-- operational and logical analysis

-- average shipping delays by region

select region,
timestampdiff(day,order_date,ship_date) as delays,
avg(timestampdiff(day,order_date,ship_date)) avg_delays
from candy_sales
group by 
timestampdiff(day,order_date,ship_date),
region;

-- avg delays by factories

select f.factory,
timestampdiff(day,s.order_date,s.ship_date) as delays,
avg(timestampdiff(day,s.order_date,s.ship_date)) avg_delays
from candy_factories f 
left join candy_products p 
on (f.factory = p.factory)
left join candy_sales s
on (p.product_id = s.product_id)
group by f.factory,
timestampdiff(day,s.order_date,s.ship_date);

-- advance analysis
-- rank top 3 product by profit 

select * from 
(
select product_name,
sum(gross_profit) as gross_profit,
rank() over (order by sum(gross_profit) desc) as ranked
from candy_sales
group by product_name
order by ranked)t
where ranked <=3;

-- ranking factory by profit per unit


with profit_per as 
(
select f.factory,
sum(gross_profit) as total_profit,
sum(units) as total_units,
sum(gross_profit)/sum(units) as profit_per_units
from candy_factories f
left join candy_products p
on (f.factory=p.factory)
left join candy_sales s
on (p.product_id = s.product_id)
group by f.factory
order by profit_per_units desc
)
select
factory,
profit_per_units,
rank () over(order by profit_per_units desc )as ranked
from profit_per;

-- month over month sales growth
with monthly as
(
select 
month(order_date) as month_num,
monthname(order_date ) as month_name,
sum(sales) as total_sales
from candy_sales
group by month_num,month_name
order by month_num asc) 

select
month_num,
month_name,
total_sales,
lag(total_sales,1) over(order  by month_num) as previous_sales,
total_sales -lag(total_sales,1) over(order  by month_num) as change_over_month
from monthly
order by month_num;

-- quarter wise growth

with monthly as
(
select month(order_date)as month_num,
monthname(order_date) as month_name,
sum(sales) as total_sales
from candy_sales
group by month_num,month_name
order by month_num,month_name)

select
month_num,
month_name,
total_sales,
ntile(4) over (order by month_num) as quarters
from monthly
group by month_num,month_name
order by quarters;

select division from candy_sales
group by division;

-- quarter wise sales of division

with monthly as 
(
select month(order_date) as month_num,
monthname(order_date) as month_name,
sum(sales) as total_sales,
division
from candy_sales
group by division,month_num,month_name

)

select
division,
total_sales,
ntile(4) over (partition by division order by total_sales) as quarters
from monthly
order by division,quarters;

-- key metrics report

select 'total_revenue' as measure_name ,sum(sales) as measure_value from candy_sales
union all
select 'total_units' as measure_name ,sum(units) as measure_value from candy_sales
 union all
 select'total_profit' as measure_name ,sum(gross_profit) as measure_value from candy_sales
 union all
 select 'total_cost' as measure_name ,sum(cost) as measure_value from candy_sales
 union all 
 select 'total_products' as measure_name ,count(distinct product_id) as measure_value from candy_sales
 union all
 select 'total_divison' as measure_name ,count(distinct division) as measure_value from candy_sales
 union all
 select 'total_orders' as measure_name ,count(distinct order_id) as measure_value from candy_sales
 union all
 select 'total_country' as measure_name ,count(distinct country) as measure_value from candy_sales
 union all
 select 'total_region' as measure_name ,count(distinct region) as measure_value from candy_sales
 union all 
 select 'total_factory' as measure_name ,count(distinct factory) as measure_value from candy_factories;


