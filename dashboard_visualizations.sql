CREATE DATABASE movielens_Stork;
USE DATABASE movielens_Stork;

CREATE STAGE movielens_movielens;

CREATE TABLE age_group (
    id INT NOT NULL PRIMARY KEY, 
    name VARCHAR NULL 
);

CREATE TABLE genres (
    id INT NOT NULL PRIMARY KEY, 
    name VARCHAR NULL 
);

CREATE TABLE genres_movies (
    id INT NOT NULL PRIMARY KEY,
    genre_id INT NULL,
    movie_id INT NULL,
    CONSTRAINT genre_movies_idx FOREIGN KEY (genre_id) REFERENCES genres(id),
    CONSTRAINT movie_genres_idx FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE TABLE movies (
    id INT NOT NULL PRIMARY KEY,
    release_year CHAR(4),
    title VARCHAR(255)
);
SELECT * FROM movies LIMIT 10;--(testt)

CREATE TABLE occupations (
    id INT NOT NULL PRIMARY KEY, 
    name VARCHAR NULL 
);

CREATE TABLE ratings (
    id INT NOT NULL PRIMARY KEY, 
    movie_id INT NULL, 
    rated_at DATETIME NULL,
    rating INT NULL, 
    user_id INT NULL, 
    CONSTRAINT ratings_movie_fk FOREIGN KEY (movie_id) REFERENCES movies(id),
    CONSTRAINT ratings_user_fk FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE tags (
    id INT NOT NULL PRIMARY KEY, 
    created_at DATETIME NULL, 
    movie_id INT NULL, 
    tags VARCHAR NULL, 
    user_id INT NULL, 
    CONSTRAINT tags_movie_fk FOREIGN KEY (movie_id) REFERENCES movies(id),
    CONSTRAINT tags_user_fk FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE users (
    id INT NOT NULL PRIMARY KEY,
    age INT,
    gender CHAR(1),
    occupation_id INT,
    zip_code VARCHAR
);

ALTER TABLE users
ADD CONSTRAINT user_age_fk FOREIGN KEY (age) REFERENCES age_group(id);

ALTER TABLE users
ADD CONSTRAINT user_occupation_fk FOREIGN KEY (occupation_id) REFERENCES occupations(id);

COPY INTO movies (id, title, release_year)
FROM @MOVIELENS_MOVIELENS/movies.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
SELECT * FROM movies LIMIT 10;

COPY INTO users (id, age, gender, occupation_id, zip_code)
FROM @MOVIELENS_MOVIELENS/users.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
SELECT * FROM users LIMIT 10;

COPY INTO genres (id, name)
FROM @MOVIELENS_MOVIELENS/genres.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
SELECT * FROM genres LIMIT 10;

COPY INTO ratings (id, user_id, movie_id, rating, rated_at)
FROM @MOVIELENS_MOVIELENS/ratings.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
SELECT * FROM ratings LIMIT 10;

COPY INTO tags (id, user_id, movie_id, tags, created_at)
FROM @MOVIELENS_MOVIELENS/tags.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
SELECT * FROM tags LIMIT 10;

COPY INTO occupations (id, name)
FROM @MOVIELENS_MOVIELENS/occupations.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
SELECT * FROM occupations LIMIT 10;

COPY INTO genres_movies (id, movie_id, genre_id)
FROM @MOVIELENS_MOVIELENS/genres_movies.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
SELECT * FROM genres_movies LIMIT 10;

COPY INTO age_group (id, name)
FROM @MOVIELENS_MOVIELENS/age_group.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
SELECT * FROM age_group LIMIT 10;

CREATE TABLE dim_users AS
SELECT DISTINCT
    u.id AS dim_user_id,
    CASE 
        WHEN u.age < 18 THEN 'Under 18'
        WHEN u.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN u.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN u.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN u.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN u.age >= 55 THEN '55+'
        ELSE 'Unknown'
    END AS age_group,
    u.gender,
    o.name AS occupation
FROM users u
LEFT JOIN occupations o ON u.occupation_id = o.id;

CREATE TABLE dim_movies AS
SELECT DISTINCT
    m.id AS dim_movie_id,
    m.title,
    m.release_year
FROM movies m;

CREATE TABLE dim_age_group AS
SELECT 
    id AS dim_age_group_id,
    name AS age_group
FROM age_group;

CREATE TABLE dim_occupations AS
SELECT 
    id AS dim_occupation_id,
    name AS occupation
FROM occupations;

CREATE TABLE fact_ratings AS
SELECT 
    r.id AS fact_rating_id,
    r.rating,
    r.rated_at AS timestamp,
    u.dim_user_id AS user_id,
    m.dim_movie_id AS movie_id
FROM ratings r
JOIN dim_users u ON r.user_id = u.dim_user_id
JOIN dim_movies m ON r.movie_id = m.dim_movie_id;
SELECT * FROM fact_ratings LIMIT 10; --(test)


DROP TABLE IF EXISTS age_group;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS genres_movies;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS occupations;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS users;

SHOW TABLES; --(test)

