-- 3.2 Lesson
select currentUser()
select version()

--CREATE DATABASE IF NOT EXISTS {database_name}
--COMMENT '{describtion}'

CREATE DATABASE IF NOT EXISTS edu_bronze
COMMENT 'Слой сырых данных';

CREATE DATABASE IF NOT EXISTS edu_silver
COMMENT 'Слой очищенных данных';

CREATE DATABASE IF NOT EXISTS edu_gold
COMMENT 'Слой витрин';

SELECT * FROM system.databases