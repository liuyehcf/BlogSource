---
title: DBMS-Isolation
date: 2017-09-02 14:13:31
tags: 
- 摘录
categories: 
- Database
- Basic Concepts
---

**阅读更多**

<!--more-->

# 1 前言

本篇文章针对`MySQL`的`InnoDB数据库引擎`

# 2 ACID

**A：事务的原子性(Atomicity)**：指一个事务要么全部执行，要么不执行。也就是说一个事务不可能只执行了一半就停止了。比如你从取款机取钱，这个事务可以分成两个步骤：1划卡，2出钱。不可能划了卡，而钱却没出来。这两步必须同时完成，要么就不完成
**C：事务的一致性(Consistency)**：指事务的运行并不改变数据库中数据的一致性。例如，完整性约束了a+b=10，一个事务改变了a，那么b也应该随之改变
**I：独立性(Isolation)**：事务的独立性也有称作隔离性，是指两个以上的事务不会出现交错执行的状态。因为这样可能会导致数据不一致
**D：持久性(Durability)**：事务的持久性是指事务执行成功以后，该事务所对数据库所作的更改便是持久的保存在数据库之中，不会无缘无故的回滚

# 3 名词解释

## 3.1 第一类丢失更新

A事务撤销时，把已经提交的B事务的更新数据覆盖了

| 时间 | 取款事务A | 转账事务B |
|:--|:--|:--|
| T1 | **开始事务** | / |
| T2 | / | **开始事务** |
| T3 | 查询账户余额为1000元 | / |
| T4 | / | 查询账户余额为1000元 |
| T5 | / | 汇入100元，把余额改为1100元 |
| T6 | / | **提交事务** |
| T7 | 取出100元，把余额改为900元 | / |
| T8 | **撤销事务** | / |
| T9 | **余额恢复为1000元(丢失更新)** | / |

**第一类丢失更新的本质是：`回滚覆盖`，这个基本上可以算是数据库实现的bug了，mysql的任何隔离级别都不会有这个问题**

## 3.2 第二类丢失更新

A事务覆盖B事务已经提交的数据，造成B事务所作的操作丢失

| 时间 | 取款事务A | 转账事务B |
|:--|:--|:--|
| T1 | / | **开始事务** |
| T2 | **开始事务** | / |
| T3 | / | 查询账户余额为1000元 |
| T4 | 查询账户余额为1000元 | / |
| T5 | / | 取出100元，把余额改为900元 |
| T6 | / | **提交事务** |
| T7 | 汇入100元 | / |
| T8 | **提交事务** | / |
| T9 | **把余额改为1100元(丢失更新)** | / |

**第二类丢失更新的本质是：`提交覆盖`，基于一个过时的查询结果进行更新。因此Repeatable read可以解决第二类丢失更新问题**

## 3.3 脏读

脏读就是指当一个事务正在访问数据，并且对数据进行了修改，而这种修改还没有提交到数据库中，这时，另外一个事务也访问这个数据，然后使用了这个数据

## 3.4 不可重复读

是指在一个事务内，多次读同一数据。在这个事务还没有结束时，另外一个事务也访问该同一数据。那么，在第一个事务中的两次读数据之间，由于第二个事务的修改，那么第一个事务两次读到的的数据可能是不一样的。这样就发生了在一个事务内两次读到的数据是不一样的，因此称为是不可重复读

## 3.5 幻读

一个事务在前后两次查询同一范围的时候，后一次查询看到了前一次查询没有看到的行。除非上表锁，否则无法阻止插入新的数据

## 3.6 快照/当前读

快照读是MVCC中的概念，即读的是数据副本，不加任何锁

`当前读`又称为`加锁读`或`阻塞读`，查询的是数据的最新版本，根据加锁的不同，又可以分为两类

* `SELECT ... LOCK IN SHARE MODE`：S锁
* `SELECT ... FOR UPDATE`：X锁
* `INSERT / UPDATE / DELETE`：X锁

|  | 快照读 | 当前读 |
|:--|:--|:--|
| 读未提交 | / | 读取最新版本 |
| 读已提交 | 读取最新一份快照 | 读取最新版本，并加`记录锁` |
| 可重复读 | 读取事务开始时的快照 | 读取最新版本，并加`记录锁`以及`间隙锁` |
| 可序列化 | / | 读取最新版本，并加`记录锁`以及`间隙锁` |

# 4 事务隔离级别以及实现方式

## 4.1 Read uncommitted(读未提交)

**实现方式**：

* 事务读数据时**不加锁**，只有当前读，无快照读
* 事务写数据的时候(写操作时才加锁而不是事务一开始就加锁)加**行级独占锁**，**事务结束释放**

行级别的共享锁可以防止两个同时的写操作，但是不会对读产生影响。因此可以避免第一类丢失更新，但是会产生脏读的问题

