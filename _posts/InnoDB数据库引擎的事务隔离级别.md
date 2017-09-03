---
title: InnoDB数据库引擎的事务隔离级别
date: 2017-09-02 14:13:31
tags: 
- 摘录
categories: 
- 数据库
- 基本概念
---

__目录__

<!-- toc -->
<!--more-->

# 1 ACID

__A：事务的原子性(Atomicity)__：指一个事务要么全部执行，要么不执行。也就是说一个事务不可能只执行了一半就停止了。比如你从取款机取钱，这个事务可以分成两个步骤：1划卡，2出钱。不可能划了卡，而钱却没出来。这两步必须同时完成，要么就不完成。
__C：事务的一致性(Consistency)__：指事务的运行并不改变数据库中数据的一致性。例如，完整性约束了a+b=10，一个事务改变了a，那么b也应该随之改变。
__I：独立性(Isolation)__：事务的独立性也有称作隔离性，是指两个以上的事务不会出现交错执行的状态。因为这样可能会导致数据不一致。
__D：持久性(Durability)__：事务的持久性是指事务执行成功以后，该事务所对数据库所作的更改便是持久的保存在数据库之中，不会无缘无故的回滚。

# 2 名词解释

## 2.1 第一类丢失更新

A事务撤销时，把已经提交的B事务的更新数据覆盖了

| 时间 | 取款事务A | 转账事务B |
|:--|:--|:--|
| T1 | __开始事务__ | / |
| T2 | / | __开始事务__ |
| T3 | 查询账户余额为1000元 | / |
| T4 | / | 查询账户余额为1000元 |
| T5 | / | 汇入100元，把余额改为1100元 |
| T6 | / | __提交事务__ |
| T7 | 取出100元，把余额改为900元 | / |
| T8 | __撤销事务__ | / |
| T9 | __余额恢复为1000元(丢失更新)__ | / |

__第一类丢失更新的本质是：写操作所依赖的原数据是无效的，因此串行化写操作即可解决第一类丢失更新问题，即Read uncommitted可以解决第一类丢失更新的问题__

## 2.2 第二类丢失更新

A事务覆盖B事务已经提交的数据，造成B事务所作的操作丢失

| 时间 | 取款事务A | 转账事务B |
|:--|:--|:--|
| T1 | / | __开始事务__ |
| T2 | __开始事务__ | / |
| T3 | / | 查询账户余额为1000元 |
| T4 | 查询账户余额为1000元 | / |
| T5 | / | 取出100元，把余额改为900元 |
| T6 | / | __提交事务__ |
| T7 | 汇入100元 | / |
| T8 | __提交事务__ | / |
| T9 | __把余额改为1100元(丢失更新)__ | / |

__第二类丢失更新的本质是：取款事务A一开始查询的1000元是无效数据，如果在B事务提交后再查询一次账户余额，将会得到不同的结果。我们只要保证读取的一定是有效数据即可，即可重复读。因此Repeatable read可以解决第二类丢失更新问题__

## 2.3 脏读

脏读就是指当一个事务正在访问数据，并且对数据进行了修改，而这种修改还没有提交到数据库中，这时，另外一个事务也访问这个数据，然后使用了这个数据。

## 2.4 不可重复读

是指在一个事务内，多次读同一数据。在这个事务还没有结束时，另外一个事务也访问该同一数据。那么，在第一个事务中的两次读数据之间，由于第二个事务的修改，那么第一个事务两次读到的的数据可能是不一样的。这样就发生了在一个事务内两次读到的数据是不一样的，因此称为是不可重复读。

## 2.5 幻读

是指当事务不是独立执行时发生的一种现象，例如第一个事务对一个表中的数据进行了修改，这种修改涉及到表中的全部数据行。同时，第二个事务也修改这个表中的数据，这种修改是向表中插入一行新数据。那么，以后就会发生操作第一个事务的用户发现表中还有没有修改的数据行，就好象
发生了幻觉一样。

# 3 事务隔离级别以及实现方式

## 3.1 Read uncommitted(读未提交)

__实现方式__：

