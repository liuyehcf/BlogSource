---
title: Paper-Reading
date: 2021-09-08 17:03:18
tags: 
- 原创
categories: 
- Paper
---

**阅读更多**

<!--more-->

# 1 Morsel-Driven Parallelism: A NUMA-Aware Query Evaluation Framework for the Many-Core Age

1. 为什么现在开始关注`many-core`架构：随着内存带宽的增长，出现了一些内存级的数据库（广义或者狭义，狭义指的是所有数据完全存在于内存中；广义指的是部分数据以某种形式存在于内存中，比如缓存），对于这些数据库系统，I/O不再是性能瓶颈，能否高效利用好计算机的多个`core`决定了系统整体的性能
1. 核心是调度机制：（称为`dispatcher`），能够灵活的调整pipeline的并发度
1. 我们的调度程序运行固定的、依赖于机器的线程数，这样即使有新查询到达，也不会出现资源超额订阅，并且这些线程被固定在核心上，这样就不会由于操作系统将线程移动到不同的核心
1. `morsel`：data fragment，主要指数据格式，量词，一小部分
1. `morsel-driven`调度器的关键特征：任务的分配是在运行时完成的，因此是完全弹性的。即使面对不确定的中间结果大小分布，以及现代CPU内核难以预测的性能（即使工作量相同，性能也会变化）也能有较好的表现
1. 有一些系统采用了`operator`维度的并发控制，但是这会引入不必要的同步开销，因为在大部分场景下，operator之间是存在关联关系的，下一个operator需要接受上一个operator的输入，频繁的数据同步操作会带来负增益
1. `morsel-driven`和`volcano`模型的区别诶是：`volcano`中的执行单元是相互独立的，但是`mosel-driven`中不同的pipeline之间是存在依赖的，它们之间会通过`lock-free`机制来实现数据共享
1. `morsel-at-a-time`：一次处理一组数据，随后即进入调度，避免复杂低优先级查询饿死简单高优先级查询
1. `dispatcher`的运行有两种方式：其一，用独立的线程或者线程池来完成分发相关的code；其二，每个worker分别运行分发相关的code（take task from a lock-free-queue）
1. 由于pipeline之间是有依赖关系的，因此，当前驱pipeline完成后需要通知并驱动下一个pipeline，这种机制叫做`passive state machine`
1. `elasticity`：在任何时候可以将core分配给任何查询任务的能力
1. 在`morsel-driven`架构中，取消查询的代价非常低（可能原因是用户取消查询，或者内存分配超限等等异常情况），只需要将查询相关的pipeline标记为`cancel`，那么所有的worker便不再处理这个查询了（相比于让操作系统杀掉线程的操作来说轻量很多）
1. `morsel-size`对于性能来说不是特别重要，通常它只需要保证足够大以分摊调度开销，同时提供良好的响应时间即可
1. 在一些系统中，那些共享的数据结构，即便是`lock-free`，也很容易成为性能瓶颈。而在`morsel-driven`架构中，包含如下几个特点
    * 数据会被切割成一组互补重合的区间，`worker`工作在某一个区间上，因此`cache line`基本是和每个区间对齐的，不太可能出现缓存冲突的问题（除非`worker`从其他`worker`那边窃取了数据并进行处理
    * 并发度越高，数据结构带来的压力越低（这个怎么理解？）
    * 我们总是可以通过调大`morsel-size`来降低`work-stealing`的发生。如果`morsel-size`特别大，虽然会降低线程的工作效率（本来一份工作可以由多个线程同时处理，比如scan，但现在只由一个线程处理，有些core可能没在工作）。但是随着并发度的提高，这种负增益将会被逐渐抵消（每个core都在工作）
1. `Lock-Free Tagged Hash Table`没太看懂
    * The key idea is to tag a hash bucket list with a small filter into which all elements of that partic- ular list are “hashed” to set their 1-bit.
    * 与`Bloom filter`相比，优势是？
        * `Bloom filter`是一个额外的数据结构，而`tagged hash table`不需要，并且性能开销很低，只需要几个位运算即可
        * 对于大表，`Bloom filter`体积也会比较大，很难全部加载到cache中（或者只存在于`low-level`的cache中）
        * 可以直接使用，无需依赖优化器对选择进行一个预测（是否要构建`Bloom filter`）
    * 存储的是`tuple`的地址而不是对象本身，因此不能使用开放寻址法（为什么？？？，开放寻址法不能存指针么）
        * 可以通过降低装载因子减小冲突，同时空间开销较小
        * 链表允许存储大小不同的`tuple`（开放寻址法做不到，为什么？？？）
1. `NUMA-Aware Table Partitioning`
    * 对于需要频繁执行的join查询，最好将其通过同一个key进行散列，这样有更好的locality，避免多个节点之间的交互（shuffle）
