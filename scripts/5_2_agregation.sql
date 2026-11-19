-- 5.1 Lesson
-- Запрос на агрегацию данных
-- ***************************************************************

SELECT
	event_date AS "date",
	user_id,
	argMax(event_date, traffic_source_id) AS trafic_source_id,
	argMin(event_date, region_id) AS region_id,
	count(*) AS total_hits,
	sum(param_price) AS total_purchase_amount,
	countIf(watch_id, is_not_bounce=1) AS total_non_bounce_visits,
	countIf(watch_id, is_mobile=1) AS total_mobile_visits,
	sumIf(param_price, is_mobile=1) AS total_mobile_purchase_amount,
	groupUniqArray(url_domain) AS url_domains_list
FROM edu_silver.ym_visits FINAL
GROUP BY 
	event_date, 
	user_id;
--ORDER BY event_date, user_id;

