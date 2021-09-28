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
1. `single-master`能够有效的降低系统复杂度，并且使得`master`能够借助全局信息处理诸如`chunk`替换以及克隆等复杂操作。同时，我们要尽最大努力降低`master`在普通读写操作中的参与度，避免其成为性能瓶颈。虽然`client`不从`master`中读取数据，但是它需要知道从`master`中获取哪些`chunkserver`存储了相应的数据，因此`client`可以缓存这些信息，从而降低与`master`的交互频率
1. `chunk size`是GFS的关键参数，建议值是`64MB`。大的`chunk size`包含如下优势
    * 降低了`client`与`master`的交互频率，如果读取的数据在同一个`chunk`中，那么直接从`chunkserver`中读取即可，无需与`master`交互
    * 使得`client`的大部分操作集中在一个`chunk`中，避免多机网络开销
    * 降低了`master`中元数据的大小，`chunk size`越大，元数据数量越少，从而使得`master`将元数据存储在内存中成为可能
1. 大的`chunk size`也存在劣势，包括
    * 增大了热点chunk出现的概率。但是对于GFS的预设的工作负载来说，热点不会是主要问题，因为大部分都是顺序读写大批量的chunk
1. `master`存储了如下三种元数据
    1. 文件以及`chunk`的`namespace`
    1. `file`到`chunk`的映射关系
    1. `chunk`的每个副本的具体位置信息
    * 所有的元数据都存储在`master`的内存中，前两种类型也会以日志的形式持久化到本地磁盘上
    * `master`不存储`chunk`的具体位置信息，而是在`master`每次启动或者有新的`chunkserver`加入集群时主动询问
1. 对于存储在内存中的元数据，`master`会对其进行周期性的扫描，主要实现以下功能
    * 实现垃圾回收，清理那些被标记删除的chunk
    * `chunk`克隆，用以应对`chunkserver`宕机
    * `chunk`迁移，实现负载均衡
1. `master`不会存储`chunk`的位置信息，而是在启动时，主动向`chunkserver`拉取这些信息，`master`始终保持原信息的有效性，因为它控制着所有`chunk`的迁移、拷贝等操作，并且与`chunkserver`通过周期性的心跳包来定期同步状态
    * **采用这种设计的另一个原因是：`chunkserver`对一个`chunk`是否在其本地磁盘上有最终解释权，没有必要维护一个`master`视角下的一致性视图。大大降低了复杂度**
1. `operation log`记录了`metadata`的历史变更。`master`必须确保操作日志落盘后（本机以及用以备份的远程主机），才能返回`client`，
    * `master`可以通过重放日志来恢复自身的状态
    * 当日志数量超过一定的阈值后，可以通过`checkpoint`来解决这个问题，`checkpoint`可以简单理解成某个时刻`master`内存数据的快照，其数据结构类似B-tree
1. GFS采用了一种松一致性模型。引入两个概念`consistent`以及`defined`
    * `consistent`：所有客户端看到的数据都是一样的（从任意副本上）
    * `defined`：所有客户端都能看到引起数据变更的操作具体是什么
    * `a serial success mutation`：`consistent and difined`
    * `concurrent success mutations`：`consistent and undefined`
    * `failed mutations`：`inconsistent and undefined`
1. `Data mutations`包含两种操作`write`以及`record append`
    * `write`：表示往指定的offset写入数据
    * `record append`：表示往文件最后追加数据。在并发的场景下，至少有一个能追加成功
1. GFS的松一致性模型保证的约束有
    * 文件命名空间变更是个原子操作
    * 在`a sequence of successful mutations`之后，相应的文件是`consistent`，`difined`。GFS通过在副本上重放操作来保证`defined`特性，并且通过版本号来检测那些过时的`chunk`（`chunkserver`从错误中恢复回来，但是错过了一些变更），这些过时的`chunk`将不包含在`master`中。此外，由于`client`会缓存`chunk`的位置信息，因此在缓存失效之前可能读到旧的数据，而大部分的文件都是`append-only`的，因此大概率读到的是不完整的数据而不是错误的数据，又进一步降低了影响
    * 当一个`chunk`的所有副本均丢失后，`chunk`才算丢失。在恢复之前，GFS会返回清晰的错误信息而不是错误的数据
