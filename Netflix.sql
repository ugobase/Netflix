/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [id]
      ,[title]
      ,[type]
      ,[description]
      ,[release_year]
      ,[age_certification]
      ,[runtime]
      ,[genres]
      ,[production_countries]
      ,[seasons]
      ,[imdb_id]
      ,[imdb_score]
      ,[imdb_votes]
      ,[tmdb_popularity]
      ,[tmdb_score]
  FROM [Netflix].[dbo].[titles$]

SELECT *
FROM [Netflix].[dbo].[titles$]

/** 1.	How many movies are there on Netflix? **/
SELECT COUNT(type) AS movies
FROM (SELECT type
FROM [Netflix].[dbo].[titles$]
WHERE type = 'MOVIE')e

SELECT COUNT (type) AS movies
FROM [Netflix].[dbo].[titles$]
WHERE type = 'MOVIE'

WITH UGO AS (SELECT *, DENSE_RANK() OVER(ORDER BY movies) AS rnk
FROM (SELECT COUNT(type) AS movies
FROM [Netflix].[dbo].[titles$]
WHERE type = 'MOVIE')e)
SELECT *
FROM UGO

WITH UGO AS (SELECT COUNT(type) AS movies
FROM [Netflix].[dbo].[titles$]
WHERE type = 'MOVIE'),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY movies) AS rnk
FROM UGO)
SELECT *
FROM BASE


/** 2.	How many actors acted in each movie? **/
SELECT COUNT(DISTINCT(character)) AS count_actors, title,role
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE type = 'MOVIE'
GROUP BY title,role
HAVING role = 'ACTOR'
ORDER BY count_actors

SELECT COUNT(character) AS count_actors, title,role
FROM(SELECT DISTINCT character, title, role
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE type = 'MOVIE')e
GROUP BY title,role
HAVING role = 'ACTOR'
ORDER BY count_actors DESC


WITH UGO AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_actors DESC) AS rnk
FROM (SELECT COUNT(DISTINCT(character)) AS count_actors, title,role
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE type = 'MOVIE'
GROUP BY title,role
HAVING role = 'ACTOR')e)
SELECT *
FROM UGO

WITH UGO AS (SELECT COUNT(DISTINCT(character)) AS count_actors, title,role
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE type = 'MOVIE'
GROUP BY title,role
HAVING role = 'ACTOR'),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_actors DESC) AS rnk
FROM UGO)
SELECT *
FROM BASE

/** 3.	In what year was the most movies released? **/
SELECT *, DENSE_RANK() OVER(ORDER BY count_title DESC) AS rnk
FROM(SELECT COUNT(DISTINCT(title)) AS count_title, release_year
FROM [Netflix].[dbo].[titles$]
WHERE type = 'MOVIE'
GROUP BY release_year)e


WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY count_title DESC) AS rnk
FROM(SELECT COUNT(DISTINCT(title)) AS count_title, release_year
FROM [Netflix].[dbo].[titles$]
WHERE type = 'MOVIE'
GROUP BY release_year)e)
SELECT *
FROM UGO
WHERE rnk = 1

WITH UGO AS (SELECT COUNT(DISTINCT(title)) AS count_title, release_year
FROM [Netflix].[dbo].[titles$]
WHERE type = 'MOVIE'
GROUP BY release_year),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_title DESC) AS rnk
FROM UGO)
SELECT *
FROM BASE
WHERE rnk = 1


/** 4.	Which actor has the most feature in both movies and shows **/
WITH UGO AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_title DESC) AS rnk
FROM(SELECT name, type, COUNT(T.id) AS count_title, character
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE type = 'MOVIE'
GROUP BY character, type, name
HAVING character != 'NULL')e)
SELECT *
FROM UGO
WHERE rnk = 1

WITH UGO AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_title DESC) AS rnk
FROM(SELECT name, type, COUNT(T.id) AS count_title, character
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE type = 'SHOW'
GROUP BY character, type, name
HAVING character != 'NULL')e)
SELECT *
FROM UGO
WHERE rnk = 1

