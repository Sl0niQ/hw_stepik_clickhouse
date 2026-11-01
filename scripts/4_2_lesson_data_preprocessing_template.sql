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

-- Запрос на захват невалидных строк
SELECT *
FROM edu_bronze.ym_visits
WHERE is_robot <> 0 
OR is_robot IS NULL
OR region_id = 0 
OR region_id IS NULL;	
	
	
	
	AND user_id <> 0
	AND watch_id <> 0
	AND (_source_system IS NOT NULL AND _source_system <> '');


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

DESCRIBE TABLE edu_bronze.ym_visits;