-- лаба 7
USE [lw7]


-- 1. Добавить внешние ключи.
ALTER TABLE [lesson]
	ADD CONSTRAINT [lesson_teacher_fkey]
		FOREIGN KEY ([id_teacher]) REFERENCES [teacher] ([id_teacher]);

ALTER TABLE [lesson]
	ADD CONSTRAINT [lesson_subject_fkey]
		FOREIGN KEY ([id_subject]) REFERENCES [subject] ([id_subject]);
	
ALTER TABLE [lesson]
	ADD CONSTRAINT [lesson_group_fkey]
		FOREIGN KEY ([id_group]) REFERENCES [group] ([id_group]);

ALTER TABLE [mark]
  ADD CONSTRAINT [mark_lesson_fkey]
    FOREIGN KEY ([id_lesson]) REFERENCES [lesson] ([id_lesson]);

ALTER TABLE [mark]
  ADD CONSTRAINT [mark_student_fkey]
    FOREIGN KEY ([id_student]) REFERENCES [student] ([id_student]);

ALTER TABLE [student]
  ADD CONSTRAINT [student_group_fkey]
    FOREIGN KEY ([id_group]) REFERENCES [group] ([id_group]);
GO


-- 2. Выдать оценки студентов по информатике если они обучаются данному предмету. Оформить выдачу данных с использованием view.
CREATE VIEW it_students_marks AS
  SELECT
    st.[id_student],
    st.[name] AS [student_name],
    m.[mark]
  FROM [subject] su
  JOIN [lesson] l ON l.[id_subject] = su.[id_subject]
  JOIN [mark] m ON m.[id_lesson] = l.[id_lesson]
  JOIN [student] st ON st.[id_student] = m.[id_student]
  WHERE
    su.[name] = 'Информатика';
GO
--SELECT * FROM it_students_marks;


-- 3. Дать информацию о должниках с указанием фамилии студента и названия предмета. Должниками считаются студенты, 
-- не имеющие оценки по предмету, который ведется в группе. Оформить в виде процедуры, на входе идентификатор группы.
CREATE PROCEDURE [get_students_behind]
    @group_id INT
AS
BEGIN
    SELECT 
        st.[id_student],
        st.[name] AS [student_name],
        g.[id_group],
        g.[name] AS [group_name],
        su.[id_subject],
        su.[name] AS [subject_name]
    FROM 
        [group] g
        JOIN [student] st ON st.[id_group] = g.[id_group]
        JOIN [lesson] l ON l.[id_group] = g.[id_group]
        JOIN [subject] su ON su.[id_subject] = l.[id_subject]
    WHERE 
        g.[id_group] = @group_id
        AND NOT EXISTS (
            SELECT 1
            FROM [lesson] l2
            JOIN [mark] m ON m.[id_lesson] = l2.[id_lesson]
            WHERE 
                l2.[id_subject] = su.[id_subject]
                AND m.[id_student] = st.[id_student]
        )
    GROUP BY
        st.[id_student],
        st.[name],
        g.[id_group],
        g.[name],
        su.[id_subject],
        su.[name];
END;

--EXEC get_students_behind @group_id = 1;


-- 4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по которым занимается не менее 35 студентов.
SELECT
    su.[id_subject],
    su.[name] AS [subject_name],
    CAST(
		SUM(CAST(su_g.[mark_sum] AS DECIMAL(10,2))) / 
		NULLIF(SUM(CAST(su_g.[num_marks] AS DECIMAL(10,2))), 0)
		AS DECIMAL(10,2)
) AS [average_mark]
FROM [subject] su
JOIN (
    SELECT
        l.[id_subject],
        l.[id_group],
        SUM(m.[mark]) AS [mark_sum],
        COUNT(*) AS [num_marks]
    FROM [mark] m
    JOIN [lesson] l ON l.[id_lesson] = m.[id_lesson]
    GROUP BY l.[id_subject], l.[id_group]
) su_g ON su_g.[id_subject] = su.[id_subject]
JOIN (
    SELECT
        st.[id_group],
        COUNT(*) AS [num_students]
    FROM [student] st
    GROUP BY st.[id_group]
) g ON g.[id_group] = su_g.[id_group]
GROUP BY su.[id_subject], su.[name]
HAVING
    SUM(g.[num_students]) >= 35;


-- 5. Дать оценки студентов специальности ВМ по всем проводимым предметам с указанием группы, фамилии, 
-- предмета, даты. При отсутствии оценки заполнить значениями поля оценки.
SELECT 
	g.[name] AS [group_name],
	st.[name] AS [student_name],
	su.[name] AS [subject_name],
	l.[date] AS [lesson_date],
CASE 
    WHEN m.[mark] IS NULL THEN 'NULL' 
    ELSE CAST(m.[mark] AS VARCHAR(10)) 
END AS [mark]
FROM [group] g
	JOIN [student] st ON st.[id_group] = g.[id_group]
	JOIN [lesson] l ON l.[id_group] = g.[id_group]
	JOIN [subject] su ON su.[id_subject] = l.[id_subject]
	LEFT JOIN [mark] m ON m.[id_lesson] = l.[id_lesson] AND m.[id_student] = st.[id_student]
WHERE
	g.[name] = 'ВМ';


-- 6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету БД до 12.05, повысить эти оценки на 1 балл.
SELECT ------------------------------------------ отображение
    g.[name] AS [group_name],
    st.[name] AS [student_name],
    su.[name] AS [subject_name],
    l.[date] AS [lesson_date],
    m.[mark] AS [current_mark],
CASE 
	WHEN m.[mark] < 5 THEN m.[mark] + 1 ELSE m.[mark] 
END AS [updated_mark]
FROM [group] g
	JOIN [student] st ON st.[id_group] = g.[id_group]
	JOIN [lesson] l ON l.[id_group] = g.[id_group]
	JOIN [subject] su ON su.[id_subject] = l.[id_subject]
	JOIN [mark] m ON m.[id_lesson] = l.[id_lesson] AND m.[id_student] = st.[id_student]
WHERE
    g.[name] = 'ПС'
    AND su.[name] = 'БД'
    AND l.[date] < '2023-05-12'
    AND m.[mark] < 5;

UPDATE m ---------------------------------------- обновление
SET 
    m.[mark] = m.[mark] + 1
FROM [mark] m
JOIN [lesson] l ON l.[id_lesson] = m.[id_lesson]
JOIN [student] st ON st.[id_student] = m.[id_student]
JOIN [group] g ON g.[id_group] = st.[id_group]
JOIN [subject] su ON su.[id_subject] = l.[id_subject]
WHERE
    g.[name] = 'ПС'
    AND su.[name] = 'БД'
    AND l.[date] < '2023-05-12'
    AND m.[mark] < 5;


-- 7. Добавить необходимые индексы
CREATE INDEX [idx_student_id_group]		ON [student] ([id_group]);
CREATE INDEX [idx_lesson_id_subject]	ON [lesson] ([id_subject]);
CREATE INDEX [idx_lesson_id_group]		ON [lesson] ([id_group]);
CREATE INDEX [idx_mark_id_student]		ON [mark] ([id_student]);
CREATE INDEX [idx_mark_id_lesson]		ON [mark] ([id_lesson]);

CREATE INDEX [idx_group_name]		ON [group] ([name]);
CREATE INDEX [idx_subject_name]		ON [subject] ([name]);
CREATE INDEX [idx_lesson_date]		ON [lesson] ([date]);
CREATE INDEX [idx_student_name]		ON [student] ([name]);