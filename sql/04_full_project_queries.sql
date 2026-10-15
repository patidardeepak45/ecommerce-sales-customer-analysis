CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;
select count(*) from customers;
select count(*) from products;
select count(*) from orders;
select count(*) from order_items;
select * from customers LIMIT 5;
select * from products LIMIT 5;
select * from orders LIMIT 5;
select * from order_items LIMIT 5;

-- What is the total revenue from completed orders
SELECT order_status,COUNT(*) FROM orders group by order_status;

-- What is the total revenue from completed orders
select sum(oi.quantity*p.price) 
from orders o 
join order_items oi 
on oi.order_id=o.order_id 
join products p 
on oi.product_id=p.product_id 
where o.order_status='Completed';

-- Total revenue by category
select p.category,sum(oi.quantity*p.price) as total_revenue
from orders o 
join order_items oi
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id
where o.order_status='Completed'
group by p.category;

-- Top 10 customers by total revenue from completed orders.
select c.customer_id,c.customer_name,sum(oi.quantity*p.price) as total_revenue
from orders o
join order_items oi
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id
join customers c
on o.customer_id=c.customer_id 
where o.order_status='Completed'
group by c.customer_id,c.customer_name 
order by sum(oi.quantity*p.price) desc
limit 10;

-- Find the monthly revenue from completed orders.
select date_format(o.order_date,'%YY-%mm'),sum(oi.quantity*p.price) as total_revenue
from orders o
join order_items oi
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id
join customers c
on o.customer_id=c.customer_id 
where o.order_status='Completed'
group by date_format(o.order_date,'%YY-%mm');

-- Find the Top 5 products by total quantity sold from completed orders.
select p.product_id,p.product_name,sum(oi.quantity) as total_quantity
from orders o
join order_items oi
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id
join customers c
on o.customer_id=c.customer_id 
where o.order_status='Completed'
group by p.product_id,p.product_name
order by sum(oi.quantity) desc
limit 5;

-- option 2 
with cte as (select p.product_id,p.product_name,sum(oi.quantity) as total_quantity
from orders o
join order_items oi
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id
join customers c
on o.customer_id=c.customer_id 
where o.order_status='Completed'
group by p.product_id,p.product_name),
cte1 as(select *,dense_rank() over (order by total_quantity desc)as rnk from cte)
select * from cte1 where rnk<=5;

-- Top 5 products by total revenue from completed orders
select p.product_id,p.product_name,sum(oi.quantity*p.price) as total_revenue
from orders o
join order_items oi
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id
join customers c
on o.customer_id=c.customer_id 
where o.order_status='Completed'
group by p.product_id,p.product_name
order by sum(oi.quantity*p.price) desc
limit 5;

-- Find customers who have never placed a completed order
select c.customer_id,c.customer_name,o.customer_id
from customers c
left join orders o  
on c.customer_id=o.customer_id
where o.customer_id is null;

-- option 2
select c.customer_id,c.customer_name
from customers c where not exists(select 1 from orders o where o.customer_id=c.customer_id);

-- Find customers who have placed orders, but have NOT placed any completed order.
select c.customer_id,c.customer_name
from customers c where not exists(select 1 from orders o where o.customer_id=c.customer_id and o.order_status='Completed');

-- Find the top 3 customers from each city based on total completed-order revenue.
with cte as (select c.customer_id,c.customer_name,c.city,sum(oi.quantity*p.price) as total_revenue
from customers c
join orders o 
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by c.city,c.customer_id,c.customer_name),
cte1 as(select *,dense_rank() over (partition by city order by total_revenue desc) as rnk from cte)
select * from cte1 where rnk<=3;

-- Find the month-wise number of unique customers who placed completed orders.
select date_format(o.order_date,'%y-%m') as months,count(distinct c.customer_id) as number_of_customer
from customers c
join orders o
on c.customer_id=o.customer_id
where o.order_status='Completed'
group by date_format(o.order_date,'%y-%m')
order by date_format(o.order_date,'%y-%m');

-- Find customers who placed a completed order in both 2025 and 2026.
select c.customer_id,c.customer_name,COUNT(DISTINCT YEAR(order_date))
from customers c
join orders o
on c.customer_id=o.customer_id
where o.order_status='Completed'  AND YEAR(o.order_date) IN (2025, 2026)
group by c.customer_id,c.customer_name
having COUNT(DISTINCT YEAR(order_date))=2;

