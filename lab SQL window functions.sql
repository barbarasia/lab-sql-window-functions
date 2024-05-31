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
, rank () over (partition by rating order by length) as 'rank_by_category'
from film
where length is not null
order by length;

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted 
-- in the greatest number of films, as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

with actor_popularity as(
select last_name, count(last_name) over () from actor)

select * from actor_popularity;


title
, actor_popularity.last_name
#, count(film_id) over (partition by actor_id) as film_q
from film
inner join film_actor
	using(film_id)
inner join actor
	using (actor_id)
;

