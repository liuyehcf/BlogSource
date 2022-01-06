---
title: Database-System
date: 2021-12-06 09:39:17
tags: 
- 摘录
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 Introduction

**关系型代数（`Relational algebra`）**

| 符号 | 含义 |
|:--|:--|
| **`σ`** | **Select, Choose a subset of the tuples from a relation that satisfies a selection predicate** |
| **`π`** | **Projection, Generate a relation with tuples that contains only the specified attributes** |
| **`∪`** | **Union, Generate a relation that contains all tuples that appear in either only one or both input relations** |
| **`∩`** | **Intersection, Generate a relation that contains only the tuples that appear in both of the input relations** |
| **`-`** | **Difference, Generate a relation that contains only the tuples that appear in the first and not the second of the input relations** |
| **`×`** | **Product, Generate a relation that contains all possible combinations of tuples from the input relations** |
| **`⋈`** | **Join, Generate a relation that contains all tuples that are a combination of two tuples (one from each input relation) with a common value(s) for one or more attributes** |
| `ρ` | Rename |
| `←` | Assignment |
| `δ` | Duplicate Elimination |
| `γ` | Aggregation |
| `τ` | Sorting |
| `÷` | Division |

# 2 Advanced Sql

`Relational Languages`：用户只需要描述结果，而无需描述如何获取结果

**Sql支持的语法：**

1. `Aggregations + Group By`
1. `String / Date / Time Operations`
1. `Output Control + Redirection`
    * `SORT`
    * `LIMIT`
1. `Nested Queries`
1. `Window Functions`
1. `Common Table Expressions`
    * `WITH`
    * `WITH RECURSIVE`

`COMMON TABLE EXPRESSIONS`

# 3 Storage 1

**存储架构，从上往下依次是：**

1. `Registers`
1. `L1 Cache`、`L2 Cache`、`L3 Cache`
1. `DRAM`
1. `SSD`
1. `HDD`
1. `Network Storage`
* 1-3是易失性存储（`volatile storage`）
* 4-6是非易失性存储（`non-volatile storage`）

**设计目标：**

1. 允许`DBMS`管理超过内存大小的数据
1. 由于直接读写磁盘的开销很大，因此需要避免产生大停顿

![3-1](/images/Database-System/3-1.png)

![3-2](/images/Database-System/3-2.png)

![3-3](/images/Database-System/3-3.png)

![3-4](/images/Database-System/3-4.png)

**为什么不直接使用OS？几乎所有的`DMBS`都希望完全掌控如下事情：**

* 将脏页（`Dirty Page`）以合适的顺序刷入磁盘
* `Prefetching`以提高缓存命中率
* 缓存替换策略
* 线程调度

## 3.1 File Storage

**`Storage Manager`：**

* 管理文件，对读写任务进行调度，以提高时间上以及空间上的局部性
* 以`Page`的形式管理文件

**`Database Pages`：**

* 一个`Page`指的是固定大小的数据
* 每个`Page`都由一个唯一的标识，该标识可以映射到物理位置
* 该`Page`不是`Hardware Page`也不是`OS Page`
* 组织`Page`的形式有如下几种
    1. `Heap File Organization`
        * `Heap File`中包含了一组无序的`Page`
        * 实现方式有2种：
            1. `Linked List`
                * 每个`Heap File`存储2个指针，分别指向`Free Page List`以及`Data Page List`
                * 每个`Page`存储2个指针，分别指向`Next`以及`Prev`
                * ![3-5](/images/Database-System/3-5.png)
            1. `Page Directory`
                * ![3-6](/images/Database-System/3-6.png)
    1. `Sequential / Sorted File Organization`
    1. `Hashing File Organization`

## 3.2 Page Layout

**`Page Header`：每个`Page`都包含一个`Header`用以存储元数据，包括：**

1. `Page Size`
1. `Checksum`
1. `DBMS Version`
1. `Transaction Visibility`
1. `Compression Information`

**`Slotted Pages`：**

* `Slot Array`中的`Slots`存储的是对应`Tuple`的起始偏移量
* 同时`Header`还需要维护`Slot`的占用情况以及最后一个`Slot`的起始偏移量
* ![3-7](/images/Database-System/3-7.png)

