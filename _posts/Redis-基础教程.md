---
title: Redis-基础教程
date: 2017-08-17 19:54:16
tags: 
- 摘录
categories: 
- 数据库
- 非关系型数据库(NoSQL)
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

## 1.1 Redis简介

Redis是完全开源免费的，遵守BSD协议，是一个高性能的key-value数据库。
Redis与其他key-value缓存产品有以下三个特点：

* __Redis支持数据的持久化__，可以将内存中的数据保存在磁盘中，重启的时候可以再次加载进行使用。
* __Redis不仅仅支持简单的key-value类型的数据__，同时还提供list，set，zset，hash等数据结构的存储。
* __Redis支持数据的备份__，即master-slave模式的数据备份。

## 1.2 Redis优势

* __性能极高__：Redis能读的速度是110000次/s，写的速度是81000次/s 。
* __丰富的数据类型__：Redis支持`Strings`，`Lists`，`Hashes`，`Sets`及`Ordered Sets`数据类型操作。
* __原子__：Redis的所有操作都是原子性的，同时Redis还支持对几个操作全并后的原子性执行。
* __丰富的特性__：Redis还支持`publish/subscribe`，通知，key过期等等特性。

## 1.3 Redis与其他key-value存储有什么不同？

Redis有着更为复杂的数据结构并且提供对他们的原子性操作，这是一个不同于其他数据库的进化路径。Redis的数据类型都是基于基本数据结构的同时对程序员透明，无需进行额外的抽象。

Redis运行在内存中但是可以持久化到磁盘，所以在对不同数据集进行高速读写时需要权衡内存，因为数据量不能大于硬件内存。在内存数据库方面的另一个优点是，相比在磁盘上相同的复杂的数据结构，在内存中操作起来非常简单，这样Redis可以做很多内部复杂性很强的事情。同时，在磁盘格式方面他们是紧凑的以追加的方式产生的，因为他们并不需要进行随机访问。

# 2 数据类型

Redis支持五种数据类型：`string`（字符串），`hash`（哈希），`list`（列表），`set`（集合）及`zset`(sorted set：有序集合)。

## 2.1 string(字符串)

string是redis最基本的类型，你可以理解成与Memcached一模一样的类型，一个key对应一个value。

string类型是二进制安全的。意思是redis的string可以包含任何数据。比如jpg图片或者序列化的对象。

* __二进制安全的意思是：只关心二进制化的字符串，不关心具体格式。只会严格的按照二进制的数据存取。不会妄图已某种特殊格式解析数据。__

string类型是Redis最基本的数据类型，一个键最大能存储512MB。

## 2.2 Hash(哈希)

Redis hash是一个键名对集合。

Redis hash是一个string类型的field和value的映射表，hash特别适合用于存储对象。

每个hash可以存储`2^32 - 1`键值对（40多亿）。

## 2.3 List(列表)

Redis 列表是简单的字符串列表，按照插入顺序排序。你可以添加一个元素到列表的头部（左边）或者尾部（右边）。

列表最多可存储`2^32 - 1`个元素(4294967295，每个列表可存储40多亿)。

## 2.4 Set(集合)

Redis的Set是string类型的无序集合。

集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。

集合中最大的成员数为`2^32 - 1`(4294967295，每个集合可存储40多亿个成员)。

## 2.5 zset(sorted set：有序集合)

Redis zset 和 set 一样也是string类型元素的集合，且不允许重复的成员。

不同的是每个元素都会关联一个double类型的分数。redis正是通过分数来为集合中的成员进行从小到大的排序。

zset的成员是唯一的，但分数(score)却可以重复。

# 3 命令

## 3.1 登陆

`redis-cli`

`redis-cli -h host -p port -a password`

## 3.2 Redis键(key)

Redis键命令用于管理redis的键。

__语法：__

* `COMMAND KEY_NAME`

| 命令 | 描述 |
|:--|:--|
| `DEL key` | 该命令用于在key存在时删除key |
| `DUMP key` | 序列化给定key，并返回被序列化的值 |
| `EXISTS key` | 检查给定key是否存在 |
| `EXPIRE key seconds` | 为给定key设置过期时间 |
| `EXPIREAT key timestamp` | EXPIREAT的作用和EXPIRE类似，都用于为key设置过期时间。不同在于EXPIREAT命令接受的时间参数是UNIX时间戳(unix timestamp)。 |
| `PEXPIRE key milliseconds` | 设置key的过期时间以毫秒计。 |
| `PEXPIREAT key milliseconds-timestamp` | 设置key过期时间的时间戳(unix timestamp)以毫秒计 |
| `KEYS pattern` | 查找所有符合给定模式(pattern)的key。 |
| `MOVE key db` | 将当前数据库的key移动到给定的数据库db当中。 |
| `PERSIST key` | 移除key的过期时间，key将持久保持。 |
| `PTTL key` | 以毫秒为单位返回key的剩余的过期时间。 |
| `TTL key` | 以秒为单位，返回给定key的剩余生存时间(TTL，time to live)。 |
| `RANDOMKEY` | 从当前数据库中随机返回一个key。 |
| `RENAME key newkey` | 修改key的名称 |
| `RENAMENX key newkey` | __仅当newkey不存在时__，将key改名为newkey。 |
| `TYPE key` | 返回 key 所储存的值的类型。 |

## 3.3 Redis 字符串(String)

Redis字符串数据类型的相关命令用于管理redis字符串值，基本语法如下：

* `COMMAND KEY_NAME`

# 4 参考

* [Redis 教程](http://www.runoob.com/redis/redis-intro.html)
