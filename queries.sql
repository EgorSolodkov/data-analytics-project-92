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
