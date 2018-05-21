---
title: Redis-基础教程
date: 2017-08-17 19:54:16
tags: 
- 摘录
categories: 
- 数据库
- 非关系型数据库(NoSQL)
---

__阅读更多__

<!--more-->

# 1 前言

## 1.1 Redis简介

Redis是完全开源免费的，遵守BSD协议，是一个高性能的key-value数据库
Redis与其他key-value缓存产品有以下三个特点：

* __Redis支持数据的持久化__，可以将内存中的数据保存在磁盘中，重启的时候可以再次加载进行使用
* __Redis不仅仅支持简单的key-value类型的数据__，同时还提供list，set，zset，hash等数据结构的存储
* __Redis支持数据的备份__，即master-slave模式的数据备份

## 1.2 Redis优势

* __性能极高__：Redis能读的速度是110000次/s，写的速度是81000次/s 
* __丰富的数据类型__：Redis支持`Strings`，`Lists`，`Hashes`，`Sets`及`Ordered Sets`数据类型操作
* __原子__：Redis的所有操作都是原子性的，同时Redis还支持对几个操作全并后的原子性执行
* __丰富的特性__：Redis还支持`publish/subscribe`，通知，key过期等等特性

## 1.3 Redis与其他key-value存储有什么不同？

Redis有着更为复杂的数据结构并且提供对他们的原子性操作，这是一个不同于其他数据库的进化路径。Redis的数据类型都是基于基本数据结构的同时对程序员透明，无需进行额外的抽象

Redis运行在内存中但是可以持久化到磁盘，所以在对不同数据集进行高速读写时需要权衡内存，因为数据量不能大于硬件内存。在内存数据库方面的另一个优点是，相比在磁盘上相同的复杂的数据结构，在内存中操作起来非常简单，这样Redis可以做很多内部复杂性很强的事情。同时，在磁盘格式方面他们是紧凑的以追加的方式产生的，因为他们并不需要进行随机访问

# 2 数据类型

Redis支持五种数据类型：`string`（字符串），`hash`（哈希），`list`（列表），`set`（集合）及`zset`(sorted set：有序集合)

## 2.1 string(字符串)

string是redis最基本的类型，你可以理解成与Memcached一模一样的类型，一个key对应一个value

string类型是二进制安全的。意思是redis的string可以包含任何数据。比如jpg图片或者序列化的对象

* __二进制安全的意思是：只关心二进制化的字符串，不关心具体格式。只会严格的按照二进制的数据存取。不会妄图已某种特殊格式解析数据。__

string类型是Redis最基本的数据类型，一个键最大能存储512MB

## 2.2 Hash(哈希)

Redis hash是一个键名对集合

Redis hash是一个string类型的field和value的映射表，hash特别适合用于存储对象

每个hash可以存储`2^32 - 1`键值对（40多亿）

## 2.3 List(列表)

Redis 列表是简单的字符串列表，按照插入顺序排序。你可以添加一个元素到列表的头部（左边）或者尾部（右边）

列表最多可存储`2^32 - 1`个元素(4294967295，每个列表可存储40多亿)

## 2.4 Set(集合)

Redis的Set是string类型的无序集合

集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)

集合中最大的成员数为`2^32 - 1`(4294967295，每个集合可存储40多亿个成员)

## 2.5 zset(sorted set：有序集合)

Redis zset 和 set 一样也是string类型元素的集合，且不允许重复的成员

不同的是每个元素都会关联一个double类型的分数。redis正是通过分数来为集合中的成员进行从小到大的排序

zset的成员是唯一的，但分数(score)却可以重复

# 3 命令

## 3.1 登陆

`redis-cli`

`redis-cli -h host -p port -a password`

## 3.2 Redis键(key)

Redis键命令用于管理redis的键

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

Redis hash是一个__string类型__的field和value的映射表，hash特别适合用于存储对象

Redis中每个hash可以存储`2^32 - 1`键值对（40多亿）

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

一个列表最多可以包含`2^32 - 1`个元素(4294967295，每个列表超过40亿个元素)

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

Redis的Set是string类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据

Redis中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)
集合中最大的成员数为`2^32 - 1`(4294967295，每个集合可存储40多亿个成员)

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

Redis有序集合和集合一样也是string类型元素的集合，且不允许重复的成员
不同的是每个元素都会关联一个double类型的分数。redis正是通过分数来为集合中的成员进行从小到大的排序

有序集合的成员是唯一的，但分数(score)却可以重复

集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。集合中最大的成员数为`2^32 - 1`(4294967295，每个集合可存储40多亿个成员)

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

## 3.8 Redis HyperLogLog

Redis在 2.8.9版本添加了HyperLogLog结构

__Redis HyperLogLog是用来做基数统计的算法__，HyperLogLog的优点是，在输入元素的数量或者体积非常非常大时，计算基数所需的空间总是固定的、并且是很小的

在Redis里面，每个HyperLogLog键只需要花费12KB内存，就可以计算接近2^64个不同元素的基数。这和计算基数时，元素越多耗费内存就越多的集合形成鲜明对比