### 4.1.1 验证

**准备工作**

```sql
DROP DATABASE IF EXISTS test;
CREATE DATABASE test;

CREATE TABLE test.user(
id INT NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL DEFAULT "",
PRIMARY KEY(id)
)Engine=InnoDB;

INSERT INTO test.user(name)
VALUES("张三");
```

**客户端1**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| READ-UNCOMMITTED       |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT name FROM test.user WHERE id = 1; -- 查询数据
+--------+
| name   |
+--------+
| 张三   |
+--------+
1 row in set (0.00 sec)
```

**客户端2**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| READ-UNCOMMITTED       |
+------------------------+
1 row in set (0.01 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE test.user SET name = '张八' WHERE id = 1; -- 更新数据
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

**客户端1**
执行如下操作

```sql
mysql> SELECT name FROM test.user WHERE id = 1; -- 查询数据
+--------+
| name   |
+--------+
| 张八   |
+--------+
1 row in set (0.00 sec)
```

**客户端1读取到了客户端2未提交的数据，符合预期**

**客户端2**
执行如下操作

```sql
mysql> ROLLBACK; -- 回滚事务
Query OK, 0 rows affected (0.00 sec)
```

**客户端1**
执行如下操作

```sql
mysql> SELECT name FROM test.user WHERE id = 1; -- 查询数据
+--------+
| name   |
+--------+
| 张三   |
+--------+
1 row in set (0.00 sec)
```

**客户端1读取到了客户端2回滚后的数据，符合预期。接下来我们分析一下加锁情况(接着上面操作继续)**

**客户端1**
执行如下操作

```sql
mysql> UPDATE test.user SET name = '李四' WHERE id = 1; -- 更新数据
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

**客户端2**
执行如下操作

```sql
mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE test.user SET name = '李四' WHERE id = 1; -- 更新数据
```

**客户端2阻塞了，符合预期**

**客户端3**
执行如下操作

```sql
mysql> SELECT * FROM information_schema.INNODB_LOCKS; -- 查看锁状态
+---------------+-------------+-----------+-----------+---------------+------------+------------+-----------+----------+-----------+
| lock_id       | lock_trx_id | lock_mode | lock_type | lock_table    | lock_index | lock_space | lock_page | lock_rec | lock_data |
+---------------+-------------+-----------+-----------+---------------+------------+------------+-----------+----------+-----------+
| 16652:176:3:2 | 16652       | X         | RECORD    | `test`.`user` | PRIMARY    |        176 |         3 |        2 | 1         |
| 16651:176:3:2 | 16651       | X         | RECORD    | `test`.`user` | PRIMARY    |        176 |         3 |        2 | 1         |
+---------------+-------------+-----------+-----------+---------------+------------+------------+-----------+----------+-----------+
2 rows in set, 1 warning (0.00 sec)

mysql> SELECT * FROM information_schema.INNODB_LOCKS\G; -- 将得到列状的输出
*************************** 1. row ***************************
    lock_id: 16652:176:3:2
lock_trx_id: 16652
  lock_mode: X
  lock_type: RECORD
 lock_table: `test`.`user`
 lock_index: PRIMARY
 lock_space: 176
  lock_page: 3
   lock_rec: 2
  lock_data: 1
*************************** 2. row ***************************
    lock_id: 16651:176:3:2
lock_trx_id: 16651
  lock_mode: X
  lock_type: RECORD
 lock_table: `test`.`user`
 lock_index: PRIMARY
 lock_space: 176
  lock_page: 3
   lock_rec: 2
  lock_data: 1
2 rows in set, 1 warning (0.00 sec)

ERROR:
No query specified
```

可以看到写操作是有锁的，而且是X锁(排他锁)

**客户端3**
执行如下操作