1. 聚合算子的性能与基数分布密切相关（`distinct keys`），解决这个问题，通常来说有两种途径，一种是基于优化器的预测；另一种就是两阶段聚合，第一阶段做本地聚合，第二阶段做partition聚合，每个partition也有一个hashTable，但是互不重叠
1. 通常来说，基于hash的聚合算法要比基于排序的聚合算法要更快
1. 排序也采用了两阶段，难点在于：聚合阶段，如何进行并行聚合且没有同步开销。具体做法是，在第一阶段进行本地排序后，对排序后的数据进行切分，此时需要获取全局的分布信息。这样切分完之后，就可以送往多个不同的节点进行独立的处理（不同节点上的数据也是不会存在重叠的）

**progress：5/12 3.3**

# 2 Google File System

1. GFS的目标包括：performance（高性能）、scalability（高可扩展）、reliability（高可靠）、availability（高可用）
1. 在设计中，把失败视为常态而非异常。因此系统必须具备的核心能力包括：持续监控、错误勘探、错误容忍、自动恢复
1. 管理几十亿个`KB`大小的文件不是一种好方法，需要重新设计文件格式、`I/O`操作的块大小等参数
1. 绝大部分情况下，文件总是追加写入而不是覆盖写入，因此并无随机写入的需求
1. GFS放宽了一致性模型的要求，从而大大简化了文件系统的设计，降低用户的使用心智
1. GFS的假设
    * 文件系统由许多廉价的机器构成，并且这些机器容易出错（宕机等）。因此必须能够持续监控自身、探测错误、容错，并且敏捷地从异常中恢复
    * 系统存储少量大文件，大小在100M、1G甚至更大。并且能够基于这些大文件提供高效的操作。小文件肯定支持，但是不会针对小文件做太多优化
    * 工作负载包含两类读操作：大数据量的流式读取以及小数据量的随机读取。对于小数据量的随机读取，性能敏感性应用通常会进行批处理和排序，以稳定地浏览文件而不是来回移动
    * 工作负载支持两类写操作：大数据量的顺序写入以及小数据量的随机写入。其中小数据量的随机写入性能不会很好
    * 系统必须为并发写入提供高效的实现，并且提供明确的语义
    * 可持续的高带宽比低延迟更重要
1. GFS具有常规文件系统的接口，包括：`create`、`delete`、`open`、`close`、`read`、`write`。同时增加了两个新操作`snapshot`以及`record append`
    * `snapshot`以非常低的开销进行文件或者目录树的拷贝
    * `record append`能够处理大量客户端的并发请求，并且保证其写入的原子性
1. GFS包含一个`master`、多个`chunkserver`以及大量的`clients`
    * 文件被拆分成大小固定的`chunks`，每个`chunk`由一个全局唯一的`chunk handler`标识，该标识由`master`签发
    * `chunkserver`将`chunk`以linux文件的形式存储在本地磁盘上，并且通过`chunk handler`进行操作。基于可靠性考虑，每个`chunk`都会存在多个副本，并且分布在不同的`chunkserver`中
    * `master`中存储了全部的元信息，包括`namespace`、`access control`、文件与`chunk`的映射关系、`chunk`的位置信息等。同时，`master`也控制着`chunk lease`、垃圾回收（无用chunk）、`chunk`迁移等过程。`master`与`chunkserver`之间通过心跳包保持通信，用于传递指令以及采集状态信息
    * `client`从`master`中获取元数据，然后直接从`chunkserver`中读写数据
    * 无论是`client`（`client`会缓存元数据，但是不会缓存数据）或者`chunkserver`都不用缓存（这里的缓存指的是GFS层面的缓存），这是由工作负载决定的，大部分的时间都在读写大批量的数据，缓存在这种场景中，用处很小。无缓存降低了系统的复杂度。虽然`chunkserver`不用缓存，但是其存储是基于Linux文件系统的，Linux文件系统本身是有缓存的，对于频繁读写的数据是有性能增益的
1. `single-master`能够有效的降低系统复杂度，并且使得`master`能够借助全局信息处理诸如`chunk`替换以及复制等复杂操作。同时，我们要尽最大努力降低`master`在普通读写操作中的参与度，避免其成为性能瓶颈。虽然`client`不从`master`中读取数据，但是它需要知道从`master`中获取哪些`chunkserver`存储了相应的数据，因此`client`可以缓存这些信息，从而降低与`master`的交互频率
1. `chunk size`是GFS的关键参数，建议值是`64MB`。大的`chunk size`包含如下优势
    * 降低了`client`与`master`的交互频率，如果读取的数据在同一个`chunk`中，那么直接从`chunkserver`中读取即可，无需与`master`交互
    * 使得`client`的大部分操作集中在一个`chunk`中，避免多机网络开销
    * 降低了`master`中元数据的大小，`chunk size`越大，元数据数量越少，从而使得`master`将元数据存储在内存中成为可能
1. 大的`chunk size`也存在劣势，包括
    * 增大了热点chunk出现的概率。但是对于GFS的预设的工作负载来说，热点不会是主要问题，因为大部分都是顺序读写大批量的chunk

# 3 Efficiency in the Columbia Database Query Optimizer

# 4 Fast Selection and Aggregation on Encoded Data using Operator Specialization

# 5 Shared memory consistency models - A tutorial

