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
select 	sales_person_id, floor(sum(quantity*price)) as income, count(quantity) as operations
from sales s 
inner join products p on s.product_id = p.product_id
group by sales_person_id
order by income desc
)
select concat(first_name, ' ', last_name) as name, operations, income
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
with sort1 as (
select sales_person_id,
extract(dow from sale_date) as weekday1,
round(sum(quantity*price)) as income
from sales s
inner join products p on p.product_id = s.product_id
group by sales_person_id, weekday1
order by weekday1),
sort2 as 
(
select sales_person_id,
case when weekday1 = 0 then 6
when weekday1 = 1 then 0
when weekday1 = 2 then 1
when weekday1 = 3 then 2
when weekday1 = 4 then 3
when weekday1 = 5 then 4
when weekday1 = 6 then 5
end as weekday1, income
from sort1)
select concat(first_name, ' ', last_name) as name,
case when weekday1 = 0 then 'monday   '
when weekday1 = 1 then 'tuesday  '
when weekday1 = 2 then 'wednesday'
when weekday1 = 3 then 'thursday '
when weekday1 = 4 then 'friday   '
when weekday1 = 5 then 'saturday '
when weekday1 = 6 then 'sunday   '
end as weekday, income
from sort2 s inner join employees e on sales_person_id = employee_id
order by weekday1, name


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
with sort1 as (
select customer_id, first_value(product_id) over(partition by customer_id order by sale_date) as first_product,
first_value(sales_person_id) over(partition by customer_id order by sale_date) as first_emplyee,
first_value(sale_date) over(partition by customer_id order by sale_date) as first_sale
from sales s),
sort2 as (
select customer_id, min(first_product) as first_product, min(first_emplyee) as first_employee,
min(first_sale) as sale_date
from sort1
group by customer_id),
sort3 as 
(
select customer_id, first_product, first_employee, sale_date
from sort2 s2 inner join products p on s2.first_product = p.product_id
where price = 0)
select concat(c.first_name, ' ', c.last_name) as customer,
sale_date,
concat(e.first_name, ' ', e.last_name) as seller
from sort3 s inner join customers c on c.customer_id = s.customer_id
inner join employees e on first_employee = employee_id