```sql
mysql> SELECT * FROM information_schema.INNODB_TRX; -- 查看事务状态
...省略输出...

mysql> SELECT * FROM information_schema.INNODB_TRX\G; -- 将得到列状的输出
*************************** 1. row ***************************
                    trx_id: 16652
                 trx_state: LOCK WAIT
               trx_started: 2021-05-15 11:10:54
     trx_requested_lock_id: 16652:176:3:2
          trx_wait_started: 2021-05-15 11:10:54
                trx_weight: 2
       trx_mysql_thread_id: 9
                 trx_query: UPDATE test.user SET name = '李四' WHERE id = 1
       trx_operation_state: starting index read
         trx_tables_in_use: 1
         trx_tables_locked: 1
          trx_lock_structs: 2
     trx_lock_memory_bytes: 1136
           trx_rows_locked: 1
         trx_rows_modified: 0
   trx_concurrency_tickets: 0
       trx_isolation_level: READ UNCOMMITTED
         trx_unique_checks: 1
    trx_foreign_key_checks: 1
trx_last_foreign_key_error: NULL
 trx_adaptive_hash_latched: 0
 trx_adaptive_hash_timeout: 0
          trx_is_read_only: 0
trx_autocommit_non_locking: 0
*************************** 2. row ***************************
                    trx_id: 16651
                 trx_state: RUNNING
               trx_started: 2021-05-15 11:09:44
     trx_requested_lock_id: NULL
          trx_wait_started: NULL
                trx_weight: 3
       trx_mysql_thread_id: 8
                 trx_query: NULL
       trx_operation_state: NULL
         trx_tables_in_use: 0
         trx_tables_locked: 1
          trx_lock_structs: 2
     trx_lock_memory_bytes: 1136
           trx_rows_locked: 1
         trx_rows_modified: 1
   trx_concurrency_tickets: 0
       trx_isolation_level: READ UNCOMMITTED
         trx_unique_checks: 1
    trx_foreign_key_checks: 1
trx_last_foreign_key_error: NULL
 trx_adaptive_hash_latched: 0
 trx_adaptive_hash_timeout: 0
          trx_is_read_only: 0
trx_autocommit_non_locking: 0
2 rows in set (0.00 sec)

ERROR:
No query specified
```

**可以看出，一个事务(Client1)处于RUNNING状态，另一个事务(Client2)处于锁定状态。且独占锁在写操作后并未释放，而是等到事务结束后才释放**

## 4.2 Read committed(读已提交)

**实现方式**：

* 事务读数据（**对于mysql而言，特指S锁当前读**）的时候(读操作时才加锁而不是事务一开始就加锁)加**行级共享锁**，**读完释放**
* 事务写数据的时候(写操作时才加锁而不是事务一开始就加锁)加**行级独占锁**，**事务结束释放**

由于事务写操作加上独占锁，因此事务写操作时，读操作不能进行，因此，不能读到事务的未提交数据，避免了脏读问题，**但是由于读操作的锁加在读上面，而不是加在事务之上，所以，在同一事务的两次读操作之间可以插入其他事务的写操作，所以可能发生不可重复读的问题**

### 4.2.1 验证

可以很负责人的跟大家说，**MySQL中的READ COMMITTED隔离级别不单单是通过加锁实现的，实际上还有REPEATABLE READ隔离级别，其实这两个隔离级别效果的实现还需要一个辅助，这个辅助就是MVCC-多版本并发控制**，但其实它又不是严格意义上的多版本并发控制，是不是很懵，没关系，我们一一剖析

#### 4.2.1.1 快照读

**准备工作**

```sql
DROP DATABASE IF EXISTS test;
CREATE DATABASE test;

CREATE TABLE test.user(
id INT NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL DEFAULT "",
PRIMARY KEY(id)
)Engine=InnoDB;

INSERT INTO test.user(name)
VALUES("张三");
```

**客户端1**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| READ-COMMITTED         |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE test.user SET name = '张八' WHERE id = 1; -- 更新数据
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

**客户端2**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| READ-COMMITTED         |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT name FROM test.user WHERE id = 1; -- 查询数据
+--------+
| name   |
+--------+
| 张三   |
+--------+
1 row in set (0.00 sec)
```

这里的读事务并没有按照预期那样阻塞，而是读到了写事务(Client1)事务开始前的数据。**因为内部使用了MVCC机制，实现了一致性非阻塞读，大大提高了并发读写效率，写不影响读，且读到的是记录的镜像版本**

**客户端1**
执行如下操作

```sql
mysql> COMMIT; -- 提交事务
Query OK, 0 rows affected (0.01 sec)
```

**客户端2**
执行如下操作

```sql
mysql> SELECT name FROM test.user WHERE id = 1; -- 查询数据
+--------+
| name   |
+--------+
| 张八   |
+--------+
1 row in set (0.00 sec)
```

**在客户端2的事务中，读到了客户端1所提交的数据，符合预期**

#### 4.2.1.2 当前读

**准备工作**

```sql
DROP DATABASE IF EXISTS test;
CREATE DATABASE test;

CREATE TABLE test.user(
id INT NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL DEFAULT "",
PRIMARY KEY(id)
)Engine=InnoDB;

INSERT INTO test.user(name)
VALUES("张三");
```

**客户端1**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| READ-COMMITTED         |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE test.user SET name = '张八' WHERE id = 1; -- 更新数据
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

**客户端2**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| READ-COMMITTED         |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT name FROM test.user WHERE id = 1 LOCK IN SHARE MODE; -- 查询数据
```

**当前读阻塞，符合预期**

**客户端1**
执行如下操作

```sql
mysql> COMMIT; -- 提交事务
Query OK, 0 rows affected (0.01 sec)
```

**客户端2**
从阻塞中恢复

