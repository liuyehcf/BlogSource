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

__命令：__

| 命令 | 描述 |
|:--|:--|
| `DEL key` | 该命令用于在key存在时删除key |
| `DUMP key` | 序列化给定key，并返回被序列化的值 |
| `EXISTS key` | 检查给定key是否存在 |
| `EXPIRE key seconds` | 为给定key设置过期时间 |
| `EXPIREAT key timestamp` | EXPIREAT的作用和EXPIRE类似，都用于为key设置过期时间。不同在于EXPIREAT命令接受的时间参数是UNIX时间戳(unix timestamp) |
| `PEXPIRE key milliseconds` | 设置key的过期时间以毫秒计 |
| `PEXPIREAT key milliseconds-timestamp` | 设置key过期时间的时间戳(unix timestamp)以毫秒计 |
| `KEYS pattern` | 查找所有符合给定模式(pattern)的key |
| `MOVE key db` | 将当前数据库的key移动到给定的数据库db当中 |
| `PERSIST key` | 移除key的过期时间，key将持久保持 |
| `PTTL key` | 以毫秒为单位返回key的剩余的过期时间 |
| `TTL key` | 以秒为单位，返回给定key的剩余生存时间(TTL，time to live) |
| `RANDOMKEY` | 从当前数据库中随机返回一个key |
| `RENAME key newkey` | 修改key的名称 |
| `RENAMENX key newkey` | __仅当newkey不存在时__，将key改名为newkey |
| `TYPE key` | 返回 key 所储存的值的类型 |

## 3.3 Redis 字符串(String)

Redis字符串数据类型的相关命令用于管理redis字符串值，基本语法如下：

* `COMMAND KEY_NAME`

__命令：__

| 命令 | 描述 |
|:--|:--|
| `SET key value` | 设置指定 key 的值 |
| `GET key` | 获取指定 key 的值 |
| `GETRANGE key start end` | 返回key中字符串值的子字符 |
| `GETSET key value` | 将给定key的值设为value，并返回key的旧值(old value) |
| `GETBIT key offset` | 对key所储存的字符串值，获取指定偏移量上的位(bit) |
| `MGET key1 [key2..]` | 获取所有(一个或多个)给定key的值 |
| `SETBIT key offset value` | 对key所储存的字符串值，设置或清除指定偏移量上的位(bit) |
| `SETEX key seconds value` | 将值value关联到key，并将key的过期时间设为seconds(以秒为单位) |
| `SETNX key value` | 只有在key不存在时设置key的值 |
| `SETRANGE key offset value` | 用value参数覆写给定key所储存的字符串值，从偏移量offset开始 |
| `STRLEN key` | 返回key所储存的字符串值的长度 |
| `MSET key value [key value ...]` | 同时设置一个或多个key-value对 |
| `MSETNX key value [key value ...]` | 同时设置一个或多个key-value对，当且仅当所有给定key都不存在 |
| `PSETEX key milliseconds value` | 这个命令和SETEX命令相似，但它以毫秒为单位设置key的生存时间，而不是像SETEX命令那样，以秒为单位 |
| `INCR key` | 将key中储存的数字值增一 |
| `INCRBY key increment` | 将key所储存的值加上给定的增量值（increment） |
| `INCRBYFLOAT key increment` | 将key所储存的值加上给定的浮点增量值（increment） |
| `DECR key` | 将key中储存的数字值减一 |
| `DECRBY key decrement` | key所储存的值减去给定的减量值（decrement） |
| `APPEND key value` | 如果key已经存在并且是一个字符串，APPEND 命令将value追加到key原来的值的末尾 |

## 3.4 Redis 哈希(Hash)

Redis hash是一个__string类型__的field和value的映射表，hash特别适合用于存储对象。

Redis中每个hash可以存储`2^32 - 1`键值对（40多亿）。

__命令：__

| 命令 | 描述 |
|:--|:--|
| `HDEL key field2 [field2]` | 删除一个或多个哈希表字段 |
| `HEXISTS key field` | 查看哈希表key中，指定的字段是否存在 |
| `HGET key field` | 获取存储在哈希表中指定字段的值 |
| `HGETALL key` | 获取在哈希表中指定key的所有字段和值 |
| `HINCRBY key field increment` | 为哈希表key中的指定字段的整数值加上增量 increment |
| `HINCRBYFLOAT key field increment` | 为哈希表key中的指定字段的浮点数值加上增量increment |
| `HKEYS key` | 获取所有哈希表中的字段 |
| `HLEN key` | 获取哈希表中字段的数量 |
| `HMGET key field1 [field2]` | 获取所有给定字段的值 |
| `HMSET key field1 value1 [field2 value2 ]` | 同时将多个__field-value(域-值)对__设置到哈希表key中 |
| `HSET key field value` | 将哈希表key中的字段field的值设为value |
| `HSETNX key field value` | 只有在字段field不存在时，设置哈希表字段的值 |
| `HVALS key` | 获取哈希表中所有值 |
| `HSCAN key cursor [MATCH pattern] [COUNT count]` | 迭代哈希表中的键值对 |

## 3.5 Redis 列表(List)

Redis列表是简单的字符串列表，按照插入顺序排序。你可以添加一个元素到列表的头部（左边）或者尾部（右边）

一个列表最多可以包含`2^32 - 1`个元素(4294967295，每个列表超过40亿个元素)。

__命令：__

