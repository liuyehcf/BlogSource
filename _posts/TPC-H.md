---
title: TPC-H
date: 2021-09-11 16:28:25
mathjax: true
tags: 
- 原创
categories: 
- Database
- Benchmark
---

**阅读更多**

<!--more-->

**本文转载摘录自[TPC-H 使用](https://blog.csdn.net/leixingbang1989/article/details/8766047)**

# 1 前言

## 1.1 TPC简介

事务处理性能委员会（`Transaction Processing Performance Council`），是由数10家会员公司创建的非盈利组织，总部设在美国。该组织对全世界开放，但迄今为止，绝大多数会员都是美、日、西欧的大公司。TPC的成员主要是计算机软硬件厂家，而非计算机用户，它的功能是制定商务应用基准程序（Benchmark）的标准规范、性能和价格度量，并管理测试结果的发布

`TPC-C`用于测试数据库系统的事务处理能力，`TPC-App`用于测试`7×24`环境下`B2B`的应用服务和`Web`服务的能力。`TPC`组织还发布过`TPC-S`（Server专门测试基准程序）、`TPC-E`（大型企业信息服务测试基准程序）和`TPC-Client/Server`等测试标准，但这3个标准不被业界接受而被放弃

`TPC`不给出基准程序的代码，而只给出基准程序的标准规范（`Standard Specification`）。任何厂家或其它测试者都可以根据规范，最优地构造出自己的系统（测试平台和测试程序）。（需要自己写测试工具，测试完之后提交给`TPC`协会）为保证测试结果的客观性，被测试者（通常是厂家）必须提交给`TPC`一套完整的报告（`FullDisclosure Report`），包括被测系统的详细配置、分类价格和包含五年维护费用在内的总价格。该报告必须由`TPC`授权的审核员核实（`TPC`本身并不做审计），现在全球只有不到十个审核员，全部在美国。（测试价格昂贵的原因）

## 1.2 TPC目前推出的基准程序

`TPC`推出过11套基准程序，分别是正在使用的`TPC-App`、`TPC-H`、`TPC-C`、`TPC-W`，过时的`TPC-A`、`TPC-B`、`TPC-D`和`TPC-R`，以及因为不被业界接受而放弃的`TPC-S`（Server专门测试基准程序）、`TPC-E`（大型企业信息服务测试基准程序）和`TPC-Client/Server`

# 2 TPC-Ｈ的目的

`TPC-H`主要目的是评价特定查询的决策支持能力，强调服务器在数据挖掘、分析处理方面的能力。查询是决策支持应用的最主要应用之一，数据仓库中的复杂查询可以分成两种类型：一种是预先知道的查询，如定期的业务报表；另一种则是事先未知的查询，称为动态查询（`Ad-Hoc Query`）

通俗的讲，`TPC-H`就是当一家数据库开发商开发了一个新的数据库操作系统，采用`TPC-H`作为测试基准，来测试衡量数据库操作系统查询决策支持方面的能力

# 3 TPC-H的衡量指标

它模拟决策支持系统中的数据库操作，测试数据库系统复杂查询的响应时间，以每小时执行的查询数(`TPC-H QphH@Siz`)作为度量指标

# 4 TPC-H标准规范

## 4.1 数据库运行的环境条件

`TPC-H`测试模型为数据库服务器连续`7×24`小时工作，可能只有1次/月的维护；多用户并发执行复杂的动态查询，同时有并发执行表修改操作。数据库模型共有`8`张表，除`Nation`和`Region`表外，其它表与测试的数据量有关，即比例因`SF（Scale Factor）`

数据库关系图以及表各个字段定义如下图：

![tables](/images/TPC-H/tables.png)

## 4.2 数据量规定

由于数据量的大小对查询速度有直接的影响，`TPC-H`标准对数据库系统中的数据量有严格、明确的规定。用`SF`描述数据量，`1SF`对应`1GB`单位，`SF`由低到高依次是`1`、`10`、`30`、`100`、`300`、`1000`、`3000`、`10000`。需要强调，`SF`规定的数据量只是`8`个基本表的数据量，不包括索引和临时表。

从`TPC-H`测试全程来看，需要的数据存储空较大，一般包括有基本表、索引、临时表、数据文件和备份文件，基本表的大小为`x`；索引和临时空间的经验值为`3-5`倍，取上限`5x`；`DBGEN`产生的数据文件的大小为`x`；备份文件大小为`x`；总计需要的存储空间为`8x`。就是说`SF=1`，需要准备`8`倍，即`8GB`存储空间，才能顺利地进行测试

## 4.3 `22`个查询语句

`TPC-H`测试围绕`22`个`SELECT`语句展开，每个`SELECT`严格定义，遵守`SQL-92`语法，并且不允许用户修改。标准中从`4`个方面定义每个`SELECT`语句，即商业问题、`SELECT`的语法、参数和查询确认。这些`SELECT`语句的复杂程度超过大多数实际的`OLTP`应用，一个`SELECT`执行时间少则几十秒，多则达15小时以上，`22`个查询语句执行一遍需数个小时

## 4.4 `2`个更新操作

为了逼真地模拟数据仓库的实际应用环境，在`22`个查询执行的同时，还有一对更新操作`RF1`和`RF2`并发地执行。`RF1`向`Order`表和`Lineitem`表中插入原行数的`0.1%`的新行，模拟新销售业务的数据加入到数据库中；`RF2`从`Order`表和`Lineitem`表中删除等量与`RF1`增加的数据，模拟旧的销售数据被淘汰。`RF1`和`RF2`的执行必须保证数据库的`ACID`约束，并保持测试前后的数据库中的数据量不变。更新操作除输出成功或失败信息外，不产生其它输出信息

## 4.5 `3`个测试

`TPC-H`测试分解为`3`个子测试：数据装载测试、`Power`测试和`Throughput`测试。建立测试数据库的过程被称为装载数据，装载测试是为测试`DBMS`装载数据的能力。装载测试是第一项测试，测试装载数据的时间，这项操作非常耗时。`Power`测试是在数据装载测试完成后，数据库处于初始状态，未进行其它任何操作，特别是缓冲区还没有被测试数据库的数据，被称为`raw`查询。`Power`测试要求`22`个查询顺序执行`1`遍，同时执行一对`RF1`和`RF2`操作。最后进行`Throughput`测试，也是最核心和最复杂的测试，它更接近于实际应用环境，与`Power`测试比对`SUT`系统的压力有非常大的增加，有多个查询语句组，同时有一对`RF1`和`RF2`更新流

## 4.6 度量指标

测试中测量的基础数据都与执行时间有关，这些时间又可分为：装载数据的每一步操作时间、每个查询执行时间和每个更新操作执行时间，由这些时间可计算出：数据装载时间、`Power@Size`、`Throughput@Size`、`QphH@Size`和`QphH@Size`

### 4.6.1 装载数据时间

装载数据的全过程有记时操作和不记时操作之分，记时操作必须测量所用时间，并计入到数据装载时间中。一般情况下，需要记时的操作有建表、插入数据和建立索引

### 4.6.2 查询和更新时间

在`Power`测试和`Throughput`测试中所有查询和更新流的时间必须被测量和记录，每个查询时间的计时是从被提交查询的第一个字符开始到获得查询结果最后一个字符的时间为止。更新时间要分别测量`RF1`和`RF2`的时间，是从提交操作开始到完成操作结束的时间

### 4.6.3 `Power@Size`

`Power@Size`是`Power`测试的结果，被定义为查询时间和更改时间的几何平均值的倒数，公式如下：

{% raw %}$$Power@Size=\frac{3600 \times SF}{\sqrt[24]{\prod_{i=1}^{i=22}{QI(i, 0) \times \prod_{j=1}^{j=2}{RI(j, 0)}}}}$${% endraw %}

其中：

* `Size`为数据规模
* `SF`为数据规模的比例因子
* `QI(i，0)`为第`i`个查询的时间，以秒为单位
* `RI(j，0)`为第`j`个更新的时间，以秒为单位

### 4.6.4 `Throughput@Size`

`Throughput@Size`是`Throughput`测试的结果，被定义为在测量间隔长度内执行的查询总数的比率，公式如下

{% raw %}$$Throughput@Size = \frac{S \times 22 \times 3600}{T_s \times SF} $${% endraw %}

### 4.6.5 `QphH@Size`

{% raw %}$$QphH@Size = \sqrt{Power@Size \times Throughput@Size}$${% endraw %}

# 5 实践

在[TPC Download Current Specs/Source](http://tpc.org/tpc_documents_current_versions/current_specifications5.asp)中下载`TCP-H`相关的程序

## 5.1 编译安装

将上述源码包解压缩

```sh
cd dbgen
cp makefile.suite makefile
```

**修改`makefile`文件中的`CC`、`DATABASE`、`MACHINE`、`WORKLOAD`的变量的定义**

```sh
CC      = gcc
DATABASE= MYSQL
MACHINE = LINUX
WORKLOAD = TPCH
```

**修改`tpcd.h`，在最后增加几行宏定义**

```
#ifdef MYSQL
#define GEN_QUERY_PLAN ""
#define START_TRAN "START TRANSACTION"
#define END_TRAN "COMMIT"
#define SET_OUTPUT ""
#define SET_ROWCOUNT "limit %d;\n"
#define SET_DBASE "use %s;\n"
#endif
```

**编译，编译后会生成几个可执行文件**

* `dbgen`：数据生成工具
* `qgen`：sql生成工具

```sh
make
```

**重要文件以及目录：**

* `dbgen/queries`：查询语句模板
* `dbgen/dss.ddl`：建表语句

## 5.2 生成数据

```sh
cd dbgen

# 生成1G大小的数据
./dbgen -s 1

# 查看生成后的数据
ls -lh *tbl
```

## 5.3 生成sql

```sh
cd dbgen

mkdir q
for id in `seq 1 22`
do
    DSS_QUERY=./queries ./qgen ${id} > q/${id}.sql
done
```

**注意，这样生成的sql，可能格式稍微有些出入，看情况修改就行**

# 6 参考

* [TPC-H Vesion 2 and Version 3](http://www.tpc.org/tpch/)
* [TPC-H specification](http://tpc.org/tpc_documents_current_versions/pdf/tpc-h_v3.0.0.pdf)
* [TPC-H 使用](https://blog.csdn.net/leixingbang1989/article/details/8766047)
* [DB性能测试-常用3套件-手把手一步一步跑TPCH](http://ilongda.com/2020/06/22/TPCH/)
* [TPC-C 、TPC-H和TPC-DS区别](https://zhuanlan.zhihu.com/p/339886289)
* [TPC-H数据导入MySQL教程](https://www.cnblogs.com/joyeecheung/p/3599698.html)
* [MySQL TPCH测试工具简要手册](https://www.php.cn/mysql-tutorials-133722.html)
