---
title: DBMS-Monitor
date: 2017-09-04 16:11:10
tags: 
- 原创
categories: 
- Database
- Maintenance
---

**阅读更多**

<!--more-->

# 1 系统参数

## 1.1 查看所有系统参数

```sql
SHOW VARIABLES -- 以数据表形式输出
SHOW VARIABLES\G -- 以行形式输出
SHOW VARIABLES LIKE '%isolation%';
```

## 1.2 查看指定系统参数的值

以系统参数`tx_isolation`为例

```sql
SELECT @@global.tx_isolation; -- 全局
SELECT @@session.tx_isolation; -- 当前会话
SELECT @@tx_isolation; -- 默认当前会话

SHOW GLOBAL VARIABLES LIKE 'tx_isolation'; -- 全局
SHOW SESSION VARIABLES LIKE 'tx_isolation'; -- 当前会话
SHOW VARIABLES LIKE 'tx_isolation'; -- 默认当前会话
```

## 1.3 修改系统参数的值

以系统参数`profiling_history_size`为例

```sql
SET GLOBAL profiling_history_size = 10;
SET SESSION profiling_history_size = 15;
SET profiling_history_size = 15;

SET @@global.profiling_history_size = 10;
SET @@session.profiling_history_size = 15;
SET @@profiling_history_size = 15;
```

以系统参数`tx_isolation`为例，这个参数比较特殊，需要用特殊的赋值语句

```sql
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

# 2 查看版本号

```sql
SELECT VERSION();
```

# 3 执行状态分析

```sql
SHOW PROCESSLIST;
```

# 4 profile工具

**查看profile相关的系统变量**

```
mysql> SHOW VARIABLES LIKE '%profi%';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| have_profiling         | YES   |
| profiling              | OFF   |
| profiling_history_size | 15    |
+------------------------+-------+
3 rows in set (0.01 sec)
```

**开启profiling功能**

```
mysql> SET SESSION profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> SHOW VARIABLES LIKE '%profi%';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| have_profiling         | YES   |
| profiling              | ON    |
| profiling_history_size | 15    |
+------------------------+-------+
3 rows in set (0.00 sec)
```

**查询所有语句的id以及执行时间**

```
mysql> SHOW PROFILES;
+----------+------------+-------------------------------------+
| Query_ID | Duration   | Query                               |
+----------+------------+-------------------------------------+
|       10 | 0.00006000 | SET SESSION @@session.profiling = 1 |
|       11 | 0.00005800 | SET SESSION @@profiling = 1         |
|       12 | 0.00010100 | SET SESSION profiling = 1           |
|       13 | 0.00190400 | SHOW VARIABLES LIKE '%profi%'       |
|       14 | 0.00005800 | SHOW PROFIILES                      |
+----------+------------+-------------------------------------+
5 rows in set, 1 warning (0.00 sec)
```

**查询某个特定的语句**

```
mysql> SHOW PROFILE FOR QUERY 13;
+----------------------+----------+
| Status               | Duration |
+----------------------+----------+
| starting             | 0.000063 |
| checking permissions | 0.000016 |
| Opening tables       | 0.000016 |
| init                 | 0.000052 |
| System lock          | 0.000008 |
| optimizing           | 0.000004 |
| optimizing           | 0.000002 |
| statistics           | 0.000013 |
| preparing            | 0.000014 |
| statistics           | 0.000007 |
| preparing            | 0.000006 |
| executing            | 0.000009 |
| Sending data         | 0.000007 |
| executing            | 0.000002 |
| Sending data         | 0.001597 |
| end                  | 0.000009 |
| query end            | 0.000006 |
| closing tables       | 0.000016 |
| removing tmp table   | 0.000009 |
| closing tables       | 0.000008 |
| freeing items        | 0.000028 |
| cleaning up          | 0.000012 |
+----------------------+----------+
22 rows in set, 1 warning (0.00 sec)
```

**查询某个特定的语句的详细信息**

1. ALL：显示所有性能信息
    * `SHOW PROFILE ALL FOR QUERY 13;`
1. CPU：CPU占用情况
    * `SHOW PROFILE CPU FOR QUERY 13;`
1. BLOCK IO：显示块IO的次数
    * `SHOW PROFILE BLOCK IO FOR QUERY 13;`
1. CONTEXT SWITCHES：显示自动和被动的上下文切换数量
    * `SHOW PROFILE CONTEXT SWITCHES FOR QUERY 13;`
1. IPC：显示发送和接受的消息数量
    * `SHOW PROFILE IPC FOR QUERY 13;`
1. MEMORY：显示内存占用情况
    * `SHOW PROFILE MEMORY FOR QUERY 13;`
1. SWAPS：显示swap的次数
    * `SHOW PROFILE SWAPS FOR QUERY 13;`
1. 以上参数可以组合使用
    * `SHOW PROFILE BLOCK IO, CPU FOR QUERY 13;`

# 5 EXPLAIN-分析执行计划

**语法**

```
EXPLAIN + SQL

mysql> EXPLAIN SELECT * FROM test WHERE id = 1;
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | test  | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

```

**参数解释**

1. **select_type**：
1. **table**：显示这一行的数据是关于哪张表的
1. **partitions**：
1. **type**：这是重要的列，显示连接使用了何种类型。**从最好到最差的连接类型为const、eq_reg、ref、range、index和ALL**
1. **possible_keys**：**显示可能应用在这张表中的索引**。如果为空，没有可能的索引。可以为相关的域从WHERE语句中选择一个合适的语句
1. **key**： **实际使用的索引**。如果为NULL，则没有使用索引。很少的情况下，MYSQL会选择优化不足的索引。这种情况下，可以在SELECT语句中使用USE INDEX（indexname）来强制使用一个索引或者用IGNORE INDEX（indexname）来强制MYSQL忽略索引
    * NULL：表示没有使用索引
    * PRIMARY：表示使用主键作为索引
    * 索引名字：表示使用的索引的名字
1. **key_len**：使用的索引的长度。在不损失精确性的情况下，长度越短越好
1. **ref**：显示索引的哪一列被使用了，如果可能的话，是一个常数
1. **rows**：MYSQL认为必须检查的用来返回请求数据的行数
1. **filtered**：
1. **Extra**：关于MYSQL如何解析查询的额外信息。将在表4.3中讨论，但这里可以看到的坏的例子是Using temporary和Using filesort，意思MYSQL根本不能使用索引，结果是检索会很慢

# 6 参考

* [MYSQL的用户变量(@)和系统变量(@@)](http://www.cnblogs.com/awishfullyway/p/6485070.html)
* [MySQL优化 profile工具](https://jingyan.baidu.com/article/c35dbcb085eb688916fcbc01.html)
* [MySQL常用性能分析方法-profile，explain，索引](http://blog.csdn.net/21aspnet/article/details/52938346)
* [详解MySQL中EXPLAIN解释命令](http://database.51cto.com/art/200912/168453.htm)
* [MYSQL 用 explain 语句判断select查询是否使用了索引](http://blog.csdn.net/u014453898/article/details/55004193)
