-- 4.4 Lesson
-- Автоматизация загрузки данных
-- ***************************************************************

-- 4.4.1 
-- Создание схемы для скриптов
CREATE DATABASE IF NOT EXISTS edu_etl
COMMENT 'Схема для скриптов загрузки данных';
-- ***************************************************************

-- 4.4.2
-- Создание материализованного представления для загрузки очищенных данных в серебряную таблицу
CREATE MATERIALIZED VIEW IF NOT EXISTS edu_etl.mv_bronze_to_silver
TO edu_silver.ym_visits
AS
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
;
-- ***************************************************************

-- 4.4.3
-- Создание материализованного представления для загрузки невалидных данных в таблицу карантина
CREATE MATERIALIZED VIEW IF NOT EXISTS edu_etl.mv_bronze_to_dlq
TO edu_dlq.ym_visits
AS
	SELECT 	* 
	FROM edu_bronze.ym_visits
	WHERE 
		is_robot <> 0
		OR is_robot IS NULL
		OR region_id = 0
		OR region_id IS NULL
;

-- Загрузка данных за 2013-11-12 в бронзовую таблицу
INSERT INTO edu_bronze.ym_visits (
	event_date			,
	event_time			,
	user_id				,
	watch_id			,
	traffic_source_id	,
	utm_source			,
	utm_medium			,
	utm_campaign		,
	utm_content			,
	utm_term			,
	search_phrase		,
	referer_domain		,
	referer				,
	url_domain			,
	url					,
	region_id			,
	os					,
	user_agent			,
	is_mobile			,
	mobile_phone		,
	mobile_phone_model	,
	resolution_width	,
	resolution_height	,
	is_robot			,
	is_not_bounce		,
	goals_reached		,
	param_order_id		,
	param_price			
)
SELECT 
	EventDate			,
	EventTime			,
	UserID				,
	WatchID				,
	TraficSourceID		,
	UTMSource			,
	UTMMedium			,
	UTMCampaign			,
	UTMContent			,
	UTMTerm				,
	SearchPhrase		,
	RefererDomain		,
	Referer				,
	URLDomain			,
	URL					,
	RegionID			,
	OS					,
	UserAgent			,
	IsMobile			,
	MobilePhone			,
	MobilePhoneModel	,
	ResolutionWidth		,
	ResolutionHeight	,
	IsRobot				,
	IsNotBounce			,
	GoalsReached		,
	ParamOrderID		,
	ParamPrice	
FROM url(
	'https://huggingface.co/datasets/ivannatarov/clickhouse_course/resolve/main/parquet-files/hits_2013-11-12.parquet',
	'Parquet'
)
SETTINGS
	max_http_get_redirects = 10,
	min_insert_block_size_rows = 100000;