| 命令 | 描述 |
|:--|:--|
| `BLPOP key1 [key2 ] timeout` | 移出并获取列表的第一个元素，如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止 |
| `BRPOP key1 [key2 ] timeout` | 移出并获取列表的最后一个元素，如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止|
| `BRPOPLPUSH source destination timeout` | 从列表中弹出一个值，将弹出的元素插入到另外一个列表中并返回它；如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止 |
| `LINDEX key index` | 通过索引获取列表中的元素 |
| `LINSERT key BEFORE/AFTER pivot value` | 在列表的元素前或者后插入元素 |
| `LLEN key` | 获取列表长度 |
| `LPOP key` | 移出并获取列表的第一个元素 |
| `LPUSH key value1 [value2]` | 将一个或多个值插入到列表头部 |
| `LPUSHX key value` | 将一个值插入到已存在的列表头部 |
| `LRANGE key start stop` | 获取列表指定范围内的元素 |
| `LREM key count value` | 移除列表元素 |
| `LSET key index value` | 通过索引设置列表元素的值 |
| `LTRIM key start stop` | 对一个列表进行修剪(trim)，就是说，让列表只保留指定区间内的元素，不在指定区间之内的元素都将被删除 |
| `RPOP key` | 移除并获取列表最后一个元素 |
| `RPOPLPUSH source destination` | 移除列表的最后一个元素，并将该元素添加到另一个列表并返回 |
| `RPUSH key value1 [value2]` | 在列表中添加一个或多个值 |
| `RPUSHX key value` | 为已存在的列表添加值 |

* R：Right
* L：Left
* B：Block

## 3.6 Redis 集合(Set)

Redis的Set是string类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据。

Redis中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。
集合中最大的成员数为`2^32 - 1`(4294967295，每个集合可存储40多亿个成员)。

__命令：__

| 命令 | 描述 |
|:--|:--|
| `SADD key member1 [member2]` | 向集合添加一个或多个成员 |
| `SCARD key` | 获取集合的成员数 |
| `SDIFF key1 [key2]` | 返回给定所有集合的差集 |
| `SDIFFSTORE destination key1 [key2]` | 返回给定所有集合的差集并存储在destination中 |
| `SINTER key1 [key2]` | 返回给定所有集合的交集 |
| `SINTERSTORE destination key1 [key2]` | 返回给定所有集合的交集并存储在destination中 |
| `SISMEMBER key member` | 判断member元素是否是集合key的成员 |
| `SMEMBERS key` | 返回集合中的所有成员 |
| `SMOVE source destination member` | 将member元素从source集合移动到destination集合 |
| `SPOP key` | 移除并返回集合中的一个随机元素 |
| `SRANDMEMBER key [count]` | 返回集合中一个或多个随机数 |
| `SREM key member1 [member2]` | 移除集合中一个或多个成员 |
| `SUNION key1 [key2]` | 返回所有给定集合的并集 |
| `SUNIONSTORE destination key1 [key2]` | 所有给定集合的并集存储在 destination 集合中 |
| `SSCAN key cursor [MATCH pattern] [COUNT count]` | 迭代集合中的元素 |

## 3.7 Redis 有序集合(sorted set)

Redis有序集合和集合一样也是string类型元素的集合,且不允许重复的成员。
不同的是每个元素都会关联一个double类型的分数。redis正是通过分数来为集合中的成员进行从小到大的排序。

有序集合的成员是唯一的，但分数(score)却可以重复。

集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。集合中最大的成员数为`2^32 - 1`(4294967295，每个集合可存储40多亿个成员)。

__命令：__

| 命令 | 描述 |
|:--|:--|
| `ZADD key score1 member1 [score2 member2]` | 向有序集合添加一个或多个成员，或者更新已存在成员的分数 |
| `ZCARD key` | 获取有序集合的成员数 |
| `ZCOUNT key min max` | 计算在有序集合中指定区间分数的成员数 |
| `ZINCRBY key increment member` | 有序集合中对指定成员的分数加上增量increment |
| `ZINTERSTORE destination numkeys key [key ...]` | 计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合key中 |
| `ZLEXCOUNT key min max` | 在有序集合中计算指定字典区间内成员数量 |
| `ZRANGE key start stop [WITHSCORES]` | 通过索引区间返回有序集合成指定区间内的成员 |
| `ZRANGEBYLEX key min max [LIMIT offset count]` | 通过字典区间返回有序集合的成员 |
| `ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT]` | 通过分数返回有序集合指定区间内的成员 |
| `ZRANK key member` | 返回有序集合中指定成员的索引 |
| `ZREM key member [member ...]` | 移除有序集合中的一个或多个成员 |
| `ZREMRANGEBYLEX key min max` | 移除有序集合中给定的字典区间的所有成员 |
| `ZREMRANGEBYRANK key start stop` | 移除有序集合中给定的排名区间的所有成员 |
| `ZREMRANGEBYSCORE key min max` | 移除有序集合中给定的分数区间的所有成员 |
| `ZREVRANGE key start stop [WITHSCORES]` | 返回有序集中指定区间内的成员，通过索引，分数从高到底 |
| `ZREVRANGEBYSCORE key max min [WITHSCORES]` | 返回有序集中指定分数区间内的成员，分数从高到低排序 |
| `ZREVRANK key member` | 返回有序集合中指定成员的排名，有序集成员按分数值递减(从大到小)排序 |
| `ZSCORE key member` | 返回有序集中，成员的分数值 |
| `ZUNIONSTORE destination numkeys key [key ...]` | 计算给定的一个或多个有序集的并集，并存储在新的key中 |
| `ZSCAN key cursor [MATCH pattern] [COUNT count]` | 迭代有序集合中的元素（包括元素成员和元素分值） |

# 4 参考

* [Redis 教程](http://www.runoob.com/redis/redis-intro.html)
