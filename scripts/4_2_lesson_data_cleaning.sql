-- 4.2 Lesson
-- Очистка данных

-- Запрос на очистку и трансформацию данных
SELECT 	* 
		-- исключение полей is_robot и _ingestion_time
		EXCEPT(is_robot, _ingestion_time) 
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
WHERE is_robot = 0
AND region_id <> 0;
