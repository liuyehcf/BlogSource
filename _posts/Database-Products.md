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
1. `MPP`架构
1. 支持`ANSI SQL`标准
1. 向量化。数据按列组织，具有较好的空间局部性，对`Cache`友好，向量化效果好
1. 支持数据实时写入
1. 索引
1. 支持在线查询
1. 不支持事务

**架构：**

**主页：**

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

**主页：**

* [home](https://delta.io/)
* [github](https://github.com/delta-io/delta)

# 3 Doris

**类型：`OLAP`**

**特性：**

**架构：**

**主页：**

* [home](https://doris.apache.org/)
* [github](https://github.com/apache/incubator-doris)

# 4 Druid

**类型：`OLAP`**

**特性：**

1. 列存储架构
1. 可扩展的分布式架构
1. `MPP`架构
1. 支持实时和批处理
1. 具有自动异常恢复、自动负载均衡等能力，运维简单
1. 云原生
1. 使用`bitmap`索引来加速数据过滤
1. 支持数据分区，默认以时间分区
1. 支持近似算法，比如近似计算`count-discount`等，用于应对一些正确性不敏感，但是时间敏感的场景
1. 在查询数据时进行自动汇总，以提高效率

**架构：**

* [Design](https://druid.apache.org/docs/latest/design/architecture.html)
* ![druid_architecture](/images/Database-Products/druid_architecture.png)

**主页：**

* [home](https://druid.apache.org/)
* [github](https://github.com/apache/druid/)

# 5 Gbase

**类型：`OLAP`**

**特性：**

**架构：**

**主页：**

# 6 GreenPlum

**类型：`OLAP`**

**特性：**

1. 先进的基于开销的优化器（`Cost-Based Optimizer, CBO`）
1. `MPP`架构
1. 基于`PostgreSQL 9.4`
1. `Append-optimized storage`
1. 列存
1. 执行引擎采用火山模型（`Volcano-style`）

**架构：**

* [About the Greenplum Architecture](https://gpdb.docs.pivotal.io/5280/admin_guide/intro/arch_overview.html)
* ![greenplum_architecture](/images/Database-Products/greenplum_architecture.jpeg)

**主页：**

* [home](https://greenplum.org/)
* [github](https://github.com/greenplum-db/gpdb)

# 7 Hadoop

**包含三大组件：**

1. `HDFS`：存储
1. `MapReduce`：计算
1. `YARN`：调度

**类型：`Framework`**

**特性：**

**架构：**

**主页：**

* [home](https://hadoop.apache.org/)
* [github](https://github.com/apache/hadoop)

# 8 Hawq

**类型：`OLAP`**

**特性：**

1. 支持`SQL-92`、`SQL-99`、`SQL-2003`、`OLAP extension`
1. 比`Hadoop SQL engines`快
1. 优秀的并行优化器
1. 完整的事务支持
1. 基于`UDP`的流引擎
1. 弹性执行引擎
1. 支持多级分区和基于列表/范围的分区表
1. 支持多种压缩算法
1. 支持多用语言的`UDF`，包括：`Python`、`Perl`、`Java`、`C/C++`、`R`
1. 易接入其他数据源
1. `Hadoop Native`
1. 支持标准链接，包括`JDBC/ODBC`

**架构：**

* [HAWQ Architecture](https://hawq.apache.org/docs/userguide/2.3.0.0-incubating/overview/HAWQArchitecture.html)
* ![hawq_high_level_architecture](/images/Database-Products/hawq_high_level_architecture.png)
* ![hawq_architecture_components](/images/Database-Products/hawq_architecture_components.png)

**主页：**

* [home](https://hawq.apache.org/)
* [github](https://github.com/apache/hawq)

# 9 HBase

**类型：`NoSQL`/`Storage`**

**特性：**

1. 线性和模块化的可扩展性
1. 强一致性的读写
1. 自动和可配置的表分片
1. 自动异常恢复
1. 面向Java的连接器
1. 通过`Block Cache`以及布隆过滤器支持实时查询

**架构：**

* [Architecture of HBase](https://www.geeksforgeeks.org/architecture-of-hbase/)
* ![hbase_architecture](/images/Database-Products/hbase_architecture.png)

**主页：**

* [home](https://hbase.apache.org/)
* [github](https://github.com/apache/hbase)

# 10 Hive

**类型：`OLAP`**

**特性：**

1. 通过`SQL`访问管理数据，`hive`会将其转换成数仓的任务，例如提取/转换/加载（`extract/transform/load, ETL`）、报告和数据分析
1. 支持多种数据格式
1. 支持`HDFS`、`HBase`等存储层
1. 执行引擎通过`Apache Tez`、`Apache Spark`、`MapReduce`等系统来完成具体的操作
1. 通过`Hive LLAP`、`Apache YARN`和`Apache Slider`进行亚秒级查询检索。

**架构：**

* [Design](https://cwiki.apache.org/confluence/display/hive/design)
* ![hive_architecture](/images/Database-Products/hive_architecture.png)

**主页：**

* [home](https://hive.apache.org/)
* [github](https://github.com/apache/hive)

# 11 Hudi

**类型：`Data Lake`**

**特性：**

1. 更新、删除性能好，索引插件化
1. 事务、回滚、并发控制
1. 自动调整文件大小、数据集群、压缩、清理
1. 用于可扩展存储访问的内置元数据跟踪
1. 增量查询，记录级别更改流
1. 支持多种数据源，包括`Spark`、`Presto`、`Trino`、`Hive`

**架构：**

* [Design And Architecture](https://cwiki.apache.org/confluence/display/HUDI/Design+And+Architecture)
* ![hudi_architecture](/images/Database-Products/hudi_architecture.png)

**主页：**

* [home](https://hudi.apache.org/)
* [github](https://github.com/apache/hudi)

# 12 Iceberg

**类型：`Data Lake`**

**特性：**

**架构：**

**主页：**

* [home](https://iceberg.apache.org/)
* [github](https://github.com/apache/iceberg)

# 13 Impala

**类型：`OLAP`**

**特性：**

1. 支持SQL
1. 支持在`Hadoop`上查询大量数据
1. 分布式架构
1. 无需复制或导出/导入步骤即可在不同组件之间共享数据文件；例如，用`Pig`编写，用`Hive`转换，用`Impala`查询。`Impala`可以读取和写入`Hive`表，从而使用`Impala`实现简单的数据交换，以分析`Hive`生成的数据
1. 用于大数据处理和分析的单一系统，因此客户可以避免仅用于分析的昂贵建模和`ETL`

**架构：**

* [Impala-Architecture](https://www.tutorialspoint.com/impala/impala_architecture.htm)
* ![impala_architecture](/images/Database-Products/impala_architecture.jpeg)

**主页：**

* [impala-home](https://impala.apache.org/)
* [impala-github](https://github.com/apache/impala)

# 14 Kudu

**类型：`Columnar Storage`**

**特性：**

1. 能快速处理`OLAP`的工作负载
1. 与`MapReduce`、`Spark`和其他`Hadoop`生态系统组件集成较好
1. 与`Apache Impala`高度集成
1. 强大但灵活的一致性模型，允许基于每个请求选择不同的一致性模型，包括严格序列化一致性的选项
1. 同时支持顺序和随机的工作负载，且性能较好
1. 便于管理
1. 高可用
1. 结构化的数据模型

**架构：**

* [Architectural Overview](https://kudu.apache.org/docs/#_architectural_overview)
* ![kudu_architecture](/images/Database-Products/kudu_architecture.png)

**主页：**

* [kudu-home](https://kudu.apache.org/)
* [kudu-github](https://github.com/apache/kudu)

# 15 Kylin

**类型：`OLAP`**

**特性：**

1. 为`Hadoop`提供标准`SQL`支持大部分查询功能
1. 多维体立方
1. 实时多维分析
1. 与`BI`工具无缝整合，包括`Tableau`，`PowerBI/Excel`，`MSTR`，`QlikSense`，`Hue`和 `SuperSet`

**架构：**

* ![kylin_architecture](/images/Database-Products/kylin_architecture.png)

**主页：**

* [home](https://kylin.apache.org/cn/)
* [github](https://github.com/apache/kylin)

# 16 Pinot

**类型：`OLAP`**

**特性：**

1. 列存
1. 索引插件化，支持包括`Sorted Index`、`Bitmap Index`、`Inverted Index`、`StarTree Index`、`Bloom Filter`、`Range Index`、`Text Search Index(Lucence/FST)`、`Json Index`、`Geospatial Index`
1. 可以基于元数据进行查询优化
1. 支持从`Kafka`、`Kinesis`中实时获取数据
1. 支持从`Hadoop`、`S3`、`Azure`、`GCS`中批量获取数据
1. 提供类似于`SQL`的语言，用于聚合、过滤、分组、排序等操作
1. 易于水平扩展，容错性好

**架构：**

* [Architecture(https://docs.pinot.apache.org/basics/architecture)
* ![pinot_architecture](/images/Database-Products/pinot_architecture.svg)

**主页：**

* [home](https://pinot.apache.org/)
* [github](https://github.com/apache/pinot)

# 17 PostgreSQL

**类型：`OLAP`**

**特性：**

**架构：**

**主页：**

* [home](https://www.postgresql.org/)
* [github](https://github.com/postgres/postgres)

**其他：**

* [PostgreSQL衍生产品](https://wiki.postgresql.org/wiki/PostgreSQL_derived_databases)
* [PostgreSQL 与 MySQL 相比，优势何在？](https://www.zhihu.com/question/20010554/answer/94999834)

# 18 Presto

**类型：`OLAP`**

**特性：**

1. 支持就地分析（`In-place analysis`）。直接对接数据源，包括`Hive`、`Cassandra`、`Relational Databases`甚至是专有数据存储
1. 允许单个查询的数据来自不同的数据源

**架构：**

* [Introduction to Presto](https://prestodb.io/overview.html)
* ![presto_architecture](/images/Database-Products/presto_architecture.png)

**主页：**

* [home](https://prestodb.io/)
* [github](https://github.com/prestodb/presto)

# 19 Starrocks

**类型：`OLAP`**

**特性：**

1. `MPP`架构
1. 架构精简，不依赖外部系统
1. 全面向量化引擎
1. 只能查询分析
1. 联邦查询
1. 物化视图
1. 兼容mysql协议

**架构：**

* [StarRocks的系统架构](https://docs.starrocks.com/zh-cn/main/quick_start/Architecture)
* ![starrocks_architecture](/images/Database-Products/starrocks_architecture.png)

**主页：**

* [home](https://www.starrocks.com/zh-CN/index)
* [github](https://github.com/StarRocks/starrocks)

# 20 Snowflake

**类型：`OLAP`**

**特性：**

1. 数据安全
1. 支持标准以及扩展`SQL`
1. 大量的工具
1. 面向各类语言的连接器，包括`Python`、`Spark`、`Node.js`、`Go`、`.NET`、`JDBC`、`ODBC`、`PHP`等等

**架构：**

* [Key Concepts & Architecture](https://docs.snowflake.com/en/user-guide/intro-key-concepts.html)
* ![snowflake_architecture](/images/Database-Products/snowflake_architecture.png)

**主页：**

* [home](https://www.snowflake.com/)

# 21 Spark

**类型：`Analytics Engine`（`Alternative to MapReduce`）**

**特性：**

1. 支持流批
1. 支持`ANSI SQL`

**架构：**

* ![spark_ecology](/images/Database-Products/spark_ecology.png)

**主页：**

* [home](https://spark.apache.org/)
* [github](https://github.com/apache/spark)

# 22 TiDB

**类型：`OLTP`**

**特性：**

1. 一键水平扩容或者缩容
1. 金融级高可用
1. 实时`HTAP`
1. 云原生的分布式数据库
1. 兼容`MySQL 5.7`协议和`MySQL`生态

**架构：**

* [TiDB 整体架构](https://docs.pingcap.com/zh/tidb/stable/tidb-architecture)
* ![tidb_architecture](/images/Database-Products/tidb_architecture.png)

**主页：**

* [home](https://docs.pingcap.com/zh/tidb/stable/)
* [github](https://github.com/pingcap/tidb)

# 23 Trino

**类型：**

**特性：**

1. 并行化、分布式的查询引擎，查询速度快
1. 兼容`ANSI SQL`，与`BI`工具集成较好，包括`R`、`Tablau`、`Power BI`、`Superset`
1. 支持多种工作负载，包括实时分析、批处理、亚秒级查询
1. 支持就地分析（`In-place analysis`）。直接对接数据源，包括`Hadoop`、`S3`、`Cassandra`、`MySQL`等
1. 允许单个查询的数据来自不同的数据源
1. 支持云原生

**架构：**

* [Trino Architecture](https://www.oreilly.com/library/view/trino-the-definitive/9781098107703/ch04.html)
* ![trino_architecture_01](/images/Database-Products/trino_architecture_01.png)
* ![trino_architecture_02](/images/Database-Products/trino_architecture_02.png)

**主页：**

* [home](https://trino.io/)
* [github](https://github.com/trinodb/trino)

# 24 Vertica

**类型：`OLAP`**

**特性：**

**架构：**

**主页：**

* [home](https://www.vertica.com/)

# 25 TODO

1. mysql
1. sqlite
1. duckdb

# 26 参考

* [你需要的不是实时数仓 | 你需要的是一款合适且强大的OLAP数据库(上)](https://segmentfault.com/a/1190000020385432)
* [你需要的不是实时数仓 | 你需要的是一款强大的OLAP数据库(下)](https://segmentfault.com/a/1190000020385389)
* [开源OLAP引擎测评报告(SparkSql、Presto、Impala、HAWQ、ClickHouse、GreenPlum)](https://blog.csdn.net/oDaiLiDong/article/details/86570211)
