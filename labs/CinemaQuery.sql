USE [lw3 option 3]

-- доп. сущность: киностудия
CREATE TABLE FilmStudio (
    id_studio INT IDENTITY(1,1) NOT NULL,
    studio_name NVARCHAR(100) NOT NULL,
    country NVARCHAR(50) NOT NULL,
    foundation_year INT NOT NULL,
    website NVARCHAR(255),

    CONSTRAINT PK_FilmStudio_id_studio PRIMARY KEY (id_studio)
);

-- доп. сущность: зал кинотеатра
CREATE TABLE CinemaHall (
    id_hall INT IDENTITY(1,1) NOT NULL,
    -- id_cinema INT IDENTITY(1,1) NOT NULL,
	hall_name NVARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    has_3d BIT NOT NULL DEFAULT 0,
    has_dolby_atmos BIT NOT NULL DEFAULT 0,

    CONSTRAINT PK_CinemaHall_id_hall PRIMARY KEY (id_hall),
    CONSTRAINT CHK_CinemaHall_capacity CHECK (capacity > 0),
	--CONSTRAINT FK_CinemaHall_id_cinema FOREIGN KEY (id_cinema) 
      --  REFERENCES Cinema(id_cinema),
);

-- кинотеатр
CREATE TABLE Cinema (
    id_cinema INT IDENTITY(1,1) NOT NULL,
    cinema_name NVARCHAR(100) NOT NULL,
    [address] NVARCHAR(255) NOT NULL,
    phone_number NVARCHAR(20) NOT NULL,
    opening_hours NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Cinema_id_cinema PRIMARY KEY (id_cinema)
);

-- фильм
CREATE TABLE Movie (
    id_movie INT IDENTITY(1,1) NOT NULL,
    title NVARCHAR(100) NOT NULL,
    release_year INT NOT NULL,
    duration_minutes INT NOT NULL,
    age_rating NVARCHAR(10) NOT NULL,
    genre NVARCHAR(50) NOT NULL,

    id_studio INT NOT NULL,
    CONSTRAINT PK_Movie_id_movie PRIMARY KEY (id_movie),
    CONSTRAINT FK_Movie_id_studio FOREIGN KEY (id_studio) 
        REFERENCES FilmStudio(id_studio),
    CONSTRAINT CHK_Movie_release_year CHECK (release_year > 1888), -- первый фильм снят в 1888
    CONSTRAINT CHK_Movie_duration CHECK (duration_minutes > 0)
);

-- отд сущн, типа зала
-- прокат фильмов (связь кинотеатра и фильма)
CREATE TABLE MovieRental (
    id_rental INT IDENTITY(1,1) NOT NULL,
    [start_date] DATE NOT NULL,
    end_date DATE NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,

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
    CONSTRAINT CHK_MovieRental_dates CHECK (end_date >= start_date),
    CONSTRAINT CHK_MovieRental_price CHECK (ticket_price > 0),
    CONSTRAINT UQ_MovieRental_cinema_movie_hall UNIQUE (id_cinema, id_movie, id_hall, start_date)
);