1. 使用GFS的应用，最好使用追加写而不是覆盖写，因为追加写具有更好的性能以及错误恢复能力
1. 系统被设计为尽量避免与master交互
1. `Leases and Mutation Order`
    * 在执行变更操作时，`master`会挑选出某一个副本作为`primary`，然后由这个`primary`决定这一组操作的执行顺序，然后将这个执行顺序同步给其他副本
    * 租赁机制是为了降低`master`的参与度，避免`master`成为系统的瓶颈
    * 在执行变更的过程中，`master`还有可能通过心跳包发送额外的变更请求，或者直接终止变更操作
        * 假设有2个副本A、B，A变更结束，B还在变更，此时`master`发送终止变更的消息，A和B将如何恢复？
    * 变更操作的整体流程（看论文就行，这里不赘述）
        * 第三步：论文中是由client向所有的replicas推送待写入的数据，这就要求clients必须知道集群中的所有副本情况，才知道发给谁，感觉有点怪。更好的做法是：发给其中某个副本，然后让这个副本同步给其他副本
        * 第六步：如果部分副本变更成功，部分副本变更失败时，怎么回滚？不需要回滚，因为数据有版本的概念，假设有三个副本A、B、C，A、B都写入成功了，`chunk`的版本号是6；C写失败，版本号还是5。但此时，A和B构成了一个多数派，变更操作成功，并且将版本信息告知`master`，下次`client`读的时候，仍然可以从A、B、C三个副本中随机读取，假设选择的是C，但是一看版本号不是最新的，那么就会重新发起读操作，直至读取到最新的数据。此外，失败的副本会有补偿机制来进行修复
    * 如果需要写入大量数据（规模超过`chunkSize`），`client`会首先将其拆分成多个小块，但是这多个小块的多次写操作可能不是原子的。因为在写入的过程中，可能会插入其他client的写入操作。最终多个副本上的数据一定是相同的，但是从不同client的视角上来说，变更的顺序可能是不同的。因此此时就是`consistent but undefined`
1. `Data Flow`
    * 控制流与数据流解耦（控制流中不要阻塞等待io事件）
    * 为了最大程度地利用机器带宽，数据被组织在线性的`pipeline`中，而不是其他复杂的拓扑结构。目的是为了更快的传递数据，而不是将时间消耗在拓扑结构处理中（效果会很好？） 
    * 更具体来说，当有数据需要传送到多个节点时，机器只会将数据发送给离自己最近的节点，然后依次类推。如何计算距离：通过ip地址（估计通过网段的差异性来判断距离的远近）
    * 当机器收到数据的同时，就立即将数据`forward`到其他节点
1. `Atomic Record Appends`
    * 传统的写操作，需要提供数据以及写入的`offset`，并发写无法做同步（为啥？？？），导致最终结果包含多个`client`的数据
    * 在`append write`中，客户端只需要提供数据，GFS会提供该操作的至少写入一次的原子语义，并且将数据写入的`offset`发送给`client`。这与Unix中的`O APPEND`文件模式相同
    * 如果任何一个副本写失败，客户端都会重试。这就会导致不同副本上的同一个chunk可能包含不同的数据（由于重试导致的重复）。GFS并不保证chunk在字节层面完全一致，它只保证数据至少被写入一次
    * 写操作成功意味着，数据以相同的`offset`被写入到所有副本的chunk中。这不是跟上条矛盾了么，如何解决？为后续的写操作分配一致的offset，一般来说，就是那个包含重复数据最多的chunk的末尾的`offset`，这样能够保证相同`offset`这个语义（会导致`chunk`中存在空白块）
