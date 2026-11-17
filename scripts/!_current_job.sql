TRUNCATE TABLE edu_bronze.ym_visits;
SELECT count(*) FROM edu_bronze.ym_visits;

TRUNCATE TABLE edu_silver.ym_visits;
SELECT count(*) FROM edu_silver.ym_visits;

TRUNCATE TABLE edu_dlq.ym_visits;
SELECT count(*) FROM edu_dlq.ym_visits;

DROP table edu_etl.mv_bronze_to_dlq;
DROP table edu_etl.mv_bronze_to_silver;

SELECT event_date, count(*) FROM edu_silver.ym_visits GROUP BY event_date;

SELECT event_date, count(*) FROM edu_dlq.ym_visits GROUP BY event_date;

SELECT event_date, count(*) FROM edu_bronze.ym_visits GROUP BY event_date;

INSERT INTO edu_dlq.ym_visits
SELECT 	* 
	FROM edu_bronze.ym_visits
	WHERE (
		is_robot <> 0
		OR is_robot IS NULL
		OR region_id = 0
		OR region_id IS NULL
		)
		AND event_date = '2013-11-11'
;

INSERT INTO edu_silver.ym_visits (
    event_date, event_time, user_id, watch_id, traffic_source_id,
    utm_source, utm_medium, utm_campaign, utm_content, utm_term,
    search_phrase, referer_domain, referer, url_domain, url,
    region_id, os, user_agent, is_mobile, mobile_phone,
    mobile_phone_model, resolution_width, resolution_height, is_not_bounce,
    goals_reached, param_order_id, param_price, _source_system
)
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
	AND region_id <> 0
	AND event_date = '2013-11-12'
;