```sql
mysql> SELECT name FROM test.user WHERE id = 1 LOCK IN SHARE MODE; -- 查询数据
+--------+
| name   |
+--------+
| 张八   |
+--------+
1 row in set (2.33 sec)
```

**事务2读到了事务1提交的数据，符合预期**

## 4.3 undo/redo log

数据库通常借助日志来实现事务，常见的有`undo log`、`redo log`，`undo/redo log`都能保证事务特性，这里主要是原子性和持久性，即事务相关的操作，要么全做，要么不做，并且修改的数据能得到持久化

在概念上，`innodb`通过`force log at commit`机制实现事务的持久性，即在事务提交的时候，必须先将该事务的所有事务日志写入到磁盘上的`redo log file`和`undo log file`中进行持久化

假设数据库在操作时，按如下约定记录日志：

1. 事务开始时，记录`START T`
2. 事务修改时，记录`(T, x, v)`，说明事务`T`操作对象`x`，`x`的值为`v` 
3. 事务结束时，记录`COMMIT T `

### 4.3.1 undo log

**`undo log`有两个作用：提供回滚和多个行版本控制(MVCC)**

`undo log`是把所有没有`COMMIT`的事务回滚到事务开始前的状态，系统崩溃时，可能有些事务还没有`COMMIT`，在系统恢复时，这些没有`COMMIT`的事务就需要借助`undo log`来进行回滚

**使用`undo log`时，要求**

1. 记录修改日志时，`(T, x, v)`中`v`为`x`修改前的值，这样才能借助这条日志来回滚
2. 事务提交后，必须在事务的所有修改（包括记录的修改日志）都持久化后才能写事务`T`的`COMMIT`日志；这样才能保证，宕机恢复时，已经`COMMIT`的事务的所有修改都已经持久化，不需要回滚

**使用`undo log`时事务执行顺序**

1. 记录`START T`
2. 记录需要修改的记录的旧值（要求持久化）
3. 根据事务的需要更新数据库（要求持久化）
4. 记录`COMMIT T`

**使用`undo log`进行宕机回滚**

1. 扫描日志，找出所有已经`START`，还没有`COMMIT`的事务
2. 针对所有未`COMMIT`的日志，根据`undo log`来进行回滚 

**如果数据库访问很多，日志量也会很大，宕机恢复时，回滚的工作量也就很大，为了加快回滚，可以通过`checkpoint`机制来加速回滚**

1. 在日志中记录`checkpoint_start(T1, T2, ..., Tn)` (`Tx`代表做`checkpoint`时，正在进行还未`COMMIT`的事务）
1. 等待所有正在进行的事务`(T1~Tn)`执行`COMMIT`操作
1. 在日志中记录`checkpoint_end`

**借助`checkpoint`来进行回滚：从后往前，扫描`undo log`**

1. 如果先遇到`checkpoint_start`，则将`checkpoint_start`之后的所有未提交的事务进行回滚
2. 如果先遇到`checkpoint_end`，则将前一个`checkpoint_start`之后所有未提交的事务进行回滚（在`checkpoint`的过程中，可能有很多新的事务`START`或者`COMMIT`)

### 4.3.2 redo log

为了实现持久化这一特性，必须保证：在事务提交后，所有的数据修改都需要落盘。**最简单的做法是在每次事务提交的时候，将该事务涉及修改的数据页全部刷新到磁盘中。但是这么做会有严重的性能问题，主要体现在两个方面**

1. 因为`Innodb`是以`页`为单位进行磁盘交互的，而一个事务很可能只修改一个数据页里面的几个字节，这个时候将完整的数据页刷到磁盘的话，太浪费资源了
1. 一个事务可能涉及修改多个数据页，并且这些数据页在物理上并不连续，使用随机IO写入性能太差

**于是`mysql`设计了`redo log`，具体来说就是只记录事务对数据页做了哪些修改，这样就能完美地解决性能问题了**

1. **随机写改为顺序写**
1. **每次写改为批量写**

`redo log`包括两部分：一个是内存中的日志缓冲`redo log buffer`，另一个是磁盘上的日志文件`redo log file`。mysql每执行一条`DML`语句，先将记录写入`redo log buffer`，后续某个时间点再一次性将多个操作记录写到`redo log file`。这种先写日志，再写磁盘的技术就是`WAL(Write-Ahead Logging)`技术

**使用`redo log`时事务执行顺序**

1. 记录`START T`
2. 记录事务需要修改记录的新值（要求持久化）
3. 记录`COMMIT T`（要求持久化）
4. 将事务相关的修改写入数据库 

**在日志中使用checkpoint**

1. 在日志中记录`checkpoint_start(T1, T2, ..., Tn)`（`Tx`代表做`checkpoint`时，正在进行还未`COMMIT`的日志）
2. 将所有已提交的事务的更改进行持久化
3. 在日志中记录`checkpoint_end`

