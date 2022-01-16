---
title: Database-Products
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

1. 基于`Spark`上的`ACID`事务：可序列化的隔离级别确保读者永远不会看到不一致的数据
1. 可扩展的元数据处理：利用`Spark`分布式处理能力轻松处理具有数十亿文件的`PB`级表的所有元数据
1. 流和批处理统一
1. `Schema enforcement`：自动处理`Schema`的变化，以防止在变更过程冲插入异常记录
1. `Time travel`：数据版本控制支持回滚、完整的历史审计跟踪
1. `Upserts`和`Deletes`：支持合并、更新和删除操作，以启用复杂的用例

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

1. `Columnar storage format`：列存储架构
1. `Scalable distributed system`：可扩展的分布式架构
1. `Massively parallel processing`：MPP架构的计算引擎
1. `Realtime or batch ingestion`：支持实时和批处理
1. `Self-healing, self-balancing, easy to operate`：具有自动异常恢复、自动负载均衡等能力，便于操作
1. `Cloud-native, fault-tolerant architecture that won't lose data`：不会丢失数据的云原生容错架构
1. `Indexes for quick filtering`：使用`bitmap`索引来加速数据过滤
1. `Time-based partitioning`：支持数据分区，默认以时间分区
1. `Approximate algorithms`：支持近似算法，比如近似计算`count-discount`等，用于应对一些正确性不敏感，但是时间敏感的场景
1. `Automatic summarization at ingest time`：在查询数据时进行自动汇总，以提高效率

**架构：**

* ![druid-architecture](/images/Database-Products/druid-architecture.png)
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
