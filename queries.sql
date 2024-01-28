INSERT INTO "--считает стоимость покупок людей старше 50
select sum(quantity*price) as amount_above_age_50
from sales s inner join products p 
on s.product_id =p.product_id 
where customer_id in 
(
select customer_id from customers where age > 50
)" (amount_above_age_50) VALUES
	 (8459367910.1900);
