---
title: Database-Product-Analysis
date: 2022-01-14 14:31:10
tags: 
- 摘录
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 [ClickHouse](https://clickhouse.com/)

**类型：`OLAP`**

**特性：**

1. 列存
1. 压缩性能高。由于列存，数据同质化，便于压缩，较易获得较高的压缩比
1. 多核并行处理
1. MMP
1. 支持`ANSI SQL`标准
1. 向量化。数据按列组织，具有较好的空间局部性，对`Cache`友好，向量化效果好
1. 支持数据实时写入
1. 索引
1. 支持在线查询
1. 不支持事务

**架构：**

**资料：**

* [home](https://clickhouse.com/)
* [github](https://github.com/ClickHouse/ClickHouse)

# 2 Delta

**类型：`Data Lake`**

**特性：**

**架构：**

**资料：**

* [home](https://delta.io/)
* [github](https://github.com/delta-io/delta)

# 3 Doris

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://doris.apache.org/)
* [github](https://github.com/apache/incubator-doris)

# 4 Druid

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://druid.apache.org/)
* [github](https://github.com/apache/druid/)

# 5 Gbase

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

# 6 GreenPlum

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://greenplum.org/)
* [github](https://github.com/greenplum-db/gpdb)

# 7 Hawq

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://hawq.apache.org/)
* [github](https://github.com/apache/hawq)

# 8 Hive

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://hive.apache.org/)
* [github](https://github.com/apache/hive)

# 9 Hudi

**类型：`Data Lake`**

**特性：**

**架构：**

**资料：**

* [home](https://hudi.apache.org/)
* [github](https://github.com/apache/hudi)

# 10 Iceberg

**类型：`Data Lake`**

**特性：**

**架构：**

**资料：**

* [home](https://iceberg.apache.org/)
* [github](https://github.com/apache/iceberg)

# 11 Impala & Kudu

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [kudu-home](https://kudu.apache.org/)
* [kudu-github](https://github.com/apache/kudu)
* [impala-home](https://impala.apache.org/)
* [impala-github](https://github.com/apache/impala)

# 12 Kylin

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://kylin.apache.org/cn/)
* [github](https://github.com/apache/kylin)

# 13 Pinot

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://pinot.apache.org/)
* [github](https://github.com/apache/pinot)

# 14 Presto

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://prestodb.io/)
* [github](https://github.com/prestodb/presto)

# 15 Starrocks

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://www.starrocks.com/zh-CN/index)
* [github](https://github.com/StarRocks/starrocks)

# 16 Snowflake

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://www.snowflake.com/)

# 17 Sparksql

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

# 18 TiDB

**类型：`OLTP`**

**特性：**

**架构：**

**资料：**

* [home](https://docs.pingcap.com/zh/tidb/stable/)
* [github](https://github.com/pingcap/tidb)

# 19 Vertica

**类型：`OLAP`**

**特性：**

**架构：**

**资料：**

* [home](https://www.vertica.com/)

# 20 参考

* [你需要的不是实时数仓 | 你需要的是一款合适且强大的OLAP数据库(上)](https://segmentfault.com/a/1190000020385432)
* [你需要的不是实时数仓 | 你需要的是一款强大的OLAP数据库(下)](https://segmentfault.com/a/1190000020385389)
* [开源OLAP引擎测评报告(SparkSql、Presto、Impala、HAWQ、ClickHouse、GreenPlum)](https://blog.csdn.net/oDaiLiDong/article/details/86570211)
