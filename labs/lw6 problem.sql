-- лаба 6
USE [lw6]


-- 1. Добавить внешние ключи
ALTER TABLE [booking]
	ADD CONSTRAINT [fk_booking_id_client]
		FOREIGN KEY ([id_client]) REFERENCES [client] ([id_client]);

ALTER TABLE [room]
	ADD CONSTRAINT [fk_room_id_hotel]
		FOREIGN KEY ([id_hotel]) REFERENCES [hotel] ([id_hotel]);

ALTER TABLE [room]
	ADD CONSTRAINT [fk_room_id_room_category]
		FOREIGN KEY ([id_room_category]) REFERENCES [room_category] ([id_room_category]);

ALTER TABLE [room_in_booking]
	ADD CONSTRAINT [fk_room_in_booking_id_booking]
		FOREIGN KEY ([id_booking]) REFERENCES [booking] ([id_booking]);

ALTER TABLE [room_in_booking]
	ADD CONSTRAINT [fk_room_in_booking_id_room]
		FOREIGN KEY ([id_room]) REFERENCES [room] ([id_room]);


-- 2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах категории “Люкс” на 1 апреля 2019г.
SELECT
	c.[id_client],
	c.[name],
	c.[phone]
FROM [hotel] h
	JOIN [room] r ON r.[id_hotel] = h.[id_hotel]
	JOIN [room_category] rc ON rc.[id_room_category] = r.[id_room_category]
	JOIN [room_in_booking] rib ON rib.[id_room] = r.[id_room]
	JOIN [booking] b ON b.[id_booking] = rib.[id_booking]
	JOIN [client] c ON c.[id_client] = b.[id_client]
WHERE
	h.[name] = 'Космос'
	AND rc.[name] = 'Люкс'
	AND rib.[checkin_date] <= '2019-04-01' AND '2019-04-01' < rib.[checkout_date];


-- 3. Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT
	h.[id_hotel] AS [id_hotel],
	h.[name] AS [hotel_name],
	r.[id_room] AS [id_room],
	r.[number] AS [room_number],
	r.[price] AS [room_price],
	rc.[name] AS [room_category]
FROM "room" r
	JOIN [room_category] rc ON rc.[id_room_category] = r.[id_room_category]
	JOIN [hotel] h ON h.[id_hotel] = r.[id_hotel]
WHERE NOT EXISTS (
	SELECT 1
	FROM [room_in_booking] rib
	WHERE
		rib.[id_room] = r.[id_room]
		AND rib.[checkin_date] <= '2019-04-22' AND '2019-04-22' < rib.[checkout_date] 
);


-- 4. Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров
SELECT
	rc.[name] AS [category],
	COUNT(*) AS [count]
FROM [hotel] h
	JOIN [room] r ON r.[id_hotel] = h.[id_hotel]
	JOIN [room_category] rc ON rc.[id_room_category] = r.[id_room_category]
	LEFT JOIN [room_in_booking] rib ON rib.[id_room] = r.[id_room]
WHERE
	h.[name] = 'Космос' AND rib.[checkin_date] <= '2019-03-23' AND '2019-03-23' < rib.[checkout_date]
GROUP BY rc.[name];


-- 5 Дать список последних проживавших клиентов по всем комнатам гостиницы “Космос”, выехавшим в апреле с указанием даты выезда.
SELECT TOP (1) WITH TIES
	r.[id_room],
	r.[number] AS [room_number],
	c.[id_client],
	c.[name] AS [client_name],
	c.[phone] AS [client_phone],
	rib.[checkout_date]
FROM [room_in_booking] rib
	JOIN [room] r ON r.[id_room] = rib.[id_room]
	JOIN [hotel] h ON h.[id_hotel] = r.[id_hotel]
	JOIN [booking] b ON b.[id_booking] = rib.[id_booking]
	JOIN [client] c ON c.[id_client] = b.[id_client]
WHERE 
	rib.[checkout_date] BETWEEN '2019-04-01' AND '2019-04-30' AND h.[name] = 'Космос'
ORDER BY 
	DENSE_RANK() OVER (PARTITION BY r.[id_room] ORDER BY rib.[checkout_date] DESC);


