drop table if exists netflix;

create table netflix 
(
	show_id	 varchar(6),
	type	varchar(10),
	title	varchar(150),
	director  varchar(208),
	casts   varchar(1000),
	country  varchar(150),
	date_added   varchar(50),
	release_year  int,
	rating   varchar(10),
	duration  varchar(15),
	listed_in  varchar(100),
	description  varchar(250)

);


COPY netflix FROM 'C:\\Users\\madis\\OneDrive\\Desktop\\Netflix dataset\\netflix_titles.csv'
DELIMITER ',' CSV HEADER;

--To find the total number of rows in the data
select count(*) as total_data from netflix;

--To find the different types in the types column
select distinct type from netflix;

-- (15 Business Problems & Solutions)

--1. Count the number of Movies vs TV Shows
select 
   type, count(*) as total_content
from netflix
GROUP BY type;

--2. Find the most common rating for movies and TV shows
select
type, rating
from
(select type, rating, count(*),
rank()over(partition by type order by count(*) desc) as ranking
from netflix
group by type, rating) as t1
where ranking = 1;


--3. List all movies released in a specific year (e.g., 2020)
select * 
from netflix
where release_year = 2020 and type = 'Movie';

--4. Find the top 5 countries with the most content on Netflix
select 
unnest(string_to_array(country, ',')) as new_country,
count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;

--5. Identify the longest movie
select *
from netflix
where type = 'Movie' and duration = (select max(duration) from netflix);

-- 6. Find content added in the last 5 years
select 
*
from netflix
where 
To_date(date_added, 'Month DD, YYYY') >= current_date - INTERVAL '5 years';


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * 
from netflix
--where director = 'Rajiv Chilaka'
where director like '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
select * from netflix
where
   type = 'TV Show'
   and
   split_part(duration, ' ', 1):: numeric > 5;

-- 9. Count the number of content items in each genre
select 
unnest(string_to_array(listed_in, ',')) as genre,
count(show_id) as total_content
from netflix
group by 1;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
select
extract(Year from To_date(date_added, 'Month DD, YYYY')) as year,
count(*) as yearly_content,
round(count(*):: numeric/(select count(*) from netflix where country = 'India'):: numeric *100, 2) as avg_content
from netflix
where country = 'India'
group by 1;

-- 11. List all movies that are documentaries
select *
from netflix
where listed_in like '%Documentaries%';

-- 12. Find all content without a director
select * 
from netflix
where director isnull;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select 
*
from netflix
where casts like '%Salman Khan%'
and
release_year > extract(year from current_date)-10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
unnest(string_to_array(casts, ',')),
count(*) as total_content
from netflix
where country = 'India'
group by 1
order by 2 desc
limit 10;

/* 15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

with new_table as (
select *,
case
when
    description ILIKE '%kill%'
	or
	description ILIKE '%violence%' then 'Bad_content'
	else 'Good_content'
end category
from netflix
)
select category,
count(*) as total_content
from new_table
group by 1;



