USE [lw4 option 3]

-- доп. сущность: киностудия 
CREATE TABLE FilmStudio (
    id_studio INT IDENTITY(1,1) NOT NULL,
    studio_name NVARCHAR(100) NOT NULL,
    country NVARCHAR(50) NOT NULL,
    foundation_year INT NOT NULL,
    website NVARCHAR(255),
    last_contract_date DATETIME, 

    CONSTRAINT PK_FilmStudio_id_studio PRIMARY KEY (id_studio),
    CONSTRAINT CHK_FilmStudio_foundation_year CHECK (foundation_year > 1800 AND foundation_year <= YEAR(GETDATE()))
);

-- доп. сущность: зал кинотеатра
CREATE TABLE CinemaHall (
    id_hall INT IDENTITY(1,1) NOT NULL,
    hall_name NVARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    has_3d BIT NOT NULL DEFAULT 0,
    has_dolby_atmos BIT NOT NULL DEFAULT 0,
    renovation_date DATE,

    CONSTRAINT PK_CinemaHall_id_hall PRIMARY KEY (id_hall),
    CONSTRAINT CHK_CinemaHall_capacity CHECK (capacity > 0)
);

-- кинотеатр
CREATE TABLE Cinema (
    id_cinema INT IDENTITY(1,1) NOT NULL,
    cinema_name NVARCHAR(100) NOT NULL,
    [address] NVARCHAR(255) NOT NULL,
    phone_number NVARCHAR(20) NOT NULL,
    opening_hours NVARCHAR(100) NOT NULL,
    opening_date DATE NOT NULL,

    CONSTRAINT PK_Cinema_id_cinema PRIMARY KEY (id_cinema)
);

-- фильм
CREATE TABLE Movie (
    id_movie INT IDENTITY(1,1) NOT NULL,
    title NVARCHAR(100) NOT NULL,
    release_year INT NOT NULL,
    duration_minutes INT NOT NULL,
    age_rating NVARCHAR(4) NOT NULL,
    genre NVARCHAR(50) NOT NULL,
    added_to_db DATETIME NOT NULL DEFAULT GETDATE(), 

    id_studio INT NOT NULL,
    CONSTRAINT PK_Movie_id_movie PRIMARY KEY (id_movie),
    CONSTRAINT FK_Movie_id_studio FOREIGN KEY (id_studio) 
        REFERENCES FilmStudio(id_studio),
    CONSTRAINT CHK_Movie_release_year CHECK (release_year > 1888),
    CONSTRAINT CHK_Movie_duration CHECK (duration_minutes > 0)
);

-- прокат фильмов (связь кинотеатра и фильма)
CREATE TABLE MovieRental (
    id_rental INT IDENTITY(1,1) NOT NULL,
    [start_date] DATE NOT NULL,
    end_date DATE NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,
    last_updated DATETIME NOT NULL DEFAULT GETDATE(),

    id_cinema INT NOT NULL,
    id_movie INT NOT NULL,
    id_hall INT NOT NULL,
    CONSTRAINT PK_MovieRental_id_rental PRIMARY KEY (id_rental),
    CONSTRAINT FK_MovieRental_id_cinema FOREIGN KEY (id_cinema) 
        REFERENCES Cinema(id_cinema),
    CONSTRAINT FK_MovieRental_id_movie FOREIGN KEY (id_movie) 
        REFERENCES Movie(id_movie),
    CONSTRAINT FK_MovieRental_id_hall FOREIGN KEY (id_hall) 
        REFERENCES CinemaHall(id_hall),
    CONSTRAINT CHK_MovieRental_dates CHECK (end_date >= [start_date]),
    CONSTRAINT CHK_MovieRental_price CHECK (ticket_price > 0),
    CONSTRAINT UQ_MovieRental_cinema_movie_hall UNIQUE (id_cinema, id_movie, id_hall, [start_date])
);


-- рандомные данные 
INSERT INTO FilmStudio (studio_name, country, foundation_year, website, last_contract_date)
VALUES 
('Warner Bros.', 'USA', 1923, 'www.warnerbros.com', '2023-05-15 10:30:00'),
('Marvel Studios', 'USA', 1993, 'www.marvel.com', '2023-06-20 14:45:00'),
('Mosfilm', 'Russia', 1920, 'www.mosfilm.ru', '2023-04-10 09:15:00');

