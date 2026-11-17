-- 5.1 Lesson
-- Загрузка недостающих данных за 2013-11-11 в серебряный слой
-- ***************************************************************

-- 5.1.1 
-- Запрос для загрузки данных в серебряную таблицу
EXPLAIN ESTIMATE
SELECT *
	-- исключение полей is_robot и _ingestion_time
	EXCEPT (is_robot, _ingestion_time) 
	REPLACE (
		-- извлечение корректной даты из поля event_time
		toDate(event_time) AS event_date,
		-- извлечение корректного домена из поля referer
		domain(referer) AS referer_domain,
		-- извлечение корректного домена из поля url
		domain(url) AS url_domain
	)
FROM edu_bronze.ym_visits
-- исключение записей от робота и с нулевым регионом
WHERE 
	is_robot = 0
	AND region_id <> 0
	AND event_date = '2013-11-11'
;
-- ***************************************************************

-- 5.1.2
-- Запрос для загрузки данных в таблицу карантина
EXPLAIN ESTIMATE
SELECT * 
FROM edu_bronze.ym_visits
WHERE 
	(
		is_robot <> 0
		OR is_robot IS NULL
		OR region_id = 0
		OR region_id IS NULL
	)
	AND event_date = '2013-11-11'
;
-- ***************************************************************

-- 5.1.3
-- Загрузка данных в серебряную таблицу
INSERT INTO edu_silver.ym_visits
SELECT *
	-- исключение полей is_robot и _ingestion_time
	EXCEPT (is_robot, _ingestion_time) 
	REPLACE (
		-- извлечение корректной даты из поля event_time
		toDate(event_time) AS event_date,
		-- извлечение корректного домена из поля referer
		domain(referer) AS referer_domain,
		-- извлечение корректного домена из поля url
		domain(url) AS url_domain
	)
FROM edu_bronze.ym_visits
-- исключение записей от робота и с нулевым регионом
WHERE 
	is_robot = 0
	AND region_id <> 0
	AND event_date = '2013-11-11'
;
-- ***************************************************************

-- 5.1.4
-- Загрузка данных в таблицу карантина
INSERT INTO edu_dlq.ym_visits
SELECT * 
FROM edu_bronze.ym_visits
WHERE 
	(
		is_robot <> 0
		OR is_robot IS NULL
		OR region_id = 0
		OR region_id IS NULL
	)
	AND event_date = '2013-11-11'
;
-- ***************************************************************

-- Проверка наличия данных за 2013-11-11 и 2013-11-12 в серебряной таблице
SELECT
	toString(event_date) AS "Date",
	count(*) AS "Rows" 
FROM edu_silver.ym_visits
WHERE event_date IN ('2013-11-11', '2013-11-12')
GROUP BY event_date
ORDER BY event_date ASC

-- Проверка наличия данных за 2013-11-11 и 2013-11-12 в таблице карантина
SELECT
	toString(event_date) AS "Date",
	count(*) AS "Rows" 
FROM edu_dlq.ym_visits
WHERE event_date IN ('2013-11-11', '2013-11-12')
GROUP BY event_date
ORDER BY event_date ASC

SELECT * FROM edu_dlq.ym_visits WHERE event_date = '2013-11-09'
SELECT *
FROM edu_bronze.ym_visits
WHERE 
	(
		is_robot <> 0
		OR is_robot IS NULL
		OR region_id = 0
		OR region_id IS NULL
	)
	AND event_date = '2013-11-11'

SELECT
    query_id,
    user,
    client_hostname,
    query,
    event_time,
    type,
    exception
FROM system.query_log
WHERE event_time > now() - INTERVAL 31 DAY
AND query LIKE '%dlq%'
ORDER BY event_time DESC
LIMIT 100;

SELECT
    query_id,
    event_time,
    type,
    exception,
    query
FROM system.query_log
WHERE type = 'ExceptionBeforeStart'
  AND event_time > now() - INTERVAL 100 MINUTE
ORDER BY event_time DESC;

SET log_queries_min_type = 'EXCEPTION_BEFORE_START';

SHOW CREATE TABLE edu_etl.mv_bronze_to_dlq;