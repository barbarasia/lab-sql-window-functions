-- Challenge 1
-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 

-- You will use it to rank films by their length, their length within the rating category, and by the actor or actress 
-- who has acted in the greatest number of films.

-- Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

select title, length
, rank () over (order by length) as 'length_rank'
from film
where length is not null
order by length;

-- Rank films by length within the rating category and create an output table that includes the title, 
-- length, rating and rank columns only. Filter out any rows with null or zero values in the length column.

select title, length, rating
, rank () over (partition by rating order by length desc) as 'rank_by_category'
from film
where length is not null
order by length desc;

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted 
-- in the greatest number of films, as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.


#too hard, I asked chat GPT to do it


WITH ActorPopularity AS (
    SELECT 
        actor.actor_id,
        actor.last_name,
        COUNT(film_actor.film_id) AS film_count
    FROM 
        actor
    INNER JOIN 
        film_actor ON actor.actor_id = film_actor.actor_id
    GROUP BY 
        actor.actor_id, actor.last_name
),
FilmActorPopularity AS (
    SELECT 
        film.film_id,
        film.title,
        film_actor.actor_id,
        ActorPopularity.last_name,
        ActorPopularity.film_count,
        ROW_NUMBER() OVER (PARTITION BY film.film_id ORDER BY ActorPopularity.film_count DESC) AS row_num
    FROM 
        film
    INNER JOIN 
        film_actor ON film.film_id = film_actor.film_id
    INNER JOIN 
        ActorPopularity ON film_actor.actor_id = ActorPopularity.actor_id
)
SELECT 
    title,
    last_name AS most_popular_actor,
    film_count AS total_films_acted_in
FROM 
    FilmActorPopularity
WHERE 
    row_num = 1
ORDER BY 
    title;


-- This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. 
-- By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer 
-- retention and increase revenue.

-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an 
-- analysis on the monthly percentage change in the number of active customers and the number of retained customers. 
-- Use the Sakila database and progressively build queries to achieve the desired outcome.

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

select month(rental_date) as rental_month, count(distinct customer_id) rental_by_month
from rental
inner join customer
	using(customer_id)
group by month(rental_date);


-- Step 2. Retrieve the number of active users in the previous month.

select 
month(rental_date) as rental_month
, count(distinct customer_id) rental_by_month
, lag(count(distinct customer_id)) over () as previous_count
from rental
inner join customer
	using(customer_id)
group by month(rental_date);


-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.

select 
month(rental_date) as rental_month
, count(distinct customer_id) rental_by_month
, lag(count(distinct customer_id)) over () as previous_count
, (count(distinct customer_id) - lag(count(distinct customer_id)) over ())/count(distinct customer_id) as difference
from rental
inner join customer
	using(customer_id)
group by month(rental_date);





-- Step 1: Extract rental data with month and customer information
WITH rental_months AS (
    SELECT 
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM 
        rental
    GROUP BY 
        customer_id, rental_month
),

-- Step 2: Aggregate customers by month
monthly_customers AS (
    SELECT 
        rental_month,
        GROUP_CONCAT(DISTINCT customer_id) AS customer_list
    FROM 
        rental_months
    GROUP BY 
        rental_month
),

-- Step 3: Use LAG() to get the previous month's customer list
customer_comparison AS (
    SELECT 
        rental_month,
        customer_list,
        LAG(customer_list) OVER (ORDER BY rental_month) AS previous_month_customers
    FROM 
        monthly_customers
);

-- Step 4: Identify retained customers by comparing current and previous month lists

WITH month_info as (
SELECT 
month(rental_date) as rental_month,
customer_id 
FROM sakila.rental
) ,
 prev_month AS (
SELECT 
rental_month,
customer_id, 
LAG(rental_month) OVER (partition by customer_id) as previous_month
FROM month_info  
)
SELECT
    COUNT(DISTINCT customer_id) AS active_customers
FROM prev_month
WHERE previous_month IS NOT NULL;




WITH rental_months AS (
    SELECT 
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m-01') AS rental_month
    FROM 
        rental
    GROUP BY 
        customer_id, rental_month
)
, recurring as (
	select rental_month
    , rental_month = date_add(lag (rental_month) over (partition by customer_id order by rental_month), interval 1 MONTH) as is_recurring
    from rental_months
)

select rental_month, sum(is_recurring), count(*)
from recurring
group by rental_month;