-- Find the average order value for completed orders.
select round(sum(oi.quantity*p.price)/COUNT(DISTINCT o.order_id),2) as total_revenue 
from order_items oi
join products p
on oi.product_id=p.product_id 
join orders o 
on o.order_id=oi.order_id
where o.order_status='Completed';

-- Find the top 5 customers based on their total completed-order revenue.
select c.customer_id,c.customer_name,round(sum(oi.quantity*p.price),1) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on o.order_id=oi.order_id
join products p
on oi.product_id=p.product_id
where o.order_status='Completed'
group by c.customer_id,c.customer_name
order by sum(oi.quantity*p.price) desc
limit 5;

-- Find the customer who has placed the highest number of completed orders.
select c.customer_id,c.customer_name,count(o.order_id)
from customers c
join orders o
on c.customer_id=o.customer_id
where o.order_status='Completed'
group by c.customer_id,c.customer_name
order by count(o.order_id) desc
limit 1;

-- Find the customer who has spent the most money on completed orders.
select c.customer_id,c.customer_name,sum(oi.quantity*p.price)as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by c.customer_id,c.customer_name
order by sum(oi.quantity*p.price) desc
limit 1;

-- Find customers who placed a completed order in both 2025 and 2026 and calculate their total revenue across both years.
select c.customer_id,c.customer_name,COUNT(DISTINCT YEAR(order_date)),sum(oi.quantity*p.price) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi 
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'  AND YEAR(o.order_date) IN (2025, 2026)
group by c.customer_id,c.customer_name
having COUNT(DISTINCT YEAR(order_date))=2 ;

-- Find the top 3 products by revenue in each category.
with cte as (select p.category,p.product_name,sum(oi.quantity*p.price) as total_revenue
from products p
join order_items oi
on p.product_id=oi.product_id
join orders o
on o.order_id=oi.order_id
where o.order_status='Completed'
group by p.product_name,p.category),
cte1 as (select *,dense_rank() over (partition by category order by total_revenue desc) as rnk from cte)
select * from cte1 where rnk<=3;

-- Find the second-highest spending customer in each city based on completed-order revenue.
with cte as (select c.city,c.customer_id,c.customer_name,sum(oi.quantity*p.price) as total_revenue
from customers c
join orders o 
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by c.city,c.customer_id,c.customer_name),
cte1 as(select *,dense_rank() over (partition by city order by total_revenue desc) as rnk from cte)
select * from cte1 where rnk=2;

-- Find the monthly completed-order revenue and calculate the previous month's revenue and MoM growth percentage.
with cte as (select date_format(o.order_date,'%y-%m') as months,sum(oi.quantity*p.price) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by date_format(o.order_date,'%y-%m')),
cte1 as (select *,lag(total_revenue) over (order by months) as previous_m_revenue from cte)
select *,round(((total_revenue-previous_m_revenue)*100)/nullif(previous_m_revenue,0),2) as growth_percentage from cte1 ;

-- Find the monthly completed-order revenue and calculate the cumulative/running revenue over time.
with cte as (select date_format(o.order_date,'%y-%m') as months,sum(oi.quantity*p.price) as monthly_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by date_format(o.order_date,'%y-%m'))
select *, sum(monthly_revenue) over(order by months) as running_revenue from cte;

-- Find the monthly completed-order revenue and calculate the 3-month rolling average revenue.
with cte as (select date_format(o.order_date,'%Y-%m') as months,sum(oi.quantity*p.price) as monthly_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by date_format(o.order_date,'%Y-%m'))
select *, avg(monthly_revenue) over(order by months rows between 2 preceding and current row) as running_revenue from cte;

-- Find customers who placed orders on 3 consecutive dates.
with cte as (select c.customer_name,c.customer_id,o.order_id,o.order_date ,lead(o.order_date,1) over (partition by c.customer_id order by o.order_date) as next_date,lead(o.order_date,2) over (partition by c.customer_id order by o.order_date) as next_next_date from customers c join orders o 
on c.customer_id=o.customer_id)
select distinct customer_id,customer_name from cte where datediff(next_date,order_date)=1 and  datediff(next_next_date,next_date)=1;

