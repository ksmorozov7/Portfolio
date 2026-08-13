-- 1. Таблица пользователей кинотеатра
CREATE TABLE cinema_users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    city VARCHAR(50),
    age INT,
    subscription_type VARCHAR(20), -- Free, Basic, Premium
    registration_date DATE
);

-- 2. Таблица каталога фильмов
CREATE TABLE cinema_movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(30), -- Action, Comedy, Drama, Sci-Fi
    release_year INT,
    duration_mins INT
);

-- 3. Таблица фактов просмотра (Сюда Airflow потом будет сыпать данные!)
CREATE TABLE cinema_views (
    view_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES cinema_users(user_id),
    movie_id INT REFERENCES cinema_movies(movie_id),
    view_date TIMESTAMP,
    watched_mins INT, -- сколько минут посмотрел
    device VARCHAR(20) -- Mobile, TV, Web
);

-- Зальем базовые справочники (клиентов и фильмы)
INSERT INTO cinema_users (first_name, city, age, subscription_type, registration_date) VALUES
('Алексей', 'Москва', 24, 'Basic', '2026-01-10'),
('Мария', 'Санкт-Петербург', 31, 'Premium', '2026-02-15'),
('Дмитрий', 'Новосибирск', 19, 'Free', '2026-03-01'),
('Ольга', 'Краснодар', 42, 'Premium', '2026-01-20');

INSERT INTO cinema_movies (title, genre, release_year, duration_mins) VALUES
('Интерстеллар', 'Sci-Fi', 2014, 169),
('1+1', 'Comedy', 2011, 112),
('Джентльмены', 'Action', 2019, 113),
('Зеленая миля', 'Drama', 1999, 189);