* 事务读数据时__不加锁__
* 事务写数据的时候(写操作时才加锁而不是事务一开始就加锁)加__行级独占锁__，__事务结束释放__

行级别的共享锁可以防止两个同时的写操作，但是不会对读产生影响。因此可以避免第一类丢失更新，但是会产生脏读的问题。

### 3.1.1 验证

__测试工具__

1. mysql-5.7.16
1. bash

__准备工作__
```
CREATE TABLE test(
id int not null auto_increment,
name varchar(20) not null default "",
primary key(id)
)Engine=InnoDB;

INSERT INTO test(name)
VALUES("张三");
```

__客户端1__
执行如下操作
```
SET autocommit = 0; # 取消事务的自动提交

SELECT @@session.tx_isolation; # 查看隔离级别
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; # 修改隔离级别
SELECT @@session.tx_isolation; # 查看隔离级别

BEGIN; # 开启事务
SELECT name FROM test WHERE id = 1;
```

输出如下
```
mysql> SELECT name FROM test WHERE id = 1;
+--------+
| name   |
+--------+
| 张三   |
+--------+
1 row in set (0.00 sec)
```

__客户端2__
执行如下操作
```
SET autocommit = 0; # 取消事务的自动提交

SELECT @@session.tx_isolation; # 查看隔离级别
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; # 修改隔离级别
SELECT @@session.tx_isolation; # 查看隔离级别

UPDATE test SET name = '张八' WHERE id = 1;
```

输出如下
```
mysql> UPDATE test SET name = '张八' WHERE id = 1;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

__客户端1__
执行如下操作
```
SELECT name FROM test WHERE id = 1;
```

输出如下
```
mysql> SELECT name FROM test WHERE id = 1;
+--------+
| name   |
+--------+
| 张八   |
+--------+
1 row in set (0.00 sec)
```

此时我们发现，客户端1读取到了客户端2未提交的数据'张八'

__客户端2__
执行如下操作
```
rollback;
```

__客户端1__
执行如下操作
```
SELECT name FROM test WHERE id = 1;
```

输出如下
```
mysql> SELECT name FROM test WHERE id = 1;
+--------+
| name   |
+--------+
| 张三   |
+--------+
1 row in set (0.00 sec)
```

__接下来我们分析一下加锁情况(接着上面操作继续)__

__客户端1__
执行如下操作
```
UPDATE test SET name = '李四' WHERE id =1;
```

输出如下
```
mysql> UPDATE test SET name = '李四' WHERE id =1;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

__客户端2__
执行如下操作
```
UPDATE test SET name = '李四' WHERE id =1;
```

此时我们发现，操作并没有进行，而是被阻塞了

__客户端3__
执行如下操作
```
SELECT * FROM information_schema.INNODB_LOCKS; # 查看锁状态
SELECT * FROM information_schema.INNODB_LOCKS\G; # 将得到列状的输出
```

输出如下
```
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+---------------+-------------+-----------+-----------+------------------+------------+------------+-----------+----------+-----------+
| lock_id       | lock_trx_id | lock_mode | lock_type | lock_table       | lock_index | lock_space | lock_page | lock_rec | lock_data |
+---------------+-------------+-----------+-----------+------------------+------------+------------+-----------+----------+-----------+
| 14435:148:3:2 | 14435       | X         | RECORD    | `mybatis`.`test` | PRIMARY    |        148 |         3 |        2 | 1         |
| 14434:148:3:2 | 14434       | X         | RECORD    | `mybatis`.`test` | PRIMARY    |        148 |         3 |        2 | 1         |
+---------------+-------------+-----------+-----------+------------------+------------+------------+-----------+----------+-----------+
2 rows in set, 1 warning (0.00 sec)
```

可以看到写操作是有锁的，而且是X锁(排他锁)

__客户端3__
执行如下操作
```
SELECT * FROM information_schema.INNODB_TRX; # 查看事务状态
SELECT * FROM information_schema.INNODB_TRX\G; # 将得到列状的输出
```