1. `Snapshot`
    * GFS几乎在瞬间就可以生成文件或者目录树的快照，尽量减少在生成期间由于其他变更引入的数据不一致。在实际场景中，会大量使用该功能来创建海量数据的副本（或者副本的副本），以及创建`checkpoint`
    * GFS使用了`Copy-On-Write`技术来实现快照
    * 当`master`收到了创建快照的请求时，会先回收相关`chunk`的租赁，于是后续针对这些`chunk`的写操作都需要与`master`进行交互。然后`master`创建该`chunk`的一个副本
        * 拷贝一份文件或者目录树的元数据，新老两份元数据指向的是同一个`chunk`
        * 当对副本进行写操作时，才会进行`chunk`的拷贝动作
1. `master`允许同时处理多个请求，并采用适当粒度的锁来保证同步
    1. 与传统文件系统不同，GFS没有为目录提供用于保存该目录下所有文件和子目录的数据结构，也不支持别名（类似于软硬链接）。GFS在逻辑上将其命名空间表示为将完整路径名映射到元数据的查找表。使用前缀压缩算法，该查找表可以保存在内存中
    1. 每个命名空间（文件或者目录）都有一个读写锁。每个操作都需要获取一系列的锁，例如对`/d1/d2/.../dn/leaf`的操作，需要先后获取`/d1`、`/d1/d2`、`/d1/d2/d3`、...、`/d1/d2/.../dn`以及`/d1/d2/.../dn/leaf`的锁，这里`leaf`可以是文件也可以是目录
        * 以一个例子来说明锁机制是如何工作的：在创建`/home/user`的快照`/save/user`的过程中，创建`/home/user/foo`文件。首先，快照操作会获取`/home`、`/save`的读锁以及`/home/user`、`/save/user`的写锁。文件创建操作需要获取`/home`以及`/home/user`的读锁以及`/home/user/foo`的写锁。因此这两个操作会被串行执行，因为它们都需要获取`/home/user`这个锁（读写锁冲突）
        * 可以看到，我们在创建文件时，在其父目录上只加了一把读锁，这种锁机制的好处在于，它允许在同一个目录上进行并发操作。例如我们可以并发地在一个目录上创建多个文件。同时，该读锁可以确保目录不被删除、重命名、创建快照
        * 由于`namespace`包含了非常多的节点，因此读写锁被设计成延迟加载，以及在不用时，锁会被删除
        * GFS会严格保证按照namespace的层次结构依次顺序获取锁，以免发生死锁
1. `Replica Placement`
    * GFS集群可以包含多个层级结构。通常一个GFS集群包含成百上千个节点，这些节点可能跨机房部署，因此两台机器之间的通信也可能跨机房。显然跨机房的网络带宽一般小于同机房的网络带宽。因此`multi-level`分布式架构对高可用、高可靠、高可扩展提出了全新的挑战
    * `hunk replica placement policy`有两个目标
        * 最大化可靠性和可用性
        * 最大化带宽利用率
    * 为了达到上述两个目的，仅跨机传播副本是不够的，还必须跨机房传播副本，以提高容灾能力。即便一个机房挂了，服务也照样可用。同时跨机传输会带来带宽的开销，因此需要在两者之间做一个权衡
1. `Creation, Re-replication, Rebalancing`
    * `chunk`副本的主要原因有三个：`chunk`的创建、恢复以及负载均衡
    * 当`master`创建一个新的`chunk`时，需要决定将这个`chunk`放到哪个`chunkserver`上，会考虑如下几个因素
        * 挑选一个磁盘负载最低的`chunkserver`
        * 控制每个`chunksever`近期创建`chunk`的数量。尽管`chunk`创建本身开销很低，但是创建通常伴随着大量的写入操作，因此整体上来讲需要做一个动态平衡
        * 将`chunk`跨机房分布
    * 当`chunk`的副本数量小于一个阈值时，`master`会开启副本拷贝的流程
    * 此外，`chunk`克隆也有优先级。因素包括：缺失的`chunk`数量
    * 为了避免克隆带来的网络开销，`master`会在集群维度和`chunkserver`维度分别限制克隆任务的数量
    * `master`还会周期性的迁移这些`chunk`，以获得更好的分布情况，磁盘利用率以及负载均衡

# 3 Efficiency in the Columbia Database Query Optimizer

# 4 Fast Selection and Aggregation on Encoded Data using Operator Specialization

# 5 Shared memory consistency models - A tutorial

