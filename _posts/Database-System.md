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

# 4 Storage 2

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

# 28 CMU-课件

1. [01-introduction](/resources/Database-System/01-introduction.pdf)
1. [02-advancedsql](/resources/Database-System/02-advancedsql.pdf)
1. [03-storage1](/resources/Database-System/03-storage1.pdf)
1. [04-storage2](/resources/Database-System/03-storage2.pdf)
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
