-- 3.4 Lesson
-- Загрузка сырых данных из внешнего источника за период с 2013-11-04 по 2013-11-10

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
	'https://huggingface.co/datasets/ivannatarov/clickhouse_course/resolve/main/parquet-files/hits_2013-11-{04..10}.parquet',
	'Parquet'
)
SETTINGS
	max_http_get_redirects = 10,
	min_insert_block_size_rows = 100000;

DESCRIBE TABLE url(
	'https://huggingface.co/datasets/ivannatarov/clickhouse_course/resolve/main/parquet-files/hits_2013-11-{04..10}.parquet',
	'Parquet'
)
SETTINGS
	max_http_get_redirects = 10,
	min_insert_block_size_rows = 100000;

(
	SELECT * FROM edu_bronze.ym_visits
	--WHERE event_date = (SELECT min(event_date) FROM  edu_bronze.ym_visits)
	ORDER BY event_date ASC, event_time ASC 
	LIMIT 1
)
UNION ALL 
(
	SELECT * FROM edu_bronze.ym_visits
	--WHERE event_date = (SELECT max(event_date) FROM  edu_bronze.ym_visits)
	ORDER BY event_date DESC, event_time DESC
	LIMIT 1
);