/** 5.	Fetch the years that have the most and least genre released **/
WITH UGO AS (SELECT release_year, COUNT(DISTINCT(genres)) AS count_genre
FROM [Netflix].[dbo].[titles$]
GROUP BY release_year)
SELECT DISTINCT CONCAT(first_value(release_year) OVER(ORDER BY count_genre DESC), ' = ', first_value(count_genre) OVER(ORDER BY count_genre DESC)) AS highest_year,
CONCAT(first_value(release_year) OVER(ORDER BY count_genre ASC), ' = ', first_value(count_genre) OVER(ORDER BY count_genre ASC)) AS least_year
FROM UGO

/** 6. 	What is the ratio of Movie to shows on Netflix? **/
WITH UGO AS (SELECT COUNT(type) AS count_movies
FROM [Netflix].[dbo].[titles$]
WHERE type ='MOVIE'),
BASE AS (SELECT COUNT(type) AS count_shows
FROM [Netflix].[dbo].[titles$]
WHERE type ='SHOW')
SELECT DISTINCT CONCAT('1:',CAST(ROUND(count_movies/CAST(count_shows AS decimal(9,4)),2)AS float))AS Ratio
FROM UGO,BASE

/** 7.	List the top 3 movies with the most actors **/
WITH UGO AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_id DESC) AS rnk
FROM(SELECT COUNT(T.id) AS count_id, title
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS N
ON T.id = N.id
WHERE character!= 'NULL'
GROUP BY title)e)
SELECT *
FROM UGO
WHERE rnk <=3
ORDER BY count_id DESC

WITH UGO AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_character DESC) AS rnk
FROM(SELECT COUNT(character) AS count_character, title
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS N
ON T.id = N.id
WHERE character!= 'NULL' AND role!= 'DIRECTOR'
GROUP BY title)e)
SELECT *
FROM UGO
WHERE rnk <=3
ORDER BY count_character DESC

/** 8.	Fetch the movies that have the most IMDB score and most IMDB votes **/
WITH UGO AS (SELECT COUNT(DISTINCT(imdb_score)) AS count_imdb_score,COUNT(DISTINCT(imdb_votes)) AS count_imdb_vote, type
FROM [Netflix].[dbo].[titles$]
GROUP BY type)
SELECT DISTINCT CONCAT(first_value(type) OVER(ORDER BY count_imdb_vote DESC), ' = ', first_value(count_imdb_vote) OVER(ORDER BY count_imdb_vote DESC)) AS highest_imdb_vote,
CONCAT(first_value(type) OVER(ORDER BY count_imdb_score DESC), ' = ', first_value(count_imdb_score) OVER(ORDER BY count_imdb_score DESC)) AS highest_imdb_score
FROM UGO


/** 9.	List all movies that have comedy listed in their genre **/
SELECT id, title, genres, release_year, COUNT(type) AS count_type
FROM [Netflix].[dbo].[titles$]
WHERE genres LIKE '%comedy%'
GROUP BY genres, release_year, id, title
HAVING id LIKE '%tm%'
ORDER BY release_year DESC

/** 10.	How many movies has Robert De Niro been casted in? **/
SELECT *, DENSE_RANK() OVER(ORDER BY number_of_movies) AS rnk
FROM(SELECT name, COUNT(T.id) AS number_of_movies
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE name = 'Robert De Niro'
GROUP BY name)e


WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY number_of_movies) AS rnk
FROM(SELECT name, COUNT(T.id) AS number_of_movies
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE name = 'Robert De Niro'
GROUP BY name)e)
SELECT *
FROM UGO

/** 11.	Identify the number actors that has only acted in one movie **/
WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY number_of_movies) AS rnk
FROM(SELECT name, COUNT(T.id) AS number_of_movies
FROM [Netflix].[dbo].[titles$] AS T
JOIN [Netflix].[dbo].[credits$] AS C
ON T.id = C.id
WHERE type = 'MOVIE'
GROUP BY name)e)
SELECT name, number_of_movies
FROM UGO
WHERE rnk = 1

