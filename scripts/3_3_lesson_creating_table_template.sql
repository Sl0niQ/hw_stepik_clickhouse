-- 3.3 Lesson
-- Замените переменные {} своими значениями без {}

-- Создание таблицы в сыром слое 
CREATE TABLE IF NOT EXISTS {Название схемы}.{Название таблицы} ( 
-- Дата и время
{Название колонки} {Тип данных} COMMENT '{Описание поля}',
{Название колонки} {Тип данных} COMMENT '{Описание поля}',
...
-- Идентификаторы
{Название колонки} {Тип данных} COMMENT '{Описание поля}',
...
-- Информация о событии
{Название колонки} {Тип данных} COMMENT '{Описание поля}',
...
-- Любая дополнительная информация
{Название колонки} {Тип данных} COMMENT '{Описание поля}',
...
-- Технические поля (Meta)
_ingestion_time DateTime DEFAULT now() COMMENT 'Время записи данных в таблицу',
-- Если система передается в INSERT и не является константой
_source_system LowCardinality(String) COMMENT 'Система-источник данных'
)
-- Движок 
ENGINE = MergeTree()
-- При необходимости скорректируйте в зависимости от объемов данных
PARTITION BY toYYYYMM(event_date)
-- При необходимости скорректируйте в зависимости от сценариев работы с таблицей
ORDER BY (event_date, user_id)
-- Время жизни данных
TTL _ingestion_time + INTERVAL 3 YEAR
-- Описание таблицы
COMMENT '{Описание таблицы}'

CREATE TABLE IF NOT EXISTS edu_bronze.ym_visits (
	event_date			Date COMMENT 'Дата посещения UTC-0',
	event_time			DateTime COMMENT 'Дата и время посещения UTC-0',
	user_id				UInt64 COMMENT 'Идентификатор пользователя',
	watch_id			UInt64 COMMENT 'Идентификатор просмотра страницы',
	traffic_source_id	Int8 COMMENT 'Код типа источника трафика',
	utm_source			LowCardinality(String) COMMENT 'UTM-метка источника трафика',
	utm_medium			LowCardinality(String) COMMENT 'UTM-метка типа трафика',
	utm_campaign		LowCardinality(String) COMMENT 'UTM-метка названия рекламной кампании',
	utm_content			LowCardinality(String) COMMENT 'UTM-метка содержания объявления или дополнительной информации',
	utm_term			String COMMENT 'UTM-метка ключевого слова или поисковой фразы из рекламы',
	search_phrase		LowCardinality(String) COMMENT 'Текст поискового запроса',
	refer_domain		LowCardinality(String) COMMENT 'Домен страницы источника перехода',
	refer				String COMMENT 'Полный URL-адрес страницы, с которой пользователь перешел на текущую страницу',
	url_domain			LowCardinality(String) COMMENT 'Домен сайта, на котором происходит просмотр',
	url					String COMMENT 'Полный адрес просматриваемой страницы сайта',
	region_id			UInt32 COMMENT 'Числовой идентификатор географического региона пользователя',
	os					UInt8 COMMENT 'Внутренний числовой идентификатор операционной системы',
	user_agent			UInt8 COMMENT 'Внутренний числовой идентификатор браузера',
	is_mobile			UInt8 COMMENT 'Флаг типа устройства',
	mobile_phone		UInt8 COMMENT 'Идентификатор бренда мобильного телефона',
	mobile_phone_model	LowCardinality(String) COMMENT 'Название модели устройства',
	resolution_width	UInt16 COMMENT 'Разрешение экрана устройства в пикселях по ширине',
	resolution_height	UInt16 COMMENT 'Разрешение экрана устройства в пикселях по высоте',
	is_robot			UInt8 COMMENT 'Флаг антифрод-системы',
	is_not_bounce		UInt8 COMMENT 'Флаг не-отказа',
	goal_reached		Array(UInt32) COMMENT 'Массив числовых идентификаторов целей, достигнутых в рамках хита',
	param_order_id		String COMMENT 'Номер оформленного заказа',
	param_price			UInt32 COMMENT 'Сумма заказа',
	_ingestion_time 	DateTime DEFAULT now() COMMENT 'Дата и время загрузки данных'
)
ENGINE MergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, user_id)
TTL _ingestion_time + INTERVAL 3 YEAR
COMMENT 'Необработанные логи Яндекс Метрики - визиты';

DESCRIBE TABLE edu_bronze.ym_visits;