-- 6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам комнат категории “Бизнес”, которые заселились 10 мая.
SELECT ------------------------------------------ отображение
    rib.[id_room_in_booking],
    h.[name] AS [hotel_name],
    rc.[name] AS [room_category],
    rib.[checkin_date],
    rib.[checkout_date] AS [original_checkout_date],
    DATEADD(day, 2, rib.[checkout_date]) AS [new_checkout_date]
FROM 
    [room_in_booking] rib
    JOIN [room] r ON rib.[id_room] = r.[id_room]
    JOIN [room_category] rc ON rc.[id_room_category] = r.[id_room_category]
    JOIN [hotel] h ON h.[id_hotel] = r.[id_hotel]
WHERE
    h.[name] = 'Космос'
    AND rc.[name] = 'Бизнес'
    AND rib.[checkin_date] = '2019-05-10';

UPDATE rib -------------------------------------- обновление
SET 
	rib.[checkout_date] = DATEADD(DAY, 2, rib.[checkout_date])
FROM [room_in_booking] rib
	JOIN [room] r ON rib.[id_room] = r.[id_room]
	JOIN [room_category] rc ON rc.[id_room_category] = r.[id_room_category]
	JOIN [hotel] h ON h.[id_hotel] = r.[id_hotel]
WHERE
	h.[name] = 'Космос'
	AND rc.[name] = 'Бизнес'
	AND rib.[checkin_date] = '2019-05-10';


-- 7 Найти все "пересекающиеся" варианты проживания. Правильное состояние: не может быть забронирован один номер 
-- на одну дату несколько раз, т.к. нельзя заселиться нескольким клиентам в один номер. Записи в таблице room_in_booking 
-- с id_room_in_booking = 5 и 2154 являются примером неправильного состояния, которые необходимо найти. Результирующий кортеж
-- выборки должен содержать информацию о двух конфликтующих номерах.
SELECT
	rib1.[id_room_in_booking],
	rib1.[id_booking],
	rib1.[id_room],
	rib1.[checkin_date],
	rib1.[checkout_date],
	rib2.[id_room_in_booking], 
	rib2.[id_booking],
	rib2.[id_room],
	rib2.[checkin_date],
	rib2.[checkout_date]
FROM [room_in_booking] rib1
	JOIN [room_in_booking] rib2 ON rib1.[id_room] = rib2.[id_room]
WHERE
	NOT (rib1.[checkout_date] <= rib2.[checkin_date] OR rib2.[checkout_date] <= rib1.[checkin_date])
	AND rib1.[id_room_in_booking] < rib2.[id_room_in_booking];


-- 8. Создать бронирование в транзакции.
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @new_booking_id INT;
    DECLARE @new_room_in_booking_id INT;
	
    INSERT INTO [booking] ([id_client], [booking_date])
    VALUES (1, CAST(GETDATE() AS DATE))
    SET @new_booking_id = SCOPE_IDENTITY();

    INSERT INTO [room_in_booking] ([id_booking], [id_room], [checkin_date], [checkout_date])
    VALUES (@new_booking_id, 1, '2019-04-15', '2019-09-20') -- рандом даты
    SET 
		@new_room_in_booking_id = SCOPE_IDENTITY();
    SELECT 
        @new_booking_id AS new_booking_id,
        @new_room_in_booking_id AS new_room_in_booking_id;    
    COMMIT TRANSACTION;
END TRY

BEGIN CATCH
    ROLLBACK TRANSACTION;
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH


-- 9. Добавить необходимые индексы для всех таблиц.
CREATE INDEX [idx_booking_id_client]			ON [booking] ([id_client]);
CREATE INDEX [idx_room_id_hotel]				ON [room] ([id_hotel]);
CREATE INDEX [idx_room_id_room_category]		ON [room] ([id_room_category]);
CREATE INDEX [idx_room_in_booking_id_booking]	ON [room_in_booking] ([id_booking]);
CREATE INDEX [idx_room_in_booking_id_room]		ON [room_in_booking] ([id_room]);

CREATE INDEX [idx_hotel_name]			ON [hotel] ([name]);
CREATE INDEX [idx_room_category_name]	ON [room_category] ([name]);

CREATE INDEX [idx_room_in_booking]		ON [room_in_booking] ([checkin_date], [checkout_date]);