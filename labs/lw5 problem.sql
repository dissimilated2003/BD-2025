-- лаба 5
USE [lw5]


-- 1. Добавить внешние ключи.
ALTER TABLE [dealer]
	ADD CONSTRAINT [fk_dealer_company]
		FOREIGN KEY ([id_company]) REFERENCES [company] ([id_company]);

ALTER TABLE [production]
	ADD CONSTRAINT [fk_production_company]
		FOREIGN KEY ([id_company]) REFERENCES [company] ([id_company]);

ALTER TABLE [production]
	ADD CONSTRAINT [fk_production_medicine]
		FOREIGN KEY ([id_medicine]) REFERENCES [medicine] ([id_medicine]);

ALTER TABLE [orders]
	ADD CONSTRAINT [fk_order_production]
		FOREIGN KEY ([id_production]) REFERENCES [production] ([id_production]);

ALTER TABLE [orders]
	ADD CONSTRAINT [fk_order_dealer]
		FOREIGN KEY ([id_dealer]) REFERENCES [dealer] ([id_dealer]);

ALTER TABLE [orders]
	ADD CONSTRAINT [fk_order_pharmacy]
		FOREIGN KEY ([id_pharmacy]) REFERENCES [pharmacy] ([id_pharmacy]);


-- 2. Выдать информацию по всем заказам лекарствам “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов.
SELECT
	o.[id_order],
	ph.[name] AS [pharmacy_name], 
	o.[quantity],
	o.[date] AS [order_date]
FROM [orders] o
	JOIN [pharmacy] ph ON ph.[id_pharmacy] = o.[id_pharmacy]
	JOIN [production] pr ON pr.[id_production] = o.[id_production]
	JOIN [company] c ON c.[id_company] = pr.[id_company]
	JOIN [medicine] m ON m.[id_medicine] = pr.[id_medicine]
WHERE
    m.[name] = 'Кордерон' AND c.[name] = 'Аргус';


-- 3 Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января.
SELECT --DISTINCT 
	m.[id_medicine], m.[name]
FROM [medicine] m
	JOIN [production] pr ON pr.[id_medicine] = m.[id_medicine]
	JOIN [company] c ON c.[id_company] = pr.[id_company] AND c.[name] = 'Фарма'
WHERE NOT EXISTS (
	SELECT 1	-- проверить, есть ли
	FROM [orders] o
	WHERE 
		o.[id_production] = pr.[id_production] AND o.[date] < '2019-01-25'
);


-- 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов.
SELECT 
    c.[name], 
    MAX(pr.[rating]) AS [max_rating], 
    MIN(pr.[rating]) AS [min_rating]
FROM [company] c
	JOIN [production] pr ON pr.[id_company] = c.[id_company]
	JOIN [orders] o ON o.[id_production] = pr.[id_production]
GROUP BY c.[name] 
HAVING 
	COUNT(o.[id_order]) >= 120;


-- 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. Если у дилера нет заказов, 
-- в названии аптеки проставить NULL.
SELECT
	d.[name] AS [dealer_name],
	COALESCE(ph.[name], 'NULL') AS [pharmacy_name],
	COUNT(o.[id_order]) AS [orders_count]
FROM [dealer] d
	JOIN [company] c ON c.[id_company] = d.[id_company]
	LEFT JOIN [orders] o ON o.[id_dealer] = d.[id_dealer]
	LEFT JOIN [pharmacy] ph ON ph.[id_pharmacy] = o.[id_pharmacy]
WHERE 
	c.[name] = 'AstraZeneca'
GROUP BY d.[name], ph.[name];


-- 6 Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней.
SELECT ------------------------------------------ отображение
    c.[name] AS [company_name],
    m.[name] AS [medicine_name],
    pr.[id_production],
    CAST(pr.[price] AS DECIMAL(10,2)) AS [cost],
    CAST(pr.[price] * 0.8 AS DECIMAL(10,2)) AS [updated_cost]
FROM [production] pr
    JOIN [medicine] m ON m.[id_medicine] = pr.[id_medicine]
    JOIN [company] c ON c.[id_company] = pr.[id_company]
WHERE
    m.[cure_duration] <= 7 AND pr.[price] > 3000;

UPDATE pr --------------------------------------- обновление
SET 
    [price] = pr.[price] * 0.8
FROM [production] pr
    JOIN [medicine] m ON m.[id_medicine] = pr.[id_medicine]
WHERE
    m.[cure_duration] <= 7 AND pr.[price] > 3000;


-- 7. Добавить необходимые индексы.
CREATE INDEX [idx_dealer_id_company]		ON [dealer] ([id_company]);
CREATE INDEX [idx_production_id_company]	ON [production] ([id_company]);
CREATE INDEX [idx_production_id_medicine]	ON [production] ([id_medicine]);
CREATE INDEX [idx_order_id_production]		ON [orders] ([id_production]);
CREATE INDEX [idx_order_id_dealer]			ON [orders] ([id_dealer]);
CREATE INDEX [idx_order_id_pharmacy]		ON [orders] ([id_pharmacy]);

CREATE INDEX [idx_order_date]		ON [orders] ([date]);
CREATE INDEX [idx_medicine_name]	ON [medicine] ([name]);
CREATE INDEX [idx_company_name]		ON [company] ([name]);
CREATE INDEX [idx_pharmacy_name]	ON [pharmacy] ([name]);