-- Find customers whose total completed-order revenue is greater than the average revenue across all customers.
with cte1 as (select c.customer_name,c.customer_id,o.order_status,round(sum(oi.quantity*p.price),1) as total_revenue 
from customers c join orders o 
on c.customer_id=o.customer_id 
join order_items oi 
on oi.order_id=o.order_id 
join products p 
on p.product_id=oi.product_id
where o.order_status='Completed'
group by c.customer_id,c.customer_name)
SELECT
customer_id,
customer_name,
total_revenue
FROM cte1 where total_revenue>(select avg(total_revenue) as average_customer_revenue from cte1);

-- find customers who:
-- Have placed at least one order previously.
-- Have not placed a completed order in the last 90 days.
-- Use 2026-09-23 as the reference date.

with cte as (select customer_id from customers c 
where exists
(select 1 from orders o where c.customer_id=o.customer_id)),
cte1 as (select customer_id from cte ct
where not exists
(select 1 from orders o where ct.customer_id=o.customer_id and o.order_date>=date_sub('2026-09-23',interval 90 DAY)AND o.order_date <= '2026-09-23' and o.order_status='Completed'))
select * from cte1;

-- Using our E-Commerce dataset, find the top 3 customers by total completed-order revenue in each year.
with cte as (select year(o.order_date) as years,c.customer_id,c.customer_name,sum(oi.quantity*p.price) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by year(o.order_date),c.customer_id,c.customer_name),
cte1 as (select years,customer_id,customer_name,total_revenue,dense_rank() over (partition by years order by total_revenue desc) as rnk from cte)
select * from cte1 where rnk<=3; 

-- Find the percentage contribution of each product to its category's total completed-order revenue.
with cte as (select p.category,p.product_name,sum(oi.quantity*p.price) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by p.category,p.product_name
order by p.category,total_revenue desc),
cte1 as (select category,product_name,total_revenue,sum(total_revenue) over(partition by category) as cat_total_revenue
from cte)
select *,round((total_revenue)*100/cat_total_revenue,1) from cte1;

-- Find the month-over-month (MoM) revenue growth percentage for each product category
with cte as (select date_format(o.order_date,'%Y-%m') as months,p.category,sum(oi.quantity*p.price) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by p.category,date_format(o.order_date,'%Y-%m')
order by p.category,date_format(o.order_date,'%Y-%m')),
cte1 as (select *,lag(total_revenue) over(partition by category order by category,months) as previous_revenue
from cte)
select *,(total_revenue-previous_revenue)/nullif(previous_revenue,0)*100 from cte1;

-- Find the customers whose latest order was a Completed order.
with cte as (select c.customer_id,c.customer_name,o.order_date,o.order_status,ROW_NUMBER() OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date DESC
) as rnk 
from customers c join orders o 
on c.customer_id=o.customer_id)
select * from cte where rnk=1 and order_status='Completed';

-- Find the first order placed by each customer and return:
with cte as (select c.customer_id,c.customer_name,o.order_date,o.order_status,ROW_NUMBER() OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date 
) as rnk 
from customers c join orders o 
on c.customer_id=o.customer_id)
select 	customer_id,customer_name,order_date as first_order_date,order_status as first_order_status from cte where rnk=1 ;

-- Find customers who placed more than 3 completed orders and show:
select c.customer_id,c.customer_name,o.order_status,count(DISTINCT o.order_id) as total_completed_order,sum(oi.quantity*p.price) as total_revenue 
from customers c join orders o 
on c.customer_id=o.customer_id
join order_items oi
on oi.order_id=o.order_id
join products p
on p.product_id=oi.product_id
where o.order_status='Completed'
group by c.customer_id,c.customer_name
having count(DISTINCT o.order_id)>3;

-- Find the best-selling product in each category based on total quantity sold.
with cte as(select p.category,p.product_name,sum(oi.quantity) as total_quantity,o.order_status
from products p join order_items oi 
on p.product_id=oi.product_id
join orders o
on o.order_id=oi.order_id
where o.order_status='completed'
group by p.category,p.product_name),
cte1 as (select *,dense_rank() over (partition by category order by total_quantity desc) as rnk from cte)
select * from cte1 where rnk=1;

select * from customers;
-- Find the customer who has the highest number of completed orders in each city.
with cte as (select c.city,c.customer_id,c.customer_name,o.order_status,count(distinct o.order_id) as total_complted_order
from customers c
join orders o
on c.customer_id=o.customer_id
where o.order_status='Completed'
group by c.city,c.customer_name,c.customer_id),
cte1 as ( select *,dense_rank() over (partition by city order by total_complted_order desc) as rnk from cte)
select * from cte1 where rnk=1;
