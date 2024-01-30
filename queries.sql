INSERT INTO "--считает стоимость покупок людей старше 50
select sum(quantity*price) as amount_above_age_50
from sales s inner join products p 
on s.product_id =p.product_id 
where customer_id in 
(
select customer_id from customers where age > 50
)" (amount_above_age_50) VALUES
	 (8459367910.1900);

!!!top_10_total_income
with inc as 
(
select 	sales_person_id, round(sum(quantity*price)) as income, count(quantity) as operations
from sales s 
inner join products p on s.product_id = p.product_id
group by sales_person_id
order by income desc
)
select concat(first_name, ' ', last_name) as name, income, operations
from inc i inner join employees e on i.sales_person_id = e.employee_id
order by income desc limit 10

!!!lowest_average_income
with help1 as (
select sales_person_id, round(avg(quantity*price)) as avg_income
from sales s inner join products p on s.product_id = p.product_id 
group by sales_person_id
)
select concat(first_name, ' ', last_name) as name, avg_income
from employees e inner join help1 h on sales_person_id = employee_id
where avg_income < (select avg(price*quantity) from products p 
inner join sales s on p.product_id = s.product_id)
order by avg_income

!!!day_of_the_week_income
with sort as 
(
select sales_person_id, extract(dow from sale_date) as weekday,
round(sum(quantity*price)) as income 
from sales s 
inner join products p on s.product_id = p.product_id
group by sales_person_id, weekday
order by sales_person_id, weekday
)
select concat(first_name, ' ', last_name) as name,
case when weekday = 0 then 'monday'
when weekday = 1 then 'tuesday'
when weekday = 2 then 'wednesday'
when weekday = 3 then 'thursday'
when weekday = 4 then 'friday'
when weekday = 5 then 'saturday'
when weekday = 6 then 'sunday'
end as weekday, income
from sort s inner join employees e on sales_person_id = employee_id

!!!age_groups
select case 
	when age > 16 and age <= 25  then '16-25'
	when age > 25 and age <= 40  then '25-40'
	when age > 40  then '40+'
	end as age_category,
	count(distinct customer_id)
from customers
group by age_category 
order by age_category
count(distinct customer_id)
	
!!!customers_by_month
select to_char(sale_date, 'YYYY-MM') as date, count(distinct customer_id) as total_customers,
round(sum(quantity*price)) as income
from sales inner join products on sales.product_id = products.product_id
group by date
	
!!!special_offer
with sales1 as 
(
select s.customer_id, product_id, concat(c.first_name, ' ', c.last_name) as customer, sale_date,
concat(e.first_name, ' ', e.last_name) as seller
from sales s inner join customers c on s.customer_id = c.customer_id
inner join employees e on sales_person_id = employee_id
),
mk1 as (
select customer_id, customer, 
first_value(sale_date) over(partition by customer order by sale_date) as sale_date,
first_value(product_id) over(partition by customer order by sale_date) as product_id,
first_value(seller) over(partition by customer order by sale_date) as seller
from sales1)
select customer, sale_date, seller from mk1 m
inner join products p on p.product_id =m.product_id
where price = 0
group by customer, sale_date, m.product_id, seller, customer_id
order by customer_id


