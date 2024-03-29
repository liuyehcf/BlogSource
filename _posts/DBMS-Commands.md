---
title: DBMS-Commands
date: 2018-04-22 19:55:17
tags: 
- 原创
categories: 
- Database
- Maintenance
---

**阅读更多**

<!--more-->

# 1 DML

数据操纵语言`Data Manipulation Language, DML`是`SQL`语言中，负责对数据库对象运行数据访问工作的指令集，以`INSERT`、`UPDATE`、`DELETE`三种指令为核心，分别代表插入、更新与删除，是开发以数据为中心的应用程序必定会使用到的指令，因此有很多开发人员都把加上`SQL`的`SELECT`语句的四大指令以`CRUD`来称呼

```sql
UPDATE -- 更新数据库表中的数据
DELETE -- 从数据库表中删除数据
INSERT INTO -- 向数据库表中插入数据
```

# 2 DDL

数据定义语言`Data Definition Language, DDL`，是用于描述数据库中要存储的现实世界实体的语言

```sql
CREATE DATABASE -- 创建新数据库
ALTER DATABASE -- 修改数据库
CREATE TABLE -- 创建新表
ALTER TABLE -- 变更（改变）数据库表
DROP TABLE -- 删除表
CREATE INDEX -- 创建索引（搜索键）
DROP INDEX -- 删除索引
```

# 3 DCL

数据控制语言`Data Control Language, DCL`，是一种可对数据访问权进行控制的指令，它可以控制特定用户账户对数据表、查看表、存储程序、用户自定义函数等数据库对象的控制权

```sql
GRANT
```

# 4 DQL

数据库查询语言`Data Query Language, DQL`

```sql
SELECT
```

# 5 辅助命令

**这些辅助命令一般来说都支持SQL操作的一些关键字，比如LIKE等等**

## 5.1 SHOW

```sql
SHOW DATABASES; -- 显示所有数据库
SHOW TABLES; -- 显示当前数据库中所有表
SHOW COLUMNS FROM [表名]; -- 该表中所有列的信息
DESCRIBE [表名]; -- 同上
DESC [表名]; -- 同上
SHOW STATUS; -- 用于显示广泛的服务器状态
SHOW CREATE DATABASE [数据库名]; -- 显示创建特定数据库的MySQL语句
SHOW CREATE TABLE [表明]; -- 显示创建特定表的MySQL语句
SHOW GRANTS -- 显示授予用户的安全权限
SHOW ERRORS和SHOW WARNINGS -- 用来显示服务器错误或警告消息
SHOW VARIABLES; -- 显示系统变量
SHOW PROFILES; -- 显示最近发送到服务器上执行的语句的资源使用情况
SHOW PROFILE; -- 显示最近一条语句执行的详细资源占用信息，默认显示 Status和Duration两列
SHOW PROFILE FOR QUERY [num]; -- 展示指定语句执行的详细资源占用信息，默认显示 Status和Duration两列
SHOW ENGINES; -- 显示数据库引擎
```

## 5.2 SELECT

```sql
SELECT @@global.tx_isolation; -- 全局
SELECT @@session.tx_isolation; -- 当前会话
SELECT @@tx_isolation; -- 默认当前会话
SELECT version(); -- 查看MySQL版本
SELECT database(); -- 当前所在数据库名称
SELECT user(); -- 查看当前用户名称
```

## 5.3 SET

```sql
SET GLOBAL profiling_history_size = 10; -- 全局
SET SESSION profiling_history_size = 15; -- 当前会话
SET profiling_history_size = 15; -- 当前会话

SET @@global.profiling_history_size = 10; -- 全局
SET @@session.profiling_history_size = 15; -- 当前会话
SET @@profiling_history_size = 15; -- 当前会话
```

## 5.4 EXPLAIN

```sql
EXPLAIN [SQL] -- 分析指定SQL的执行计划
```

# 6 Grant

```sql
-- 创建用户
CREATE USER 'test'@'localhost' IDENTIFIED BY '123456';

-- 授权
GRANT ALL PRIVILEGES ON *.* TO 'test'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
```

* `ALL PRIVILEGES`：表示将所有权限授予给用户。也可指定具体的权限，如：`SELECT`、`CREATE`、`DROP`等，以逗号分隔。
* `ON`：表示这些权限对哪些数据库和表生效，格式：`数据库名.表名`，这里写`*.*`表示`所有数据库`的`所有表`。如果我要指定将权限应用到`test`库的`user`表中，可以这么写：`test.user`
* `TO`：将权限授予哪个用户。格式：`'用户名'@'登录IP或域名'`。`%`表示没有限制，在任何主机都可以登录。比如：`'test'@'192.168.0.%'`，表示`test`这个用户只能在`192.168.0`IP段登录
* `IDENTIFIED BY`：指定用户的登录密码
* `WITH GRANT OPTION`：表示允许用户将自己的权限授权给其它用户

# 7 Tips

1. 直接在shell中执行sql：`mysql -uroot -pxxx -e 'select * from table'`
1. 执行sql文件中的所有sql
    * `mysql -uroot -p123456 -e 'source /root/temp.sql'`
    * `mysql -uroot -p123456 < /root/temp.sql`