但是，因为HyperLogLog只会根据输入元素来计算基数，而不会储存输入元素本身，所以HyperLogLog不能像集合那样，返回输入的各个元素

__什么是基数?__：比如数据集{1, 3, 5, 7, 5, 7, 8}，那么这个数据集的基数集为{1, 3, 5 ,7, 8}，基数(不重复元素)为5。 基数估计就是在误差可接受的范围内，快速计算基数

__命令：__

| 命令 | 描述 |
|:--|:--|
| `PFADD key element [element ...]` | 添加指定元素到HyperLogLog中 |
| `PFCOUNT key [key ...]` | 返回给定HyperLogLog的基数估算值 |
| `PFMERGE destkey sourcekey [sourcekey ...]` | 将多个HyperLogLog合并为一个HyperLogLog |

## 3.9 Redis发布订阅

Redis发布订阅(pub/sub)是一种消息通信模式：发送者(pub)发送消息，订阅者(sub)接收消息

Redis客户端可以订阅任意数量的频道

下图展示了频道channel1，以及订阅这个频道的三个客户端——client2、client5和client1之间的关系：

![fig1](/images/Redis-基础教程/fig1.png)

当有新消息通过PUBLISH命令发送给频道channel1时，这个消息就会被发送给订阅它的三个客户端：

![fig2](/images/Redis-基础教程/fig2.png)

__命令：__

| 命令 | 描述 |
|:--|:--|
| `PSUBSCRIBE pattern [pattern ...]` | 订阅一个或多个符合给定模式的频道 |
| `PUBSUB subcommand [argument [argument ...]]` | 查看订阅与发布系统状态 |
| `PUBLISH channel message` | 将信息发送到指定的频道 |
| `PUNSUBSCRIBE [pattern [pattern ...]]` | 退订所有给定模式的频道 |
| `SUBSCRIBE channel [channel ...]` | 订阅给定的一个或多个频道的信息 |
| `UNSUBSCRIBE [channel [channel ...]]` | 指退订给定的频道 |

## 3.10 Redis 事务

Redis事务可以一次执行多个命令，并且带有以下两个重要的保证：

1. __事务是一个单独的隔离操作__：事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中，不会被其他客户端发送来的命令请求所打断
1. __事务是一个原子操作__：事务中的命令要么全部被执行，要么全部都不执行

__一个事务从开始到执行会经历以下三个阶段__：

1. 开始事务
1. 命令入队
1. 执行事务

__命令：__

| 命令 | 描述 |
|:--|:--|
| `DISCARD` | 取消事务，放弃执行事务块内的所有命令 |
| `EXEC` | 执行所有事务块内的命令 |
| `MULTI` | 标记一个事务块的开始 |
| `UNWATCH` | 取消WATCH命令对所有key的监视 |
| `WATCH key [key ...]` | 监视一个(或多个)key，如果在事务执行之前这个(或这些)key被其他命令所改动，那么事务将被打断 |

## 3.11 Redis 连接

Redis连接命令主要是用于连接redis服务

__命令：__

| 命令 | 描述 |
|:--|:--|
| `AUTH password` | 验证密码是否正确 |
| `ECHO message` | 打印字符串 |
| `PING` | 查看服务是否运行 |
| `QUIT` | 关闭当前连接 |
| `SELECT index` | 切换到指定的数据库 |

* 当服务器设定了密码后，客户端可以在连接时就输入密码(`redis-cli -h host -p port -a password`)，或者登陆后用auth来验证密码(`AUTH password`)

# 4 高级特性

## 4.1 Redis 数据备份与恢复

Redis SAVE命令用于创建当前数据库的备份

该命令将在__redis安装目录__中创建`dump.rdb`文件

如果需要恢复数据，只需将备份文件(dump.rdb)移动到redis安装目录并启动服务即可。获取redis目录可以使用CONFIG命令：`CONFIG GET dir`

创建redis备份文件也可以使用命令BGSAVE，该命令在后台执行

## 4.2 Redis 安全

我们可以通过redis的配置文件设置密码参数，这样客户端连接到redis服务就需要密码验证，这样可以让你的redis服务更安全

查看密码：`CONFIG get requirepass`。默认情况下requirepass参数是空的，这就意味着你无需通过密码验证就可以连接到redis服务

你可以通过以下命令来修改该参数：`CONFIG set requirepass "runoob"`

设置密码后，客户端连接redis服务就需要密码验证，否则无法执行命令

## 4.3 Redis 性能测试

Redis性能测试是通过同时执行多个命令实现的

__语法：__

* `redis-benchmark [option] [option value]`

__参数：__

