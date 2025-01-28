select * from beauty_products
select count (*) from beauty_products

--PRODUCT PERFORMANCE ANALYSIS

--Which products have the highest ratings and the most reviews in each category?

with RankedProducts as (
select category, product_name, brand, rating, number_of_reviews,
row_number() over(partition by category order by rating desc, number_of_reviews desc) as rnk
from beauty_products
)
select category, product_name, brand, rating, number_of_reviews from RankedProducts 
where rnk = 1;

--What is the avg price of products by category, brand, and skin type?

select category, brand, skin_type, round(avg(price_usd), 2) as avg_price
from beauty_products 
group by category, brand, skin_type
order by category, brand, skin_type;

--How do cruelty-free products perform in terms of ratings and reviews compared to non-cruelty-
--free products?

select cruelty_free, round(avg(rating),2) as avg_rating, 
round(avg(number_of_reviews),2) as avg_reviews,
count(product_name) as total_products
from beauty_products
group by cruelty_free;


--CUSTOMER PREFERENCES

--Which main ingrediants are most common among high_rated products?

select main_ingrediant, count(product_name) as products
from beauty_products 
where rating >= 4.5
group by main_ingrediant order by products desc;

--What is the most popular product size for each category and target gender?
select category, target_gender, product_size as most_popular_size
from
(select category, target_gender, product_size, count(product_name) as total_products,
row_number() over(partition by category, target_gender order by count(product_name) desc) as rnk
from beauty_products
group by category, target_gender, product_size) 
where rnk = 1;

--Which brands have the most products catering to sensitive skin?

select * from 
(select brand, count(product_name) as total_products from beauty_products 
where skin_type = 'Sensitive'
group by brand order by total_products desc) 
where total_products between 80 and 100;


--MARKET TRENDS

--Which countries produced the highest-rated products?

select * from
(select country_of_origin, round(avg(rating),2) as avg_rating,
count(product_name) as total_products,
row_number() over(partition by country_of_origin order by round(avg(rating),2) desc ) as rnk
from beauty_products group by  country_of_origin) 
where rnk = 1 order by avg_rating desc;

--What are the top-rated packaging types across different skin types or target genders?

select * from
(select target_gender, skin_type, packaging_type, count(product_name), round(avg(rating),2),
row_number() over(partition by target_gender, skin_type order by round(avg(rating),2) desc) as
ranking 
from beauty_products group by target_gender, skin_type, packaging_type)
where ranking = 1;


--PRICE OPTIMIZATION

--What is the average price range for products with a rating above 4.5?

select category, min(price_usd) as min_prics, max(price_usd) as max_price,
round(avg(price_usd), 2) as avg_price
from beauty_products 
where rating > 4.5 
group by category
order by avg_price desc;

--Are higher-priced products more likely to receive higher ratings and reviews?

select case 
when price_usd <= 15 then 'Lower Price'
when price_usd > 15 and price_usd <= 75 then 'Medium Price'
when price_usd > 75 and price_usd <= 125 then 'Higher Price'
else 'Premium Price'
end as price_range,
 round(avg(rating),2) as avg_rating, sum(number_of_reviews) as total_reviews, 
 count(product_name) as total_products
from beauty_products 
group by price_range order by avg_rating, total_reviews;


--BRAND COMPARISON

--Compare the average ratings, number of reviews, and price ranges between two or more brands.

select brand, round(avg(rating),2) as avg_rating, 
sum(number_of_reviews) as total_reviews, min(price_usd) as min_price,
max(price_usd) as max_price, round(avg(price_usd),2) 
from beauty_products 
group by brand
order by brand asc;

--Which brand dominates in each category based on ratings?

select category, brand from
(select category, brand, round(avg(rating),2) as avg_rating,
sum(number_of_reviews) as total_reviews,
rank() over(partition by category order by round(avg(rating),2) desc, sum(number_of_reviews)
desc) as ranking
from beauty_products
group by category, brand) 
where ranking = 1;

--







