-- Витрина: Аналитика популярности жанров кино
CREATE OR REPLACE VIEW cinema.dm_genre_analytics AS
SELECT
    m.genre AS movie_genre,
    COUNT(v.view_id) AS total_views_cnt,
    SUM(v.watched_mins) AS total_watched_mins,
    ROUND(AVG(v.watched_mins), 1) AS avg_duration_mins
FROM cinema.cinema_views v
JOIN cinema.cinema_movies m ON v.movie_id = m.movie_id
GROUP BY m.genre;