| 选项 | 描述 | 默认值 |
|:--|:--|:--|
| -h | 指定服务器主机名 | 127.0.0.1 |
| -p | 指定服务器端口 | 6379 |
| -s | 指定服务器socket | / |
| -c | 指定并发连接数 | 50 |
| -n | 指定请求数 | 10000 |
| -d | 以字节的形式指定SET/GET值的数据大小 | 2 |
| -k | 1=keep alive 0=reconnect | 1 |
| -r | SET/GET/INCR使用随机key，SADD使用随机值 | / |
| -P | 通过管道传输`<numreq>`请求 | 1 |
| -q | 强制退出redis。仅显示query/sec值 | / |
| --csv | 以CSV格式输出 | / |
| -l | 生成循环，永久执行测试 | / |
| -t | 仅运行以逗号分隔的测试命令列表 | / |
| -I | Idle模式。仅打开N个idle连接并等待 | / |

## 4.4 Redis 客户端连接

Redis通过监听一个TCP端口或者Unix socket的方式来接收来自客户端的连接，当一个连接建立后，Redis内部会进行以下一些操作：

1. 首先，客户端socket会被设置为非阻塞模式，因为Redis在网络事件处理上采用的是非阻塞多路复用模型
1. 然后为这个socket设置TCP_NODELAY属性，禁用Nagle算法
1. 然后创建一个可读的文件事件用于监听这个客户端socket的数据发送

__最大连接数__

* 在Redis2.4中，最大连接数是被直接硬编码在代码里面的，而在2.6版本中这个值变成可配置的
* maxclients的默认值是10000，你也可以在redis.conf中对这个值进行修改

在服务启动时设置最大连接数为 100000：`redis-server --maxclients 100000`

__命令：__

| 命令 | 描述 |
|:--|:--|
| `CLIENT LIST` | 返回连接到redis服务的客户端列表 |
| `CLIENT SETNAME` | 设置当前连接的名称 |
| `CLIENT GETNAME` | 获取通过CLIENT SETNAME命令设置的服务名称 |
| `CLIENT PAUSE` | 挂起客户端连接，指定挂起的时间以毫秒计 |
| `CLIENT KILL` | 关闭客户端连接 |	

## 4.5 Redis 管道技术

Redis是一种基于客户端-服务端模型以及请求/响应协议的TCP服务。这意味着通常情况下一个请求会遵循以下步骤：

1. 客户端向服务端发送一个查询请求，并监听Socket返回，通常是以阻塞模式，等待服务端响应
1. 服务端处理命令，并将结果返回给客户端

__Redis管道技术可以在服务端未响应时，客户端可以继续向服务端发送请求，并最终一次性读取所有服务端的响应。__

## 4.6 Redis 分区

分区是分割数据到多个Redis实例的处理过程，因此每个实例只保存key的一个子集

__分区的优势：__

1. 通过利用多台计算机内存的和值，允许我们构造更大的数据库
1. 通过多核和多台计算机，允许我们扩展计算能力；通过多台计算机和网络适配器，允许我们扩展网络带宽

__分区的不足：__

1. redis的一些特性在分区方面表现的不是很好：
1. 涉及多个key的操作通常是不被支持的。举例来说，当两个set映射到不同的redis实例上时，你就不能对这两个set执行交集操作
1. 涉及多个key的redis事务不能使用
1. 当使用分区时，数据处理较为复杂，比如你需要处理多个rdb/aof文件，并且从多个实例和主机备份持久化文件
1. 增加或删除容量也比较复杂。redis集群大多数支持在运行时增加、删除节点的透明数据平衡的能力，但是类似于客户端分区、代理等其他系统则不支持这项特性。然而，一种叫做presharding的技术对此是有帮助的

__分区类型：__Redis有两种类型分区。假设有4个Redis实例R0，R1，R2，R3，和类似user:1，user:2这样的表示用户的多个key，对既定的key有多种不同方式来选择这个key存放在哪个实例中。__也就是说，有不同的系统来映射某个key到某个Redis服务。__

* __范围分区__：最简单的分区方式是按范围分区，就是映射一定范围的对象到特定的Redis实例
    * 比如，ID从0到10000的用户会保存到实例R0，ID从10001到 20000的用户会保存到R1，以此类推
    * 这种方式是可行的，并且在实际中使用，不足就是要有一个区间范围到实例的映射表。这个表要被管理，同时还需要各种对象的映射表，通常对Redis来说并非是好的方法
* __哈希分区__：另外一种分区方法是hash分区。这对任何key都适用，也无需object_name:这种形式，像下面描述的一样简单：
    * 用一个hash函数将key转换为一个数字，比如使用crc32 hash函数。对key foobar执行crc32(foobar)会输出类似93024922的整数
    * 对这个整数取模，将其转化为0-3之间的数字，就可以将这个整数映射到4个Redis实例中的一个了。`93024922 % 4 = 2`，就是说key foobar应该被存到R2实例中。注意：取模操作是取除的余数，通常在多种编程语言中用%操作符实现
* __一致性hash分区__：哈希分区有一个不足之处，就是增加或者删除机器时节点的分布就被完全打乱了，不满足单调性。而对于一致性hash，增加节点后，原来的数据要么存放在之前的节点上，要么存放在新的节点上

# 5 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [Redis 教程](http://www.runoob.com/redis/redis-intro.html)
