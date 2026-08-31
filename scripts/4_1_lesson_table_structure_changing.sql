-- 3.5 Lesson
-- Изменение структуры таблицы (добавление технического поля для указания источника загрузки) и перезалив данных

-- Очистка таблицы
TRUNCATE TABLE edu_bronze.ym_visits;

-- Добавление поля для источника данных
ALTER TABLE edu_bronze.ym_visits
ADD COLUMN IF NOT EXISTS _source_system LowCardinality(String) COMMENT 'Источник данных'
AFTER _ingestion_time;

-- Загрузка данных
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
	param_price			,
	_source_system
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
	ParamPrice			,
	_file
FROM url(
	'https://huggingface.co/datasets/ivannatarov/clickhouse_course/resolve/main/parquet-files/hits_2013-11-{04..10}.parquet',
	'Parquet'
)
SETTINGS
	max_http_get_redirects = 10,
	min_insert_block_size_rows = 100000;


SELECT
	event_date,
	user_id,
	traffic_source_id,
	_ingestion_time,
	_source_system
FROM edu_bronze.ym_visits
LIMIT 10;