---
title: Redis-Persistence-Mechanism
date: 2017-08-03 14:30:33
tags: 
- 摘录
categories: 
- Database
- NoSQL
---

**阅读更多**

<!--more-->

# 1 前言

Redis提供了RDB持久化和AOF持久化，本篇文章中将会对这两种机制进行一些对比

# 2 RDB

RDB持久化是指在指定的时间间隔内将内存中的数据集快照写入磁盘。也是默认的持久化方式，这种方式是就是将内存中数据以快照的方式写入到二进制文件中，默认的文件名为dump.rdb

可以通过配置设置自动做快照持久化的方式。我们可以配置redis在n秒内如果超过m个key被修改就自动做快照，下面是默认的快照保存配置

```
   save 900 1  #900秒内如果超过1个key被修改，则发起快照保存
   save 300 10 #300秒内容如超过10个key被修改，则发起快照保存
   save 60 10000
```

## 2.1 RDB文件保存过程

RDB文件保存过程如下

1. redis调用fork，现在有了子进程和父进程
1. 父进程继续处理client请求，子进程负责将内存内容写入到临时文件。由于os的写时复制机制（copy on write)父子进程会共享相同的物理页面，**当父进程处理写请求时os会为父进程要修改的页面创建副本，而不是写共享的页面。所以子进程的地址空间内的数据是fork时刻整个数据库的一个快照。**
1. 当子进程将快照写入临时文件完毕后，用临时文件替换原来的快照文件，然后子进程退出

client 也可以使用save或者bgsave命令通知redis做一次快照持久化。save操作是在主线程中保存快照的，由于redis是用一个主线程来处理所有client的请求，这种方式会阻塞所有client请求。所以不推荐使用

另一点需要注意的是，**每次快照持久化都是将内存数据完整写入到磁盘一次，并不是增量的只同步脏数据。如果数据量大的话，而且写操作比较多，必然会引起大量的磁盘io操作，可能会严重影响性能。**

## 2.2 优势

1. 一旦采用该方式，那么你的整个Redis数据库将只包含一个文件，这样非常方便进行备份。比如你可能打算没1天归档一些数据
1. **方便备份**，我们可以很容易的将一个一个RDB文件移动到其他的存储介质上
1. RDB在恢复大数据集时的速度比AOF的**恢复速度**要快
1. RDB可以最大化Redis的性能：父进程在保存RDB文件时唯一要做的就是fork出一个子进程，然后这个子进程就会处理接下来的所有保存工作，**父进程无须执行任何磁盘I/O操作**

## 2.3 劣势

1. 如果你需要尽量避免在服务器故障时丢失数据，那么RDB不适合你。虽然Redis允许你设置不同的保存点（save point）来控制保存RDB文件的频率。**但是，因为RDB文件需要保存整个数据集的状态，所以它并不是一个轻松的操作**。因此你可能会至少5分钟才保存一次RDB文件。在这种情况下，一旦发生故障停机，你就可能会丢失好几分钟的数据
1. 每次保存RDB的时候，Redis都要fork()出一个子进程，并由子进程来进行实际的持久化工作。**在数据集比较庞大时，fork()可能会非常耗时，造成服务器在某某毫秒内停止处理客户端**；如果数据集非常巨大，并且CPU时间非常紧张的话，那么这种停止时间甚至可能会长达整整一秒。虽然AOF重写也需要进行fork()，但无论AOF重写的执行间隔有多长，数据的耐久性都不会有任何损失

# 3 AOF

**redis会将每一个收到的写命令都通过write函数追加到文件中(默认是appendonly.aof)。**

当redis重启时会通过重新执行文件中保存的写命令来在内存中重建整个数据库的内容。**当然由于os会在内核中缓存write做的修改，所以可能不是立即写到磁盘上。这样aof方式的持久化也还是有可能会丢失部分修改**。不过我们可以通过配置文件告诉redis我们想要通过fsync函数强制os写入到磁盘的时机。有三种方式如下（默认是：每秒fsync一次）

```
appendonly yes              //启用aof持久化方式
# appendfsync always      //每次收到写命令就立即强制写入磁盘，最慢的，但是保证完全的持久化，不推荐使用
appendfsync everysec     //每秒钟强制写入磁盘一次，在性能和持久化方面做了很好的折中，推荐
# appendfsync no    //完全依赖os，性能最好，持久化没保证
```