**根据checkpoint来加速恢复：从后往前，扫描`redo log`**

1. 如果先遇到`checkpoint_start`，则把`T1~Tn`以及`checkpoint_start`之后的所有已经`COMMIT`的事务进行重做
2. 如果先遇到`checkpoint_end`，则`T1~Tn`以及前一个`checkpoint_start`之后所有已经`COMMIT`的事务进行重做

## 4.4 MVCC机制剖析

在MySQL中`MVCC(Multi-Version Concurrency Control)`是在Innodb存储引擎中得到支持的，Innodb为每行记录都实现了三个隐藏字段：

1. 隐藏的ID
1. 6字节的事务ID（`DB_TRX_ID`）：当某个事务对某条记录进行改动时，对会把对应的事务id赋值给该字段
1. 7字节的回滚指针（`DB_ROLL_PTR`）：可以通过这个指针找到该记录修改前的信息

**MVCC在MySQL中的实现依赖的是`undo log`与`read view`**

1. **`undo log`**：`undo log`中记录的是数据表记录行的多个版本，也就是事务执行过程中的回滚段，其实就是MVCC中的一行原始数据的多个版本镜像数据
1. **`read view`**：主要用来判断当前版本数据的可见性

**行的更新过程**

1. 初始数据行
    * ![fig1](/images/DBMS-Isolation/fig1.jpeg)
    * F1～F6是某行列的名字，1～6是其对应的数据。后面三个隐含字段分别对应该行的事务号和回滚指针，假如这条数据是刚INSERT的，可以认为ID为1，其他两个字段为空
1. 事务1更改该行的各字段的值
    * ![fig2](/images/DBMS-Isolation/fig2.jpeg)
    * 当事务1更改该行的值时，会进行如下操作：
        * 用排他锁锁定该行
        * 记录redo log
        * 把该行修改前的值Copy到`undo log`，即上图中下面的行
        * 修改当前行的值，填写事务编号，使回滚指针指向`undo log`中的修改前的行
1. 事务2修改该行的值
    * ![fig3](/images/DBMS-Isolation/fig3.jpeg)
    * 与事务1相同，此时`undo log`，中有有两行记录，并且通过回滚指针连在一起

**`read view`判断当前版本数据项是否可见**：在innodb中，创建一个新事务的时候，innodb会将当前系统中的活跃事务列表创建一个副本（`read view`），副本中保存的是系统**当前不应该被本事务看到的其他事务id列表**。当用户在这个事务中要读取该行记录的时候，innodb会将该行当前的版本号与该`read view`进行比较。主要的概念如下

1. `m_ids`：表示在生成`read view`时，当前系统中活跃的读写事务id列表
1. `min_trx_id`：表示在生成`read view`时，当前系统中活跃的读写事务中最小的事务id，也就是`m_ids`中最小的值
1. `max_trx_id`：表示在生成`read view`时，系统中应该分配给下一个事务的id值
1. `creator_trx_id`：表示在生成`read view`时，事务的id

**`read view`具体的算法如下：**

* 设该行的当前事务id为`trx_id`
1. 如果被访问版本的`trx_id`，与`read view`中的`creator_trx_id`值相同，表明当前事务在访问自己修改过的记录，该版本可以被当前事务访问
1. 如果被访问版本的`trx_id`，小于`read view`中的`min_trx_id`值，表明生成该版本的事务在当前事务生成`read view`前已经提交（`m_ids`存的是活跃的事务列表，如果不在这个列表中的话，就表示已提交），该版本可以被当前事务访问
1. 如果被访问版本的`trx_id`，大于或等于`read view`中的`max_trx_id`值，表明生成该版本的事务在当前事务生成`read view`后才开启，该版本不可以被当前事务访问
1. 如果被访问版本的`trx_id`，值在`read view`的`min_trx_id`和`max_trx_id`之间，就需要判断`trx_id`属性值是不是在`m_ids`列表中
    * 如果在：说明创建`read view`时生成该版本的事务还是活跃的，该版本不可以被访问
    * 如果不在：说明创建`read view`时生成该版本的事务已经被提交，该版本可以被访问

**生成`read view`时机**

* `RC隔离级别`：每次读取数据前，都生成一个`read view`，只要当前语句执行前已经提交的数据都是可见的
* `RR隔离级别`：在第一次读取数据前，生成一个`read view`，只要是当前事务执行前已经提交的数据都是可见的

### 4.4.1 问题

1. **事务尚未提交或者回滚之前，已经修改的数据是否会持久化到磁盘上？**
    * 会持久化到硬盘中。这也就是为什么在`Read uncommitted`这一事务隔离级别中，可以读取到未提交的数据
    * 在`Read committed`及`Repeatable read`事务隔离级别中，其他事务可以通过`undo log`来读取记录的初始值
