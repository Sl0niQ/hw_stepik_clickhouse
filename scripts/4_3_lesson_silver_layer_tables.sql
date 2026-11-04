-- 4.3 Lesson
-- Создание таблиц для хранения очищенных и невалидных данных
-- ***************************************************************

-- 4.3.1 
-- Создание схемы для хранения невалидных данных

CREATE DATABASE IF NOT EXISTS edu_dlq
COMMENT 'Слой невалидных данных';
-- ***************************************************************

-- 4.3.2
-- Создание таблицы для очищенных данных
-- - за исключением тех. полей копирует структуру таблицы сырых данных из бронзового слоя
-- - движок ReplacingMergeTree с полем времени обработки в качестве столбца версии

CREATE TABLE IF NOT EXISTS edu_silver.ym_visits
(
    event_date Date COMMENT 'Дата посещения UTC-0',
	event_time DateTime COMMENT 'Дата и время посещения UTC-0',
	user_id UInt64 COMMENT 'Идентификатор пользователя',
	watch_id UInt64 COMMENT 'Идентификатор просмотра страницы',
	traffic_source_id Int8 COMMENT 'Код типа источника трафика',
	utm_source LowCardinality(String) COMMENT 'UTM-метка источника трафика',
	utm_medium LowCardinality(String) COMMENT 'UTM-метка типа трафика',
	utm_campaign LowCardinality(String) COMMENT 'UTM-метка названия рекламной кампании',
	utm_content LowCardinality(String) COMMENT 'UTM-метка содержания объявления или дополнительной информации',
	utm_term String COMMENT 'UTM-метка ключевого слова или поисковой фразы из рекламы',
	search_phrase LowCardinality(String) COMMENT 'Текст поискового запроса',
	referer_domain LowCardinality(String) COMMENT 'Домен страницы источника перехода',
	referer String COMMENT 'Полный URL-адрес страницы, с которой пользователь перешел на текущую страницу',
	url_domain LowCardinality(String) COMMENT 'Домен сайта, на котором происходит просмотр',
	url String COMMENT 'Полный адрес просматриваемой страницы сайта',
	region_id UInt32 COMMENT 'Числовой идентификатор географического региона пользователя',
	os UInt8 COMMENT 'Внутренний числовой идентификатор операционной системы',
	user_agent UInt8 COMMENT 'Внутренний числовой идентификатор браузера',
	is_mobile UInt8 COMMENT 'Флаг типа устройства',
	mobile_phone UInt8 COMMENT 'Идентификатор бренда мобильного телефона',
	mobile_phone_model LowCardinality(String) COMMENT 'Название модели устройства',
	resolution_width UInt16 COMMENT 'Разрешение экрана устройства в пикселях по ширине',
	resolution_height UInt16 COMMENT 'Разрешение экрана устройства в пикселях по высоте',
	--is_robot UInt8 COMMENT 'Флаг антифрод-системы', - боты отсеяны фильтрацией
	is_not_bounce UInt8 COMMENT 'Флаг не-отказа',
	goals_reached Array(UInt32) COMMENT 'Массив числовых идентификаторов целей, достигнутых в рамках хита',
	param_order_id String COMMENT 'Номер оформленного заказа',
	param_price UInt32 COMMENT 'Сумма заказа',
	_processed_time DateTime DEFAULT now() COMMENT 'Дата и время обработки данных',
	_source_system LowCardinality(String) COMMENT 'Источник данных'
)
ENGINE = ReplacingMergeTree(_processed_time)
PARTITION BY toYYYYMM(event_date)
-- ORDER BY (event_date, user_id, url) - поле event_date удаляет уникальные записи внутри суток
ORDER BY (event_time, user_id, url)
TTL _processed_time + INTERVAL 3 YEAR DELETE
SETTINGS index_granularity = 8192
COMMENT 'Таблица для очищенных данных (серебряный слой)';

-- DROP TABLE edu_silver.ym_visits
-- ***************************************************************

-- 4.3.3
-- Создание таблицы каратнина
--	- копирует структуру таблицы сырых данных из бронзового слоя
--	- значение _ingestion_time берется из таблицы бронзового слоя

CREATE TABLE IF NOT EXISTS edu_dlq.ym_visits
(
    event_date Date COMMENT 'Дата посещения UTC-0',
	event_time DateTime COMMENT 'Дата и время посещения UTC-0',
	user_id UInt64 COMMENT 'Идентификатор пользователя',
	watch_id UInt64 COMMENT 'Идентификатор просмотра страницы',
	traffic_source_id Int8 COMMENT 'Код типа источника трафика',
	utm_source LowCardinality(String) COMMENT 'UTM-метка источника трафика',
	utm_medium LowCardinality(String) COMMENT 'UTM-метка типа трафика',
	utm_campaign LowCardinality(String) COMMENT 'UTM-метка названия рекламной кампании',
	utm_content LowCardinality(String) COMMENT 'UTM-метка содержания объявления или дополнительной информации',
	utm_term String COMMENT 'UTM-метка ключевого слова или поисковой фразы из рекламы',
	search_phrase LowCardinality(String) COMMENT 'Текст поискового запроса',
	referer_domain LowCardinality(String) COMMENT 'Домен страницы источника перехода',
	referer String COMMENT 'Полный URL-адрес страницы, с которой пользователь перешел на текущую страницу',
	url_domain LowCardinality(String) COMMENT 'Домен сайта, на котором происходит просмотр',
	url String COMMENT 'Полный адрес просматриваемой страницы сайта',
	region_id UInt32 COMMENT 'Числовой идентификатор географического региона пользователя',
	os UInt8 COMMENT 'Внутренний числовой идентификатор операционной системы',
	user_agent UInt8 COMMENT 'Внутренний числовой идентификатор браузера',
	is_mobile UInt8 COMMENT 'Флаг типа устройства',
	mobile_phone UInt8 COMMENT 'Идентификатор бренда мобильного телефона',
	mobile_phone_model LowCardinality(String) COMMENT 'Название модели устройства',
	resolution_width UInt16 COMMENT 'Разрешение экрана устройства в пикселях по ширине',
	resolution_height UInt16 COMMENT 'Разрешение экрана устройства в пикселях по высоте',
	is_robot UInt8 COMMENT 'Флаг антифрод-системы',
	is_not_bounce UInt8 COMMENT 'Флаг не-отказа',
	goals_reached Array(UInt32) COMMENT 'Массив числовых идентификаторов целей, достигнутых в рамках хита',
	param_order_id String COMMENT 'Номер оформленного заказа',
	param_price UInt32 COMMENT 'Сумма заказа',
	_ingestion_time DateTime COMMENT 'Дата и время загрузки данных',
	_source_system LowCardinality(String) COMMENT 'Источник данных'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, user_id)
TTL _ingestion_time + toIntervalYear(3)
SETTINGS index_granularity = 8192
COMMENT 'Таблица для невалидных данных';

SELECT * FROM system.databases
WHERE name LIKE 'edu%';

DESCRIBE TABLE edu_silver.ym_visits;
DESCRIBE TABLE edu_dlq.ym_visits;

SELECT * FROM edu_bronze.ym_visits;