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

**`Database Storage`的两个问题：**

1. `DBMS`如何用磁盘上的文件表示数据库
1. `DBMS`如何管理其内存并从磁盘来回移动数据

**`Spatial Control`：**

* 将`Page`刷到磁盘上的什么位置
* 目标是让经常一起使用的页面在磁盘上尽可能地靠近在一起

**`Temporal Control`：**

* 何时将`Page`读入内存，何时将其写入磁盘
* 目标是最大限度地减少从磁盘读取数据的延时

## 5.1 Buffer Pool Manager

**内存结构**

* **内存区域被组织成由多个定长`Page`构成的数组，数组中的每个元素称为`Frame`（`Page`需要放置到`Frame`中）**
* **每个在内存中的`Page`都会记录在`Page Table`中**
* ![5-1](/images/Database-System/5-1.png)

**`Locks vs. Latches`**

* `Locks`
    * 保护数据库的逻辑内容免受其他事务的影响
    * 在事务期间持有
    * 需要支持回滚
* `Latches`
    * 保护`DBMS`中的关键数据避免收到其其他线程的影响
    * 在操作期间持有
    * 无需支持回滚

**`Page Table vs. Page Directory`**

* `Page Table`
    * 存储的是`Page Id`到`Buffer Pool Frame`的映射关系
* `Page Directory`
    * 存储的是`Page Id`到该`Page`对应的磁盘文件的位置

**`Buffer Pool Optimization`：**

* `Multiple Buffer Pool`
    * `Per-database buffer pool`
    * `Per-page type buffer pool`
    * 分成多个`Pool`可以减少`Latch`的竞争
* `Pre-Fetching`
    * 针对部分查询，比如`Sequential Scans`、`Index Scans`，可以将`Page`预取到`Buffer Poll`中的`Frame`
* `Scan Sharing`
    * 相同或者不同的查询（只要`Scan`部分相同或相似），可以复用同一份数据（这里指的是内存中的`Page`，无需取多次）
* `Buffer Pool Bypass`
    * `Sequential Scan`不会将从存储层取到的`Page`放入`Buffer Pool`，从而降低负载
    * 在`Informix`中被称为`Light Scans`

**大多数`DBMS`会使用直接`I/O`（`Direct I/O`）来绕开`OS' Cache`**

* `OS Cache`提供的预读取、顺序读等特性，并不适用于所有场景，比如数据库
* 数据库通常都由自己的一套缓存机制，如果不使用`Direct I/O`，就会存在双重`Cache`

## 5.2 Replacement Policies

当`DBMS`需要释放一个`Frame`来为新的`Page`腾出空位时，需要决定释放`Buffer Pool`中的哪一个`Frame`

**替换策略的设计目标包括：**

1. 正确性
1. 准确性
1. 效率
1. 开销

### 5.2.1 Least-Recently Used

需要维护每个`Page`最近一次访问的时间戳。当`DBMS`需要驱逐一个`Page`时，选择时间戳最小的那个`Page`

* 保持`Page`的有序性，可以减小驱逐的搜索时间

### 5.2.2 Clock

**`Clock`类似于`LRU`，但是不需要为每个`Page`单独维护一个时间戳，而是：**

* 每个`Page`维护一个`Reverence Bit`，当`Page`被访问时，设置成1
* 通过时钟定时检查，扫描所有`Page`的`Reverence Bit`
    * 若为`1`，那么设置成`0`
    * 若为`0`，择驱逐

**`Clock`和`LRU`的共同问题：`Sequential Flooding`**

* 一个扫描全表的查询会读取该表所有的`Page`
* 这会污染`Buffer Pool`，因为每个`Page`读取一次后就再也不用了

### 5.2.3 LRU-K

**`LRU-K`核心思想是将「最近使用过1次」的判断标准扩展成「最近使用K次」，需要多维护一个队列，用于记录所有缓存数据被访问的历史。只有当数据的访问次数达到`K`次的时候，才将数据放入缓存。当需要淘汰数据时，`LRU-K`会淘汰第`K`次访问时间距当前时间最大的数据**

**`DBMS`会用访问记录来预估下一次`Page`的访问时间**

### 5.2.4 Localization

**`DBMS`根据查询来选择驱逐哪个`Page`**

* 需要追踪每个查询访问的`Page`

### 5.2.5 Priority Hints

**`DBMS`有查询的上下文信息，它能向`Buffer Pool`提供有关页面是否重要的提示**

### 5.2.6 Dirty Pages

**针对脏页的处理策略**

* 如果`Buffer Pool`中的`Page`不是`Dirty`的，那么可以简单的丢弃它
* 如果`Buffer Pool`中的`Page`是`Dirty`的，那么需要将其写回存储层以持久化改动

### 5.2.7 Background Writing

**`DBMS`可以周期性的扫描`Page Table`，并将脏页写回**