aof的方式也同时带来了另一个问题。持久化文件会变的越来越大。例如我们调用incr test命令100次，文件中必须保存全部的100条命令，其实有99条都是多余的。因为要恢复数据库的状态其实文件中保存一条set test100就够了

## 3.1 AOF文件压缩

为了压缩aof的持久化文件。redis提供了bgrewriteaof命令。收到此命令redis将使用与快照类似的方式将内存中的数据以命令的方式保存到临时文件中，最后替换原来的文件。具体过程如下

1. redis调用fork，现在有父子两个进程
1. 子进程根据内存中的数据库快照，往临时文件中写入重建数据库状态的命令
1. 父进程继续处理client请求，除了把写命令写入到原来的aof文件中。同时把收到的写命令缓存起来。这样就能保证如果子进程重写失败的话并不会出问题
1. 当子进程把快照内容写入已命令方式写到临时文件中后，子进程发信号通知父进程。然后父进程把缓存的写命令也写入到临时文件
1. 现在父进程可以使用临时文件替换老的aof文件，并重命名，后面收到的写命令也开始往新的aof文件中追加

需要注意到是重写aof文件的操作，并没有读取旧的aof文件，而是将整个内存中的数据库内容用命令的方式重写了一个新的aof文件，这点和快照有点类似

压缩的核心思路：由于保存数据本身所占的内存要比保存所有写命令所占的内存要大。在执行压缩的时刻(bgrewriteaof)，将之前的数据用快照来保存，之后仍然将每一个收到的写命令都通过write函数追加到文件中

## 3.2 优势

1. **使用AOF持久化会让Redis变得非常耐久（much more durable）**：你可以设置不同的fsync策略，比如无fsync，每秒钟一次fsync，或者每次执行写入命令时fsync。AOF的默认策略为每秒钟fsync一次，在这种配置下，Redis仍然可以保持良好的性能，并且就算发生故障停机，也最多只会丢失一秒钟的数据（fsync会在后台线程执行，所以主线程可以继续努力地处理命令请求）
1. **AOF文件是一个只进行追加操作的日志文件（append only log）**，因此对AOF文件的写入不需要进行seek，即使日志因为某些原因而包含了未写入完整的命令（比如写入时磁盘已满，写入中途停机，等等），redis-check-aof工具也可以轻易地修复这种问题。Redis可以在AOF文件体积变得过大时，自动地在后台对AOF进行重写：重写后的新AOF文件包含了恢复当前数据集所需的最小命令集合。整个重写操作是绝对安全的，因为Redis在创建新AOF文件的过程中，会继续将命令追加到现有的AOF文件里面，即使重写过程中发生停机，现有的AOF文件也不会丢失。而一旦新AOF文件创建完毕，Redis就会从旧AOF文件切换到新AOF文件，并开始对新AOF文件进行追加操作
1. **AOF文件有序地保存了对数据库执行的所有写入操作**，这些写入操作以Redis协议的格式保存，因此AOF文件的内容非常容易被人读懂，对文件进行分析（parse）也很轻松。导出（export）AOF文件也非常简单：举个例子，如果你不小心执行了FLUSHALL命令，但只要AOF文件未被重写，那么只要停止服务器，移除AOF文件末尾的FLUSHALL命令，并重启Redis，就可以将数据集恢复到FLUSHALL执行之前的状态

## 3.3 劣势

1. 对于相同的数据集来说，**AOF文件的体积通常要大于RDB文件的体积(这也是AOF能压缩的原因)**
1. 根据所使用的fsync策略，**AOF的速度可能会慢于RDB**。在一般情况下，每秒fsync的性能依然非常高，而关闭fsync可以让AOF的速度和RDB一样快，即使在高负荷之下也是如此。不过在处理巨大的写入载入时，RDB可以提供更有保证的最大延迟时间（latency）
1. AOF在过去曾经发生过这样的bug：因为个别命令的原因，导致AOF文件在重新载入时，无法将数据集恢复成保存时的原样。（举个例子，阻塞命令BRPOPLPUSH就曾经引起过这样的bug。）测试套件里为这种情况添加了测试：它们会自动生成随机的、复杂的数据集，并通过重新载入这些数据来确保一切正常。虽然这种bug在AOF文件中并不常见，但是对比来说，RDB几乎是不可能出现这种bug的

# 4 参考

* [RDB和AOF持久化对比](http://www.cnblogs.com/rollenholt/p/3874443.html)
* [Redis 设计与实现](http://redisbook.readthedocs.io/en/latest/internal/aof.html)