INSERT INTO CinemaHall (hall_name, capacity, has_3d, has_dolby_atmos, renovation_date)
VALUES 
('Зал 1', 150, 1, 1, '2022-01-15'),
('Зал 2', 200, 0, 1, '2022-03-20'),
('VIP Зал', 50, 1, 1, '2023-01-10');

INSERT INTO Cinema (cinema_name, [address], phone_number, opening_hours, opening_date)
VALUES 
('Киномакс', 'ул. Ленина, 10', '+79151234567', '10:00-23:00', '2015-05-20'),
('Синема Парк', 'ул. Гагарина, 5', '+79157654321', '09:00-00:00', '2018-11-15'),
('IMAX Киноцентр', 'пр. Мира, 12', '+79159876543', '08:00-22:00', '2020-07-10');

INSERT INTO Movie (title, release_year, duration_minutes, age_rating, genre, id_studio, added_to_db)
VALUES 
('Аватар', 2009, 162, 'PG-13', 'Фантастика', 1, '2023-01-15 12:00:00'),
('Мстители: Финал', 2019, 181, 'PG-13', 'Боевик', 2, '2023-02-20 15:30:00'),
('Иван Васильевич меняет профессию', 1973, 88, '12+', 'Комедия', 3, '2023-03-10 10:15:00');

INSERT INTO MovieRental ([start_date], end_date, ticket_price, id_cinema, id_movie, id_hall, last_updated)
VALUES 
('2023-06-01', '2023-06-30', 350.00, 1, 1, 1, GETDATE()),
('2023-06-15', '2023-07-15', 400.00, 2, 2, 2, GETDATE()),
('2023-07-01', '2023-07-31', 300.00, 3, 3, 3, GETDATE());


-- запросы 3.1 - 3.10

-- 3.1 INSERT // не работает
-- a. без указания списка полей
INSERT INTO CinemaHall VALUES ('Зал 3', 180, 1, 0, '2023-02-15');
-- b. с указанием списка полей
INSERT INTO Movie (title, release_year, duration_minutes, age_rating, genre, id_studio)
VALUES ('Крепкий орешек', 1988, 132, '16+', 'Боевик', 1);
-- c. с чтением значения из другой таблицы
INSERT INTO MovieRental ([start_date], end_date, ticket_price, id_cinema, id_movie, id_hall)
SELECT '2023-08-01', '2023-08-31', 450.00, id_cinema, 1, 1 FROM Cinema WHERE cinema_name = 'Киномакс';


-- 3.2. DELETE
-- a. всех записей
DELETE FROM CinemaHall WHERE hall_name = 'Зал 3';
-- b. по условию
DELETE FROM Movie WHERE title = 'Крепкий орешек';


-- 3.3. UPDATE
-- a. всех записей
UPDATE CinemaHall SET has_3d = 1;
-- b. по условию обновляя один атрибут
UPDATE Movie SET age_rating = '16+' WHERE title = 'Аватар';
-- c. по условию обновляя несколько атрибутов
UPDATE MovieRental 
SET ticket_price = 500.00, end_date = '2023-08-15' 
WHERE id_cinema = 1 AND id_movie = 1;


-- 3.4. SELECT
-- a. с набором извлекаемых атрибутов
SELECT title, release_year, genre FROM Movie;
-- b. со всеми атрибутами
SELECT * FROM Cinema;
-- c. с условием по атрибуту
SELECT * FROM Movie WHERE genre = 'Комедия';


-- 3.5. SELECT ORDER BY + TOP (LIMIT)
-- a. с сортировкой по возрастанию ASC + ограничение вывода количества записей
SELECT TOP 2 * FROM Movie ORDER BY release_year ASC;
-- b. с сортировкой по убыванию DESC
SELECT TOP 2 * FROM Movie ORDER BY release_year DESC;
-- c. с сортировкой по двум атрибутам + ограничение вывода количества записей
SELECT TOP 3 title, genre, release_year FROM Movie ORDER BY genre ASC, release_year DESC;
-- d. с сортировкой по первому атрибуту, из списка извлекаемых
SELECT title, release_year, duration_minutes FROM Movie ORDER BY 1;