**`Log-Structured File Organization`：**

* 不同于`Slotted Pages`存储`Tuple`，`Log-Structured File Organization`只存储日志记录，包括
    * `Insert`：存储整个`Tuple`
    * `Delete`：标记`Tuple`被删除
    * `Update`：只包含待更新的属性
* 在读取记录时，`DBMS`扫描日志，并依据日志重建`Tuple`
* 构建索引，用于在不同记录之间进行跳转
* 定期整理精简日志
* ![3-8](/images/Database-System/3-8.png)

## 3.3 Tuple Layout

**`Tuple`本质上就是一个字节序列，`DBMS`需要将`Tuple`对应的字节序列解析成对应的属性和数值**

![3-9](/images/Database-System/3-9.png)

**`Tuple Header`用于存储元数据，包括：**

* 可见性（并发控制）
* 针对`NULL`的`Bit Map`

**`Tuple Data`：**

* 按照创建`Table`时定义的顺序依次存储每个属性

**`Records ids`：**

* 每个`Tuple`都由一个唯一标识，通常是`page_id + offset/slot`

# 4 Storage 2

## 4.1 Data Representation

1. `integer/bigint/smallint/tinyint`：`C/C++ Representation`
1. `float/real/numeric/decimal`：`IEEE-754 Standard`/`Fixed-point Decimals`
1. `varchar/varbinary/text/blob`：`header + bytes`，其中`header`中记录长度信息
1. `time/date/timestamp`：`32/64`位的整数来存储unix时间戳

**`Variable Precision Numbers`：**

* 这些类型包括：`float/real/double`
* `precision`以及`scale`会变化
* 一般用`C/C++`的原生类型来表示
* 效率很高，但是存在`Rounding Errors`，比如`0.1 + 0.2 != 0.3`

**`Fixed Precision Numbers`：**

* 这些类型包括：`numeric/decimal`
* `precision`以及`scale`固定
* 不会出现`Rounding Errors`

**`Postgres`对`numeric`的定义如下：**

```cpp
typedef unsigned char NumericDigit;
typedef struct {
    int ndigits;
    int weight;
    int scale;
    int sign;
    NumericDigit* digits;
} numeric;
```

**`Larget Values`：**

* 大多数`DBMS`系统不允许`Tuple`的大小超过单个`Page`的大小
* 部分`DBMS`则允许，它们会用一个`Overflow Page`来存储
* ![4-1](/images/Database-System/4-1.png)

**`External Value Storage`：**

* 部分系统允许在外部文件中存储一个特别大的数值，它会被当成`Blob`类型
* `DBMS`无法操作外部文件的内容
* ![4-2](/images/Database-System/4-2.png)

## 4.2 System Catalogs

**`DBMS`会在`catalogs`中存储数据库的元数据，包括**

* 表、列、索引、视图
* 用户、权限
* 内部统计数据

**几乎所有的`DBMS`都会存储其数据库的目录本身：**

* 我们可以通过查询`INFORMATION_SCHEMA`来获取数据库的元数据信息

```sql
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE table_catalog = '<db name>';

SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE table_name = '<table name>';
```

**关系模型并不要求我们将一个`Tuple`的所有属性都存储在同一个`Page`中，不同的存储布局适用于不同的工作负载：**

* `OLTP`：查询或更新单一实体的部分数据
* `OLAP`：查询横跨多实体的大量数据
* ![4-3](/images/Database-System/4-3.png)

## 4.3 Storage Models

`DBMS`可以通过不同的存储方式来适应`OLTP`或者`OLAP`的工作负载

### 4.3.1 N-ARY Storege Model

`N-ARY Storage Model`又称为行存（`Row Storage`）

**在行存中，`DBMS`会将一个`Tuple`中的属性连续存储。对于`OLTP`而言，这是一种理想的存储模型，因为在`OLTP`中，大部分的查询只操作单个实体，并且伴随着大量的插入操作**

![4-4](/images/Database-System/4-4.png)

**优势：**

