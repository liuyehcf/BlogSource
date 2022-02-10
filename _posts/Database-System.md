---
title: Database-System
date: 2021-12-06 09:39:17
mathjax: true
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

SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = '<your database name>' ORDER BY table_rows DESC
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

**示意图参考课件中的`18 ~ 31`页**

### 6.2.2 Robin Hood Hashing

**`Robin Hood Hashing`是`Linear Probe Hashing`的变体。每个键值对存放的最佳槽位（通过哈希计算出来的槽位）和实际槽位之间的距离称为`d`，那么`Robin Hood Hashing`的核心思想在于降低距离`d`的总和{% raw %}$\sum{d}${% endraw %}**

* 会在插入、删除时，调整已有元素的位置，从而保证{% raw %}$\sum{d}${% endraw %}最小

**示意图参考课件中的`34 ~ 40`页**

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

**示意图参考课件中的`42 ~ 49`页**

## 6.3 Dynamic Hashing Schemes

`Dynamic Hashing Schemes`的特点是：在必要时会进行`resize`操作

### 6.3.1 Chained Hashing

每个槽位维护一个链表，链表中的元素称为`Bucket`，每个`Bucket`存放`Hash Key`相同的元素

![6-3](/images/Database-System/6-3.png)

### 6.3.2 Extendible Hashing

由于`Chained Hashing`中的`Bucket Chain`可能会不断膨胀，`Extendible Hashing`是`Chained Hashing`的改良版，特点包括：

* 会在必要时对`Bucket Chain`进行分裂操作
* 多个`Slot`可能指向同一个`Bucket Chain`
* 在`Bucket Chain Split`时，会进行`reshuffle`操作，进行重组

**示意图参考课件中的`55 ~ 63`页**

### 6.3.3 Linear Hashing

`Linear Hashing`是`Extendible Hashing`的改良版，特点包括：

* 每个`Bucket`会维护一个`pointer`指向其分裂得到的`Bucket`（如果有分裂过的话）
* 可以通过不同的`Hash`来定位指定的`Bucket`
* 可以使用不同的`Overflow`标准，包括
    * 空间利用率
    * `Bucket Chain`平均长度

**示意图参考课件中的`65 ~ 83`页**

# 7 Trees1

## 7.1 Table Indexes

**表索引（`Table Index`）是表中部分属性的副本，且有序组织，用于提高查询效率。`DBMS`会保证表中数据与索引中的数据在逻辑上是同步的。`DBMS`的任务之一就是为每个查询寻找最合适的索引**

**索引的开销包括：**

1. 存储开销
1. 维护成本

## 7.2 B+ Tree Overview

**`B-Tree Family`包括：**

1. `B-Tree`
1. `B+Tree`
1. `B*Tree`
1. `Blink-Tree`

**`B+Tree`包含如下特点：**

1. 平衡树，各叶子节点高度完全一致
1. 节点存储的数据多，有利于减少磁盘读写
1. 数据有序组织
1. 便于顺序访问
1. 查询、插入、删除等操作的复杂度是`O(log n)`

**关于`B+Tree`的定义可以参考{% post_link BPlus-tree-详解%}**

**`B+Tree`叶节点存放的值是什么？**

* 存放记录`id`
    * `PostgreSQL`
    * `SQLServer`
    * `DB2`
    * `Oracle`
* 存放`Tuple Data`
    * `Sqlite`
    * `SQLServer`
    * `Mysql`
    * `Oracle`

**`B-Tree`和`B+Tree`的差异：**

* `B-Tree`在非叶节点也存储具体的数据，更节省空间
* `B+Tree`只在叶节点存储数据，因此需要额外的非叶节点来辅助索引过程。对顺序访问、范围查找比较友好

**`B+Tree`可视化网站：**

