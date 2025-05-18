---
title: ClickHouse-Trial
date: 2022-07-18 20:17:45
tags: 
- 原创
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 Tips

## 1.1 如何创建分布式表

[Distributed Table Engine](https://clickhouse.com/docs/en/engines/table-engines/special/distributed/#distributed-creating-a-table)

首先，在每个节点创建本地表

```sql
CREATE TABLE IF NOT EXISTS t0_local (fn_int UInt32,fn_int_null UInt32, par_int_low UInt32, par_int_high UInt32, par_str_low LowCardinality(String), par_str_high String) ENGINE = MergeTree() PRIMARY KEY (fn_int)
```

然后，在任意一个节点，创建分布式表

```sql
CREATE TABLE IF NOT EXISTS t0 (fn_int UInt32,fn_int_null UInt32, par_int_low UInt32, par_int_high UInt32, par_str_low LowCardinality(String), par_str_high String) ENGINE = Distributed('perftest_3shards_1replicas', 'analytic_1M', 't0_local', fn_int)
```

这流程，属实一言难尽😢

## 1.2 如何查看配置

```sql
select * from system.settings;
```

## 1.3 如何删除数据

[TRUNCATE Statement](https://clickhouse.com/docs/en/sql-reference/statements/truncate/)

## 1.4 clickhouse-client

* `-m`：多行模式，以`;`作为`SQL`结束标识符，默认以换行作为结束标识符

```sh
clickhouse-client -h 172.26.194.221 --password sr -m
```

## 1.5 How to output table to csv

```sql
SELECT * FROM lineitem limit 5 INTO OUTFILE '/path/test.csv' FORMAT CSV;
```

## 1.6 How to output hdfs file to csv

Follow doc [Install ClickHouse](https://clickhouse.com/docs/en/install), start a clickhouse local, and execute sql like

```sql
INSERT INTO FUNCTION file('ssb100.csv', `CSV`)
SELECT * FROM hdfs('hdfs://xxx:8020/user/hive/warehouse/lineorder_flat/*', 'Parquet');
```

## 1.7 Format

1. TSVRaw
    * Outputs only the raw data, with no column names (unlike TSV, which includes a header row).
    * Does not escape characters like newlines (`\n`), tabs (`\t`), or backslashes.
    * Preserves multi-line strings exactly as they are stored, including real line breaks.

# 2 Hash Functions

## 2.1 CityHashV2

[google/cityhash](https://github.com/google/cityhash)

* [v1.0.2](https://github.com/google/cityhash/commit/bc38ef45ddbbe640e48db7b8ef65e80ea7f71298)
