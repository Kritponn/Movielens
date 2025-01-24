# Movielens

Tento projekt je zameraný na analýzu filmových hodnotení z datasetu MovieLens. Obsahuje podrobný popis zdrojových dát, dimenzionálneho modelu a postup ETL procesu v Snowflake.

---

## 1. Úvod a popis projektu

### 1.1 Téma projektu
Projekt MovieLens predstavuje rozsiahlu databázu filmových hodnotení vytvorených používateľmi. Obsahuje dáta o filmoch, používateľoch, ich hodnoteniach (ratings) a tagoch.

### 1.2 Účel analýzy
Cieľom je analyzovať:
- Ktoré filmy sú najviac hodnotené.
- Obľúbenosť žánrov.
- Aktivity používateľov v čase.
- Ako sa hodnotenia líšia medzi rôznymi skupinami ľudí.

---

## 2. Základný popis zdrojových tabuliek

- **Movies**
  - **Hlavné stĺpce**: `movieId`, `title`, `genres`
  - **Význam**: Obsahuje informácie o filmoch, ich názvy a žánre.

- **Ratings**
  - **Hlavné stĺpce**: `userId`, `movieId`, `rating`, `timestamp`
  - **Význam**: Uchováva hodnotenia filmov používateľmi na škále 0,5 až 5.

- **Tags**
  - **Hlavné stĺpce**: `userId`, `movieId`, `tag`, `timestamp`
  - **Význam**: Obsahuje textové popisy filmov od používateľov.

- **Users**
  - **Hlavné stĺpce**: `userId`, demografické informácie (vek, pohlavie, povolanie).
  - **Význam**: Informácie o používateľoch, ktoré umožňujú analýzu rozdielov v preferenciách.

---

## 3. Dátová architektúra

### 3.1 ERD diagram zdrojových dát
Pôvodná štruktúra datasetu zahŕňa nasledujúce vzťahy:

- **Ratings** je prepojovacia tabuľka medzi **Users** a **Movies**.
- **Tags** obdobne prepája **Users** a **Movies**.

![ERD pôvodný diagram](image.png)

---

## 4. Dimenzionálny model

Navrhnutý hviezdicový model zahŕňa dve faktové tabuľku a viaceré dimenzie.V tomto prípade sa hviezdicový model len rozšíri o dalšiu faktovu tabuľku("galaxy model").

### 4.1 Faktová tabuľka
- **fact_ratings**:
  - Kľúče: `id`, `user_id`, `movie_id`, `date_id`, `time_id`
  - Metodiky: `rating` (hodnotenie od 0,5 do 5)

### 4.2 Dimenzie
- **dim_users**: Informácie o používateľoch (vek, pohlavie, povolanie).
- **dim_movies**: Informácie o filmoch (názov, rok vydania, žánre).
- **dim_date**: Dátum hodnotenia (deň, mesiac, rok, štvrťrok).
- **dim_time**: Podrobné časové údaje (hodina, AM/PM).

![Hviezdicový model](image-1.png)

---

## 5. ETL proces v Snowflake

### 5.1 Extrakcia dát
Dáta sa importujú zo zdrojových CSV súborov (získane, extrahované do CSV pomocou PhpMyAdmin) do staging zóny pomocou príkladného príkazu:
```sql
COPY INTO movies (id, title, release_year)
FROM @MOVIELENS_MOVIELENS/movies.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
```

### 5.2 Transformácia dát
Príklad vytvorenia dimenzie **dim_users**:
```sql
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
```

### 5.3 Načítanie dát
Transformácia faktovej tabuľky **fact_ratings**:
```sql
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
```

---

## 6. Vizualizácia dát

### 6.1 Grafy

1. **Počet hodnotení podľa hodín dňa**
   - *Otázka*: Kedy sú používatelia najaktívnejší?
   - SELECT 
    DATE_PART('hour', rated_at) AS hour_of_day,
    COUNT(*) AS total_ratings
FROM fact_ratings
GROUP BY hour_of_day
ORDER BY hour_of_day;

2. **Priemerné hodnotenie podľa žánru**
   - *Otázka*: Ktoré žánre sú najobľúbenejšie?
   - SELECT 
    g.name AS genre_name,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM fact_ratings r
JOIN genres_movies gm ON r.movie_id = gm.movie_id
JOIN genres g ON gm.genre_id = g.id
GROUP BY g.name
ORDER BY avg_rating DESC;

3. **Hodnotenia v priebehu času**
   - *Otázka*: Ako sa mení počet hodnotení podľa času?
   - SELECT 
    DATE_PART('year', rated_at) AS year,
    DATE_PART('month', rated_at) AS month,
    COUNT(*) AS total_ratings
FROM fact_ratings
GROUP BY year, month
ORDER BY year, month;

4. **Priemerné hodnotenie podľa vekovej skupiny**
   - *Otázka*: Ovplyvňuje vek hodnotenie?
   - SELECT 
    u.age_group AS age_group,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM fact_ratings r
JOIN dim_users u ON r.user_id = u.dim_user_id
GROUP BY u.age_group
ORDER BY u.age_group;

5. **Top 10 najlepšie hodnotených filmov**
   - *Otázka*: Ktoré filmy sú najlepšie hodnotené?
   - SELECT 
    m.title AS movie_title,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM fact_ratings r
JOIN dim_movies m ON r.movie_id = m.dim_movie_id
GROUP BY m.title
ORDER BY avg_rating DESC
LIMIT 10;

---

**Autor:** Martin Riziky