* 当脏页被成功写回后，`DBMS`可以选择驱逐该`Page`也可以选择保留该`Page`并将`Dirty Flag`置位
* 注意，在日志写入成功之前，不能写回脏页

## 5.3 Other Memory Pools

`DBMS`需要使用内存来做其他事情，而不仅仅只是缓存`Tuple`以及`Index`，包括：

1. `Sorting + Join Buffers`
1. `Query Caches`
1. `Maintenance Buffers`
1. `Log Buffers`
1. `Dictionary Caches`

## 5.4 总结

1. `DBMS`需要维护缓存而不能依赖`OS Cache`
1. 可以借助查询计划来更好地进行决策，包括：
    * `Evictions`：如何驱逐
    * `Allocations`：如何分配
    * `Pre-Fetching`：如何预取

# 6 Hash Tables

**哈希表实现了一个将键映射到值的无序关联数。通过哈希函数（`Hash Function`）计算出给定键的数组偏移量，从而找到对应的值**

## 6.1 Hash Functions

**关于哈希函数：**

* 如何将大的键空间映射到较小的域
* 如何在性能和冲突概率之间权衡
* 如何处理冲突
* 如何在分配大哈希表和通过额外操作和数据结构来实现插入和查找

**哈希函数的实现：**

* [CRC-64](https://create.stephan-brumme.com/crc32/)
* [MurmurHash](https://github.com/aappleby/smhasher)
* [Google CityHash](https://github.com/google/cityhash)
* [Facebook XXHash](http://cyan4973.github.io/xxHash/)
* [Google FarmHash](https://github.com/google/farmhash)
* ![6-1](/images/Database-System/6-1.png)
* ![6-2](/images/Database-System/6-2.png)

## 6.2 Static Hashing Schemes

### 6.2.1 Linear Probe Hashing

其实现方式是一个巨大的数组

**如何解决冲突：**

* 在插入时，若某个槽位上已经有数据了，那么就顺延到下一个槽位，直至找到一个空的槽位。例如，通过哈希函数算出来的偏移量是`3`，若位置`3`上已经有数据了，那么看下槽位`4`是否空闲，若仍然有数据，继续看槽位`5`，以此类推，直至找到空的槽位
* 需要记录槽位是否被占用
* 在删除后，有两种选择
    * `Tombstone`：将某个槽位标记为删除，这样其他元素就不需要移动
    * `Movement`：如果有必要的话，移动其他元素

**`Non-Unique Keys`：同一个键映射到不同的值**

* 为每个键维护一个链表，哈希表中存的就是键到链表的映射
* 直接在哈希表中进行冗余存储

**缺点：**

* 键值对存放的槽位可能距离最佳槽位（通过哈希计算出来的槽位）很远，这样会导致较差的性能（在这段距离上，是通过遍历查找的）

### 6.2.2 Robin Hood Hashing

**`Robin Hood Hashing`是`Linear Probe Hashing`的变体。每个键值对存放的最佳槽位（通过哈希计算出来的槽位）和实际槽位之间的距离称为`d`，那么`Robin Hood Hashing`的核心思想在于降低距离`d`的总和$\sum{d}$**

* 会在插入、删除时，调整已有元素的位置，从而保证$\sum{d}$最小

### 6.2.3 Cuckoo Hashing

**`Cuckoo Hashing`会维护两个哈希函数和两张哈希表，其中`Hash Function 1`对应`Hash Table 1`，`Hash Function 2`对应`Hash Table 2`**

* 会在插入、删除时，动态调整元素的位置，比如把一个哈希表中的某个元素挪到另一个哈希表中
* 如果动态调整后也无法存入元素，那么会将哈希表进行大小调整（例如扩容）

**举个例子：**

* 插入键值对`A -> V(A）`，其中通过`Hash Function 1`计算出来的槽位是`1`，且`Hash Table 1`中的该槽位空闲，那么直接将其存入
* 插入键值对`B -> V(B）`，其中通过`Hash Function 1`计算出来的槽位是`1`（与`A`冲突），通过`Hash Function 2`计算出来的槽位是`2`，且`Hash Table 2`中的该槽位空闲，那么直接将其存入
* 插入键值对`C -> V(C）`，其中通过`Hash Function 1`计算出来的槽位是`1`（与`A`冲突），通过`Hash Function 2`计算出来的槽位是`2`（与`B`冲突）
    * 将`C -> V(C）`存入`Hash Table 2`中的槽位`2`，此时`B -> V(B）`被换出
    * 将`B -> V(B）`存入`Hash Table 1`中的槽位`1`，此时`A -> V(A）`被换出
    * `A -> V(A）`，通过`Hash Function 2`计算出来的槽位是`3`，且`Hash Table 2`中的该槽位空闲，那么直接将其存入

## 6.3 Dynamic Hashing Schemes

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
| `LRU` | Least-Recently Used |

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