* 插入、更新、删除效率高
* 对于需要获取全量属性的查询友好

**劣势：**

* 对于需要全量扫描某几个属性的查询不友好

### 4.3.2 Decomposition Storage Model

`Decomposition Storage Model`又称为列存（`Column Store`）

**在列存中，`DBMS`会独立存储不同的属性。对于`OLAP`而言，这是一种理想的存储模型，因为在`OLAP`中，大部分查询都需要扫描全表中的某几个属性**

![4-5](/images/Database-System/4-5.png)

**`Tuple Identification`：**

* 方案1：约定同一个`Tuple`的不同属性，在其列存中的索引都一样
* 方案2：每个列中的元素，额外存储行信息
* ![4-6](/images/Database-System/4-6.png)

**优势：**

* `I/O`友好，因为只需要查询需要的列
* 对数据压缩更友好，同一列中，数据同质化，能达到更好的压缩效率

**劣势：**

* 全量属性点查、插入、更新、删除不友好

# 5 Buffer Pool

# 6 Hash Tables

# 7 Trees1

# 8 Trees2

# 9 Index Concurrency

# 10 Sorting

# 11 Joins

# 12 Query Execution 1

# 13 Query Execution 2

# 14 Optimization 1

# 15 Optimization 2

# 16 Concurrency Control

# 17 Two Phase Locking

# 18 Timestamp Ordering

# 19 Multiversoning

# 20 Logging

# 21 Recovery

# 22 Distributed

# 23 Distributed OLTP

# 24 Distributed OLAP

# 25 Oracle

# 26 Potpourri

# 27 缩写表

| 缩写 | 全称 |
|:--|:--|
| `DBMS` | Database Management System |
| `DML` | Data Manipulation Language |
| `DDL` | Data Definition Language |
| `DCL` | Data Control Language |
| `CTE` | Common Table Expressions |
| `HDD` | Hard Disk Drive |
| `SSD` | Solid-state Drive |
| `OLTP` | On-line Transaction Processing |
| `OLAP` | On-line Analytical Processing |

# 28 CMU-课件

1. [01-introduction](/resources/Database-System/01-introduction.pdf)
1. [02-advancedsql](/resources/Database-System/02-advancedsql.pdf)
1. [03-storage1](/resources/Database-System/03-storage1.pdf)
1. [04-storage2](/resources/Database-System/04-storage2.pdf)
1. [05-bufferpool](/resources/Database-System/05-bufferpool.pdf)
1. [06-hashtables](/resources/Database-System/06-hashtables.pdf)
1. [07-trees1](/resources/Database-System/07-trees1.pdf)
1. [08-trees2](/resources/Database-System/08-trees2.pdf)
1. [09-indexconcurrency](/resources/Database-System/09-indexconcurrency.pdf)
1. [10-sorting](/resources/Database-System/10-sorting.pdf)
1. [11-joins](/resources/Database-System/11-joins.pdf)
1. [12-queryexecution1](/resources/Database-System/12-queryexecution1.pdf)
1. [13-queryexecution2](/resources/Database-System/13-queryexecution2.pdf)
1. [14-optimization1](/resources/Database-System/14-optimization1.pdf)
1. [15-optimization2](/resources/Database-System/15-optimization2.pdf)
1. [16concurrencycontrol](/resources/Database-System/16concurrencycontrol.pdf)
1. [17-twophaselocking](/resources/Database-System/17-twophaselocking.pdf)
1. [18-timestampordering](/resources/Database-System/18-timestampordering.pdf)
1. [19-multiversioning](/resources/Database-System/19-multiversioning.pdf)
1. [20-logging](/resources/Database-System/20-logging.pdf)
1. [21-recovery](/resources/Database-System/21-recovery.pdf)
1. [22-distributed](/resources/Database-System/22-distributed.pdf)
1. [23-distributedoltp](/resources/Database-System/23-distributedoltp.pdf)
1. [24-distributedolap](/resources/Database-System/24-distributedolap.pdf)
1. [25-oracle](/resources/Database-System/25-oracle.pdf)
1. [26-potpourri](/resources/Database-System/26-potpourri.pdf)

进度：01
