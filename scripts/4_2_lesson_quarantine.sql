-- 4.2 Lesson
-- Очистка данных

-- Запрос на захват невалидных строк
SELECT *
FROM edu_bronze.ym_visits
WHERE is_robot <> 0 
	OR is_robot IS NULL
	OR region_id = 0 
	OR region_id IS NULL;	