-- 3.6. работа с датами
-- a. WHERE по дате
SELECT * FROM MovieRental WHERE [start_date] = '2023-06-01';
-- b. WHERE дата в диапазоне
SELECT * FROM Movie 
WHERE added_to_db BETWEEN '2023-01-01' AND '2023-03-01';
-- c. извлечь из таблицы не всю дату, а только год
SELECT title, YEAR(added_to_db) AS added_year FROM Movie;


-- 3.7. функции агрегации
-- a. посчитать количество записей в таблице
SELECT COUNT(*) AS total_movies FROM Movie; 
-- b. посчитать количество уникальных записей в таблице
SELECT COUNT(DISTINCT genre) AS unique_genres FROM Movie;
-- c. вывести уникальные значения столбца
SELECT DISTINCT genre FROM Movie;
-- d. найти максимальное значение столбца
SELECT MAX(ticket_price) AS max_price FROM MovieRental;
-- e. найти минимальное значение столбца
SELECT MIN(duration_minutes) AS min_duration FROM Movie;
-- f. написать запрос COUNT() + GROUP BY
SELECT genre, COUNT(*) AS movies_count FROM Movie GROUP BY genre;


-- 3.8. SELECT GROUP BY + HAVING
-- a.1. жанры, у которых более 1 фильма в базе (хотя у нас по 1, но для примера)
SELECT genre, COUNT(*) AS movies_count 
FROM Movie 
GROUP BY genre 
HAVING COUNT(*) > 1;
-- a.2. кинотеатры, которые сдают в прокат фильмы с ценой билета выше среднего
SELECT c.cinema_name, AVG(mr.ticket_price) AS avg_price
FROM Cinema c
JOIN MovieRental mr ON c.id_cinema = mr.id_cinema
GROUP BY c.cinema_name
HAVING AVG(mr.ticket_price) > (SELECT AVG(ticket_price) FROM MovieRental);
-- a.3. киностудии, основанные после 1920 года
SELECT country, COUNT(*) AS studios_count
FROM FilmStudio
WHERE foundation_year > 1920
GROUP BY country
HAVING COUNT(*) > 0;
-- що нить прилумать

-- 3.9. SELECT JOIN
-- a. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
SELECT m.title, fs.studio_name
FROM Movie m
LEFT JOIN FilmStudio fs ON m.id_studio = fs.id_studio
WHERE m.genre = 'Фантастика';
-- b. RIGHT JOIN. получить такую же выборку, как и в 3.9 (a)
SELECT m.title, fs.studio_name
FROM FilmStudio fs
RIGHT JOIN Movie m ON fs.id_studio = m.id_studio
WHERE m.genre = 'Фантастика';
-- c. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
SELECT m.title, c.cinema_name, ch.hall_name
FROM Movie m
LEFT JOIN MovieRental mr ON m.id_movie = mr.id_movie
LEFT JOIN Cinema c ON mr.id_cinema = c.id_cinema
LEFT JOIN CinemaHall ch ON mr.id_hall = ch.id_hall
WHERE m.release_year > 2000 AND c.opening_date > '2010-01-01' AND ch.capacity > 100;
-- d. INNER JOIN двух таблиц
SELECT m.title, mr.start_date, mr.end_date
FROM Movie m
INNER JOIN MovieRental mr ON m.id_movie = mr.id_movie;


-- 3.10. подзапросы
-- a. написать запрос с условием WHERE IN (подзапрос)
SELECT * FROM Movie 
WHERE id_studio IN (SELECT id_studio FROM FilmStudio WHERE country = 'USA');
-- b. написать запрос SELECT atr1, atr2, (подзапрос) FROM ...
SELECT 
    m.title,
    m.release_year,
    (SELECT studio_name FROM FilmStudio WHERE id_studio = m.id_studio) AS studio_name
FROM Movie m;
-- c. написать запрос вида SELECT * FROM (подзапрос)
SELECT * FROM 
    (SELECT title, release_year, genre FROM Movie WHERE release_year > 2000) AS RecentMovies;
-- d. написать запрос вида SELECT * FROM table JOIN (подзапрос) ON ...
SELECT c.cinema_name, mr.ticket_price
FROM Cinema c
JOIN (SELECT id_cinema, ticket_price FROM MovieRental WHERE ticket_price > 300) mr
ON c.id_cinema = mr.id_cinema;