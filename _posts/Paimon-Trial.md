---
title: Paimon-Trial
date: 2024-06-07 23:05:38
tags: 
- 原创
categories: 
- Database
- Lakehouse
---

**阅读更多**

<!--more-->

# 1 Paimon With Hive

[Doc](https://paimon.apache.org/docs/master/engines/hive/)

First, start a hive cluster by [docker-hive](https://github.com/big-data-europe/docker-hive)

```sh
cd docker-hive
docker-compose up -d
```

Second, download paimon-hive-connector with corresponding version.

```sh
wget -O paimon-hive-connector-2.3-0.8.0.jar 'https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-hive-connector-2.3/0.8.0/paimon-hive-connector-2.3-0.8.0.jar'
```

Then, copy the jar file into hive's container, and restart it

```sh
docker exec docker-hive-hive-server-1 mkdir -p /opt/hive/auxlib
docker cp paimon-hive-connector-2.3-0.8.0.jar docker-hive-hive-server-1:/opt/hive/auxlib
docker restart docker-hive-hive-server-1
```

Finally, test it:

```sh
docker exec -it docker-hive-hive-server-1 bash
/opt/hive/bin/beeline -u jdbc:hive2://localhost:10000

CREATE TABLE `hive_paimon_test_table`(
  `a` int COMMENT 'The a field',
  `b` string COMMENT 'The b field'
) STORED BY 'org.apache.paimon.hive.PaimonStorageHandler';

INSERT INTO hive_paimon_test_table (a, b) VALUES (1, '1'), (2, '2');

SELECT * FROM hive_paimon_test_table;
```

# 2 Paimon With Spark

[Doc](https://paimon.apache.org/docs/master/spark/quick-start/)

First, start a spark cluster by [docker-spark](https://github.com/big-data-europe/docker-spark)

```sh
cd docker-spark
docker-compose up -d
```

Second, download paimon-spark with corresponding version.

```sh
wget -O paimon-spark-3.3-0.8.0.jar 'https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-spark-3.3/0.8.0/paimon-spark-3.3-0.8.0.jar'
```

Then, copy the jar file into hive's container

```sh
docker cp paimon-spark-3.3-0.8.0.jar spark-master:/spark/jars
```

Finally, test it:

```sh
docker exec -it spark-master bash
# Catalogs are configured using properties under spark.sql.catalog.(catalog_name)
/spark/bin/spark-sql --jars /spark/jars/paimon-spark-3.3-0.8.0.jar \
    --conf spark.sql.catalog.my_test_paimon=org.apache.paimon.spark.SparkCatalog \
    --conf spark.sql.catalog.my_test_paimon.warehouse=file:/spark/paimon \
    --conf spark.sql.extensions=org.apache.paimon.spark.extensions.PaimonSparkSessionExtensions

USE my_test_paimon;
USE default;

create table my_table (
    k int,
    v string
) tblproperties (
    'primary-key' = 'k'
);

INSERT INTO my_table VALUES (1, 'Hi'), (2, 'Hello');

SELECT * FROM my_table;

# Switch back to default catalog
USE spark_catalog;
USE default;

SELECT * FROM my_test_paimon.default.my_table;
```

# 3 Paimon With Flink

[Doc](https://paimon.apache.org/docs/master/flink/quick-start/)

First, start a hive cluster by [docker-flink](https://github.com/big-data-europe/docker-flink)

```sh
cd docker-flink
docker-compose up -d
```