1. **事务A更新某一行，提交；事务B同时更新同一行，回滚（在时间上，提交早于回滚）。`undo log`如何工作？**
    * 当前事务id记为`id_current`，事务B对应的`undo log`中记录的原始数据的事务id记为`id_original`，若`id_current > id_original`且`id_current`对应的事务已提交，那么不做任何操作（**这只是我的猜想**）

## 4.5 Repeatable read(可重复读)

**实现方式**：

* 事务读数据（**对于mysql而言，特指S锁当前读**）的时候(读操作时才加锁而不是事务一开始就加锁)加**行级共享锁**，**事务结束释放**
* 事务写数据的时候(写操作时才加锁而不是事务一开始就加锁)加**行级独占锁**，**事务结束释放**

由于事务读操作在事务结束后才释放共享锁，因此可以避免在同一读事务中读取到不同的数据，另外可以避免第二类丢失更新的问题

### 4.5.1 验证

真实情况是：读不影响写，写不影响读

1. 读不影响写：事务以排他锁的形式修改原始数据，读时不加锁，因为MySQL在事务隔离级别Read committed 、Repeatable Read下，**InnoDB存储引擎采用非锁定性一致读**--即读取不占用和等待表上的锁。即采用的是MVCC中一致性非锁定读模式。因读时不加锁，所以不会阻塞其他事务在相同记录上加X锁来更改这行记录
1. 写不影响读：事务以排他锁的形式修改原始数据，当读取的行正在执行delete或者update 操作，这时读取操作不会因此去等待行上锁的释放。相反地，InnoDB存储引擎会去读取行的一个快照数据

#### 4.5.1.1 当前读

**准备工作**

```sql
DROP DATABASE IF EXISTS test;
CREATE DATABASE test;

CREATE TABLE test.user(
id INT NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL DEFAULT "",
PRIMARY KEY(id)
)Engine=InnoDB;

INSERT INTO test.user(name)
VALUES("张三");
```

**客户端1**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| REPEATABLE-READ        |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE test.user SET name = '张八' WHERE id = 1; -- 更新数据
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

**客户端2**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| REPEATABLE-READ        |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT name FROM test.user WHERE id = 1; -- 查询数据
+--------+
| name   |
+--------+
| 张三   |
+--------+
1 row in set (0.00 sec)
```

这里的读事务并没有按照预期那样阻塞，而是读到了写事务(Client1)事务开始前的数据。**因为内部使用了MVCC机制，实现了一致性非阻塞读，大大提高了并发读写效率，写不影响读，且读到的是记录的镜像版本**

**客户端1**
执行如下操作

```sql
mysql> COMMIT; -- 提交事务
Query OK, 0 rows affected (0.00 sec)
```

**客户端2**
执行如下操作

```sql
mysql> SELECT name FROM test.user WHERE id = 1; -- 查询数据
+--------+
| name   |
+--------+
| 张三   |
+--------+
1 row in set (0.00 sec)
```

**在客户端2的事务中，读到的还是事务1提交之前的数据，符合预期**

#### 4.5.1.2 当前读

**准备工作**

```sql
DROP DATABASE IF EXISTS test;
CREATE DATABASE test;

CREATE TABLE test.user(
id INT NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL DEFAULT "",
PRIMARY KEY(id)
)Engine=InnoDB;

INSERT INTO test.user(name)
VALUES("张三");
```

**客户端1**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| REPEATABLE-READ        |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE test.user SET name = '张八' WHERE id = 1; -- 更新数据
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

**客户端2**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| REPEATABLE-READ        |
+------------------------+
1 row in set (0.00 sec)

mysql> SELECT name FROM test.user WHERE id = 1 LOCK IN SHARE MODE; -- 查询数据
```

**当前读阻塞，符合预期**

**客户端1**
执行如下操作

```sql
mysql> COMMIT; -- 提交事务
Query OK, 0 rows affected (0.01 sec)
```

**客户端2**
从阻塞中恢复

```sql
mysql> SELECT name FROM test.user WHERE id = 1 LOCK IN SHARE MODE; -- 查询数据
+--------+
| name   |
+--------+
| 张八   |
+--------+
1 row in set (16.77 sec)
```

## 4.6 Serializable(串行化)

**实现方式**：

* 事务读数据的时候(读操作时才加锁而不是事务一开始就加锁)加**表级共享锁**，**事务结束释放**
* 事务写数据的时候(写操作时才加锁而不是事务一开始就加锁)加**表级独占锁**，**事务结束释放**

### 4.6.1 验证

**准备工作**

```sql
DROP DATABASE IF EXISTS test;
CREATE DATABASE test;

CREATE TABLE test.user(
id INT NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL DEFAULT "",
PRIMARY KEY(id)
)Engine=InnoDB;

INSERT INTO test.user(name)
VALUES("张三");
```

