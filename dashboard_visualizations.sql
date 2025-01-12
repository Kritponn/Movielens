-- Dashboard Visualizations for MovieLens

-- 1. Počet hodnotení podľa času (hodina dňa)
SELECT 
    DATE_PART('hour', rated_at) AS hour_of_day,
    COUNT(*) AS total_ratings
FROM fact_ratings
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 2. Priemerné hodnotenie podľa žánru
SELECT 
    g.name AS genre_name,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM fact_ratings r
JOIN genres_movies gm ON r.movie_id = gm.movie_id
JOIN genres g ON gm.genre_id = g.id
GROUP BY g.name
ORDER BY avg_rating DESC;

-- 3. Vývoj počtu hodnotení v čase (po mesiacoch alebo rokoch)
SELECT 
    DATE_PART('year', rated_at) AS year,
    DATE_PART('month', rated_at) AS month,
    COUNT(*) AS total_ratings
FROM fact_ratings
GROUP BY year, month
ORDER BY year, month;

-- 4. Priemerné hodnotenie podľa vekovej skupiny používateľa
SELECT 
    u.age_group AS age_group,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM fact_ratings r
JOIN dim_users u ON r.user_id = u.dim_user_id
GROUP BY u.age_group
ORDER BY u.age_group;

-- 5. Najobľúbenejšie filmy (top 10) podľa priemernej známky
SELECT 
    m.title AS movie_title,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM fact_ratings r
JOIN dim_movies m ON r.movie_id = m.dim_movie_id
GROUP BY m.title
ORDER BY avg_rating DESC
LIMIT 10;