* [BTree](https://www.cs.usfca.edu/~galles/visualization/BTree.html)
* [BPlusTree](https://www.cs.usfca.edu/~galles/visualization/BPlusTree.html)

**聚簇索引`Cluster Indexes`是指，整个数据表以`primary key`作为排序键，进行有序存储**

**哈希索引 vs. B+Tree**

* 哈希索引不支持前缀匹配，比如创建一个包含三列的哈希索引，那么查询条件必须包含这三列才能使用哈希索引
* `B+Tree`支持前缀匹配，比如创建了一个`Index(a, b, c)`，那么`a = 5`、`a = 5 and b = 2`都能使用索引

## 7.3 Design Decisions

在设计实现`B+Tree`时，需要考虑如下节点：

1. `Node Size`：存储性能越差的设备，`Node Size`建议更大
    * `HDD`：1MB
    * `SSD`：10KB
    * `Memory`：512B
1. `Merge Threshold`：**在实现时，并不一定要完全按照定义，比如当某个节点中的数据数量少于容量的一半时，可以不执行合并操作。有些`DBMS`允许`underflows`，且会定期重新构建整颗树**
1. `Variable Length Keys`
    * 节点大小固定，存储`Key`的指针
    * 节点的大小可以动态变化，直接存储`Key`，复杂度提升
    * 节点大小固定，且给`Key`分配的空间是该类型的最大值，不足部分补白，比较浪费空间
    * `Key Map / Indirection`，没看懂
1. `Non-Unique Indexes`
1. `Intra-Node Search`

**`Non-Unique Indexes`有如下两种策略：**

1. 重复存储`Key`
    * ![7-1](/images/Database-System/7-1.png)
1. 每个`Key`维护一个`List`
    * ![7-2](/images/Database-System/7-2.png)

**`Intra-Node Search`节点中的查找策略：**

1. `Linear`：从左往右遍历
1. `Binary`：二分查找
1. `Interpolation`：基于分布信息预估一个位置，然后再继续查找

## 7.4 Optimization

### 7.4.1 Prefix Compression

在同一个叶子节点中，由于`Key`是有序排列的，通常具有相同的前缀

![7-3](/images/Database-System/7-3.png)

### 7.4.2 Suffix Truncation

由于非叶子节点在`B+Tree`仅起到导航作用，因此有时不必存储整个`Key`，只需要存储前缀即可

![7-4](/images/Database-System/7-4.png)

![7-5](/images/Database-System/7-5.png)

### 7.4.3 Bulk Insert

构建一颗`B+Tree`最快的方法是先将所有`Key`排序，从叶节点开始往上构建，这样可以直接避免分裂操作

### 7.4.4 Pointer Swizzling

如果节点通过`Page Id`来引用其他索引中的节点，那么在内存中通过`B+Tree`进行查找时，需要将`Page Id`转换成内存地址。如果该`Page`已经在`Buffer Pool`中时，可以用指针代替`Page Id`

![7-6](/images/Database-System/7-6.png)

![7-7](/images/Database-System/7-7.png)

![7-8](/images/Database-System/7-8.png)

# 8 Trees2

## 8.1 More B+Tree

**`B+Tree`如何处理`Duplicate Keys`：**

* `Append Record Id`：额外存储一个`Unique Id`，来保证所有`Key`的唯一性
    * ![8-1](/images/Database-System/8-1.png)
* `Overflow Leaf Nodes`：允许叶节点存储多余额定数量的数据，用于存储`Duplicate Key`
    * ![8-2](/images/Database-System/8-2.png)

## 8.2 Additional Index Magic

**隐式索引（`Implicit Indexes`）：**

* 大多数`DMBS`系统会创建一个隐式的索引来实现完整性约束

**局部索引（`Partial Indexes`）：**

* 仅在一部分数据上创建索引
* 有效降低索引的大小以及维护的开销
* 一个典型的使用场景是，根据日期来分别创建索引，比如每个月，或者每年单独创建索引
    ```sql
    CREATE INDEX idx_foo
    ON foo(a, b)
    WHERE c = 'WuTang';

    SELECT b FROM foo 
    WHERE a = 123
    AND c = 'WuTang';
    ```

**覆盖索引（`Covering Indexes`）：**

* 如果索引中包含查询所需的字段，那么仅通过索引就可以返回所有的`Tuple`
* 提高查询效率，且可以有效得减少`Buffer Pool`的冲突（不需要额外访问`Page`了）
    ```sql
    CREATE INDEX idx_foo
    ON foo(a, b);

    SELECT b FROM foo
    WHERE a = 123;
    ```

**`Index Include Columns`：**

* 在索引中存储额外的列，这部分信息只能通过索引来查询。例如，`CREATE INDEX idx_foo ON foo(a, b) INCLUDE (c);`
* 这些额外的列只存储在叶节点中，且不属于`Search Key`
    ```sql
    CREATE INDEX idx_foo
    ON foo(a, b)
    INCLUDE(c);

    SELECT b FROM foo
    WHERE a = 123
    AND c = `WuTang`
    ```

**`Observation`：**

* 非叶子结点中的`Key`仅起到导航作用，并不能判断出该`Key`是否真的存在，只能访问到叶子节点中，才能知道某个`Key`是否存在
* 可以通过`Buffer Pool`来协助快速确定某个`Key`是否存在

## 8.3 Tries Tree

**`Tries Tree`称为前缀树或者字典树**

![8-3](/images/Database-System/8-3.png)

**属性：**

* 树形结构仅依赖于键空间（`Key Space`）以及键长（`Key Length`），而不依赖于已有的`Key`以及插入顺序，且不需要平衡操作
* 所有的操作的复杂度都是`O(k)`，其中`k`是键值的长度
* 键值是隐式存储的（从根到叶的整条路径就是`Key`）

**`Key Span`：**

* 当某个字符存在于某一层时，存储一个指向下一层的指针，否则存储`null`
* ![8-4](/images/Database-System/8-4.png)
* **示意图参考课件中的`39 ~ 47`页**

## 8.4 Radix Tree

**`Radix Tree`在`Tries Tree`基础上，做了如下调整：**

* 每个节点如果有孩子，那么至少要有2个孩子，否则就合并到上一层（当分布较为稀疏时，可以大大降低层级）
* **示意图参考课件中的`49 ~ 56`页**

**`Binary Comparable Keys`：并非所有属性类型都可以分解为基数树的二进制可比数字**

* `Unsigned Integers`：小端机器的字节顺序必须翻转
* `Signed Integers`：翻转二进制补码，使负数小于正数
* `Floats`：分类（`neg vs. pos`，归一化 `vs.` 非规范化），然后存储为无符号整数
* `Compound`：分别转换每个属性
* **示意图参考课件中的`58 ~ 60`页**

**`Observation`：**

* 到目前位置，我们讨论的索引仅能有效地进行点查和范围查询
* 并不是用于「在Wikipedia文章中查找包含`Pavlo`的所有文章」这种类型的查询

## 8.5 Inverted Indexe

倒排索引存储「单词」到「包含目标属性中这些单词的记录」的映射，又称为全文索引（`Full-text Search Index`）

这部分内容包含在[CMU 11-442](https://boston.lti.cs.cmu.edu/classes/11-642/)

## 8.6 Geo-Spatial Tree Indexes

包括`R-Tree`、`Quad-Tree`、`KD-Tree`，这部分内容包含在[CMU 15-826](http://www.cs.cmu.edu/~christos/courses/826.S17/)

# 9 Index Concurrency

到目前为止，讨论的数据结构都是在单线程模型下。因此，我们必须允许多个线程安全，高效地访问共享数据，这样才能充分利用多个CPU的计算资源

## 9.1 Latches Overviews

|  | Locks | Latches |
|:--|:--|:--|
| 粒度 | 事务 | 线程 |
| 保护对象 | 用户数据 | 内存中的内部数据结构 |
| 作用范围 | 整个事务 | 部分重要的片段 |
| 模式 | Shared、Exclusive、Update、Intention | Read，Write |
| 死锁 | 检测&解决 | 避免 |

**`Latches`的两种模式：**

* `Read Mode`
    * 多个线程可以同时获取同一个共享对象的`Read Latch`
    * 在其他线程持有同一个共享对象的`Write Latch`时，无法获取该对象`Read Latch`
* `Write Mode`
    * 仅有一个线程可以获取同一个共享对象的`Write Latch`
    * 在其他线程持有同一个共享对象的`Read Latch`或`Write Latch`时，无法获取该对象`Write Latch`

**`Latches`的三种实现方式：**

* `Blocking OS Mutex`，例如`std::mutex`
* `Test-and-Set Spin Latch（TAS）`，例如`std::atomic<T>`
* `Reader-Writer Latch`

## 9.2 Hash Table Latching

由于访问数据结构的方式有限，因此`Hash Table`易于支持并发访问。但是，在进行扩缩容时，需要在整个`Hash Table`上加一个全局的`Latch`，该全局的`Latch`有两种实现方式

* `Page Latches`
    * 每个`Page`都有一个`Read-Write Latch`用于保护该`Page`中的所有数据
    * 线程必须获取`Read Latch`或`Write Latch`之后才能访问一个`Page`
* `Slot Latches`
    * 每个`Slot`都有一个锁，粒度更细
    * 可以使用一个单模式的`Latch`，来降低元数据以及计算的开销
* **示意图参考课件中的`18 ~ 37`页**

## 9.3 B+Tree Latching

**为了能能够并发地访问`B+Tree`，必须解决如下两个问题：**

1. 不同线程同时修改节点中的内容
1. 当一个线程遍历`B+Tree`时，另一个线程在做`Split/Merge`节点的操作

**实现的基本思路：**

* 获取父节点的`Latch`
* 获取子节点的`Latch`
* 当节点`Safe`时，释放父节点的`Latch`
    * 当一个节点不会发生`Split`或者`Merge`操作时，称其为`Safe Node`

**`Find`流程，从根节点开始往下查找，重复如下过程：**

* 获取子节点的`R-Latch`
* 释放父节点的`R-Latch`

**`Insert/Delete`流程，从根节点开始往下查找，重复如下过程：**

* 获取子节点的`W-Latch`，成功获取后，检查它是否是`Safe`的
    * 如果是`Safe`的，那么释放所有祖先的`W-Latch`（因为插入或删除操作引发的`Split`和`Merge`动作不会扩散到该节点的祖先）
    * `Insert`与`Delete`对`Safe`的判断条件是不同的
        * `Insert`只需要考虑`Split`，孩子`Split`时，父节点会增加一个孩子，因此父节点只有非满时，`Split`操作才不会向上扩散
        * `Delete`只需要考虑`Merge`，孩子`Merge`时，父节点会减少一个孩子，因此父节点的孩子数量比一半多时，`Merge`操作才不会向上扩散

**示意图参考课件中的`50 ~ 73`页**

### 9.3.1 优化算法1

**算法思路：**

* 假设叶节点是`Safe`的
* 在`R-Latch`保护下（同`Find`过程），访问叶节点（叶节点获取`W-Latch`），检查它是否是`Safe`的
* 如果叶节点是`Safe`的，那么继续`Insert/Delete`的操作
* 如果叶节点不是`Safe`的，那么退化成原先的算法

**示意图参考课件中的`77 ~ 84`页**

## 9.4 LeafNode Scans

上面介绍的算法仅针对查找、插入、删除。但是如果要将一个叶节点上的数据移动到另一个叶节点上应该怎么操作呢？

**示意图参考课件中的`86 ~ 101`页**

* `89、90`为啥要释放节点C上的`R-Latch`呢？这个时候C节点的数据已经读完了，然后就可以释放了？

**由于`Latch`没有死锁检测或者避免的机制，只能依靠编码原则来规避死锁，因此最好能提供`no-wait`模式**

## 9.5 Delayed Parent Updates

**在`B+Truee`中，当叶节点`Overflow`时，会操作至少三个节点：**

1. 当前叶节点
1. `Split`出来的新节点
1. 当前叶节点的父节点

**`Blink-Tree`优化思路：**

* 当一个叶节点`Overflow`时，延迟更新其父节点，进行标记
    * 当父节点获取`W-Latch`时，才执行更新操作
* 于是，在执行插入或者删除操作时，从根节点开始直至叶节点，除了叶节点之外只需要获取`R-Latch`
    * 当发现一个节点被标记后，原本只需要获取`R-Latch`，需要改成获取`W-Latch`，然后进行更新操作

# 10 Sorting & Aggregate

**查询计划：**

* 查询计划中的算子会被组织成一棵树
* 数据流从叶节点流向根节点
* 根节点的输出就是查询结果

**`Disk-Oriented DBMS`：**

* 就像我们无法假设整个表中的数据可以放入内存一样，我们同样无法假设查询的结果可以全部放入内存
* 需要依赖`Buffer Pool`来实现溢出到磁盘（`spill to disk`）的算法
* 需要可以最大化顺序查询性能的算法

## 10.1 External Merge Sort

**如果全部数据可以放在内存中，那么可以利用一些标准的排序算法，比如快排。如果数据无法全部放在内存中，那么排序算法必须考虑到磁盘`I/O`的开销**

**`External Merge Sort`算法大致可以分为两步：**

1. `Sorting`：将多个数据块中的数据加载到内存中（数据块小于主存大小）排序后写回到文件中
1. `Merging`：将多个有序的文件合并成一个大文件

**`2-Way External Merge Sort`：**

* `n-Way`指的是合并`n`个子序列
* 算法需要3个`Buffer Pool`，两个用于`Input`，一个用于`Output`
* **示意图参考课件中的`11 ~ 18`页**

**`Double Buffering Optimization`：**

* 优化思路：提前将下次合并需要的`Page`加载到缓存中来，这样可以减少`I/O`等待时间

**`General External Merge Sort`：**

* 使用`B`个`Buffer Pool`，`B-1`个用于`Input`，一个用于`Output`，一次合并`B-1`个子序列

**`Using B+Tree For Sorting`：**

* 如果数据存储在`B+Tree`中，那么只需要遍历叶子节点就可以得到排序的数据
* 这里仍然需要区分两种情况
    * `Clustered B+Tree`
        * 直接从左深叶节点（或者指定叶节点）遍历后续叶节点即可得到有序的结果，无排序的计算开销，且所有的磁盘`I/O`都是顺序的
    * `Unclustered B+Tree`
        * 由于叶节点存存储的是指向包含数据的`Page`的内容（指针、引用、id）
        * 昂贵的磁盘`I/O`，几乎每次`I/O`都只读取一个`Page`

## 10.2 Aggregations

可以利用排序来实现`Distinct`（排序后，相同元素一定相邻，便于去重），但是更好的做法是`Hash`，这样可以避免排序

**`External Hashing Aggregate`算法大致可以分为两步：**

1. 将数据`Hash`到不同的分区中（分区处理，内存放不下所有数据）。当分区满了之后，将数据溢出到磁盘
    * 使用哈希函数`h1`
    * 假设我们有`B`个`Buffer Pool`，其中`B-1`个用于`Partition`，一个用于`Input Data`
1. 对于每个分区，在内存中构建`Hash Table`，并通过聚合函数计算聚合属性
    * 使用哈希函数`h2`
* **示意图参考课件中的`37 ~ 45`页**

# 11 Joins

我们通常会将业务数据根据不同的数据模型，存放在多张不同的数据表中，从而避免存储重复的数据。于是，当我们需要的信息分散在不同的数据表中时，我们需要`Join`操作来合并这些信息

通常来说，我们将数据规模更小的那张表称为`Left Table`或者`Outer Table`（在`Starrocks`中，更倾向于右表更小，这样可以构建出一个较小的`Hash Table`）

**示意图参考课件中的`4 ~ 11`页**

**`Join Algorithms`：**

1. `Nested Loop Join`
    * 简单而愚蠢的做法
1. `Sort-Merge Join`
1. `Hash Join`

**下面的分析都针对如下查询：**

```sql
SELECT R.id, S.cdate
FROM R JOIN S
ON R.id = S.id
WHERE S.value > 100
```

**这里涉及的代价计算，只考虑`I/O`开销，且有如下假设：**

1. `R`中有`M`个`Page`，`m`个`tuple`
1. `S`中有`N`个`Page`，`n`个`tuple`

## 11.1 Simple Nested Loop Join

**为啥这个算法很愚蠢？因为对于`R`中的每个`tuple`都要扫描一遍`S`，因此开销是`Cost = M + (m * N)`**

![11-1](/images/Database-System/11-1.png)

## 11.2 Block Nested Loop Join

**`Block Nested Loop Join`该算法在`Nested Loop Join`之上做了进一步的改进，以`Block`为单位进行循环。对于`R`中的每个`Blcok`，扫描一遍`S`，这样可以减小磁盘访问的频率，开销是`Cost = M + (M * N)`**

![11-2](/images/Database-System/11-2.png)

**更进一步，当我们有`B`个`Buffer Pool`时，对于`R`中每`B-2`个`Block`，扫描一遍`S`，这样可以进一步减小磁盘访问的频率，此时开销为`Cost = M + (⌈ M / (B-2) ⌉ * N)`**

* `B-2`个用于扫描`Left Table`
* 1个用于扫描`Right Table`
* 1个用于输出

![11-3](/images/Database-System/11-3.png)

## 11.3 Index Nested Loop Join

**为什么`Nested Loop Join`方法很糟糕？因为需要顺序扫描`S`。我们可以借助索引来快速查找`S`中的匹配项**

1. 使用现有的索引
1. 构建实时索引，比如`Hash Table`、`B+Tree`等

![11-4](/images/Database-System/11-4.png)

**假设索引访问的开销是`C`，那么整体的开销是`Cost = M + (m * C)`**

## 11.4 Sort Merge Join

**`Sort Merge Join`算法的大体思路如下：**

* 首先，对两张表按照`Join`列进行排序
* 然后，合并两张排序后的表，在合并的过程中，过滤出匹配项

![11-5](/images/Database-System/11-5.png)

**示意图参考课件中的`31 ~ 48`页**

**开销计算：**

* {% raw %}$Sort\ Cost(R) = 2M * (1 + \lceil log_{B-1}{\lceil \frac{M}{B} \rceil} \rceil)${% endraw %}
* {% raw %}$Sort\ Cost(S) = 2N * (1 + \lceil log_{B-1}{\lceil \frac{N}{B} \rceil} \rceil)${% endraw %}
* `Merge Cost = M + N`
* `Cost = Sort Cost(R) + Sort Cost(S) + Merge Cost`
* **当`R.id`与`S.id`存在重复时，`M + N <= Merge Cost <= M * N`**
* **当`R.id`与`S.id`全部一样时，退化成最差的情况，此时`Merge Cost = M * N`**

**什么时候使用`Sort Merge Join`：**

1. 当`join`左右两路输入都已经按`join`列排序时
1. 当`join`的结果需要排序时

## 11.5 Hash Join

**如果`r ∈ R`中的元组和`s ∈ S`中的元组满足`join`的条件，那么也就是说`join`列取值相同。当某个元组`r`被哈希到某个分区`i`时，那么`S`中对应的元组`s`也会被哈希到同一个分区。于是只需要在各自分区内进行匹配即可，大大缩减了复杂度**

**`Hash Join`算法的大体思路如下：**

1. `Build Phase`：扫描左表的数据，用哈希函数`h1`构建`Hash Table`
1. `Probe Phase`：扫描右表的数据，对每个元组，用同一个哈希函数`h1`找到对应的分桶，然后在分桶内找匹配项

![11-6](/images/Database-System/11-6.png)

**示意图参考课件中的`55 ~ 59`页**

**优化：**

* 在`Build Phase`构建一个`Bloom Filter`
* 在`Probe Phase`用`Bloom Filter`来快速判断元素是否存在于`Hash Table`中
* 这种方式也被称为`Sideways Information Passing`

**示意图参考课件中的`63 ~ 66`页**

## 11.6 Grace Hash Join

**如果没存不足以存放整个`Hash Table`时，而且不想用`Buffer Pool`，该怎么办？`Grace Hash Join`就是为解决这个问题而提出来的**

**`Grace Hash Join`的大体思路：**

1. `Build Phase`：将左右两张表哈希到不同的分区中
1. `Probe Phase`：在每个分区中查询匹配项

![11-7](/images/Database-System/11-7.png)

**示意图参考课件中的`73 ~ 75`页**

**如果分桶的大小仍然大于内存，那么可以使用`Recursive Partitioning`进行二次分区**

* 使用哈希函数`h2`（`h2 ≠ h1`）对{% raw %}$Bucket_{R,i}${% endraw %}构建`Hash Table`
* 对{% raw %}$Bucket_{S,i}${% endraw %}使用同一个哈希函数`h2`，在上一步构建的`Hash Table`中查找匹配项

**示意图参考课件中的`77 ~ 82`页**

**开销计算：**

* `Partitioning Phase = 2(M + N)`：左右表分别两次哈希，各扫描两次
* `Probing Phase =  M + N`：左右表各扫描一次
* `Cost = Partitioning Phase + Probing Phase = 3(M + N)`

## 11.7 总结

**假设：**

* `M = 1000, m = 100,000`
* `N = 500, n = 40,000`
* `Single I/O Cost = 0.1ms`

| Algorighm | IO Cost | Example |
|:--|:--|:--|
| `Simple Nested Loop Join` | `M + (m * N)` | 1.3 hours |
| `Block Nested Loop Join` | `M + (M * N)` | 50 seconds |
| `Index Nested Loop Join` | `M + (m * C)` | 20 seconds |
| `Sort-Merge Join` | `M + N + (Sort Cost)` | 0.59 seconds |
| `Hash Join` | `3(M + N)` | 0.45 seconds |

# 12 Query Execution 1

## 12.1 Processing Models

`DBMS`的`Processing Model`决定了系统如何执行一个查询计划。不同的`Processing Model`有不同的工作负载

1. `Iterator Model`
1. `Materialization Model`
1. `Vectorized / Batch Model`

### 12.1.1 Iterator Model

**每个算子都要实现`Next`方法**

* 每次触发该方法，都会返回一个`Tuple`或者返回一个标记表示没有可返回的`Tuple`
* 每个算子的`Next`方法都通过调用孩子节点的`Next`方法来获取输入数据（1个`Tuple`），并进行处理，然后返回给上一级节点

![12-1](/images/Database-System/12-1.png)

也称为`Volcano`或者`Pipeline`模型

**示意图参考课件中的`7 ~ 12`页**

**特点：**

* 易于进行输出控制，比如`limit`算子发现输出`Tuple`数量已经够了，非常容易实现提前结束

### 12.1.2 Materialization Model

**每个算子都要实现`Next`方法**

* 每个算子一次处理所有的输入，并产生最终结果
* `Next`方法拿到孩子节点的所有数据后，才会返回
* `DBMS`通常需要进行谓词下推，以免扫描太多数据

**示意图参考课件中的`15 ~ 18`页**

**特点：**

* 更少的函数调用次数
* 适用于`OLTP`，因为每次查询一小部分数据
* 不适用于`OLAP`，因为在查询中会产生非常大的中间结果

### 12.1.3 Vectorized / Batch Model

**每个算子都要实现`Next`方法**

* `Next`方法一次最多返回`Batch`个`Tuple`
* `Batch`可以动态调整

![12-3](/images/Database-System/12-3.png)

**示意图参考课件中的`21 ~ 22`页**

**特点：**

* 较少的函数调用次数
* 适用于`OLAP`，且更有利于使用`SIMD`指令

### 12.1.4 Plan Processing Direction

**执行方向（`Plan Processing Direction`）有两种：**

1. 自顶向下，`Pull`模型
1. 自底向上，`Push`模型

## 12.2 Access Methods

`Access Method`是指`DBMS`如何访问表中的数据。该内容没有定义在关系型代数中

**通常来说有三种方式：**

1. `Sequential Scan`
1. `Index Scan`
1. `Multi-Index/Bitmap Scan`

### 12.2.1 Sequential Scan

**对于表中的每个`Page`：**

* 从`Buffer Pool`获取该`Page`
* 遍历`Page`，检查是否满足条件

**这种方式是效率最差，通常来说有如下几种优化方向：**

1. `Prefetching`
1. `Buffer Pool Bypass`
1. `Parallelization`
1. `Zone Maps`
1. `Late Materialization`
1. `Heap Clustering`

#### 12.2.1.1 Zone Maps

提前计算好每个`Page`中的聚合信息，于是，在某些情况下，只需要先检查`Zone Map`中的数据，就可以判断出是否需要进一步扫描该`Page`

![12-4](/images/Database-System/12-4.png)

#### 12.2.1.2 Late Materialization

其核心思路是，可以延迟将`Tuple`拼接在一起

**示意图参考课件中的`29 ~ 32`页**

### 12.2.2 Index Scan

**`DBMS`使用某个索引来查找所需的`Tuple`，使用哪个索引，取决于：**

* 索引包含哪些属性
* 查询需要哪些属性
* 属性的值域空间
* 谓词构成
* 索引键是否唯一

**如果选择的是非聚簇索引，即获取的`Tuple`以该索引排序，那么按这种顺序从`Page`中读取数据，效率会比较低。因此，通常会先按照`Page Id`进行排序，然后进行磁盘访问**

* **示意图参考课件中的`41 ~ 44`页**

### 12.2.3 Multi-Index/Bitmap Scan

**如果针对某个查询，有多个可用索引时：**

* 用每个索引获取匹配集合
* 合并这些集合，取交集

**示意图参考课件中的`38 ~ 40`页**

**集合如何取交集？可以通过`Bitmap`、`Hash Table`、`Bloom Filter`**

## 12.3 Expression Evaluation

**`DBMS`将`Where`子句表示为一颗`Expression Tree`，通常包含如下类型：**

* `Comparisons`：包括`=, <, >, !=`等
* `Conjunction`：包括`And`
* `Disjunction`：包括`Or`
* `Arithmetic Operators`：包括`+, -, *, /, %`等
* `Const Values`
* `Tuple Attribute References`

![12-5](/images/Database-System/12-5.png)

**示意图参考课件中的`46 ~ 53`页**

**示意图这种方式的效率会比较低：**

* `DBMS`会遍历整棵树，然后每个节点都需要计算一次
* 如果表达式是`WHERE 1=1`，其实可以提前计算

**常用优化手段：**

1. 常量部分，在`SQL`解析阶段直接计算
1. 提取公共表达式
1. 即时编译（`JIT`）

# 13 Query Execution 2

**`Parallel DBMSs`：**

* 共享物理资源
* 线程间通信非常高效
* 通信廉价且可靠

**`Distributed DBMSs`：**

* 资源分布在不同的节点
* 通信效率比较低
* 通信昂贵，且伴随着衍生问题（网络通信是不可靠的）

## 13.1 Process Models

`Process Model`定义了如何构建系统以支持来自多用户应用程序的并发请求。其中，`Worker`是`DBMS`的组件，负责代表客户端执行任务并返回结果

### 13.1.1 Process per DBMS Worker

**在这种架构下，每个`Worker`就是一个独立的`OS Process`：**

* 依赖于操作系统的调度
* 需要利用`Shared Memory`来共享一些全局的数据结构
* 一个进程崩溃，不会导致系统不可用
* 例子：`IBM DB2`、`Postgres`、`Oracle`

### 13.1.2 Process Pool

**在这种架构下，`DBMS`管理了一个进程池，`Work`可以使用该进程池中的空闲进程来处理客户端的请求：**

* 仍然依赖于操作系统的调度，以及`Shared Memory`
* `Cache Locality`较差
* 例子：`IBM DB2`、`Postgres(2015)`

### 13.1.3 Thread per DBMS Worker

**在这种架构下，`DBMS`只有一个进程，但是包含了多个工作线程：**

* 自行实现调度
* 线程切换开销较小，无需管理`Shared Memory`
* 一个线程崩溃，会导致整个进程崩溃，从而导致整个系统不可用
* 例子：`IBM DB2`、`MSSQL`、`MySQL`、`Oracle(2014)`

注意，该架构并不意味着一个请求的执行可以并行化

### 13.1.4 Scheduling

**对于每个查询，`DBMS`需要决定`Where/When/How to execute`：**

* 需要产生多少个任务？
* 需要使用多少个核？
* 任务需要在哪个核上执行
* 任务如何存储其结果

## 13.2 Execution Parallelism

**`Inter VS. Intra Query Parallelism`：**

* **`Inter-Query`：重点在于，不同的查询可以并行执行，可以提高吞吐量以及降低时延**
* **`Intra-Query`：重点在于，同一个查询可以分成多个子任务然后并行执行（或者说算子并行执行），可以降低复杂查询的时延**

### 13.2.1 Intra-Query Parallelism

**`Parallel Grace Hash Join`：**

* 对于每个`Bucket`中的`R`和`S`的子集，使用一个独立的线程来进行`Join`运算
* ![13-1](/images/Database-System/13-1.png)

#### 13.2.1.1 Intra-Operator (Horizontal)

**核心思想：将算子并行化，这些算子对不同的数据子集执行相同的操作。此外，需要额外增加`Exchange`算子，来合并孩子节点的数据**

![13-2](/images/Database-System/13-2.png)

**示意图参考课件中的`22 ~ 27`页**

**`Exchange`算子有如下三种类型：**

* `Gather`：将多路输入合并成一路输出
* `Repartition`：将多路输入，重新组织成多路输出
* `Distribute`：将一路输入，重新组织成多路输出
* **示意图参考课件中的`29 ~ 36`页**

#### 13.2.1.2 Inter-Operator (Vertical)

**每种算子使用一个线程**

**示意图参考课件中的`38 ~ 40`页（没太看明白）**

#### 13.2.1.3 Bushy

**`Inter-Operator`的扩展，多个算子组成一个算子组，每种算子组使用一个线程，不同算子组之间需要通过`Exchange`来交互数据**

![13-3](/images/Database-System/13-3.png)

## 13.3 I/O Parallelism

在磁盘`I/O`成为性能瓶颈时，增加并行度不会提升效率，反而有可能降低效率，因为增大了磁盘读写的乱序程度

**`DBMS`安装在不同的磁盘上，可以实现`I/O Parallelism`：**

* 一个`Database`分布在一个`Disk`
* 一个`Database`分布在多个`Disk`
* 一个`Table`分布在一个`Disk`
* 一个`Table`分布在多个`Disk`

### 13.3.1 Multi-Disk Parallelism

**通过配置操作系统或者硬件，使得`DBMS`安装在多块不同的磁盘上。这对于`DBMS`是透明的**

* `LVM`
* `RAID`

![13-4](/images/Database-System/13-4.png)

### 13.3.2 Database Partitioning

**有些`DBMS`允许在创建`Database`时指定存储的路径**

### 13.3.3 Table Partitioning

**将单个逻辑表拆分为不相交的物理段，分别存储和管理**

* `Vertical Partitioning`：将逻辑表按列进行进行切分，分别存储
* `Horizontal Partitioning`：将逻辑表按行进行切分，分别存储

# 14 Optimization 1

由于`SQL`是声明式的语言，只表达想要获取什么数据，而没有指定如何获取。不同的执行计划的效率千差万别

**查询优化包含如下两种方式：**

* `Heuristics/Rules`：即启发式的
    * 重写SQL，去除冗余部分，精简表达式
    * 可能需要检查`Catalog`
* `Cost-based Search`
    * 使用模型来评估给定查询计划的开销
    * 在多种不同的等价查询计划中，找出开销最小的那个

![14-1](/images/Database-System/14-1.png)

**查询优化是`NP-Hard`问题，也是构建`DBMS`中最重要的部分**

## 14.1 Relational Algebra Equivalences

如果两个代数表达式（`Algebra Expression`）能产生相同的结果，那么就认为它俩是等价的

即便`DBMS`不借助`Cost Model`也可以识别哪个查询计划更优，这种方式叫做`Query Rewriting`

### 14.1.1 Predicate Pushdown

谓词下推（`Predicate Pushdown`）的核心思想是，尽可能地让数据过滤在更下层的算子中执行，这样在算子之间流转的数据量就可能大大减小

![14-2](/images/Database-System/14-2.png)

此时，以下两个代数表达式就是等价的

* {% raw %}$\pi_{name,cid}(\sigma_{grade='A'}(student \bowtie enrolled))${% endraw %}
* {% raw %}$\pi_{name,cid}(student \bowtie (\sigma_{grade='A'}(enrolled))${% endraw %}

### 14.1.2 Projections

尽可能早的进行物化操作（`Projection`），这样可以减少中间结果的产生。同时仅物化必须的列。对于列存系统，这种方式没有太大的意义

![14-3](/images/Database-System/14-3.png)

### 14.1.3 Join

对于`Join`算子，左右表的顺序可以任何兑换，例如：

* {% raw %}$R \bowtie S = S \bowtie R${% endraw %}
* {% raw %}$(R \bowtie S ) \bowtie T = R \bowtie (S \bowtie T)${% endraw %}

当`join`算子很多时，查询计划的空间会变得异常的庞大，遍历并计算每一种可能的查询计划的开销也非常耗时，因此，我们必须在有限的空间中找出相对最优的查询计划

## 14.2 Static Rules

**我们可以对原始SQL按照某些既定的规则进行重写，以达到去除冗余部分或者简化SQL的目的**

示例1：谓词恒为真或恒为假

```sql
SELECT * FROM A 
    WHERE 1 = 0;

-- 可以优化成

SELECT NULL;
```

示例2：`Join`可以消除

```sql
SELECT A1.* FROM A AS A1 
    JOIN A AS A2 ON A1.id = A2.id;

-- 可以优化成

SELECT * FROM A;
```

示例3：谓词恒为真

```sql
SELECT * FROM A AS A1
    WHERE EXISTS (
        SELECT val FROM A AS A2
        WHERE A1.id = A2.id
    );

-- 可以优化成

SELECT * FROM A;
```

示例4：谓词合并

```sql
SELECT * FROM A
    WHERE val BETWEEN 1 AND 100
        OR val BETWEEN 50 AND 150;

-- 可以优化成

SELECT * FROM A
    WHERE val BETWEEN 1 AND 150;
```

# 15 Optimization 2

## 15.1 Plan Cost Estimation

**可能影响执行效率的因素：**

* CPU
* 磁盘
* 内存
* 网络

**对于给定数据表`R`，`DBMS`通常会存储如下元数据：**

1. {% raw %}$N_{R}${% endraw %}：表的行数
1. {% raw %}$V(A, R)${% endraw %}：属性`A`的不同取值的个数（基数）

### 15.1.1 Selectivity

**于是`Selection Cardinality`就表示了某个属性的每个不同值的平均行数，即{% raw %}$SC(A, R) = \frac{N_R}{V(A, R)}${% endraw %}。即包含一个假设：分布是均匀的**

**谓词（`Predicate`）`P`的选择性（`Selectivity, sel`）可以表示为：符合条件的元组所占的比例。且不同的谓词有不同的计算方式**

* `Equality Predicate`：例如，`A = constant`
    * {% raw %}$sel(A=constant) = \frac{SC(P)}{N_R}${% endraw %}
* `Range Predicate`：例如，`A >= a`
    * {% raw %}$sel(A \ge a) = \frac{A_{max} - a}{A_{max} - A_{min}}${% endraw %}
* `Negation Predicate`：例如，`not P`
    * {% raw %}$sel(not\ P) = 1 - sel(P)${% endraw %}
* `Conjunction`：例如，`P1 ∩ P2`
    * {% raw %}$sel(P1 \cap P2) = sel(P1) * sel(P2）${% endraw %}
    * 包含假设：2个谓词是相互独立的
* `Disjunction`：例如，`P1 ∪ P2`
    * {% raw %}$sel(P1 \cup P2) = sel(P1) + sel(P2）- sel(P1 \cap P2)${% endraw %}
    * 包含假设：2个谓词是相互独立的

### 15.1.2 Sampling

现代的`DBMS`会存储一个表结构的采样数据集（在数据表发生重大变更时，会更新该采样数据级）。`DBMS`会利用采样数据来对`Selectivity`进行预测

例如，对于`Range Predicate`，借助采样就可以比较准确地进行预估

![15-1](/images/Database-System/15-1.png)

## 15.2 Plan Enumeration

`DBMS`在根据既定规则对原始SQL进行重写后，就会列举出一系列的等价查询计划，并且计算这些查询计划的开销，并从中选出最优的查询计划

### 15.2.1 Single-Relation Query Planning

**首先，选择最优的访问方式：**

1. 顺序扫描
1. 二分查找
1. 索引查找

**其次，计算各个谓词的选择性，并对其进行排序**

**对`OLTP`而言，启发式方法已经足够了（`OLTP`的查询一般来说非常简单）**

* 选择最优的索引
* join一般会建立在`foreign key`上
* 几个启发式的可选`plan`

### 15.2.2 Multi-Relation Query Planning

**当`join`的数量上升时，查询计划空间会迅速膨胀。为了简化这一问题，通常只考虑左深树（现代的`DBMS`可能不再使用这一假设）**

* 基于这一假设，更容易生成全流水化的查询计划

![15-2](/images/Database-System/15-2.png)

![15-3](/images/Database-System/15-3.png)

**列出所有可能的查询计划，维度包括：**

* 枚举左深树的顺序。比如是`T1 -> T2 -> T3`还是`T2 -> T1 -> T3`等等
* 枚举`Join`的实现方式。比如用`Hash`还是`Merge Sort`还是`Nested Loop`
* 枚举数据表的访问方式。比如用索引（哪个索引？）还是顺序访问

**这样会得到一个非常庞大的查询计划集，我们通常使用动态规划（`Dynamic Programming`）来选择最优解。示意图参考课件中的`40 ~ 44`页**

### 15.2.3 Postgre Optimizer

**`Postgre`的优化器会评估所有可能的`Join`树，包括左深树、右深树以及`bushy`**

**`Postgre`包含了2个优化器：**

1. 使用动态规划的传统的优化器（当表的数量小于12时，用这个优化器）
1. 使用遗传查询优化器`Genetic Query Optimizer, GEQO`（当表的数量大于等于12时，用这个优化器）

示意图参考课件中的`52 ~ 57`页

## 15.3 Nested Sub-queries

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
| `JIT` | Just-In-Time |
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

# 29 进阶

* [Advanced Database Systems](https://15721.courses.cs.cmu.edu/spring2020/)