**客户端1**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| SERIALIZABLE           |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE test.user SET name = '张八' WHERE id = 1; -- 更新数据
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

**客户端2**
执行如下操作

```sql
mysql> SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- 修改隔离级别
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@session.tx_isolation; -- 查看隔离级别
+------------------------+
| @@session.tx_isolation |
+------------------------+
| SERIALIZABLE           |
+------------------------+
1 row in set (0.00 sec)

mysql> BEGIN; -- 开始事务
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT name FROM test.user WHERE id = 1; -- 查询数据
```

**此时Client2阻塞了，与预期一致**

**客户端1**
执行如下操作

```sql
mysql> COMMIT; -- 提交事务
Query OK, 0 rows affected (0.00 sec)
```

**此时，客户端2从阻塞中恢复，显示查询结果**

```sql
+--------+
| name   |
+--------+
| 张八   |
+--------+
1 row in set (40.93 sec)
```

## 4.7 总结

| 隔离级别 | 是否出现脏读 | 是否出现不可重复读 | 是否出现幻读 | 是否出现第一类丢失更新 | 是否出现第二类丢失更新 |
|:--|:--|:--|:--|:--|:--|
| Serializable | 否 | 否 | 否 | 否 | 否 |
| Repeatable read | 否 | 否 | 是 | 否 | 否 |
| Read committed | 否 | 是 | 是 | 否 | 是 |
| Read uncommitted | 是 | 是 | 是 | 否 | 是 |

# 5 如何查看/修改隔离级别

**修改隔离级别**

```sql
SET [SESSION | GLOBAL] TRANSACTION ISOLATION LEVEL {READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ | SERIALIZABLE}
```

* 默认的行为（不带session和global）是为下一个（未开始）事务设置隔离级别
* 如果你使用GLOBAL关键字，语句在全局对从那点开始创建的所有新连接（除了不存在的连接）设置默认事务级别。你需要SUPER权限来做这个
* 使用SESSION关键字为将来在当前连接上执行的事务设置默认事务级别。任何客户端都能自由改变会话隔离级别（甚至在事务的中间），或者为下一个事务设置隔离级别

**查询隔离级别**

```sql
SELECT @@global.tx_isolation;
SELECT @@session.tx_isolation;
SELECT @@tx_isolation;
```

# 6 死锁问题分析

**准备工作**

```sql
-- 将隔离级别设置为 RR
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ; 

CREATE TABLE test(
id INT NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL DEFAULT "",
PRIMARY KEY(id),
UNIQUE KEY `uk_name` (`name`)
)Engine=InnoDB;

INSERT INTO test(name)
VALUES("member1");
INSERT INTO test(name)
VALUES("member2");
INSERT INTO test(name)
VALUES("member3");
```

```sql
mysql> SELECT * FROM test;
+----+---------+
| id | name    |
+----+---------+
|  1 | member1 |
|  2 | member2 |
|  3 | member3 |
+----+---------+
3 rows in set (0.00 sec)
```

下面构造死锁场景

```plantuml
skinparam backgroundColor #EEEBDC
skinparam handwritten true

skinparam sequence {
	ArrowColor DeepSkyBlue
	ActorBorderColor DeepSkyBlue
	LifeLineBorderColor blue
	LifeLineBackgroundColor #A9DCDF
	
	ParticipantBorderColor DeepSkyBlue
	ParticipantBackgroundColor DodgerBlue
	ParticipantFontName Impact
	ParticipantFontSize 17
	ParticipantFontColor #A9DCDF
	
	ActorBackgroundColor aqua
	ActorFontColor DeepSkyBlue
	ActorFontSize 17
	ActorFontName Aapex
}

participant "事务1" as tx1
participant "事务2" as tx2

tx2->tx2: BEGIN;
tx2->tx2: DELETE FROM test WHERE name = 'member2';
tx1->tx1: BEGIN;
tx1->tx1: DELETE FROM test WHERE name = 'member2';\n这里会阻塞住
tx2->tx2: INSERT INTO test (id, name) VALUES (5, 'member2');
tx1->tx1: 提示出现死锁：\nERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
```

**接下来使用`SHOW ENGINE INNODB STATUS;`命令可以查看死锁日志**