输出如下
```
mysql> mysql> SELECT * FROM information_schema.INNODB_TRX\G; # 查看事务状态
*************************** 1. row ***************************
                    trx_id: 14435
                 trx_state: LOCK WAIT
               trx_started: 2017-09-03 14:08:41
     trx_requested_lock_id: 14435:148:3:2
          trx_wait_started: 2017-09-03 14:13:40
                trx_weight: 2
       trx_mysql_thread_id: 17
                 trx_query: UPDATE test SET name = '李四' WHERE id =1
       trx_operation_state: starting index read
         trx_tables_in_use: 1
         trx_tables_locked: 1
          trx_lock_structs: 2
     trx_lock_memory_bytes: 1136
           trx_rows_locked: 3
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
                    trx_id: 14434
                 trx_state: RUNNING
               trx_started: 2017-09-03 14:00:24
     trx_requested_lock_id: NULL
          trx_wait_started: NULL
                trx_weight: 3
       trx_mysql_thread_id: 16
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
```

可以看出，一个事务(Client1)处于RUNNING状态，另一个事务(Client2)处于锁定状态。且独占锁在写操作后并未释放，而是等到事务结束后才释放

## 3.2 Read committed(读已提交)

__实现方式__：

* 事务读数据的时候(读操作时才加锁而不是事务一开始就加锁)加__行级共享锁__，__读完释放__
* 事务写数据的时候(写操作时才加锁而不是事务一开始就加锁)加__行级独占锁__，__事务结束释放__

由于事务写操作加上独占锁，因此事务写操作时，读操作不能进行，因此，不能读到事务的未提交数据，避免了脏读问题，__但是由于读操作的锁加在读上面，而不是加在事务之上，所以，在同一事务的两次读操作之间可以插入其他事务的写操作，所以可能发生不可重复读的问题__

## 3.3 Repeatable read(可重复读)

__实现方式__：

* 事务读数据的时候(读操作时才加锁而不是事务一开始就加锁)加__行级共享锁__，__事务结束释放__
* 事务写数据的时候(写操作时才加锁而不是事务一开始就加锁)加__行级独占锁__，__事务结束释放__

由于事务读操作在事务结束后才释放共享锁，因此可以避免在同一读事务中读取到不同的数据，另外可以避免第二类丢失更新的问题。

## 3.4 Serializable(串行化)

__实现方式__：

* 事务读数据的时候(读操作时才加锁而不是事务一开始就加锁)加__表级共享锁__，__事务结束释放__
* 事务写数据的时候(写操作时才加锁而不是事务一开始就加锁)加__表级独占锁__，__事务结束释放__

# 4 总结

| 隔离级别 | 是否出现脏读 | 是否出现不可重复读 | 是否出现幻读 | 是否出现第一类丢失更新 | 是否出现第二类丢失更新 |
|:--|:--|:--|:--|:--|:--|
| Serializable | 否 | 否 | 否 | 否 | 否 |
| Repeatable read | 否 | 否 | 是 | 否 | 否 |
| Read committed | 否 | 是 | 是 | 否 | 是 |
| Read uncommitted | 是 | 是 | 是 | 否 | 是 |

# 5 如何查看/修改隔离级别

__修改隔离级别__

```
SET [SESSION | GLOBAL] TRANSACTION ISOLATION LEVEL {READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ | SERIALIZABLE}
```

* 默认的行为（不带session和global）是为下一个（未开始）事务设置隔离级别
* 如果你使用GLOBAL关键字，语句在全局对从那点开始创建的所有新连接（除了不存在的连接）设置默认事务级别。你需要SUPER权限来做这个
* 使用SESSION关键字为将来在当前连接上执行的事务设置默认事务级别。任何客户端都能自由改变会话隔离级别（甚至在事务的中间），或者为下一个事务设置隔离级别。

__查询隔离级别__

```
SELECT @@global.tx_isolation;
SELECT @@session.tx_isolation;
SELECT @@tx_isolation;
```

# 6 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [数据库事务隔离级别和锁的实现方式](http://blog.csdn.net/yangtianyu1218/article/details/51543634)
* [第一类第二类丢失更新](http://blog.csdn.net/lqglqglqg/article/details/48582905)
* [数据库事务隔离级别-- 脏读、幻读、不可重复读（清晰解释）](http://blog.csdn.net/jiesa/article/details/51317164)