```sql
SHOW ENGINE INNODB STATUS;

-- ... 省略无关部分

------------------------
LATEST DETECTED DEADLOCK
------------------------
2020-02-29 20:00:36 0x70000839a000
*** (1) TRANSACTION:
TRANSACTION 15917, ACTIVE 9 sec starting index read
mysql tables in use 1, locked 1
LOCK WAIT 2 lock struct(s), heap size 1136, 1 row lock(s)
MySQL thread id 2, OS thread handle 123145440026624, query id 45 localhost root updating
-- 此时事务1正执行下面的语句
DELETE FROM test WHERE name = 'member2'
*** (1) WAITING FOR THIS LOCK TO BE GRANTED:
-- 事务1排队获取索引uk_name的排它锁（lock_mode X）
RECORD LOCKS space id 156 page no 4 n bits 72 index uk_name of table `deadlock`.`test` trx id 15917 lock_mode X waiting
Record lock, heap no 3 PHYSICAL RECORD: n_fields 2; compact format; info bits 32
 0: len 7; hex 6d656d62657232; asc member2;;
 1: len 4; hex 80000002; asc     ;;

*** (2) TRANSACTION:
TRANSACTION 15912, ACTIVE 22 sec inserting
mysql tables in use 1, locked 1
4 lock struct(s), heap size 1136, 3 row lock(s), undo log entries 2
MySQL thread id 3, OS thread handle 123145440305152, query id 46 localhost root update
-- 此时事务2正执行下面的语句
INSERT INTO test (id, name) VALUES (5, 'member2')
*** (2) HOLDS THE LOCK(S):
-- 此刻，事务2已经获取了索引uk_name的排它锁（lock_mode X），该排他锁是事务2在执行delete语句时获取的
RECORD LOCKS space id 156 page no 4 n bits 72 index uk_name of table `deadlock`.`test` trx id 15912 lock_mode X locks rec but not gap
Record lock, heap no 3 PHYSICAL RECORD: n_fields 2; compact format; info bits 32
 0: len 7; hex 6d656d62657232; asc member2;;
 1: len 4; hex 80000002; asc     ;;

-- 同时，事务2排队获取索引uk_name的共享锁（lock mode S），insert语句在普通情况下会申请所有索引的排它锁，但是这里出现了共享锁，因为uk_name索引是一个唯一索引，所以insert语句会在插入前进行一次duplicate key的检查，为了使这次检查成功，需要申请uk_name索引的共享锁，防止其他事务对name字段的修改。
-- 但是对uk_name索引的锁的申请是需要排队的，而事务1在此之前已经申请uk_name索引的排它锁，所以本次申请必须等待，因此形成了循环，死锁出现了
*** (2) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 156 page no 4 n bits 72 index uk_name of table `deadlock`.`test` trx id 15912 lock mode S waiting
Record lock, heap no 3 PHYSICAL RECORD: n_fields 2; compact format; info bits 32
 0: len 7; hex 6d656d62657232; asc member2;;
 1: len 4; hex 80000002; asc     ;;

*** WE ROLL BACK TRANSACTION (1)

-- ... 省略无关部分
```

# 7 参考

* [数据库事务隔离级别和锁的实现方式](http://blog.csdn.net/yangtianyu1218/article/details/51543634)
* [第一类第二类丢失更新](http://blog.csdn.net/lqglqglqg/article/details/48582905)
* [数据库事务隔离级别-- 脏读、幻读、不可重复读（清晰解释）](http://blog.csdn.net/jiesa/article/details/51317164)
* [数据库事务特征、数据库隔离级别，以及各级别数据库加锁情况(含实操)--read uncommitted篇](http://www.jianshu.com/p/d75fcdeb07a3)
* [数据库事务特征、数据库隔离级别，各级别数据库加锁情况(含实操)--read committed && MVCC](http://www.jianshu.com/p/fd51cb8dc03b)
* [数据库事务特征、数据库隔离级别，各级别数据库加锁情况(含实操)--Repeatable Read && MVCC](http://www.jianshu.com/p/814cf518f88d)
* [MVCC原理探究及MySQL源码实现分析](https://blog.csdn.net/joy0921/article/details/80128857)
* [mysql版本链&readview](https://zhuanlan.zhihu.com/p/110263562)
* [Mysql加锁过程详解](http://www.cnblogs.com/metoy/p/5545580.html)
* [Innodb中的事务隔离级别实现原理](http://blog.csdn.net/matt8/article/details/53096405)
* [MySQL数据库事务各隔离级别加锁情况--read committed && MVCC](http://www.imooc.com/article/17290)
* [记录一次Mysql死锁排查过程](https://blog.51cto.com/14257804/2390505?cid=732583)
* [一分钟理清Mysql的锁类型——《深究Mysql锁》](https://blog.csdn.net/zcl_love_wx/article/details/82052479)
* [InnoDB locking](https://github.com/octachrome/innodb-locks)
* [undo log与redo log原理分析](https://zhuanlan.zhihu.com/p/35574452/)
* [数据库基础（四）Innodb MVCC实现原理](https://zhuanlan.zhihu.com/p/52977862)
* [详细分析MySQL事务日志(redo log和undo log)](https://www.cnblogs.com/f-ck-need-u/archive/2018/05/08/9010872.html)
* [必须了解的mysql三大日志-binlog、redo log和undo log](https://segmentfault.com/a/1190000023827696)
